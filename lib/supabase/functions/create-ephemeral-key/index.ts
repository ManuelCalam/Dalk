// supabase/functions/create-ephemeral-key/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const STRIPE_SECRET_KEY = Deno.env.get("STRIPE_SECRET_KEY");

if (!STRIPE_SECRET_KEY) {
  throw new Error("Missing STRIPE_SECRET_KEY environment variable");
}

serve(async (req) => {
  try {
    // Verificar método POST
    if (req.method !== "POST") {
      return new Response(JSON.stringify({ error: "Method not allowed" }), { status: 405 });
    }

    const { customerId } = await req.json();
    
    if (!customerId) {
      return new Response(JSON.stringify({ error: "customerId is required" }), { status: 400 });
    }

    const response = await fetch("https://api.stripe.com/v1/ephemeral_keys", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${STRIPE_SECRET_KEY}`,
        "Content-Type": "application/x-www-form-urlencoded",
        "Stripe-Version": "2023-10-16"
      },
      body: new URLSearchParams({
        customer: customerId,
      })
    });

    const keyData = await response.json();
    
    if (response.status !== 200) {
      return new Response(JSON.stringify({ error: keyData.error?.message || "Stripe error" }), { status: 400 });
    }

    return new Response(JSON.stringify({
      secret: keyData.secret,
      id: keyData.id,
      expires: keyData.expires
    }), { 
      status: 200,
      headers: { "Content-Type": "application/json" }
    });
    
  } catch (err) {
    console.error("Error creating ephemeral key:", err);
    return new Response(JSON.stringify({ error: err.message }), { status: 500 });
  }
});