/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// const {setGlobalOptions} = require("firebase-functions");
// const {onRequest} = require("firebase-functions/https");
// const logger = require("firebase-functions/logger");

// // For cost control, you can set the maximum number of containers that can be
// // running at the same time. This helps mitigate the impact of unexpected
// // traffic spikes by instead downgrading performance. This limit is a
// // per-function limit. You can override the limit for each function using the
// // `maxInstances` option in the function's options, e.g.
// // `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// // NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// // functions should each use functions.runWith({ maxInstances: 10 }) instead.
// // In the v1 API, each function can only serve one request per container, so
// // this will be the maximum concurrent request count.
// setGlobalOptions({ maxInstances: 10 });

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
const functions = require("firebase-functions");
// const fetch = require("node-fetch");
const express = require("express");
const cors = require("cors");

const app = express();

// Habilitar CORS si lo vas a usar desde web
app.use(cors({origin: true}));

// Middleware para parsear JSON
app.use(express.json());

app.post("/", async (req, res) => {
  try {
    console.log("Body recibido en Firebase:", req.body);

    const iaUrl = "https://servidor-ia-recomendador.onrender.com/recomendar";
    console.log("Enviando petición a:", iaUrl);

    const response = await fetch(iaUrl, {
      method: "POST",
      headers: {"Content-Type": "application/json"},
      body: JSON.stringify(req.body),
    });

    console.log("Código de respuesta de la IA:", response.status);

    const data = await response.json().catch((err) => {
      console.error("Error parseando JSON:", err);
      throw new Error("Respuesta inválida de la IA");
    });

    console.log("Respuesta de la IA:", data);

    res.status(200).json(data);
  } catch (err) {
    console.error("Error en recommendWalker:", err.message, err.stack);
    res.status(500).json({error: "Error en la función"});
  }
});


exports.recommendWalker = functions.https.onRequest(app);
