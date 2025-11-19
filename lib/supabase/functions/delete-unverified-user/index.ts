import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

console.log("🔔 delete-unverified-user iniciado");

Deno.serve(async (req: Request) => {
  try {
    // 1️⃣ VALIDAR MÉTODO
    if (req.method !== "POST") {
      return new Response(
        JSON.stringify({ ok: false, error: "Método no permitido" }),
        {
          status: 405,
          headers: { "Content-Type": "application/json" },
        }
      );
    }

    // 2️⃣ EXTRAER userId DEL BODY
    const { userId } = await req.json();

    if (!userId) {
      console.error("❌ No se proporcionó userId");
      return new Response(
        JSON.stringify({ ok: false, error: "userId es requerido" }),
        {
          status: 400,
          headers: { "Content-Type": "application/json" },
        }
      );
    }

    console.log(`🔍 Eliminando usuario: ${userId}`);

    // 3️⃣ CREAR CLIENTE CON SERVICE ROLE
    const supabaseAdmin = createClient(SUPABASE_URL, SERVICE_ROLE_KEY, {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
      },
    });

    // 4️⃣ ELIMINAR DE TABLA identity_verifications (PRIMERO)
    console.log("🗑️ Eliminando de identity_verifications...");
    const { error: verificationError } = await supabaseAdmin
      .from("identity_verifications")
      .delete()
      .or(`user_uuid.eq.${userId},user_id.eq.${userId}`);

    if (verificationError) {
      console.error("⚠️ Error eliminando identity_verifications:", verificationError);
      // No detenemos el proceso, continuamos
    } else {
      console.log("✅ identity_verifications eliminado");
    }

    // 5️⃣ ELIMINAR DE TABLA addresses (si existe)
    console.log("🗑️ Eliminando de addresses...");
    const { error: addressError } = await supabaseAdmin
      .from("addresses")
      .delete()
      .eq("uuid", userId);

    if (addressError) {
      console.error("⚠️ Error eliminando addresses:", addressError);
    } else {
      console.log("✅ addresses eliminado");
    }

    // 6️⃣ ELIMINAR DE TABLA users
    console.log("🗑️ Eliminando de users...");
    const { error: usersError } = await supabaseAdmin
      .from("users")
      .delete()
      .eq("uuid", userId);

    if (usersError) {
      console.error("❌ Error eliminando users:", usersError);
      return new Response(
        JSON.stringify({
          ok: false,
          error: "Error eliminando de tabla users",
          details: usersError,
        }),
        {
          status: 500,
          headers: { "Content-Type": "application/json" },
        }
      );
    }

    console.log("✅ users eliminado");

    // 7️⃣ ELIMINAR DE AUTH (ÚLTIMO)
    console.log("🗑️ Eliminando de auth.users...");
    const { error: authError } = await supabaseAdmin.auth.admin.deleteUser(
      userId
    );

    if (authError) {
      console.error("❌ Error eliminando auth.users:", authError);
      return new Response(
        JSON.stringify({
          ok: false,
          error: "Error eliminando usuario de Auth",
          details: authError,
        }),
        {
          status: 500,
          headers: { "Content-Type": "application/json" },
        }
      );
    }

    console.log("✅ auth.users eliminado");
    console.log(`✅ Usuario ${userId} eliminado completamente`);

    // 8️⃣ RESPUESTA EXITOSA
    return new Response(
      JSON.stringify({
        ok: true,
        message: "Usuario eliminado completamente",
        userId,
      }),
      {
        status: 200,
        headers: { "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    console.error("💥 Error inesperado:", error);
    return new Response(
      JSON.stringify({
        ok: false,
        error: "Error interno del servidor",
        details: error.message,
      }),
      {
        status: 500,
        headers: { "Content-Type": "application/json" },
      }
    );
  }
});