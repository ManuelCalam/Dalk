import Stripe from "https://esm.sh/stripe@14.11.0?deno";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// Configuración de Stripe
const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!, {
  apiVersion: "2023-10-16",
});

// Configuración de Supabase
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!; 

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY, {
  auth: { persistSession: false },
});

// Moneda base
const CURRENCY = "mxn";
const APP_FEE_PERCENTAGE = 0.05; // 5%

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({ error: "Método no permitido. Solo se acepta POST." }),
      { status: 405, headers: { "Content-Type": "application/json" } },
    );
  }

  // Verificar JWT del usuario
  const authHeader = req.headers.get("Authorization");
  if (!authHeader?.startsWith("Bearer ")) {
    return new Response(
      JSON.stringify({ error: "Falta el token de autenticación (JWT)." }),
      { status: 401, headers: { "Content-Type": "application/json" } },
    );
  }

  const jwt = authHeader.replace("Bearer ", "");
  const { data: userData, error: userError } = await supabase.auth.getUser(jwt);
  if (userError || !userData.user) {
    return new Response(
      JSON.stringify({ error: "Usuario no válido o sesión expirada." }),
      { status: 401, headers: { "Content-Type": "application/json" } },
    );
  }

  

  try {
    const body = await req.json();
    const { walk_id, walker_id, customer_stripe_id, fee } = body;

    if (!walk_id || !walker_id || !customer_stripe_id || typeof fee !== "number") {
      return new Response(
        JSON.stringify({ error: "Faltan parámetros requeridos." }),
        { status: 400, headers: { "Content-Type": "application/json" } },
      );
    }

    console.log({
  walk_id,
  walker_id,
  customer_stripe_id,
  fee,
});


    // Obtener el connected_account_id del paseador
    const { data: paymentData, error: paymentError } = await supabase
      .from("walker_payments")
      .select("account_stripe_id")
      .eq("walker_uuid", walker_id)
      .single();

    if (paymentError || !paymentData?.account_stripe_id) {
      console.error("Error al obtener cuenta del paseador:", paymentError);
      return new Response(
        JSON.stringify({
          error: "No se encontró la cuenta conectada del paseador.",
        }),
        { status: 404, headers: { "Content-Type": "application/json" } },
      );
    }

    const connectedAccountId = paymentData.account_stripe_id;
    const amountCents = Math.round(fee * 100);
    const appFeeCents = Math.round(amountCents * APP_FEE_PERCENTAGE);

    // Crear ephemeral key para el cliente
    const ephemeralKey = await stripe.ephemeralKeys.create(
      { customer: customer_stripe_id },
      { apiVersion: "2023-10-16" },
    );

    // Crear PaymentIntent
    const paymentIntent = await stripe.paymentIntents.create({
      amount: amountCents,
      currency: CURRENCY,
      customer: customer_stripe_id,
      automatic_payment_methods: { enabled: true },
      application_fee_amount: appFeeCents,
      transfer_data: {
        destination: connectedAccountId,
      },
      metadata: {
        walk_id,
        walker_id,
        payer_user_id: userData.user.id,
        type: "dog_walk_payment",
      },
    });

    // Devolver client_secret y ephemeralKey al cliente
    return new Response(
      JSON.stringify({
        client_secret: paymentIntent.client_secret,
        ephemeralKey: ephemeralKey.secret,
      }),
      { status: 200, headers: { "Content-Type": "application/json" } },
    );
  } catch (error) {
    console.error("Error en pay-walk-intent:", error);
    return new Response(
      JSON.stringify({ error: "Error interno al crear el PaymentIntent." }),
      { status: 500, headers: { "Content-Type": "application/json" } },
    );
  }
});
