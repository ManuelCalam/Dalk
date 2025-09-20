// supabase/functions/create-subscription/index.ts
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
      return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401 });
    }

    const jwt = authHeader.replace("Bearer ", "");
    const { data: userData, error: userError } = await supabase.auth.getUser(jwt);
    if (userError || !userData.user) {
      return new Response(JSON.stringify({ error: "Invalid user" }), { status: 401 });
    }
    const userId = userData.user.id;

    // Obtener customer_stripe_id
    const { data: profile, error: profileError } = await supabase
      .from("users")
      .select("customer_stripe_id")
      .eq("uuid", userId)
      .single();

    if (profileError || !profile?.customer_stripe_id) {
      return new Response(JSON.stringify({ error: "No Stripe customer found" }), { status: 400 });
    }
    const customerId = profile.customer_stripe_id;

    // Extraer el plan desde el body
    const body = await req.json();
    const { plan } = body; // "monthly" o "yearly"
    const priceId = plan === "monthly"
      ? "price_1S8A1k6aB9DzvCSxERGYzOFS" // reemplaza con tu priceId mensual
      : "price_1S8A1k6aB9DzvCSxkkCJJcQt"; // reemplaza con tu priceId anual

    // Crear suscripción en Stripe
    const stripeRes = await fetch("https://api.stripe.com/v1/subscriptions", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${STRIPE_SECRET_KEY}`,
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: new URLSearchParams({
        customer: customerId,
        "items[0][price]": priceId,
        payment_behavior: "default_incomplete",
        "expand[]": "latest_invoice.payment_intent"
      })
    });

    const subscription = await stripeRes.json();

    if (stripeRes.status !== 200) {
      return new Response(JSON.stringify({ error: subscription.error?.message || "Stripe error" }), { status: 400 });
    }

    const clientSecret = subscription.latest_invoice?.payment_intent?.client_secret;
    if (!clientSecret) {
      // No guardar subscription_id si no hay client_secret
      return new Response(JSON.stringify({ error: "No client_secret returned from Stripe" }), { status: 500 });
    }

    // Guardar subscription.id solo si client_secret existe
    await supabase
      .from("users")
      .update({ subscription_id: subscription.id })
      .eq("uuid", userId);

    return new Response(
      JSON.stringify({ clientSecret }),
      { status: 200, headers: { "Content-Type": "application/json" } }
    );

  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), { status: 500 });
  }
});
