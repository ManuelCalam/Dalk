import Stripe from 'https://esm.sh/stripe@14.11.0?deno';

const TRACKER_PRICE_ID = 'price_1SJomM6aB9DzvCSxAupT1NbC'; 
const BASE_DOMAIN = 'https://dalk.com/payment';
const CURRENCY = 'mxn'; 

const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY')!, {
    apiVersion: '2023-10-16',
});

Deno.serve(async (req) => {
    if (req.method !== 'POST') {
        return new Response(JSON.stringify({ error: 'Método no permitido. Usa POST.' }), {
            status: 405,
            headers: { 'Content-Type': 'application/json' },
        });
    }

    try {
        const { itemCount, shippingPrice, customer_stripe_id } = await req.json();

        // Validación de Datos 
        if (!itemCount || typeof shippingPrice === 'undefined' || itemCount <= 0 || itemCount > 5) {
            return new Response(JSON.stringify({ error: 'Parámetros faltantes o cantidad inválida (máximo 5 rastreadores).' }), {
                status: 400,
                headers: { 'Content-Type': 'application/json' },
            });
        }

        // Definimos el Customer ID de Stripe (si existe, lo usamos; si es null, Stripe lo ignorará)
        const stripeCustomerId = customer_stripe_id ? String(customer_stripe_id) : undefined;
        
        // Creación de los Line Items
        const lineItems: Stripe.Checkout.SessionCreateParams.LineItem[] = [
            { price: TRACKER_PRICE_ID, quantity: itemCount },
            {
                price_data: {
                    currency: CURRENCY,
                    unit_amount: Math.round(shippingPrice * 100), 
                    product_data: {
                        name: 'Costo de Envío',
                        description: 'Tarifa de mensajería para el pedido.',
                    },
                },
                quantity: 1, 
            },
        ];

        // Crear la Sesión de Checkout
        const session = await stripe.checkout.sessions.create({
            line_items: lineItems, 
            mode: 'payment',
            
            // 1. MANEJO DEL CLIENTE: Si el ID existe, lo asocia. Si es undefined, Stripe creará uno nuevo.
            customer: stripeCustomerId, 
            // 2. GUARDAR LA TARJETA: Guarda el método de pago para uso futuro, asociado al cliente.
            payment_intent_data: {
                setup_future_usage: 'off_session', 
            },
            
            success_url: `${BASE_DOMAIN}/success`,
            cancel_url: `${BASE_DOMAIN}/cancel`,
            payment_method_types: ['card'],
        });

        // Devolver la URL de Checkout a la aplicación Flutter
        return new Response(JSON.stringify({ checkoutUrl: session.url }), {
            status: 200,
            headers: { 'Content-Type': 'application/json' },
        });

    } catch (error) {
        console.error('Error al crear la sesión de Stripe:', error);
        return new Response(JSON.stringify({ error: 'Error interno del servidor al procesar la solicitud.' }), {
            status: 500,
            headers: { 'Content-Type': 'application/json' },
        });
    }
});
