// /supabase/functions/create_verification.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS'
};

const SUPABASE_URL = Deno.env.get('SUPABASE_URL');
const SERVICE_ROLE_KEY = Deno.env.get('SERVICE_ROLE_KEY');
const VERIFICAMEX_SECRET_KEY = Deno.env.get('VERIFICAMEX_SECRET_KEY');
const VERIFICAMEX_API_URL = 'https://api.verificamex.com/identity/v2/identity/sessions';

console.log('🚀 create_verification function iniciada');

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response(null, { headers: corsHeaders, status: 204 });

  if (req.method !== 'POST') {
    return new Response(JSON.stringify({ error: 'Método no soportado' }), {
      status: 405, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    });
  }

  try {
    const body = await req.json();
    const { user_id, email } = body;

    if (!user_id || !email) {
      return new Response(JSON.stringify({ success: false, error: 'Faltan user_id o email' }), {
        status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      });
    }

    const supabase = createClient(SUPABASE_URL!, SERVICE_ROLE_KEY!);

    const sessionId = `session_${Date.now()}_${Math.random().toString(36).substring(2, 10)}`;
    const redirectUrl = `https://dalk-legal-git-main-noe-ibarras-projects.vercel.app/redirect_url.html?session_id=${sessionId}&user_id=${user_id}`;
    const webhookUrl = `${SUPABASE_URL}/functions/v1/verificamex_webhook`;

    // ✅ Payload para crear sesión en Verificamex
    const verificamexPayload = {
      validations: ['INE', 'CURP'],
      redirect_url: redirectUrl,
      webhook: webhookUrl,
      only_mobile_devices: true,
      with_webhook_binaries: true,
      optionals: { session_id: sessionId, user_id, email },
      customization: {
        button_color: '#0080C4',
        background_color: '#163143',
        primary_color: '#0080C4',
        secondary_color: '#CCDBFF',
        button_text_color: '#E0ECFF'
      }
    };

    console.log('📤 Enviando payload a Verificamex:', JSON.stringify(verificamexPayload, null, 2));

    const response = await fetch(VERIFICAMEX_API_URL, {
      method: 'POST',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${VERIFICAMEX_SECRET_KEY}`
      },
      body: JSON.stringify(verificamexPayload)
    });

    const dataText = await response.text();
    console.log('📦 Respuesta Verificamex:', dataText);

    if (!response.ok) {
      return new Response(JSON.stringify({ success: false, error: dataText }), {
        status: response.status, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      });
    }

    const data = JSON.parse(dataText);
    const verificamexSessionId = data.data?.id || data.id;
    const formUrl = data.data?.form_url || data.form_url;

    // ✅ Guardar sesión en la base de datos
    await supabase.from('identity_verifications').insert({
      session_id: sessionId,
      verificamex_session_id: verificamexSessionId,
      user_uuid: user_id,
      email,
      status: 'OPEN',
      verification_data: data,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    });

    return new Response(JSON.stringify({
      success: true,
      session_id: sessionId,
      verificamex_session_id: verificamexSessionId,
      form_url: formUrl
    }), { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });

  } catch (err) {
    console.error('💥 Error en create_verification:', err);
    return new Response(JSON.stringify({ success: false, error: err.message }), {
      status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    });
  }
});
