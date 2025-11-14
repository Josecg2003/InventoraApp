from flask import Flask, request, jsonify
from flask_cors import CORS
import joblib, pandas as pd
from pathlib import Path

app = Flask(__name__)
CORS(app) 
# --- Cargar modelo y encoders ---
MODEL_DIR = Path(__file__).parent / "model" 
model = joblib.load(MODEL_DIR / "modelo_inventario.pkl")
encoders = joblib.load(MODEL_DIR / "encoders.pkl")

FEATURES = ['Producto', 'Categoría', 'Precio_Soles', 'Oferta', 'Temporada', 'Mes']

@app.route("/")
def home():
    return jsonify({"status": "ok", "modelo": "Inventario RF"})

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

        def encode(col, val):
            le = encoders[col]
            try:
                return int(le.transform([val])[0])
            except:
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
            "Prediccion_Demanda": int(round(y_pred, 2)),
            "Compra_Recomendada": round(compra, 2)
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
