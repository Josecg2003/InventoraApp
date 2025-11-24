from flask import Flask, request, jsonify
from flask_cors import CORS
import joblib, pandas as pd
from pathlib import Path
import json # Necesario para metadata

app = Flask(__name__)
CORS(app) 
# --- Cargar modelo y encoders ---
MODEL_DIR = Path(__file__).parent / "model" 
# Manejo de errores si los archivos no existen
try:
    model = joblib.load(MODEL_DIR / "modelo_inventario.pkl")
    encoders = joblib.load(MODEL_DIR / "encoders.pkl")
    # Cargar Metadata (si existe)
    with open(MODEL_DIR / "metadata_modelo.json", 'r') as f:
        metadata = json.load(f)
except Exception as e:
    print(f"❌ Error al cargar archivos del modelo/metadata: {e}")
    metadata = {"error": "Archivos del modelo o metadata no encontrados."}


FEATURES = ['Producto', 'Categoría', 'Precio_Soles', 'Oferta', 'Temporada', 'Mes']

@app.route("/")
def home():
    return jsonify({"status": "ok", "modelo": "Inventario RF"})

# 🎯 NUEVO ENDPOINT PARA OBTENER LISTAS DE PRODUCTOS/CATEGORÍAS
@app.route("/productos", methods=["GET"])
def get_productos():
    """Devuelve la lista de productos conocidos por el encoder para el formulario de Flutter."""
    try:
        if "error" in metadata:
             # Si no hay metadata, intenta cargar directamente desde los encoders
             productos = encoders['Producto'].classes_.tolist()
             categorias = encoders['Categoría'].classes_.tolist()
             temporadas = encoders['Temporada'].classes_.tolist()
        else:
            productos = encoders['Producto'].classes_.tolist()
            categorias = encoders['Categoría'].classes_.tolist()
            temporadas = encoders['Temporada'].classes_.tolist()
            
        return jsonify({
            "productos": productos,
            "categorias": categorias,
            "temporadas": temporadas,
        })
    except Exception as e:
        return jsonify({"error": "No se pudo obtener la lista de parámetros: " + str(e)}), 500

@app.route("/predict", methods=["POST"])
def predict():
    data = request.get_json()
    try:
        producto = data.get("Producto")
        categoria = data.get("Categoría")
        precio = float(data.get("Precio_Soles", 0))
        oferta = int(data.get("Oferta", 0))
        temporada = data.get("Temporada")
        mes = int(data.get("Mes", 1))
        # 🎯 Usamos INT para el Stock, como lo envía Flutter
        stock = int(data.get("Stock_Actual", 0)) 

        def encode(col, val):
            le = encoders[col]
            try:
                return int(le.transform([val])[0])
            except:
                # Si se introduce un valor no visto en el entrenamiento, devuelve 0
                return 0

        row = {
            'Producto': encode('Producto', producto),
            'Categoría': encode('Categoría', categoria),
            'Precio_Soles': precio,
            'Oferta': oferta,
            'Temporada': encode('Temporada', temporada),
            'Mes': mes
        }

        X = pd.DataFrame([[row[c] for c in FEATURES]], columns=FEATURES)
        y_pred = float(model.predict(X)[0])
        compra = max(0, y_pred - stock)

        return jsonify({
            # 🎯 Devolvemos la predicción como INT redondeada
            "Prediccion_Demanda": int(round(y_pred)), 
            # 🎯 Devolvemos la compra como FLOAT para mantener decimales
            "Compra_Recomendada": round(compra, 2) 
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500
  # ======================================================
# 3️⃣ ENDPOINT: Proyección de 30 días para gráfica
# ======================================================
@app.route("/predict/serie", methods=["POST"])
def predict_serie():
    try:
        data = request.get_json()

        producto = data["Producto"]
        categoria = data["Categoría"]
        precio = float(data["Precio_Soles"])
        oferta = int(data["Oferta"])
        temporada = data["Temporada"]

        serie = []

        for i in range(30):
            fecha = pd.Timestamp.now() + pd.Timedelta(days=i)
            mes_future = fecha.month

            row = {
                "Producto": encode("Producto", producto),
                "Categoría": encode("Categoría", categoria),
                "Precio_Soles": precio,
                "Oferta": oferta,
                "Temporada": encode("Temporada", temporada),
                "Mes": mes_future
            }

            X = pd.DataFrame([[row[c] for c in FEATURES]], columns=FEATURES)
            pred = float(model.predict(X)[0])

            serie.append({
                "fecha": str(fecha.date()),
                "prediccion": round(pred, 2)
            })

        return jsonify(serie)

    except Exception as e:
        return jsonify({"error": str(e)}), 500


# ======================================================
# Opcional: Histórico basado en los datos entrenados
# ======================================================
@app.route("/historico", methods=["POST"])
def historico():
    try:
        data = request.get_json()
        producto = data["Producto"]

        # Cargar dataset original (si lo deseas)
        file = MODEL_DIR / "dataset_original.csv"

        if not file.exists():
            return jsonify({"error": "Dataset no disponible"}), 404

        df = pd.read_csv(file)
        df = df[df["Producto"] == producto]

        salida = df[["Fecha", "Cantidad_Vendida"]].to_dict(orient="records")

        return jsonify(salida)

    except Exception as e:
        return jsonify({"error": str(e)}), 500


# ======================================================
# RUN
# =====================================================  
    

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)