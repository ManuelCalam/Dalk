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

// ✅ FUNCIÓN AUXILIAR: Enviar notificación y push a un usuario
async function sendNotificationToUser(
  userId: string,
  title: string,
  body: string,
  walkId: number,
  eventType: string,
  userType: string
) {
  // Insertar en BD
  const { error: insertError } = await supabase.from('notifications').insert([
    {
      recipient_id: userId,
      title: title,
      body: body,
      event_type: eventType,
      walk_id: walkId,
      is_read: false,
      created_at: new Date().toISOString(),
    },
  ]);

  if (insertError) {
    console.error(`⚠️ Error insertando notificación para ${userId}:`, insertError);
  }

  // Buscar token FCM
  const { data: userData } = await supabase
    .from("users")
    .select("fcm_token")
    .eq("uuid", userId)
    .maybeSingle();

  if (!userData?.fcm_token) {
    return { sent: false, saved: true };
  }

  // Enviar push
  try {
    await admin.messaging().send({
      token: userData.fcm_token,
      notification: { title, body },
      data: {
        event_type: eventType,
        walk_id: walkId.toString(),
        target_user_type: userType,
        target_user_id: userId,
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
            alert: { title, body },
            sound: "default",
          },
        },
      },
    });
    
    return { sent: true, saved: true };
  } catch (fcmError) {
    console.error(`⚠️ Error enviando push a ${userId}:`, fcmError);
    return { sent: false, saved: true };
  }
}

Deno.serve(async (req) => {
  let body;
  try {
    body = await req.json();
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

    // ✅ CASO ESPECIAL: Estado "Cancelado" - Enviar a AMBOS usuarios
    if (new_status === "Cancelado") {
      // Notificación para el PASEADOR
      await sendNotificationToUser(
        walkData.walker_id,
        "Paseo cancelado",
        `El paseo de ${walkData.pet_name} ha sido cancelado`,
        walk_id,
        new_status,
        "walker"
      );

      // Notificación para el DUEÑO
      await sendNotificationToUser(
        walkData.owner_id,
        "Paseo cancelado",
        `El paseo de ${walkData.pet_name} ha sido cancelado`,
        walk_id,
        new_status,
        "owner"
      );

      return new Response(JSON.stringify({ 
        success: true,
        notifications_sent: 2,
        message: "Notificaciones enviadas a ambos usuarios"
      }), { status: 200 });
    }

    // ✅ RESTO DE CASOS (un solo destinatario)
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

      case "En curso":
        targetUserId = walkData.owner_id;
        targetUserType = "owner";
        notificationTitle = "Paseo iniciado";
        notificationBody = `${walkData.walker_name} ha iniciado el paseo de ${walkData.pet_name}`;
        break;

      case "Terminado":
        // ✅ NUEVA NOTIFICACIÓN: Solo al DUEÑO cuando el paseador termina el paseo
        targetUserId = walkData.owner_id;
        targetUserType = "owner";
        notificationTitle = "¡Paseo completado!";
        notificationBody = `${walkData.walker_name} ha terminado el paseo de ${walkData.pet_name}`;
        break;

      default:
        return new Response(JSON.stringify({ error: "Estado no válido" }), { status: 400 });
    }

    const result = await sendNotificationToUser(
      targetUserId,
      notificationTitle,
      notificationBody,
      walk_id,
      new_status,
      targetUserType
    );

    return new Response(JSON.stringify({ 
      success: true,
      notification_sent: result.sent,
      notification_saved: result.saved
    }), { status: 200 });

  } catch (err) {
    console.error("❌ Error general:", err);
    return new Response(JSON.stringify({ 
      error: "Error interno"
    }), { status: 500 });
  }
});