import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import Stripe from "https://esm.sh/stripe@^14.0.0?target=deno&pin=v135";

// =====================
// Configuración
// =====================
const STRIPE_SECRET_KEY = Deno.env.get("STRIPE_SECRET_KEY");
const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

if (!STRIPE_SECRET_KEY || !SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
    throw new Error("Missing environment variables");
}

const stripe = new Stripe(STRIPE_SECRET_KEY, {
    apiVersion: "2023-10-16",
    httpClient: Stripe.createFetchHttpClient(),
});

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);


// =====================
// Handler principal
// =====================
serve(async (req) => {
    if (req.method !== "POST") {
        return new Response(JSON.stringify({ error: "Method not allowed" }), { status: 405 });
    }

    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
        return new Response(JSON.stringify({ error: "Missing Authorization header" }), { status: 401 });
    }

    const token = authHeader.replace("Bearer ", "");
    const { data: userData, error: userError } = await supabase.auth.getUser(token);

    if (userError || !userData.user) {
        return new Response(JSON.stringify({ error: "Invalid or expired token" }), { status: 401 });
    }
    const userUUID = userData.user.id;

    const { data: userProfile, error: profileError } = await supabase
        .from("users")
        .select("subscription_id, uuid")
        .eq("uuid", userUUID)
        .single();

    if (profileError || !userProfile?.subscription_id) {
        console.error("User profile or subscription ID not found:", profileError);
        return new Response(JSON.stringify({ error: "No active subscription found for this user, or user profile missing." }), { status: 404 });
    }
    const subscriptionId = userProfile.subscription_id;

    try {
        const canceledSubscription = await stripe.subscriptions.update(
            subscriptionId,
            { 
                cancel_at_period_end: true,
            }
        );
        
        console.log(`Subscription ${subscriptionId} scheduled for cancellation.`);
        
        // Convertir el timestamp de UNIX a formato ISO para Supabase
        const periodEndTimestamp = canceledSubscription.current_period_end;
        const periodEndISO = periodEndTimestamp 
            ? new Date(periodEndTimestamp * 1000).toISOString()
            : null;

        const { error: updateError, count } = await supabase
            .from("users")
            .update({ 
                subscription_status: 'canceled_at_period_end',
                subscription_current_period_end: periodEndISO,
            })
            .eq("uuid", userUUID)
            .select('*', { count: 'exact' }); // Usar select para obtener 'count'

        if (updateError) {
            // Error explícito en la DB (problema de conexión, tipo de dato, etc.)
            console.error("Supabase DB update failed (Explicit Error):", updateError.message);
            return new Response(JSON.stringify({ error: `DB Update Failed: ${updateError.message}` }), { status: 500 });
        }
        
        if (count === 0) {
             console.error(`Supabase DB update failed (Row Count 0): The UUID ${userUUID} was found in SELECT but not updated. RLS or unique constraint violation likely.`);
             return new Response(JSON.stringify({ error: "DB Update Failed: La fila fue ignorada por la base de datos (0 filas afectadas)." }), { status: 500 });
        }
        
        console.log(`DB successfully updated for user ${userUUID}. Rows affected: ${count}. Status: canceled_at_period_end`);

        return new Response(
            JSON.stringify({ 
                message: "Cancellation scheduled successfully.",
                subscription_status: canceledSubscription.status,
                cancel_at: canceledSubscription.cancel_at,
            }),
            { 
                status: 200,
                headers: { "Content-Type": "application/json" } 
            }
        );

    } catch (stripeError) {
        console.error("Stripe cancellation error:", stripeError);
        return new Response(JSON.stringify({ error: "Stripe API error during cancellation." }), { status: 500 });
    }
});
