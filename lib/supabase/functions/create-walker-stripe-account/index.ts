// supabase/functions/create-walker-stripe-account/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import Stripe from "https://esm.sh/stripe@14.19.0";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3";

const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY");
const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
const STRIPE_SECRET_KEY = Deno.env.get("STRIPE_SECRET_KEY");
const BASE_DOMAIN = "https://dalk.com/payments";

// Stripe
const stripe = new Stripe(STRIPE_SECRET_KEY!, { apiVersion: "2023-10-16" });

// Supabase clients
const supabaseAnon = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
const supabase = createClient(SUPABASE_URL!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);

serve(async (req) => {
  try {
    // --- Autenticación ---
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401, headers: { "Content-Type": "application/json" } });
    }
    const jwt = authHeader.replace("Bearer ", "");
    const { data: { user }, error: userError } = await supabaseAnon.auth.getUser(jwt);
    if (userError || !user) {
      return new Response(JSON.stringify({ error: "Invalid user" }), { status: 401, headers: { "Content-Type": "application/json" } });
    }

    // --- Leer datos del request ---
    const { walker_id, email } = await req.json();
    if (!walker_id || !email) {
      return new Response(JSON.stringify({ error: "walker_id y email son obligatorios." }), { status: 400 });
    }

    // --- Buscar cuenta existente ---
    const { data: existing, error: fetchError } = await supabase
      .from("walker_payments")
      .select("account_stripe_id, account_status")
      .eq("walker_uuid", walker_id)
      .single();

    if (fetchError && fetchError.code !== "PGRST116") {
      console.error("Error al consultar BD:", fetchError);
      return new Response(JSON.stringify({ error: "Error al consultar la base de datos." }), { status: 500 });
    }

    let accountId: string;
    let status: string;
    let accountLinkUrl: string | null = null;

    // --- Caso A: No existe registro → crear nueva cuenta ---
    if (!existing) {
      const account = await stripe.accounts.create({
        type: "express",
        email,
        capabilities: { transfers: { requested: true } },
      });

      accountId = account.id;
      status = "pending_verification";

      const { error: insertError } = await supabase
        .from("walker_payments")
        .insert({
          walker_uuid: walker_id,
          email,
          account_stripe_id: accountId,
          account_status: status,
        });

      if (insertError) {
        console.error("Error insertando registro:", insertError);
        return new Response(JSON.stringify({ error: "Error guardando datos en la base de datos." }), { status: 500 });
      }

      // Crear onboarding link
      const accountLink = await stripe.accountLinks.create({
        account: accountId,
        refresh_url: `${BASE_DOMAIN}/refresh?walker_id=${walker_id}`,
        return_url: `${BASE_DOMAIN}/return?walker_id=${walker_id}`,
        type: "account_onboarding",
      });
      accountLinkUrl = accountLink.url;
    }
    // --- Caso B: Ya existe ---
    else {
      accountId = existing.account_stripe_id;
      status = existing.account_status;

      switch (status) {
        case "pending_verification":
        case "restricted":
          // Reabrir onboarding link
          const accountLink = await stripe.accountLinks.create({
            account: accountId,
            refresh_url: `${BASE_DOMAIN}/refresh?walker_id=${walker_id}`,
            return_url: `${BASE_DOMAIN}/return?walker_id=${walker_id}`,
            type: "account_onboarding",
          });
          accountLinkUrl = accountLink.url;
          break;

        case "verified":
          // Ya verificada, no se necesita link
          accountLinkUrl = null;
          break;

        case "disconnected":
          // Crear nueva cuenta porque la anterior fue desconectada
          const newAccount = await stripe.accounts.create({
            type: "express",
            email,
            capabilities: { transfers: { requested: true } },
          });
          accountId = newAccount.id;
          status = "pending_verification";

          const { error: updateError } = await supabase
            .from("walker_payments")
            .update({ account_stripe_id: accountId, account_status: status })
            .eq("walker_uuid", walker_id);

          if (updateError) {
            console.error("Error actualizando cuenta desconectada:", updateError);
            return new Response(JSON.stringify({ error: "Error interno." }), { status: 500 });
          }

          const newAccountLink = await stripe.accountLinks.create({
            account: accountId,
            refresh_url: `${BASE_DOMAIN}/refresh?walker_id=${walker_id}`,
            return_url: `${BASE_DOMAIN}/return?walker_id=${walker_id}`,
            type: "account_onboarding",
          });
          accountLinkUrl = newAccountLink.url;
          break;

        default:
          // Estado inesperado → solo devolver info existente
          accountLinkUrl = null;
          break;
      }
    }

    return new Response(JSON.stringify({
      account_stripe_id: accountId,
      status,
      url: accountLinkUrl,
    }), { headers: { "Content-Type": "application/json" } });

  } catch (err) {
    console.error("Error general:", err);
    return new Response(JSON.stringify({ error: "Error interno del servidor." }), { status: 500 });
  }
});
