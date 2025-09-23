// supabase/functions/detach-payment-method/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import Stripe from "https://esm.sh/stripe@12.12.0?target=deno"

serve(async (req) => {
  try {
    const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!, {
      apiVersion: "2023-10-16",
    })

    const { paymentMethodId } = await req.json()

    if (!paymentMethodId) {
      return new Response(
        JSON.stringify({ error: "Falta paymentMethodId" }),
        { status: 400 }
      )
    }

    // Detach del método de pago
    const pm = await stripe.paymentMethods.detach(paymentMethodId)

    return new Response(
      JSON.stringify({ success: true, detached: pm }),
      { headers: { "Content-Type": "application/json" }, status: 200 }
    )
  } catch (e) {
    return new Response(
      JSON.stringify({ error: e.message }),
      { status: 500 }
    )
  }
})
