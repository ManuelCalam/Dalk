// supabase/functions/list-payment-methods/index.ts
import { serve } from "https://deno.land/std@0.177.0/http/server.ts"
import Stripe from "https://esm.sh/stripe@12.18.0"

serve(async (req) => {
  try {
    const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!, {
      apiVersion: "2024-06-20",
    });

    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response("Unauthorized", { status: 401 });
    }

    const { customerId } = await req.json();

    if (!customerId) {
      return new Response("Missing customerId", { status: 400 });
    }

    const paymentMethods = await stripe.paymentMethods.list({
      customer: customerId,
      type: "card",
    });

    const cards = paymentMethods.data.map(pm => ({
      id: pm.id,
      funding: pm.card?.funding ?? "unknown",
      brand: pm.card?.brand ?? "unknown",
      last4: pm.card?.last4 ?? "0000",
      exp_month: pm.card?.exp_month ?? 0,
      exp_year: pm.card?.exp_year ?? 0,
    }));

    return new Response(JSON.stringify(cards), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (err) {
    console.error(err);
    return new Response(JSON.stringify({ error: err.message }), { status: 500 });
  }
});
