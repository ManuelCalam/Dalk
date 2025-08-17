export const config = {
  auth: true,
  runtime: "edge",
  region: "auto",
};

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import admin from "npm:firebase-admin";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// ============================
// 🔹 Mostrar todas las variables de entorno
// ============================
const envVars = [
  "FIREBASE_SERVICE_ACCOUNT",
  "SERVICE_ROLE_KEY",
  "SUPABASE_ANON_KEY",
  "SUPABASE_DB_URL",
  "SUPABASE_SERVICE_ROLE_KEY",
  "SUPABASE_URL",
  "URL_SUPABASE",
];

for (const name of envVars) {
  const value = Deno.env.get(name);
  console.log(`🔍 ${name}:`, value ?? "❌ No definida");
}

// ============================
// 🔹 Configuración Firebase
// ============================
let firebaseConfig;
try {
  const rawFirebase = Deno.env.get("FIREBASE_SERVICE_ACCOUNT");
  if (!rawFirebase) throw new Error("FIREBASE_SERVICE_ACCOUNT no definida");
  firebaseConfig = JSON.parse(rawFirebase);
} catch (err) {
  console.error("❌ Error al parsear FIREBASE_SERVICE_ACCOUNT:", err);
  throw new Error("Error de configuración Firebase");
}

try {
  admin.initializeApp({ credential: admin.credential.cert(firebaseConfig) });
  console.log("🚀 Firebase Admin inicializado correctamente");
} catch (err) {
  console.error("❌ Error al inicializar Firebase Admin:", err);
  throw new Error("Falló la inicialización de Firebase");
}

// ============================
// 🔹 Configuración Supabase
// ============================
const supabaseUrl = Deno.env.get("SUPABASE_URL");
const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

if (!supabaseUrl || !supabaseKey) {
  console.error("❌ Variables de entorno de Supabase no definidas");
  throw new Error("Error de configuración Supabase");
}

const supabase = createClient(supabaseUrl, supabaseKey);
console.log("🔧 Cliente Supabase creado");

// ============================
// 🔹 Servidor principal
// ============================
Deno.serve(async (req) => {
  const timestamp = new Date().toISOString();
  console.log(`📥 [${timestamp}] Método: ${req.method} | URL: ${req.url}`);

  let rawBody;
  try {
    rawBody = await req.text();
    console.log("📦 Raw body recibido (string):", rawBody);
  } catch (err) {
    console.error("❌ Error leyendo raw body:", err);
    return new Response(JSON.stringify({ error: "No se pudo leer body" }), { status: 400 });
  }

  let body;
  try {
    body = JSON.parse(rawBody);
    console.log("✅ Body parseado como JSON:", body);
  } catch (err) {
    console.error("❌ JSON inválido:", err);
    return new Response(JSON.stringify({ error: "JSON mal formado", raw: rawBody }), {
      status: 400,
    });
  }

  const { userUuid, title, message, eventType } = body;

  if (!userUuid || !title || !message) {
    console.error("⚠️ Payload incompleto:", body);
    return new Response(JSON.stringify({ error: "Datos faltantes", recibido: body }), {
      status: 400,
    });
  }

  try {
    console.log(`🔍 [NOTIFICACIÓN] Buscando token FCM para usuario: ${userUuid}`);
    
    const { data: user, error } = await supabase
      .from("users")
      .select("fcm_token")
      .eq("uuid", userUuid)
      .maybeSingle();

    if (error) {
      console.error("❌ Error al obtener usuario:", error);
      return new Response(JSON.stringify({ error: error.message }), { status: 500 });
    }

    if (!user?.fcm_token) {
      console.warn(`⚠️ Usuario ${userUuid} sin token FCM válido`);
      return new Response(JSON.stringify({ error: "Token FCM no encontrado" }), { status: 404 });
    }

    console.log(`📤 Enviando notificación a ${userUuid}`);

    const fcmResponse = await admin.messaging().send({
      token: user.fcm_token,
      notification: {
        title,
        body: message,
      },
      data: {
        event_type: eventType ?? "walk_status",
        timestamp: timestamp,
      },
    });

    console.log(`✅ Notificación enviada:`, fcmResponse);

    return new Response(JSON.stringify({ 
      success: true, 
      messageId: fcmResponse,
      timestamp: timestamp
    }), { status: 200 });
  } catch (err) {
    console.error("🔥 Error en función:", err);
    return new Response(JSON.stringify({ 
      error: "Error interno", 
      details: String(err),
      timestamp: timestamp 
    }), { status: 500 });
  }
});
