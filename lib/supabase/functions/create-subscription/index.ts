// supabase/functions/create-subscription/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import Stripe from "https://esm.sh/stripe@14.0.0?target=deno";

// =====================
// Configuración
// =====================
const STRIPE_SECRET_KEY = Deno.env.get("STRIPE_SECRET_KEY");
const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

const PRICE_ID_MONTHLY = "price_1S8A1k6aB9DzvCSxERGYzOFS";
const PRICE_ID_YEARLY = "price_1S8A1k6aB9DzvCSxkkCJJcQt";

if (!STRIPE_SECRET_KEY || !SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
  throw new Error("Missing environment variables");
}

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
const stripe = new Stripe(STRIPE_SECRET_KEY, {
  apiVersion: "2023-10-16",
});

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
    const { data: userData, error: userError } = await supabase.auth.getUser(jwt);

    if (userError || !userData.user) {
      return new Response(JSON.stringify({ error: "Invalid user" }), {
        status: 401,
        headers: { "Content-Type": "application/json" },
      });
    }

    const userId = userData.user.id;
    const userEmail = userData.user.email;

    // 1. Obtener el ID del cliente de Stripe, o crearlo si no existe
    const { data: profile, error: profileError } = await supabase
      .from("users")
      .select("customer_stripe_id")
      .eq("uuid", userId)
      .single();

    if (profileError) {
        throw profileError;
    }

    let customerId = profile?.customer_stripe_id;

    if (!customerId) {
        console.log("Stripe customer not found, creating a new one...");
        const customer = await stripe.customers.create({ email: userEmail });
        customerId = customer.id;

        const { error: updateError } = await supabase
            .from("users")
            .update({ customer_stripe_id: customerId })
            .eq("uuid", userId);

        if (updateError) {
            console.error("Error updating user profile with Stripe customer ID:", updateError);
            throw updateError;
        }
        console.log(`New Stripe customer created and linked: ${customerId}`);
    }

    // 2. Obtener el plan del cuerpo de la solicitud
    const { plan } = await req.json();
    const priceId = plan === "monthly" ? PRICE_ID_MONTHLY : PRICE_ID_YEARLY;

    if (!priceId) {
      return new Response(JSON.stringify({ error: "Invalid plan selected" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }
    
    // 3. Crear la suscripción en Stripe
    const subscription = await stripe.subscriptions.create({
      customer: customerId,
      items: [{ price: priceId }],
      expand: ["latest_invoice.payment_intent"],
      payment_behavior: "default_incomplete", 
      payment_settings: {
        save_default_payment_method: "on_subscription",
      }
    });

    const latestInvoice = subscription.latest_invoice as Stripe.Invoice;
    const paymentIntent = latestInvoice.payment_intent as Stripe.PaymentIntent;

    if (!paymentIntent?.client_secret) {
      throw new Error("Stripe did not return a client secret.");
    }
    
    // CAMBIO CLAVE: CREAR LA EPHEMERAL KEY
    const ephemeralKey = await stripe.ephemeralKeys.create(
        { customer: customerId },
        { apiVersion: '2023-10-16' }
    );

    return new Response(
      JSON.stringify({
          client_secret: paymentIntent.client_secret,
          ephemeral_key: ephemeralKey.secret,
          customer_id: customerId
      }),
        { status: 200, headers: { "Content-Type": "application/json" } }
    );

  } catch (err) {
    console.error("Error creating subscription:", err.message);
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});