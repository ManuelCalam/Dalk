/// <reference types="https://deno.land/x/deno@v1.42.0/cli/tsc/dts/lib.deno.ns.d.ts" />

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const SUPABASE_URL = Deno.env.get('SUPABASE_URL');
const SERVICE_ROLE_KEY = Deno.env.get('SERVICE_ROLE_KEY');

console.log('🔔 verificamex_webhook iniciado');

serve(async (req: Request) => {
  if (req.method !== 'POST') {
    return new Response(JSON.stringify({ completed: false, error: 'Método no permitido' }), {
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
    const rawStatus = data.status;
    const score = data.result ?? 0;

    // ✅ EXTRAER CORRECTAMENTE INE Y CURP STATUS
    const ineStatus = data.ine?.data?.status ?? false;
    const curpStatus = data.renapo?.data?.status ?? false;

    console.log('📊 Estados extraídos:', {
      ineStatus,
      curpStatus,
      ineData: data.ine?.data,
      renapoData: data.renapo?.data
    });

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
      return new Response(JSON.stringify({ completed: false, error: 'Missing session_id' }), {
        status: 400,
      });
    }

    // Normalizar status a tu tabla
    // ✅ LÓGICA MEJORADA PARA DETERMINAR STATUS FINAL
    let finalStatus: string;
    let failureReason: string | null = null;

    switch (rawStatus) {
      case 'OPEN':
        finalStatus = 'OPEN';
        break;

      case 'VERIFYING':
        finalStatus = 'VERIFYING';
        break;

      case 'FAILED':
        finalStatus = 'failed';
        failureReason = data.comments || JSON.stringify(data.errors) || 'Verificación fallida';
        break;

      case 'FINISHED':
        // ✅ VERIFICAR SCORE Y STATUS DE INE/CURP
        if (score >= 90) {
          finalStatus = 'completed';
          
          // ⚠️ AGREGAR WARNING SI INE O CURP FALLARON
          if (!ineStatus || !curpStatus) {
            failureReason = `Éxito (Score: ${score}), pero falló INE/CURP. INE: ${ineStatus}, CURP: ${curpStatus}`;
            console.log('⚠️ WARNING:', failureReason);
          }
        } else {
          finalStatus = 'failed';
          failureReason = `Score insuficiente: ${score}. INE: ${ineStatus}, CURP: ${curpStatus}`;
        }
        break;

      default:
        finalStatus = 'failed';
        failureReason = `Estado desconocido: ${rawStatus}`;
    }

    console.log('🔍 Estado interpretado:', { rawStatus, finalStatus, score, ineStatus, curpStatus });

    // ✅ ACTUALIZAR BD CON TODOS LOS CAMPOS
    const updateData: any = {
      status: finalStatus,
      verification_result: score,
      ine_status: ineStatus,        // ✅ AGREGAR
      curp_status: curpStatus,      // ✅ AGREGAR
      verification_data: data,
      updated_at: new Date().toISOString(),
    };

    if (failureReason) updateData.failure_reason = failureReason;
    if (finalStatus === 'completed') updateData.completed_at = new Date().toISOString();

    await supabase
      .from('identity_verifications')
      .update(updateData)
      .eq('session_id', sessionId);

    console.log('✅ identity_verifications actualizado');

    // ✅ ACTUALIZAR users.verification_status
    if (userId) {
      const userStatus =
        finalStatus === 'completed'
          ? 'verified'
          : finalStatus === 'failed'
          ? 'rejected'
          : 'pending_verification';

      await supabase.from('users').update({ verification_status: userStatus }).eq('uuid', userId);
      console.log(`✅ users.verification_status actualizado a: ${userStatus}`);
    }

    console.log('✅ Webhook procesado completamente');

    return new Response(
      JSON.stringify({
        completed: true,
        session_id: sessionId,
        final_status: finalStatus,
        score,
        ine_status: ineStatus,
        curp_status: curpStatus,
      }),
      {
        status: 200,
        headers: { 'Content-Type': 'application/json' },
      },
    );

  } catch (error: unknown) {
    console.error('💥 Error procesando webhook:', error);

    return new Response(JSON.stringify({ 
      completed: false, 
      error: error instanceof Error ? error.message : 'Unknown error' 
    }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }
});