import os
from flask import Flask, request, jsonify
import pandas as pd
from joblib import load

app = Flask(__name__)

# Cargar modelo y encoders
model = load(os.path.join(os.path.dirname(__file__), "modelo/modelo_recomendador.joblib"))
encoders = load(os.path.join(os.path.dirname(__file__), "modelo/encoders.joblib"))

@app.route("/", methods=["POST"])
def recomendar():
    try:
        datos = request.get_json()
        df = pd.DataFrame([datos])

        for col in df.columns:
            if col in encoders:
                encoder = encoders[col]
                for val in df[col].unique():
                    if val not in encoder.classes_:
                        return jsonify({"error": f"Valor desconocido en '{col}': '{val}'"}), 400
                df[col] = encoder.transform(df[col])

        pred = model.predict(df)[0]
        recomendado = encoders["recommended_paseador_id"].inverse_transform([pred])[0]
        return jsonify({"recommended_paseador_id": recomendado})
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    
from functions_framework import create_app
app = create_app(target=app)