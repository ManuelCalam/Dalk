export const config = {
  auth: true,
  runtime: "edge",
  region: "auto",
};

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import admin from "npm:firebase-admin";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// ✅ REMOVIDO: Logs de variables de entorno (solo en desarrollo)

// Configuración Firebase
let firebaseConfig;
try {
  const rawFirebase = Deno.env.get("FIREBASE_SERVICE_ACCOUNT");
  if (!rawFirebase) throw new Error("FIREBASE_SERVICE_ACCOUNT no definida");
  firebaseConfig = JSON.parse(rawFirebase);
} catch (err) {
  console.error("❌ Error Firebase config:", err);
  throw new Error("Error de configuración Firebase");
}

try {
  admin.initializeApp({ credential: admin.credential.cert(firebaseConfig) });
} catch (err) {
  console.error("❌ Error inicializando Firebase:", err);
  throw new Error("Falló la inicialización de Firebase");
}

// Configuración Supabase
const supabaseUrl = Deno.env.get("SUPABASE_URL");
const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

if (!supabaseUrl || !supabaseKey) {
  throw new Error("Error de configuración Supabase");
}

const supabase = createClient(supabaseUrl, supabaseKey);

Deno.serve(async (req) => {
  // ✅ REMOVIDO: Logs innecesarios de timestamp y raw body
  
  let body;
  try {
    body = await req.json(); // ✅ OPTIMIZADO: Usar .json() directamente
  } catch (err) {
    return new Response(JSON.stringify({ error: "JSON mal formado" }), { status: 400 });
  }

  const { walk_id, new_status } = body;

  if (!walk_id || !new_status) {
    return new Response(JSON.stringify({ error: "Datos faltantes" }), { status: 400 });
  }

  try {
    // Buscar datos del paseo
    const { data: walkData, error: walkError } = await supabase
      .from("walks_with_names")
      .select("id, owner_id, walker_id, pet_name, owner_name, walker_name")
      .eq("id", walk_id)
      .maybeSingle();

    if (walkError || !walkData) {
      return new Response(JSON.stringify({ error: "Walk no encontrado" }), { status: 404 });
    }

    // Determinar destinatario y mensaje
    let targetUserId: string;
    let targetUserType: string;
    let notificationTitle: string;
    let notificationBody: string;

    switch (new_status) {
      case "Solicitado":
        targetUserId = walkData.walker_id;
        targetUserType = "walker";
        notificationTitle = "¡Nuevo paseo!";
        notificationBody = `${walkData.owner_name} está solicitando un paseo para ${walkData.pet_name}`;
        break;

      case "Aceptado":
        targetUserId = walkData.owner_id;
        targetUserType = "owner";
        notificationTitle = "¡Paseo aceptado!";
        notificationBody = `${walkData.walker_name} ha aceptado el paseo de ${walkData.pet_name}`;
        break;

      case "Rechazado":
        targetUserId = walkData.owner_id;
        targetUserType = "owner";
        notificationTitle = "Paseo rechazado";
        notificationBody = `${walkData.walker_name} no puede realizar el paseo de ${walkData.pet_name}`;
        break;

      case "Cancelado":
        // ✅ SIMPLIFICADO: Lógica de cancelación más directa
        const isOwnerCanceling = body.actor_name === walkData.owner_name;
        targetUserId = isOwnerCanceling ? walkData.walker_id : walkData.owner_id;
        targetUserType = isOwnerCanceling ? "walker" : "owner";
        const cancelerName = isOwnerCanceling ? walkData.owner_name : walkData.walker_name;
        notificationTitle = "Paseo cancelado";
        notificationBody = `${cancelerName} ha cancelado el paseo de ${walkData.pet_name}`;
        break;

      default:
        return new Response(JSON.stringify({ error: "Estado no válido" }), { status: 400 });
    }

    // Insertar notificación en BD
    const { error: insertError } = await supabase.from('notifications').insert([
      {
        recipient_id: targetUserId,
        title: notificationTitle,
        body: notificationBody,
        event_type: new_status,
        walk_id: walk_id,
        is_read: false,
        created_at: new Date().toISOString(),
      },
    ]);

    if (insertError) {
      console.error('⚠️ Error insertando notificación:', insertError);
    }

    // Buscar token FCM
    const { data: userData } = await supabase
      .from("users")
      .select("fcm_token")
      .eq("uuid", targetUserId)
      .maybeSingle();

    if (!userData?.fcm_token) {
      return new Response(JSON.stringify({ 
        success: true,
        message: "Notificación guardada, usuario sin token FCM"
      }), { status: 200 });
    }

    // Enviar notificación push
    try {
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
          timestamp: new Date().toISOString(),
        },
        android: {
          notification: {
            channelId: "dalk_notifications",
            priority: "high",
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
            },
          },
        },
      });
      
      return new Response(JSON.stringify({ 
        success: true,
        notification_sent: true,
        notification_saved: true
      }), { status: 200 });

    } catch (fcmError) {
      return new Response(JSON.stringify({ 
        success: true,
        notification_saved: true,
        notification_sent: false,
        error: "Error enviando push"
      }), { status: 200 });
    }
  } catch (err) {
    return new Response(JSON.stringify({ 
      error: "Error interno"
    }), { status: 500 });
  }
});