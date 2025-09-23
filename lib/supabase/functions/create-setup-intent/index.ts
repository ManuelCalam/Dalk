// supabase/functions/create-setup-intent/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const STRIPE_SECRET_KEY = Deno.env.get("STRIPE_SECRET_KEY");
const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

if (!STRIPE_SECRET_KEY || !SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
  throw new Error("Missing environment variables");
}

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

serve(async (req) => {
  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { "Content-Type": "application/json" },
      });
    }

    const jwt = authHeader.replace("Bearer ", "");

    // Obtener usuario desde JWT
    const { data: userData, error: userError } = await supabase.auth.getUser(jwt);
    if (userError || !userData.user) {
      return new Response(JSON.stringify({ error: "Invalid user" }), {
        status: 401,
        headers: { "Content-Type": "application/json" },
      });
    }

    const userId = userData.user.id;

    // Obtener customer_stripe_id del usuario
    const { data: profile, error: profileError } = await supabase
      .from("users")
      .select("customer_stripe_id")
      .eq("uuid", userId) 
      .single();

    if (profileError) throw profileError;

    const customerId = profile.customer_stripe_id;
    if (!customerId) {
      return new Response(JSON.stringify({ error: "User has no Stripe customer" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    // Crear SetupIntent en Stripe
    const stripeRes = await fetch("https://api.stripe.com/v1/setup_intents", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${STRIPE_SECRET_KEY}`,
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: new URLSearchParams({
        "payment_method_types[]": "card",
        "customer": customerId,
      }),
    });

    const data = await stripeRes.json();

    if (stripeRes.status !== 200) {
      return new Response(JSON.stringify({ error: data.error?.message || "Stripe error" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    // Devolver client_secret a Flutter
    return new Response(
      JSON.stringify({ client_secret: data.client_secret }),
      { status: 200, headers: { "Content-Type": "application/json" } }
    );

  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
