// supabase/functions/create-stripe-customer/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const STRIPE_SECRET_KEY = Deno.env.get("STRIPE_SECRET_KEY");
const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY");

if (!STRIPE_SECRET_KEY || !SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY || !SUPABASE_ANON_KEY) {
  throw new Error("Missing environment variables");
}

// 1. Cliente público (para validar JWT)
const supabaseAnon = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// 2. Cliente con service_role (para escribir en BD)
const supabaseAdmin = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

serve(async (req) => {
  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: "Unauthorized" }),
        { status: 401, headers: { "Content-Type": "application/json" } }
      );
    }

    const jwt = authHeader.replace("Bearer ", "");

    //1. Obtener usuario autenticado con el cliente público
    const { data: { user }, error: userError } = await supabaseAnon.auth.getUser(jwt);
    if (userError || !user) {
      return new Response(
        JSON.stringify({ error: "Invalid user" }),
        { status: 401, headers: { "Content-Type": "application/json" } }
      );
    }

    const userId = user.id;

    //2. Revisar si ya tiene customer_stripe_id
    const { data: profile, error: profileError } = await supabaseAdmin
      .from("users")
      .select("customer_stripe_id")
      .eq("uuid", userId)
      .single();

    if (profileError) throw profileError;

    if (profile?.customer_stripe_id) {
      return new Response(
        JSON.stringify({ customerId: profile.customer_stripe_id }),
        { status: 200, headers: { "Content-Type": "application/json" } }
      );
    }

    //3. Crear Customer en Stripe
    const stripeRes = await fetch("https://api.stripe.com/v1/customers", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${STRIPE_SECRET_KEY}`,
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: new URLSearchParams({
        email: user.email ?? "",
        "metadata[supabase_user_id]": userId,
      }),
    });

    const stripeData = await stripeRes.json();

    if (stripeRes.status !== 200) {
      return new Response(
        JSON.stringify({ error: stripeData }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    //4. Guardar customer_stripe_id en Supabase (admin client)
    const { error: updateError } = await supabaseAdmin
      .from("users")
      .update({ customer_stripe_id: stripeData.id })
      .eq("uuid", userId);

    if (updateError) throw updateError;

    return new Response(
      JSON.stringify({ customerId: stripeData.id }),
      { status: 200, headers: { "Content-Type": "application/json" } }
    );

  } catch (err) {
    return new Response(
      JSON.stringify({ error: err.message }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
});
