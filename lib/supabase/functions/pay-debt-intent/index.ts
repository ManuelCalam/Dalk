import Stripe from "https://esm.sh/stripe@14.11.0?deno";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// Configuración de Stripe
const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!, {
  apiVersion: "2023-10-16",
});

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!; 

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY, {
  auth: { persistSession: false },
});

const CURRENCY = "mxn";

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({ error: "Método no permitido. Solo se acepta POST." }),
      { status: 405, headers: { "Content-Type": "application/json" } },
    );
  }

  const authHeader = req.headers.get("Authorization");
  if (!authHeader?.startsWith("Bearer ")) {
    return new Response(
      JSON.stringify({ error: "Falta el token de autenticación (JWT)." }),
      { status: 401, headers: { "Content-Type": "application/json" } },
    );
  }
  
  const jwt = authHeader.replace("Bearer ", "");
  const anonSupabase = createClient(SUPABASE_URL, Deno.env.get("SUPABASE_ANON_KEY")!);
  const { data: userData, error: userError } = await anonSupabase.auth.getUser(jwt);
  
  if (userError || !userData.user) {
    return new Response(
      JSON.stringify({ error: "Usuario no válido o sesión expirada." }),
      { status: 401, headers: { "Content-Type": "application/json" } },
    );
  }
  

  try {
    const body = await req.json();
    // *** AHORA ESPERAMOS user_id Y debt_amount DEL BODY ***
    const { debt_amount, user_id } = body; 

    if (typeof debt_amount !== "number" || debt_amount <= 0 || !user_id) {
      return new Response(
        JSON.stringify({ error: "Faltan parámetros requeridos (debt_amount o user_id) o son inválidos." }),
        { status: 400, headers: { "Content-Type": "application/json" } },
      );
    }

    // 2. OBTENER CUSTOMER ID Y WALKER ID del usuario
    const { data: userDataLookup, error: lookupError } = await supabase
      .from("users")
      .select("customer_stripe_id, uuid") 
      .eq("uuid", user_id)
      .single();

    if (lookupError || !userDataLookup?.customer_stripe_id || !userDataLookup?.walker_id) {
      console.error("Error al obtener IDs:", lookupError);
      return new Response(
        JSON.stringify({
          error: "No se encontró el Stripe Customer ID o Walker ID para el usuario.",
        }),
        { status: 404, headers: { "Content-Type": "application/json" } },
      );
    }

    const customerStripeId = userDataLookup.customer_stripe_id;
    const walkerId = userDataLookup.walker_id; 
    const amountCents = Math.round(debt_amount * 100);

    const ephemeralKey = await stripe.ephemeralKeys.create(
      { customer: customerStripeId },
      { apiVersion: "2023-10-16" },
    );

    const paymentIntent = await stripe.paymentIntents.create({
      amount: amountCents,
      currency: CURRENCY,
      customer: customerStripeId,
      automatic_payment_methods: { enabled: true },
      setup_future_usage: "off_session", 
      description: `Pago de deuda por ${debt_amount} ${CURRENCY}`,
      metadata: {
        payer_uuid: user_id,
        type: "debt_payment",
        walker_id_to_pay: walkerId, 
      },
    });

    return new Response(
      JSON.stringify({
        client_secret: paymentIntent.client_secret,
        ephemeralKey: ephemeralKey.secret,
      }),
      { status: 200, headers: { "Content-Type": "application/json" } },
    );
  } catch (error) {
    console.error("Error en pay-debt-intent:", error);
    return new Response(
      JSON.stringify({ error: "Error interno al crear el PaymentIntent de deuda." }),
      { status: 500, headers: { "Content-Type": "application/json" } },
    );
  }
});