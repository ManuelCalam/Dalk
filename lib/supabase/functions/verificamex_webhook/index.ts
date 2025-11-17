import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const SUPABASE_URL = Deno.env.get('SUPABASE_URL');
const SERVICE_ROLE_KEY = Deno.env.get('SERVICE_ROLE_KEY');

console.log('🔔 verificamex_webhook iniciado');

serve(async (req) => {
  if (req.method !== 'POST') {
    return new Response(JSON.stringify({ success: false, error: 'Método no permitido' }), {
      status: 405,
      headers: { 'Content-Type': 'application/json' },
    });
  }

  const supabase = createClient(SUPABASE_URL!, SERVICE_ROLE_KEY!);

  try {
    const body = await req.json();
    console.log('📦 Webhook body recibido:', JSON.stringify(body, null, 2));

    const data = body.data || body;

    const verificamexSessionId = data.id;
    const rawStatus = data.status; // FINISHED / OPEN / VERIFYING / FAILED
    const score = data.result ?? 0;

    const optionals = data.optionals || {};
    const userId = optionals.user_id;
    const optionalSessionId = optionals.session_id;

    // Buscar registro existente
    const { data: verification } = await supabase
      .from('identity_verifications')
      .select('*')
      .eq('verificamex_session_id', verificamexSessionId)
      .maybeSingle();

    // Puede venir de optionals si aún no existe registro
    const sessionId = verification?.session_id || optionalSessionId;

    if (!sessionId) {
      console.error('❌ No se encontró session_id');
      return new Response(JSON.stringify({ success: false, error: 'Missing session_id' }), {
        status: 400,
      });
    }

    // Normalizar status a tu tabla
    let finalStatus: string;
    let failureReason: string | null = null;

    switch (rawStatus) {
      case 'OPEN':
      case 'VERIFYING':
        finalStatus = rawStatus; // OPEN / VERIFYING
        break;

      case 'FAILED':
        finalStatus = 'failed';
        failureReason = data.comments || JSON.stringify(data.errors);
        break;

      case 'FINISHED':
        if (score >= 90) {
          finalStatus = 'completed';
        } else {
          finalStatus = 'failed';
          failureReason = `Score insuficiente: ${score}`;
        }
        break;

      default:
        finalStatus = 'failed';
        failureReason = 'Estado desconocido';
    }

    console.log('🔍 Estado interpretado:', { rawStatus, finalStatus, score });

    // Update tabla identity_verifications
    const updateData: any = {
      status: finalStatus,
      verification_result: score,
      verification_data: data,
      updated_at: new Date().toISOString(),
    };

    if (failureReason) updateData.failure_reason = failureReason;
    if (finalStatus === 'success') updateData.completed_at = new Date().toISOString();

    await supabase
      .from('identity_verifications')
      .update(updateData)
      .eq('session_id', sessionId);

    // Update users.verification_status
    if (userId) {
      const userStatus =
        finalStatus === 'success'
          ? 'verified'
          : finalStatus === 'failed'
          ? 'rejected'
          : 'pending_verification';

      await supabase.from('users').update({ verification_status: userStatus }).eq('uuid', userId);
    }

    console.log('✅ Actualización completada:', { sessionId, finalStatus });

    return new Response(
      JSON.stringify({
        success: true,
        session_id: sessionId,
        final_status: finalStatus,
        score,
      }),
      {
        status: 200,
        headers: { 'Content-Type': 'application/json' },
      },
    );

  } catch (error) {
    console.error('💥 Error procesando webhook:', error);

    return new Response(JSON.stringify({ success: false, error: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }
});
