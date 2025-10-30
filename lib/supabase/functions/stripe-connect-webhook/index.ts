// supabase/functions/stripe-connect-webhook/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import Stripe from "https://esm.sh/stripe@14.0.0?target=deno";

const STRIPE_SECRET_KEY = Deno.env.get("STRIPE_SECRET_KEY");
const STRIPE_CONNECT_WEBHOOK_SECRET = Deno.env.get("STRIPE_CONNECT_WEBHOOK_SECRET");
const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

if (!STRIPE_SECRET_KEY || !STRIPE_CONNECT_WEBHOOK_SECRET || !SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
  throw new Error("Missing environment variables");
}

const stripe = new Stripe(STRIPE_SECRET_KEY, { apiVersion: "2023-10-16" });
const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

serve(async (req) => {
  try {
    if (req.method !== "POST") {
      return new Response("Method Not Allowed", { status: 405 });
    }

    const body = await req.text();
    const sig = req.headers.get("stripe-signature");

    let event;
    try {
      event = await stripe.webhooks.constructEventAsync(body, sig, STRIPE_CONNECT_WEBHOOK_SECRET);
    } catch (err) {
      console.error("Invalid signature:", err.message);
      return new Response("Invalid signature", { status: 400 });
    }

    console.log("Connect webhook received:", event.type);

    switch (event.type) {
      case "account.updated":
        await handleAccountUpdated(event.data.object);
        break;
      case "account.external_account.created":
        await handleExternalAccountCreated(event.data.object);
        break;
      case "capability.updated":
        await handleCapabilityUpdated(event.data.object);
        break;
      case "person.updated":
        await handlePersonUpdated(event.data.object);
        break;
      case "account.application.deauthorized":
        await handleAccountDeauthorized(event.data.object);
        break;
      case "balance.available":
        await handleBalanceAvailable(event.data.object);
        break;
      case "payout.created":
        await handlePayoutCreated(event.data.object);
        break;
      case "payout.paid":
        await handlePayoutPaid(event.data.object);
        break;
      case "payout.failed":
        await handlePayoutFailed(event.data.object);
        break;

      default:
        console.log("Unhandled event:", event.type);
    }

    return new Response(JSON.stringify({ received: true }), { status: 200 });

  } catch (err) {
    console.error("Webhook error:", err);
    return new Response("Webhook Error", { status: 500 });
  }
});

async function handleAccountUpdated(account: any) {
  const accountId = account.id;
  let status = "pending_verification";

  if (account.details_submitted && account.charges_enabled && account.payouts_enabled) {
    status = "verified";
  } else if (account.requirements?.disabled_reason) {
    status = "restricted";
  }

  console.log(`Account ${accountId} updated → ${status}`);

  const { error } = await supabase
    .from("walker_payments")
    .update({ account_status: status })
    .eq("account_stripe_id", accountId);

  if (error) console.error("DB update error:", error);
}

async function handleExternalAccountCreated(externalAccount: any) {
  console.log("External account created:", externalAccount.id);
}

async function handleCapabilityUpdated(capability: any) {
  console.log("Capability updated:", capability.id, capability.status);
}

async function handlePersonUpdated(person: any) {
  console.log("Person updated:", person.id, "→ verification:", person.verification);
}

async function handleAccountDeauthorized(account: any) {
  console.log("Account disconnected:", account.id);
  await supabase
    .from("walker_payments")
    .update({ account_status: "disconnected" })
    .eq("account_stripe_id", account.id);
}

async function handleBalanceAvailable(balance: any) {
  const accountId = balance.object === "balance" ? balance.account : null;
  if (!accountId) return console.error("No account ID in balance.available event");

  const available = balance.available?.[0]?.amount || 0;
  const pending = balance.pending?.[0]?.amount || 0;

  console.log(`Balance updated for ${accountId}: available=${available}, pending=${pending}`);

  const { error } = await supabase
    .from("walker_payments")
    .update({
      available_balance: available / 100,
      pending_balance: pending / 100,
    })
    .eq("account_stripe_id", accountId);

  if (error) console.error("DB update error (balance):", error);
}


async function handlePayoutCreated(payout: any) {
  console.log(`Payout created → id: ${payout.id}, amount: ${payout.amount / 100}, account: ${payout.destination}`);
}

async function handlePayoutPaid(payout: any) {
  console.log(`Payout paid → id: ${payout.id}, amount: ${payout.amount / 100}, account: ${payout.destination}`);
}

async function handlePayoutFailed(payout: any) {
  console.log(`Payout failed → id: ${payout.id}, amount: ${payout.amount / 100}, account: ${payout.destination}, failure_code: ${payout.failure_code}`);
}