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

// =====================
// Función para eliminar suscripción incompleta existente
// =====================
async function cleanupIncompleteSubscription(customerId: string) {
  try {
    console.log("Looking for incomplete subscriptions for customer:", customerId);
    
    // 1. Buscar suscripción incomplete en la base de datos
    const { data: user, error } = await supabase
      .from("users")
      .select("subscription_id")
      .eq("customer_stripe_id", customerId)
      .eq("subscription_status", "incomplete")
      .single();

    if (error || !user?.subscription_id) {
      console.log("No incomplete subscription found to clean up");
      return;
    }

    console.log("Found incomplete subscription to clean up:", user.subscription_id);

    // 2. Eliminar la suscripción en Stripe
    try {
      const deleteRes = await fetch(`https://api.stripe.com/v1/subscriptions/${user.subscription_id}`, {
        method: "DELETE",
        headers: {
          "Authorization": `Bearer ${STRIPE_SECRET_KEY}`,
        }
      });

      if (deleteRes.status === 200) {
        console.log("✅ Successfully deleted incomplete subscription from Stripe");
      } else {
        const errorData = await deleteRes.json();
        console.log("Subscription might already be canceled:", errorData.error?.message);
      }
    } catch (stripeError) {
      console.log("Subscription already canceled or not found in Stripe");
    }

    // 3. Limpiar en la base de datos
    const { error: updateError } = await supabase
      .from("users")
      .update({ 
        subscription_id: null,
        subscription_status: null,
        subscription_current_period_end: null,
      })
      .eq("customer_stripe_id", customerId);

    if (updateError) {
      console.error("Error cleaning up database:", updateError);
    } else {
      console.log("✅ Successfully cleaned up incomplete subscription from database");
    }

  } catch (error) {
    console.error("Error in cleanupIncompleteSubscription:", error);
  }
}

// =====================
// Función auxiliar para limpiar suscripción en Stripe (en caso de error)
// =====================
async function cleanupStripeSubscription(subscriptionId: string) {
  try {
    await fetch(`https://api.stripe.com/v1/subscriptions/${subscriptionId}`, {
      method: "DELETE",
      headers: {
        "Authorization": `Bearer ${STRIPE_SECRET_KEY}`,
      }
    });
    console.log("Cleaned up Stripe subscription:", subscriptionId);
  } catch (cleanupError) {
    console.error("Error cleaning up Stripe subscription:", cleanupError);
  }
}

// =====================
// Main function
// =====================
serve(async (req) => {
  let subscriptionIdToCleanup = null;

  try {
    // 1. Validación de autorización
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401 });
    }

    const jwt = authHeader.replace("Bearer ", "");
    const { data: userData, error: userError } = await supabase.auth.getUser(jwt);
    if (userError || !userData.user) {
      return new Response(JSON.stringify({ error: "Invalid user" }), { status: 401 });
    }

    // 2. Obtener datos del request
    const body = await req.json();
    const { plan, customerId } = body;

    if (!customerId) {
      return new Response(JSON.stringify({ error: "customerId is required" }), { status: 400 });
    }

    console.log("Creating subscription for customer:", customerId);

    // 3. ✅ ELIMINAR SUSCRIPCIÓN INCOMPLETA EXISTENTE (si hay)
    await cleanupIncompleteSubscription(customerId);

    // 4. Determinar priceId
    const priceId = plan === "monthly"
      ? "price_1S8A1k6aB9DzvCSxERGYzOFS"
      : "price_1S8A1k6aB9DzvCSxkkCJJcQt";

    // 5. Obtener métodos de pago
    const paymentMethodsRes = await fetch(`https://api.stripe.com/v1/payment_methods?customer=${customerId}&type=card`, {
      headers: { "Authorization": `Bearer ${STRIPE_SECRET_KEY}` }
    });
    const paymentMethods = await paymentMethodsRes.json();
    const firstPaymentMethodId = paymentMethods.data?.[0]?.id;

    console.log("Payment methods found:", paymentMethods.data?.length);

    if (firstPaymentMethodId) {
      await fetch(`https://api.stripe.com/v1/payment_methods/${firstPaymentMethodId}/attach`, {
        method: "POST",
        headers: {
          "Authorization": `Bearer ${STRIPE_SECRET_KEY}`,
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: new URLSearchParams({
          customer: customerId,
        }),
      });
    }

    // 6. Crear suscripción en Stripe
    const bodyParams = new URLSearchParams({
      customer: customerId,
      "items[0][price]": priceId,
      payment_behavior: "default_incomplete",
      "payment_settings[payment_method_types][]": "card",
      "expand[]": "latest_invoice.payment_intent"
      
    });

    if (firstPaymentMethodId) {
      bodyParams.append("default_payment_method", firstPaymentMethodId);
    }

    const stripeRes = await fetch("https://api.stripe.com/v1/subscriptions", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${STRIPE_SECRET_KEY}`,
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: bodyParams
    });

    const subscription = await stripeRes.json();
    subscriptionIdToCleanup = subscription.id;

    console.log("Stripe API status:", stripeRes.status);
    console.log("Subscription status:", subscription.status);
    console.log("Suscription: ", subscription);
    console.log("Stripe subscription object:", JSON.stringify(subscription, null, 2));
    
    if (stripeRes.status !== 200) {
      // Error al crear suscripción en Stripe - limpiar
      await cleanupStripeSubscription(subscriptionIdToCleanup);
      return new Response(JSON.stringify({ 
        error: subscription.error?.message || "Stripe error"
      }), { status: 400 });
    }

    // 7. Obtener client_secret del PaymentIntent
    let clientSecret = subscription.latest_invoice?.payment_intent?.client_secret;

    // Si no hay PaymentIntent, crear uno manualmente
    // if (!clientSecret && subscription.latest_invoice) {
    //   console.log("Creating manual PaymentIntent for invoice:", subscription.latest_invoice.id);
      
    //   const paymentIntentRes = await fetch("https://api.stripe.com/v1/payment_intents", {
    //     method: "POST",
    //     headers: {
    //       "Authorization": `Bearer ${STRIPE_SECRET_KEY}`,
    //       "Content-Type": "application/x-www-form-urlencoded",
    //     },
    //     body: new URLSearchParams({
    //       amount: subscription.latest_invoice.amount_due.toString(),
    //       currency: "mxn",
    //       customer: customerId,
    //       description: `Pago para suscripción premium: ${subscription.id}`,
    //       "metadata[subscription_id]": subscription.id,
    //       "metadata[invoice_id]": subscription.latest_invoice.id,
    //       "payment_method_types[]": "card",
    //       "setup_future_usage": "off_session",
    //     })
    //   });

    //   const paymentIntent = await paymentIntentRes.json();
      
    //   if (paymentIntentRes.status === 200) {
    //     clientSecret = paymentIntent.client_secret;
    //     console.log("Manual PaymentIntent created:", clientSecret);
    //   } else {
    //     console.log("Error creating PaymentIntent:", paymentIntent);
    //     // Error al crear PaymentIntent - limpiar suscripción
    //     await cleanupStripeSubscription(subscriptionIdToCleanup);
    //     return new Response(JSON.stringify({ 
    //       error: "Failed to create payment session",
    //       details: paymentIntent.error?.message
    //     }), { status: 500 });
    //   }
    // }

    if (!clientSecret) {
      // No se pudo obtener client_secret - limpiar suscripción
      await cleanupStripeSubscription(subscriptionIdToCleanup);
      return new Response(JSON.stringify({ 
        error: "Failed to create payment session",
        debug: {
          subscriptionStatus: subscription.status,
          invoiceStatus: subscription.latest_invoice?.status,
          invoiceId: subscription.latest_invoice?.id
        }
      }), { status: 500 });
    }

    // 8. Guardar EN ESTADO INCOMPLETE en la base de datos
    const userId = userData.user.id;
    const { error: updateError } = await supabase
      .from("users")
      .update({ 
        subscription_id: subscription.id,
        subscription_status: "incomplete", 
        subscription_current_period_end: null,
      })
      .eq("uuid", userId);

    if (updateError) {
      // Error al actualizar base de datos - limpiar suscripción
      await cleanupStripeSubscription(subscriptionIdToCleanup);
      return new Response(JSON.stringify({ 
        error: "Error updating database",
        details: updateError.message
      }), { status: 500 });
    }

    // 9. Devolver client_secret
    return new Response(JSON.stringify({ 
      clientSecret,
      subscriptionId: subscription.id,
      status: "incomplete"
    }), {
      status: 200,
      headers: { "Content-Type": "application/json" }
    });

  } catch (err) {
    // Error inesperado - limpiar suscripción si se creó
    if (subscriptionIdToCleanup) {
      await cleanupStripeSubscription(subscriptionIdToCleanup);
    }
    
    console.error("Unexpected error:", err);
    return new Response(JSON.stringify({ error: err.message }), { status: 500 });
  }
});