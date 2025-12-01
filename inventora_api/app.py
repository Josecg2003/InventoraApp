from flask import Flask, request, jsonify
from flask_cors import CORS
import joblib, pandas as pd
from pathlib import Path
import json
import os

app = Flask(__name__)
CORS(app)  # Permite CORS desde cualquier origen (puedes restringirlo después)

# --- Cargar modelo y encoders ---
MODEL_DIR = Path(__file__).parent / "model"
try:
    model = joblib.load(MODEL_DIR / "modelo_inventario.pkl")
    encoders = joblib.load(MODEL_DIR / "encoders.pkl")
    with open(MODEL_DIR / "metadata_modelo.json", 'r') as f:
        metadata = json.load(f)
    print("✅ Modelo cargado correctamente")
except Exception as e:
    print(f"❌ Error al cargar archivos: {e}")
    metadata = {"error": "Archivos no encontrados"}

FEATURES = ['Producto', 'Categoría', 'Precio_Soles', 'Oferta', 'Temporada', 'Mes']

def encode(col, val):
    le = encoders[col]
    try:
        return int(le.transform([val])[0])
    except:
        return 0

@app.route("/")
def home():
    return jsonify({
        "status": "ok", 
        "modelo": "Inventario RF",
        "version": "1.0"
    })

@app.route("/health")
def health():
    return jsonify({"status": "healthy"}), 200

@app.route("/productos", methods=["GET"])
def get_productos():
    try:
        if "error" in metadata:
            return jsonify({"error": metadata["error"]}), 500
            
        productos = encoders['Producto'].classes_.tolist()
        categorias = encoders['Categoría'].classes_.tolist()
        temporadas = encoders['Temporada'].classes_.tolist()
            
        return jsonify({
            "productos": productos,
            "categorias": categorias,
            "temporadas": temporadas,
        })
    except Exception as e:
        return jsonify({"error": "Error al obtener listas: " + str(e)}), 500

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
        stock = int(data.get("Stock_Actual", 0))

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
            "Prediccion_Demanda": int(round(y_pred)),
            "Compra_Recomendada": round(compra, 2)
        })
    except Exception as e:
        print(f"Error en predict: {e}")
        return jsonify({"error": str(e)}), 500

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
        print(f"Error en serie: {e}") 
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    # Para desarrollo local
    app.run(host="0.0.0.0", port=5000, debug=True)

"""from flask import Flask, request, jsonify
from flask_cors import CORS
import joblib, pandas as pd
from pathlib import Path
import json

app = Flask(__name__)
CORS(app)

# --- Cargar modelo y encoders ---
MODEL_DIR = Path(__file__).parent / "model"
try:
    model = joblib.load(MODEL_DIR / "modelo_inventario.pkl")
    encoders = joblib.load(MODEL_DIR / "encoders.pkl")
    with open(MODEL_DIR / "metadata_modelo.json", 'r') as f:
        metadata = json.load(f)
except Exception as e:
    print(f"❌ Error al cargar archivos: {e}")
    metadata = {"error": "Archivos no encontrados"}

FEATURES = ['Producto', 'Categoría', 'Precio_Soles', 'Oferta', 'Temporada', 'Mes']

# ==============================================================================
# ✅ CORRECCIÓN: La función 'encode' debe estar AQUÍ (afuera de las rutas)
# ==============================================================================
def encode(col, val):
    le = encoders[col]
    try:
        # Intenta transformar el valor
        return int(le.transform([val])[0])
    except:
        # Si el valor no existe en el encoder (ej: producto nuevo), devuelve 0
        return 0
# ==============================================================================


@app.route("/")
def home():
    return jsonify({"status": "ok", "modelo": "Inventario RF"})

@app.route("/productos", methods=["GET"])
def get_productos():
    try:
        if "error" in metadata:
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
        return jsonify({"error": "Error al obtener listas: " + str(e)}), 500

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
        stock = int(data.get("Stock_Actual", 0))

        # ⛔ AQUÍ NO DEBE ESTAR LA DEFINICIÓN DE ENCODE

        row = {
            'Producto': encode('Producto', producto),   # ✅ Llama a la global
            'Categoría': encode('Categoría', categoria), # ✅ Llama a la global
            'Precio_Soles': precio,
            'Oferta': oferta,
            'Temporada': encode('Temporada', temporada), # ✅ Llama a la global
            'Mes': mes
        }

        X = pd.DataFrame([[row[c] for c in FEATURES]], columns=FEATURES)
        y_pred = float(model.predict(X)[0])
        compra = max(0, y_pred - stock)

        return jsonify({
            "Prediccion_Demanda": int(round(y_pred)),
            "Compra_Recomendada": round(compra, 2)
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500

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
                "Producto": encode("Producto", producto),   # ✅ ¡AHORA SÍ FUNCIONA!
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
        print(f"Error en serie: {e}") 
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True) """