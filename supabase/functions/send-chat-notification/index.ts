export const config = {
  auth: true,
  runtime: "edge",
  region: "auto",
};

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import admin from "npm:firebase-admin";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// Configuración Firebase
let firebaseConfig;
try {
  const rawFirebase = Deno.env.get("FIREBASE_SERVICE_ACCOUNT");
  if (!rawFirebase) throw new Error("FIREBASE_SERVICE_ACCOUNT no definida");
  firebaseConfig = JSON.parse(rawFirebase);
} catch (err) {
  console.error("Error Firebase config:", err);
  throw new Error("Error de configuración Firebase");
}

try {
  admin.initializeApp({ credential: admin.credential.cert(firebaseConfig) });
} catch (err) {
  console.error("Error inicializando Firebase:", err);
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
  let body;
  try {
    body = await req.json();
  } catch (err) {
    return new Response(JSON.stringify({ error: "JSON mal formado" }), { status: 400 });
  }

  const { sender_id, receiver_id, message, owner_id, walker_id } = body;

  if (!sender_id || !receiver_id || !message || !owner_id || !walker_id) {
    return new Response(JSON.stringify({ error: "Datos faltantes" }), { status: 400 });
  }

  try {
    // Lógica de mantenimiento: eliminar notificaciones de chat antiguas (más de 14 días)
    const fourteenDaysAgo = new Date();
    fourteenDaysAgo.setDate(fourteenDaysAgo.getDate() - 14);
    
    try {
      const { error: cleanupError } = await supabase
        .from('notifications')
        .delete()
        .eq('event_type', 'chat_message')
        .lt('created_at', fourteenDaysAgo.toISOString());
      
      if (cleanupError) {
        console.error('Error en limpieza de notificaciones:', cleanupError);
        // Continuar con el proceso aunque falle la limpieza
      }
    } catch (maintenanceError) {
      console.error('Error en mantenimiento:', maintenanceError);
      // Continuar con el proceso principal aunque falle el mantenimiento
    }

    // Buscar información del remitente
    const { data: senderData, error: senderError } = await supabase
      .from("users")
      .select("name")
      .eq("uuid", sender_id)
      .maybeSingle();

    if (senderError || !senderData) {
      return new Response(JSON.stringify({ error: "Remitente no encontrado" }), { status: 404 });
    }

    // Determinar destinatario y tipo de usuario
    let targetUserType: string;
    if (receiver_id === owner_id) {
      targetUserType = "owner";
    } else if (receiver_id === walker_id) {
      targetUserType = "walker";
    } else {
      return new Response(JSON.stringify({ error: "Receptor no válido" }), { status: 400 });
    }

    const notificationTitle = "Nuevo mensaje";
    const notificationBody = `${senderData.name}: ${message.length > 50 ? message.substring(0, 50) + '...' : message}`;

    // Insertar notificación en BD
    const { error: insertError } = await supabase.from('notifications').insert([
      {
        recipient_id: receiver_id,
        title: notificationTitle,
        body: notificationBody,
        event_type: "chat_message",
        walk_id: null,
        is_read: false,
        created_at: new Date().toISOString(),
      },
    ]);

    if (insertError) {
      console.error('Error insertando notificación:', insertError);
    }

    // Buscar token FCM
    const { data: userData } = await supabase
      .from("users")
      .select("fcm_token")
      .eq("uuid", receiver_id)
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
          event_type: "chat_message",
          target_user_type: targetUserType,
          target_user_id: receiver_id,
          sender_id: sender_id,
          owner_id: owner_id,
          walker_id: walker_id,
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