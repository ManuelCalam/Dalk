// /supabase/functions/verificamex_webhook.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const SUPABASE_URL = Deno.env.get('SUPABASE_URL');
const SERVICE_ROLE_KEY = Deno.env.get('SERVICE_ROLE_KEY');

console.log('🔔 verificamex_webhook iniciado');

serve(async (req: Request) => {
  if (req.method !== 'POST') {
    return new Response(JSON.stringify({ success: false, error: 'Método no permitido' }), {
      status: 405, headers: { 'Content-Type': 'application/json' }
    });
  }

  const supabase = createClient(SUPABASE_URL!, SERVICE_ROLE_KEY!);

  try {
    const body = await req.json();
    console.log('📦 Webhook body recibido:', JSON.stringify(body, null, 2));

    const sessionData = body.data || body;
    const verificamexSessionId = sessionData.id;
    const status = sessionData.status;
    const result = sessionData.result || 0;
    const ineStatus = sessionData.ine?.data?.status ?? false;
    const curpStatus = sessionData.renapo?.data?.status ?? false;
    const optionals = sessionData.optionals || {};

    // Buscar en BD
    const { data: verification } = await supabase
      .from('identity_verifications')
      .select('*')
      .eq('verificamex_session_id', verificamexSessionId)
      .maybeSingle();

    const sessionId = verification?.session_id || optionals.session_id;
    const userId = optionals.user_id;

    let finalStatus = 'pending';
    let failureReason = null;

    if (status === 'FINISHED') {
      finalStatus = result >= 90 ? 'completed' : 'failed';
      if (result < 90) failureReason = `Score insuficiente: ${result}`;
    } else if (status === 'FAILED') {
      finalStatus = 'failed';
      failureReason = sessionData.comments || JSON.stringify(sessionData.errors);
    } else if (status === 'OPEN' || status === 'VERIFYING') {
      finalStatus = status;
    } else if (status === 'CANCELLED') {
      finalStatus = 'cancelled';
      failureReason = 'El usuario canceló el proceso';
    }

    const updateData: any = {
      status: finalStatus,
      verification_result: result,
      ine_status: ineStatus,
      curp_status: curpStatus,
      verification_data: sessionData,
      updated_at: new Date().toISOString()
    };

    if (failureReason) updateData.failure_reason = failureReason;
    if (finalStatus === 'completed') updateData.completed_at = new Date().toISOString();

    await supabase.from('identity_verifications').update(updateData).eq('session_id', sessionId);

    
    let userVerificationStatus = 'pending_verification';
    if (finalStatus === 'completed') userVerificationStatus = 'verified';
    else if (finalStatus === 'failed' || finalStatus === 'cancelled') userVerificationStatus = 'rejected';


    // (Opcional) actualizar tabla users.verification_status
    if (userId) {
      await supabase.from('users').update({ verification_status: userVerificationStatus }).eq('uuid', userId);

    }

    console.log('✅ Verificación actualizada en DB correctamente:', { sessionId, finalStatus });

    return new Response(JSON.stringify({
      success: true,
      session_id: sessionId,
      verification_status: finalStatus
    }), { status: 200, headers: { 'Content-Type': 'application/json' } });

  } catch (error) {
    console.error('💥 Error procesando webhook:', error);
    return new Response(JSON.stringify({ success: false, error: error.message }), {
      status: 500, headers: { 'Content-Type': 'application/json' }
    });
  }
});
