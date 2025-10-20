import Stripe from 'https://esm.sh/stripe@14.11.0?deno';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const TRACKER_PRICE_ID = 'price_1SJomM6aB9DzvCSxAupT1NbC';
const CURRENCY = 'mxn'; 

// Inicialización de Stripe
const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY')!, {
 apiVersion: '2023-10-16',
});

// Inicialización de Supabase para verificar el JWT del usuario
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SUPABASE_ANON_KEY = Deno.env.get('SUPABASE_ANON_KEY')!;

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
 auth: { 
    persistSession: false,
  },
});

Deno.serve(async (req) => {
// --- Lógica de Manejo de Solicitudes y Autenticación ---
// 1. Verificar el método de la solicitud (debe ser POST para pagos)
if (req.method !== 'POST') {
 return new Response(
 JSON.stringify({ error: 'Método no permitido. Solo se acepta POST.' }), 
 { status: 405, headers: { 'Content-Type': 'application/json' } }
 );
}

  // 2. Verificar la autenticación JWT del usuario
  const authHeader = req.headers.get('Authorization');
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return new Response(JSON.stringify({ error: "Falta el token de autenticación (JWT)." }), {
      status: 401,
      headers: { "Content-Type": "application/json" },
    });
  }

  const jwt = authHeader.replace("Bearer ", "");
  const { data: userData, error: userError } = await supabase.auth.getUser(jwt);

  if (userError || !userData.user) {
    return new Response(JSON.stringify({ error: "Usuario no válido o sesión expirada." }), {
      status: 401,
      headers: { "Content-Type": "application/json" },
    });
  }
  // --- FIN de Lógica de Manejo de Solicitudes y Autenticación ---

try {
 const body = await req.json();
 
 const { 
  itemCount, 
  shippingPrice, 
  customer_stripe_id,
  internalOrderId
 } = body;

 // Validación básica de parámetros
 if (typeof itemCount !== 'number' || itemCount <= 0 || typeof shippingPrice !== 'number') {
   return new Response(JSON.stringify({ error: 'Parámetros de compra inválidos.' }), { status: 400 });
 }

 // 1. OBTENER EL PRECIO REAL del producto desde Stripe
 const price = await stripe.prices.retrieve(TRACKER_PRICE_ID);

 if (price.unit_amount === null || price.currency !== CURRENCY) {
   throw new Error(`Price ID ${TRACKER_PRICE_ID} no válido, no tiene monto o la moneda es incorrecta.`);
 }
 
 const productUnitPriceCents = price.unit_amount;
 
 // 2. CÁLCULO del PRECIO TOTAL
 const shippingPriceCents = Math.round(shippingPrice * 100);
 const productTotalCents = productUnitPriceCents * itemCount;
 const totalAmountCents = productTotalCents + shippingPriceCents;
 
//  console.log(`Total a cobrar (Cents): ${totalAmountCents}`);
   
 // 3. CREAR LA CLAVE EFÍMERA 
 let ephemeralKeySecret = null;
 if (customer_stripe_id) {
  const ephemeralKey = await stripe.ephemeralKeys.create(
   { customer: customer_stripe_id },
   { apiVersion: '2023-10-16' }
  );
   ephemeralKeySecret = ephemeralKey.secret;
 }

 // 4. CREAR EL PAYMENT INTENT
 const paymentIntent = await stripe.paymentIntents.create({
  amount: totalAmountCents, 
  currency: CURRENCY,
  customer: customer_stripe_id,
  setup_future_usage: 'off_session', 
  automatic_payment_methods: {
   enabled: true,
  },
  metadata: {
   product_type: 'tracker',
   internal_order_id: internalOrderId || 'MOCK_TRACKER_ORD', 
   product_price_id: TRACKER_PRICE_ID,
   product_unit_price_cents: productUnitPriceCents,
   item_count: itemCount,
   product_total_cents: productTotalCents,
   shipping_total_cents: shippingPriceCents,
  },
 });

 // 5. Devolver client_secret y la clave efímera para Flutter
 return new Response(
  JSON.stringify({ 
   client_secret: paymentIntent.client_secret,
   ephemeralKey: ephemeralKeySecret,
  }),
  { status: 200, headers: { 'Content-Type': 'application/json' } }
 );

} catch (error) {
 console.error('Error al crear Payment Intent para Rastreador:', error);
    // Aseguramos que la respuesta de error también sea JSON
 return new Response(JSON.stringify({ error: 'Error interno del servidor. Revisar Price ID o conexión a Stripe.' }), { status: 500 });
}
});
