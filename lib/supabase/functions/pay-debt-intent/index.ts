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
  console.log("[START] pay-debt-intent invoked.");
  
  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({ error: "Método no permitido. Solo se acepta POST." }),
      { status: 405, headers: { "Content-Type": "application/json" } },
    );
  }

  // 1. --- VERIFICACIÓN DE SEGURIDAD (JWT) ---
  const authHeader = req.headers.get("Authorization");
  if (!authHeader?.startsWith("Bearer ")) {
    console.error("[AUTH ERROR] Falta el token.");
    return new Response(
      JSON.stringify({ error: "Falta el token de autenticación (JWT)." }),
      { status: 401, headers: { "Content-Type": "application/json" } },
    );
  }
  
  const jwt = authHeader.replace("Bearer ", "");
  const anonSupabase = createClient(SUPABASE_URL, Deno.env.get("SUPABASE_ANON_KEY")!);
  const { data: userData, error: userError } = await anonSupabase.auth.getUser(jwt);
  
  if (userError || !userData.user) {
    console.error("[AUTH ERROR] Usuario no válido o sesión expirada.");
    return new Response(
      JSON.stringify({ error: "Usuario no válido o sesión expirada." }),
      { status: 401, headers: { "Content-Type": "application/json" } },
    );
  }
  
  const payerUserId = userData.user.id; // El usuario que paga (ID de Auth)
  console.log(`[DEBUG EF] Payer User ID (from JWT): ${payerUserId}`);
  // ------------------------------------------

  try {
    const body = await req.json();
    // ** Requerimos el monto y el ID del Walker al que se destina el pago **
    const { debt_amount, debt_walker_id } = body; 

    console.log(`[DEBUG EF] Body recibido: amount=${debt_amount}, walker_id=${debt_walker_id}`);

    if (typeof debt_amount !== "number" || debt_amount <= 0 || !debt_walker_id) {
      console.error("[ERROR EF] Parámetros faltantes: debt_amount o debt_walker_id.");
      return new Response(
        JSON.stringify({ 
          error: "Faltan parámetros requeridos (debt_amount o debt_walker_id) o son inválidos." 
        }),
        { status: 400, headers: { "Content-Type": "application/json" } },
      );
    }

    // 2. OBTENER CUSTOMER ID del Payer (usando el ID del JWT)
    const { data: userDataLookup, error: lookupError } = await supabase
      .from("users")
      .select("customer_stripe_id") 
      .eq("uuid", payerUserId) // Usamos el ID del JWT
      .single();

    // ** VALIDACIÓN CORREGIDA: Solo chequeamos si se encontró el customer_stripe_id **
    if (lookupError || !userDataLookup?.customer_stripe_id) {
      console.error("[ERROR EF] Lookup falló para Stripe ID:", lookupError);
      return new Response(
        JSON.stringify({
          error: "No se encontró el Stripe Customer ID para el usuario pagador.", // Mensaje más específico
        }),
        { status: 404, headers: { "Content-Type": "application/json" } },
      );
    }
    // ------------------------------------------

    const customerStripeId = userDataLookup.customer_stripe_id;
    const amountCents = Math.round(debt_amount * 100);

    console.log(`[DEBUG EF] Customer Stripe ID: ${customerStripeId}`);

    // 3. Crear ephemeral key
    const ephemeralKey = await stripe.ephemeralKeys.create(
      { customer: customerStripeId },
      { apiVersion: "2023-10-16" },
    );

    // 4. Crear Payment Intent
    const paymentIntent = await stripe.paymentIntents.create({
      amount: amountCents,
      currency: CURRENCY,
      customer: customerStripeId,
      automatic_payment_methods: { enabled: true },
      setup_future_usage: "off_session", 
      description: `Pago de deuda por ${debt_amount} ${CURRENCY}`,
      metadata: {
        payer_uuid: payerUserId,
        type: "debt_payment",
        // Usamos el ID del walker que se recibió en el body
        walker_id_to_pay: debt_walker_id, 
      },
    });

    console.log("[SUCCESS EF] Payment Intent creado.");

    return new Response(
      JSON.stringify({
        client_secret: paymentIntent.client_secret,
        ephemeralKey: ephemeralKey.secret,
      }),
      { status: 200, headers: { "Content-Type": "application/json" } },
    );
  } catch (error) {
    console.error("[ERROR EF] Error interno:", error);
    return new Response(
      JSON.stringify({ error: "Error interno al crear el PaymentIntent de deuda." }),
      { status: 500, headers: { "Content-Type": "application/json" } },
    );
  }
});