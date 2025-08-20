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

  // Espera body: { walk_id, new_status }
  const { walk_id, new_status } = body;
  console.log("[LOG] Payload recibido:", body);

  if (!walk_id || !new_status) {
    console.error("⚠️ Payload incompleto. Se esperaba walk_id y new_status. Recibido:", body);
    return new Response(JSON.stringify({ error: "Datos faltantes", recibido: body }), {
      status: 400,
    });
  }

  try {
    // Buscar datos del paseo y usuarios involucrados
    const { data: walk, error: walkError } = await supabase
      .from("walks")
      .select("id, owner_id, walker_id")
      .eq("id", walk_id)
      .maybeSingle();

    if (walkError) {
      console.error("❌ Error al obtener walk:", walkError);
      return new Response(JSON.stringify({ error: walkError.message }), { status: 500 });
    }
    if (!walk) {
      console.error("❌ Walk no encontrado para id:", walk_id);
      return new Response(JSON.stringify({ error: "Walk no encontrado", walk_id }), { status: 404 });
    }

    // Buscar tokens FCM de owner y walker
    const { data: users, error: usersError } = await supabase
      .from("users")
      .select("uuid, fcm_token")
      .in("uuid", [walk.owner_id, walk.walker_id]);

    if (usersError) {
      console.error("❌ Error al obtener usuarios:", usersError);
      return new Response(JSON.stringify({ error: usersError.message }), { status: 500 });
    }

    // Mensaje de notificación
    const title = "Actualización de paseo";
    const bodyMsg = `El estado del paseo ha cambiado a: ${new_status}`;

    // Enviar notificación a ambos usuarios
    for (const user of users) {
      if (!user.fcm_token) {
        console.warn(`⚠️ Usuario ${user.uuid} sin token FCM válido, se omite notificación.`);
        continue;
      }
      try {
        console.log(`📤 Enviando notificación a usuario: ${user.uuid}`);
        const fcmResponse = await admin.messaging().send({
          token: user.fcm_token,
          notification: {
            title,
            body: bodyMsg,
          },
          data: {
            event_type: new_status,
            timestamp: timestamp,
          },
        });
        console.log(`✅ Notificación enviada a ${user.uuid}:`, fcmResponse);
      } catch (err) {
        console.error(`🔥 Error enviando notificación a ${user.uuid}:`, err);
      }
    }

    return new Response(JSON.stringify({ 
      success: true,
      walk_id,
      new_status,
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
