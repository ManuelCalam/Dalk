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

  // Espera body: { walk_id, new_status, actor_name?, pet_name?, date? }
  const { walk_id, new_status, actor_name, pet_name, date } = body;
  console.log("[LOG] Payload recibido:", body);

  if (!walk_id || !new_status) {
    console.error("⚠️ Payload incompleto. Se esperaba walk_id y new_status. Recibido:", body);
    return new Response(JSON.stringify({ error: "Datos faltantes", recibido: body }), {
      status: 400,
    });
  }

  try {
    // Buscar datos del paseo y usuarios involucrados
    const { data: walkData, error: walkError } = await supabase
      .from("walks_with_names")
      .select("id, owner_id, walker_id, pet_name, owner_name, walker_name")
      .eq("id", walk_id)
      .maybeSingle();

    if (walkError) {
      console.error("❌ Error al obtener walk:", walkError);
      return new Response(JSON.stringify({ error: walkError.message }), { status: 500 });
    }
    if (!walkData) {
      console.error("❌ Walk no encontrado para id:", walk_id);
      return new Response(JSON.stringify({ error: "Walk no encontrado", walk_id }), { status: 404 });
    }

    console.log("📊 Datos del paseo obtenidos:", walkData);

    // Determinar destinatario, tipo de usuario y mensaje según el status
    let targetUserId: string;
    let targetUserType: string;
    let notificationTitle: string;
    let notificationBody: string;

    switch (new_status) {
      case "Solicitado":
        // Notificar al walker que hay una nueva solicitud
        targetUserId = walkData.walker_id;
        targetUserType = "walker";
        notificationTitle = "¡Nuevo paseo!";
        notificationBody = `${walkData.owner_name} está solicitando un paseo para ${walkData.pet_name}${date ? ` el día ${date}` : ''}`;
        break;

      case "Aceptado":
        // Notificar al owner que su solicitud fue aceptada
        targetUserId = walkData.owner_id;
        targetUserType = "owner";
        notificationTitle = "¡Paseo aceptado!";
        notificationBody = `${walkData.walker_name} ha aceptado el paseo de ${walkData.pet_name}`;
        break;

      case "Rechazado":
        // Notificar al owner que su solicitud fue rechazada
        targetUserId = walkData.owner_id;
        targetUserType = "owner";
        notificationTitle = "Paseo rechazado";
        notificationBody = `${walkData.walker_name} no puede realizar el paseo de ${walkData.pet_name}`;
        break;

      case "Cancelado":
        // Notificar a la otra parte que el paseo fue cancelado
        // Si cancela el owner, notificar al walker. Si cancela el walker, notificar al owner
        targetUserId = walkData.owner_id === actor_name ? walkData.walker_id : walkData.owner_id;
        targetUserType = walkData.owner_id === actor_name ? "walker" : "owner";
        const cancelerName = walkData.owner_id === actor_name ? walkData.owner_name : walkData.walker_name;
        notificationTitle = "Paseo cancelado";
        notificationBody = `${cancelerName} ha cancelado el paseo de ${walkData.pet_name}`;
        break;

      default:
        console.error("❌ Estado no reconocido:", new_status);
        return new Response(JSON.stringify({ error: "Estado no válido", status: new_status }), { status: 400 });
    }

    console.log(`🎯 Destinatario: ${targetUserId} (${targetUserType})`);
    console.log(`📢 Título: ${notificationTitle}`);
    console.log(`📝 Mensaje: ${notificationBody}`);

    // Buscar token FCM del usuario destinatario
    const { data: userData, error: userError } = await supabase
      .from("users")
      .select("uuid, fcm_token")
      .eq("uuid", targetUserId)
      .maybeSingle();

    if (userError) {
      console.error("❌ Error al obtener usuario:", userError);
      return new Response(JSON.stringify({ error: userError.message }), { status: 500 });
    }

    if (!userData) {
      console.error("❌ Usuario destinatario no encontrado:", targetUserId);
      return new Response(JSON.stringify({ error: "Usuario no encontrado", userId: targetUserId }), { status: 404 });
    }

    if (!userData.fcm_token) {
      console.warn(`⚠️ Usuario ${targetUserId} sin token FCM válido, se omite notificación.`);
      return new Response(JSON.stringify({ 
        success: true,
        message: "Usuario sin token FCM",
        walk_id,
        new_status,
        target_user: targetUserId,
        target_user_type: targetUserType,
        timestamp: timestamp
      }), { status: 200 });
    }

    // Enviar notificación
    try {
      console.log(`📤 Enviando notificación a usuario: ${targetUserId} (${targetUserType})`);
      
      const fcmResponse = await admin.messaging().send({
        token: userData.fcm_token,
        notification: {
          title: notificationTitle,
          body: notificationBody,
        },
        data: {
          event_type: new_status,
          walk_id: walk_id.toString(),
          target_user_type: targetUserType,
          target_user_id: targetUserId,
          timestamp: timestamp,
        },
        android: {
          notification: {
            channelId: "dalk_notifications",
            priority: "high",
            defaultSound: true,
            defaultVibrateTimings: true,
            defaultLightSettings: true,
            clickAction: "FLUTTER_NOTIFICATION_CLICK",
          },
        },
        apns: {
          payload: {
            aps: {
              alert: {
                title: notificationTitle,
                body: notificationBody,
              },
              sound: "default",
              badge: 1,
              category: "WALK_NOTIFICATION",
            },
          },
        },
      });
      
      console.log(`✅ Notificación enviada exitosamente:`, fcmResponse);

      return new Response(JSON.stringify({ 
        success: true,
        walk_id,
        new_status,
        target_user: targetUserId,
        target_user_type: targetUserType,
        notification_sent: true,
        fcm_response: fcmResponse,
        timestamp: timestamp
      }), { status: 200 });

    } catch (fcmError) {
      console.error(`🔥 Error enviando notificación:`, fcmError);
      return new Response(JSON.stringify({ 
        success: false,
        error: "Error enviando notificación",
        details: String(fcmError),
        walk_id,
        new_status,
        target_user: targetUserId,
        target_user_type: targetUserType,
        timestamp: timestamp
      }), { status: 500 });
    }
  } catch (err) {
    console.error("🔥 Error en función:", err);
    return new Response(JSON.stringify({ 
      error: "Error interno", 
      details: String(err),
      timestamp: timestamp 
    }), { status: 500 });
  }
});