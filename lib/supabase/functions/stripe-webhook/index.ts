// supabase/functions/stripe-webhook/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import Stripe from "https://esm.sh/stripe@14.0.0?target=deno";

// =====================
// Configuración
// =====================
const STRIPE_SECRET_KEY = Deno.env.get("STRIPE_SECRET_KEY");
const STRIPE_WEBHOOK_SECRET = Deno.env.get("STRIPE_WEBHOOK_SECRET");
const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

if (!STRIPE_SECRET_KEY || !STRIPE_WEBHOOK_SECRET || !SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
  throw new Error("Missing environment variables");
}

const stripe = new Stripe(STRIPE_SECRET_KEY, {
  apiVersion: "2023-10-16"
});

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

// =====================
// Funciones auxiliares
// =====================
async function safeUpdateUser(customerId: string, updates: any, context: string) {
  try {
    const { error, count } = await supabase
      .from("users")
      .update({
        ...updates,
      })
      .eq("customer_stripe_id", customerId);

    if (error) {
      console.error(`DB error [${context}]:`, error);
      return false;
    }
    
    if (count === 0) {
      console.warn(`No user found with customer_id: ${customerId} in [${context}]`);
      return false;
    }
    
    return true;
  } catch (err) {
    console.error(`Unexpected error in [${context}]:`, err);
    return false;
  }
}

async function preventDuplicateSubscriptions(customerId: string, newSubscriptionId: string) {
  try {
    const { data: existingSubscriptions, error } = await supabase
      .from("users")
      .select("subscription_id, subscription_status")
      .eq("customer_stripe_id", customerId)
      .in("subscription_status", ["active", "past_due", "incomplete", "trialing"]);

    if (error) return;

    if (existingSubscriptions && existingSubscriptions.length > 0) {
      for (const sub of existingSubscriptions) {
        if (sub.subscription_id && sub.subscription_id !== newSubscriptionId) {
          console.log("Found duplicate subscription, canceling:", sub.subscription_id);
          
          try {
            const existingSub = await stripe.subscriptions.retrieve(sub.subscription_id);
            
            if (existingSub.status !== "canceled") {
              await stripe.subscriptions.cancel(sub.subscription_id);
              console.log("Successfully canceled duplicate subscription:", sub.subscription_id);
            }
          } catch (cancelError: any) {
            if (cancelError.statusCode === 404) {
              console.log("Subscription not found in Stripe, cleaning up DB:", sub.subscription_id);
              await supabase
                .from("users")
                .update({ 
                  subscription_id: null,
                  subscription_status: null,
                  subscription_current_period_end: null 
                })
                .eq("subscription_id", sub.subscription_id);
            } else {
              console.error("Error canceling duplicate subscription:", cancelError);
            }
          }
        }
      }
    }
  } catch (err) {
    console.error("Error in preventDuplicateSubscriptions:", err);
  }
}

// =====================
// Webhook Handler - SIN VERIFICACIÓN DE AUTH
// =====================
serve(async (req) => {
  try {
    // ✅ Solo verificar método POST, NO verificar auth header
    if (req.method !== "POST") {
      return new Response(
        JSON.stringify({ error: "Method not allowed" }), 
        { status: 405 }
      );
    }

    const body = await req.text();
    const sig = req.headers.get("stripe-signature");

    if (!sig) {
      return new Response(
        JSON.stringify({ error: "Missing stripe-signature header" }), 
        { status: 400 }
      );
    }

    let event;
    try {
      event = await stripe.webhooks.constructEventAsync(body, sig, STRIPE_WEBHOOK_SECRET);
    } catch (err) {
      console.error("Webhook signature verification failed:", err.message);
      return new Response(
        JSON.stringify({ error: "Invalid signature" }), 
        { status: 400 }
      );
    }

    console.log("✅ Webhook received:", event.type, "ID:", event.id);

    // Manejar eventos
    switch (event.type) {
      case "setup_intent.succeeded":
        await handleSetupIntentSucceeded(event.data.object);
        break;
      case "checkout.session.completed":
        await handleCheckoutSessionCompleted(event.data.object);
        break;
      case "invoice.paid":
        await handleInvoicePaid(event.data.object);
        break;
      case "invoice.finalized":
        await handleInvoiceFinalized(event.data.object);
        break;
      case "invoice.payment_failed":
        await handlePaymentFailed(event.data.object);
        break;
      case "customer.subscription.created":
        await handleSubscriptionCreated(event.data.object);
        break;
      case "customer.subscription.updated":
        await handleSubscriptionUpdated(event.data.object);
        break;
      case "customer.subscription.deleted":
        await handleSubscriptionDeleted(event.data.object);
        break;
      case "payment_intent.succeeded":
        await handlePaymentIntentSucceeded(event.data.object);
        break;
      case "payment_intent.payment_failed":
        await handlePaymentIntentFailed(event.data.object);
        break;
      default:
        console.log("Unhandled event type:", event.type);
    }

    return new Response(
      JSON.stringify({ received: true, event: event.type }), 
      { status: 200 }
    );

  } catch (err) {
    console.error("Webhook error:", err.message);
    return new Response(
      JSON.stringify({ error: err.message }), 
      { status: 400 }
    );
  }
});

// =====================
// Handlers
// =====================
async function handleSetupIntentSucceeded(setupIntent: any) {
  console.log("✅ SetupIntent succeeded:", setupIntent.id);

  const customerId = setupIntent.customer;
  const paymentMethodId = setupIntent.payment_method;

  if (!customerId || !paymentMethodId) {
    console.warn("Missing customer or payment method in setup_intent.succeeded");
    return;
  }

  try {
    // 1. Adjuntar el método de pago al cliente (si aún no está)
    await stripe.paymentMethods.attach(paymentMethodId, {
      customer: customerId,
    });
    console.log(`PaymentMethod ${paymentMethodId} attached to customer ${customerId}`);

    // 2. Actualizar el cliente para establecer este método como el predeterminado
    await stripe.customers.update(customerId, {
      invoice_settings: {
        default_payment_method: paymentMethodId,
      },
    });
    console.log(`Customer ${customerId} default payment method updated to ${paymentMethodId}`);

  } catch (err) {
    console.error("Error updating customer default payment method:", err);
  }
}



async function handleCheckoutSessionCompleted(session: any) {
  console.log("Checkout session completed:", session.id);

  const customerId = session.customer;
  const subscriptionId = session.subscription;

  if (!customerId || !subscriptionId) {
    console.warn("Missing customer or subscription in checkout.session.completed");
    return;
  }

  let userId = session.metadata?.user_id;
  
  if (!userId && session.customer_details?.email) {
    const { data: user } = await supabase
      .from("users")
      .select("uuid")
      .eq("email", session.customer_details.email)
      .single();
    
    if (user) userId = user.uuid;
  }

  if (!userId) {
    console.error("Could not find user for checkout session");
    return;
  }

  const { error } = await supabase
    .from("users")
    .update({
      customer_stripe_id: customerId,
      subscription_id: subscriptionId,
      subscription_status: "active",
    })
    .eq("uuid", userId);

  if (error) {
    console.error("DB error [CheckoutSessionCompleted]:", error);
  } else {
    console.log("User updated with subscription from checkout session:", subscriptionId);
  }

  await preventDuplicateSubscriptions(customerId, subscriptionId);
}

async function handleInvoicePaid(invoice: any) {
  const customerId = invoice.customer;
  const subscriptionId = invoice.subscription;

  console.log("💰 Invoice paid:", subscriptionId, "Customer:", customerId);

  if (!customerId || !subscriptionId) return;

  // ✅ ACTUALIZACIÓN MÁS ROBUSTA
  const { error } = await supabase
    .from("users")
    .update({
      subscription_id: subscriptionId,
      subscription_status: "active",
      subscription_current_period_end: invoice.lines.data[0]?.period?.end
        ? new Date(invoice.lines.data[0].period.end * 1000).toISOString()
        : null,
    })
    .eq("customer_stripe_id", customerId);

  if (error) {
    console.error("❌ DB error [InvoicePaid]:", error);
    
    // ✅ FALLBACK: Intentar por subscription_id
    const { error: fallbackError } = await supabase
      .from("users")
      .update({
        subscription_status: "active",
        subscription_current_period_end: invoice.lines.data[0]?.period?.end
          ? new Date(invoice.lines.data[0].period.end * 1000).toISOString()
          : null,
      })
      .eq("subscription_id", subscriptionId);

    if (fallbackError) {
      console.error("❌ Fallback update also failed:", fallbackError);
    } else {
      console.log("✅ Fallback update successful using subscription_id");
    }
  } else {
    console.log("✅ Database updated successfully for paid invoice");
  }
}

async function handleInvoiceFinalized(invoice: any) {
  const customerId = invoice.customer;
  const subscriptionId = invoice.subscription;
  const status = invoice.status;

  console.log("Invoice finalized:", subscriptionId, "Status:", status);

  if (status === "open" && subscriptionId) {
    const success = await safeUpdateUser(
      customerId,
      { 
        subscription_id: subscriptionId,
        subscription_status: "incomplete",
        subscription_current_period_end: invoice.lines.data[0]?.period?.end
          ? new Date(invoice.lines.data[0].period.end * 1000).toISOString()
          : null
      },
      "InvoiceFinalized"
    );

    if (success) {
      console.log("Updated subscription for finalized invoice:", subscriptionId);
    }
  }
}

async function handlePaymentFailed(invoice: any) {
  const customerId = invoice.customer;
  console.log("Payment failed:", customerId);

  const success = await safeUpdateUser(
    customerId,
    { subscription_status: "past_due" },
    "PaymentFailed"
  );

  if (success) {
    console.log("Updated to past_due for customer:", customerId);
  }
}

async function handleSubscriptionCreated(subscription: any) {
  console.log("Subscription created:", subscription.id, subscription.status);

  const customerId = subscription.customer;
  const subscriptionId = subscription.id;
  const status = subscription.status;

  const { data: existingUser } = await supabase
    .from("users")
    .select("subscription_id, subscription_status")
    .eq("customer_stripe_id", customerId)
    .single();

  if (existingUser?.subscription_id && existingUser.subscription_status === "incomplete") {
    console.log("User already has incomplete subscription:", existingUser.subscription_id);
    
    const success = await safeUpdateUser(
      customerId,
      {
        subscription_status: status,
        subscription_current_period_end: subscription.current_period_end
        ? new Date(subscription.current_period_end * 1000).toISOString()
        : null      
      },
      "SubscriptionCreated"
    );

    if (success) {
      console.log("Updated existing subscription to:", status);
    }
  } else {
    const success = await safeUpdateUser(
      customerId,
      {
        subscription_id: subscriptionId,
        subscription_status: status,
        subscription_current_period_end: subscription.current_period_end
          ? new Date(subscription.current_period_end * 1000).toISOString()
          : null
      },
      "SubscriptionCreated"
    );

    if (success) {
      console.log("Database updated with new subscription:", subscriptionId);
    }
  }

  await preventDuplicateSubscriptions(customerId, subscriptionId);
}

async function handleSubscriptionUpdated(subscription: any) {
  console.log("Subscription updated:", subscription.id, subscription.status);

  const success = await safeUpdateUser(
    subscription.customer,
    {
      subscription_status: subscription.status,
      subscription_current_period_end: subscription.current_period_end
        ? new Date(subscription.current_period_end * 1000).toISOString()
        : null    },
    "SubscriptionUpdated"
  );

  if (success) {
    console.log("Subscription updated successfully:", subscription.id);
  }
}

async function handleSubscriptionDeleted(subscription: any) {
  console.log("Subscription deleted:", subscription.id);

  const success = await safeUpdateUser(
    subscription.customer,
    {
      subscription_status: "canceled",
      subscription_id: null,
      subscription_current_period_end: null
    },
    "SubscriptionDeleted"
  );

  if (success) {
    console.log("Subscription canceled and cleaned up:", subscription.id);
  }
}

// async function handlePaymentIntentSucceeded(paymentIntent: any) {
//   console.log("Payment intent succeeded:", paymentIntent.id);

//   const subscriptionId = paymentIntent.metadata?.subscription_id;
//   if (!subscriptionId) return;

//   const { error } = await supabase
//     .from("users")
//     .update({
//       subscription_status: "active",
//     })
//     .eq("subscription_id", subscriptionId)
//     .in("subscription_status", ["incomplete", "past_due"]);

//   if (error) {
//     console.error("DB error [PaymentIntentSucceeded]:", error);
//   } else {
//     console.log("Subscription activated from incomplete state:", subscriptionId);
//   }
// }

// async function handlePaymentIntentFailed(paymentIntent: any) {
//   console.log("Payment intent failed:", paymentIntent.id);

//   const subscriptionId = paymentIntent.metadata?.subscription_id;
//   if (!subscriptionId) return;

//   const success = await safeUpdateUser(
//     paymentIntent.customer,
//     { subscription_status: "past_due" },
//     "PaymentIntentFailed"
//   );

//   if (success) {
//     console.log("Updated to past_due for subscription:", subscriptionId);
//   }
// }

async function handlePaymentIntentSucceeded(paymentIntent: any) {
  console.log("Payment intent succeeded:", paymentIntent.id);

  // --- VERIFICAR COMPRA DE RASTREADOR ---
  const trackerId = paymentIntent.metadata?.internal_order_id; 

  if (trackerId) {
    console.log("Processing TRACKER purchase success for order:", trackerId);

    const { error } = await supabase
      .from("orders")
      .update({
        status: "Pagada",
        // payment_intent_id: paymentIntent.id,
      })
      .eq("tracker_id", trackerId)
      .in("status", ["Pendiente", "Fallida", "Cancelada"]); 

    if (error) {
      console.error("DB error [TrackerOrderSucceeded]:", error);
    } else {
      console.log("✅ Tracker Order marked as PAID. ID:", trackerId);
    }
    return;
  }

  // --- LÓGICA  DE SUSCRIPCIÓN ---
  const subscriptionId = paymentIntent.metadata?.subscription_id;
  if (!subscriptionId) return; 

  const { error } = await supabase
    .from("users")
    .update({
      subscription_status: "active",
    })
    .eq("subscription_id", subscriptionId)
    .in("subscription_status", ["incomplete", "past_due"]);

  if (error) {
    console.error("DB error [PaymentIntentSucceeded]:", error);
  } else {
    console.log("Subscription activated from incomplete state:", subscriptionId);
  }
}

/**
 * Maneja el evento payment_intent.payment_failed.
 */
async function handlePaymentIntentFailed(paymentIntent: any) {
  console.log("Payment intent failed:", paymentIntent.id);

  const trackerId = paymentIntent.metadata?.internal_order_id;
  
  if (trackerId) {
    console.log("Processing TRACKER purchase failure for order:", trackerId);
    
    const { error } = await supabase
      .from("orders")
      .update({ 
        status: "Fallida" 
      })
      .eq("tracker_id", trackerId);

    if (error) {
      console.error("DB error [TrackerOrderFailed]:", error);
    } else {
      console.log("Tracker Order marked as FAILED. ID:", trackerId);
    }
    // Si manejamos una orden de rastreador, terminamos la función aquí.
    return;
  }

  // --- LÓGICA  DE SUSCRIPCIÓN ---
  const subscriptionId = paymentIntent.metadata?.subscription_id;
  if (!subscriptionId) return; 

  const success = await safeUpdateUser(
    paymentIntent.customer,
    { subscription_status: "past_due" },
    "PaymentIntentFailed"
  );

  if (success) {
    console.log("Updated to past_due for subscription:", subscriptionId);
  }
}