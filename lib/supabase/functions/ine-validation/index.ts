// index.ts

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// ✅ CORS HEADERS
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

// ✅ SECRETS (configuradas en Supabase)
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const SERVICE_ROLE_KEY = Deno.env.get('SERVICE_ROLE_KEY')!
const SUPABASE_ANON_KEY = Deno.env.get('SUPABASE_ANON_KEY')!
const VERIFICAMEX_SECRET_KEY = Deno.env.get('VERIFICAMEX_SECRET_KEY')!

const VERIFICAMEX_API_URL = 'https://api.verificamex.com/identity/v2/identity/sessions'

console.log('🚀 Edge Function ine-validation iniciada')
console.log('🔑 Secrets cargadas:', {
  SUPABASE_URL: !!SUPABASE_URL,
  SERVICE_ROLE_KEY: !!SERVICE_ROLE_KEY,
  SUPABASE_ANON_KEY: !!SUPABASE_ANON_KEY,
  VERIFICAMEX_SECRET_KEY: !!VERIFICAMEX_SECRET_KEY,
})

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders, status: 204 })
  }

  try {
    console.log('📨 ========================================')
    console.log('📨 NUEVA SOLICITUD RECIBIDA')
    console.log('📨 Método:', req.method)
    console.log('📨 ========================================')

    const supabaseClient = createClient(SUPABASE_URL, SERVICE_ROLE_KEY, {
      auth: { autoRefreshToken: false, persistSession: false },
    })

    let bodyText = await req.text()
    let body: any = {}

    try {
      body = JSON.parse(bodyText)
    } catch {
      console.warn('⚠️ No se pudo parsear JSON, body recibido como texto:', bodyText)
      body = {}
    }

    console.log('📦 Body recibido:', JSON.stringify(body, null, 2))

    if (body.data && body.data.id) {
      console.log('🔔 WEBHOOK DE VERIFICAMEX DETECTADO')
      return await handleVerificamexWebhook(body, supabaseClient)
    }

    if (body.action === 'create_session') {
      console.log('🏗️ SOLICITUD PARA CREAR SESIÓN')
      return await createVerificationSession(body, supabaseClient)
    }

    console.log('❌ Acción no reconocida:', body)
    return new Response(
      JSON.stringify({ success: false, error: 'Acción no válida' }),
      { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error: any) {
    console.error('💥 ERROR GENERAL:', error)
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})

// ====================================================================
// ✅ FUNCIÓN 1: CREAR SESIÓN DE VERIFICACIÓN CON VERIFICAMEX
// ====================================================================
async function createVerificationSession(body: any, supabaseClient: any) {
  console.log('🏗️ ========================================')
  console.log('🏗️ CREANDO SESIÓN CON VERIFICAMEX')
  console.log('🏗️ ========================================')

  // 🔑 DESESTRUCTURAR EL ACCESS TOKEN ENVIADO DESDE FLUTTER
  const { user_id, email, access_token: accessToken } = body 

  if (!user_id || !email || !accessToken) { 
    console.log('❌ Faltan datos requeridos:', { user_id, email, accessToken: !!accessToken })
    return new Response(
      JSON.stringify({ success: false, error: 'Faltan user_id, email, o access_token' }),
      { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }

  console.log('🔑 Access Token recibido correctamente')
  console.log('🔑 Token length:', accessToken.length)

  try {
    const sessionId = `session_${Date.now()}_${Math.random().toString(36).substring(2, 15)}`

    // ✅ INSERTAR EN BD
    await supabaseClient.from('identity_verifications').insert({
      session_id: sessionId,
      user_uuid: user_id,
      email: email,
      status: 'pending',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    })

    // ✅ PREPARAR URL DE REDIRECCIÓN
    const redirectUrl = `https://dalk-legal-git-main-noe-ibarras-projects.vercel.app/redirect_url.html?session_id=${sessionId}&user_id=${user_id}`
    const webhookUrl = `${SUPABASE_URL}/functions/v1/ine-validation`

    // ✅ PAYLOAD PARA VERIFICAMEX
    const verificamexPayload = {
      validations: ['INE', 'CURP'],
      redirect_url: redirectUrl,
      webhook: webhookUrl,
      only_mobile_devices: true,
      with_webhook_binaries: true,
      optionals: {
        session_id: sessionId,
        user_id: user_id,
        email: email,
        timestamp: new Date().toISOString(),
      },
      customization: {
        button_color: '#0080C4',
        background_color: '#163143',
        primary_color: '#0080C4',
        secondary_color: '#CCDBFF',
        button_text_color: '#E0ECFF',
      },
    }

    console.log('📤 Enviando a Verificamex:', JSON.stringify(verificamexPayload, null, 2))

    // ✅ LLAMAR A VERIFICAMEX
    const verificamexResponse = await fetch(VERIFICAMEX_API_URL, {
      method: 'POST',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${VERIFICAMEX_SECRET_KEY}`,
      },
      body: JSON.stringify(verificamexPayload),
    })

    const responseText = await verificamexResponse.text()
    console.log('📊 Verificamex Status:', verificamexResponse.status)
    console.log('📦 Verificamex Response:', responseText)

    if (!verificamexResponse.ok) {
      console.error('❌ Verificamex retornó error:', verificamexResponse.status)
      
      await supabaseClient
        .from('identity_verifications')
        .update({
          status: 'failed',
          failure_reason: `API Error: ${verificamexResponse.status} - ${responseText}`,
          updated_at: new Date().toISOString(),
        })
        .eq('session_id', sessionId)

      return new Response(
        JSON.stringify({ 
          success: false, 
          error: 'Error en Verificamex', 
          details: responseText 
        }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const verificamexData = JSON.parse(responseText)
    const sessionData = verificamexData.data || verificamexData
    const formUrl = sessionData.form_url
    const verificamexSessionId = sessionData.id

    if (!formUrl) throw new Error('No se obtuvo form_url de Verificamex')

    // ✅ ACTUALIZAR BD CON DATOS DE VERIFICAMEX
    await supabaseClient
      .from('identity_verifications')
      .update({
        verificamex_session_id: verificamexSessionId,
        status: 'OPEN',
        verification_data: verificamexData,
        updated_at: new Date().toISOString(),
      })
      .eq('session_id', sessionId)

    console.log('✅ Sesión creada exitosamente')
    console.log('✅ Retornando access_token al cliente')

    // 🔑 RETORNAR RESPUESTA CON ACCESS_TOKEN
    // Usamos 'access_token' como clave principal Y 'refresh_token' para compatibilidad
    return new Response(
      JSON.stringify({
        success: true,
        session_id: sessionId,
        form_url: formUrl,
        verificamex_session_id: verificamexSessionId,
        user_id: user_id,
        access_token: accessToken,      // ✅ CLAVE PRINCIPAL
        refresh_token: accessToken,     // ✅ COMPATIBILIDAD CON CÓDIGO ANTERIOR
        message: 'Sesión creada exitosamente',
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error: any) {
    console.error('💥 Error en createVerificationSession:', error)
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
}

// ====================================================================
// ✅ FUNCIÓN 2: MANEJAR WEBHOOK DE VERIFICAMEX
// ====================================================================
async function handleVerificamexWebhook(body: any, supabaseClient: any) {
  console.log('🔔 ========================================')
  console.log('🔔 PROCESANDO WEBHOOK DE VERIFICAMEX')
  console.log('🔔 ========================================')

  const webhookData = body.data
  const verificamexSessionId = webhookData.id
  const status = webhookData.status
  const result = webhookData.result
  const ineStatus = webhookData.ine?.data?.status || false
  const curpStatus = webhookData.renapo?.data?.status || false
  const optionals = webhookData.optionals || {}

  console.log('📊 Webhook Data:', {
    verificamexSessionId,
    status,
    result,
    ineStatus,
    curpStatus,
  })

  try {
    const { data: verification } = await supabaseClient
      .from('identity_verifications')
      .select('*')
      .eq('verificamex_session_id', verificamexSessionId)
      .maybeSingle()

    const sessionId = verification?.session_id || optionals.session_id
    const userId = optionals.user_id

    let finalStatus = 'pending'
    let failureReason = null
    const successThreshold = 90

    // 🚨 LÓGICA DE VALIDACIÓN CORREGIDA
    if (status === 'FINISHED') {
      if (result >= successThreshold) {
        // ✅ ÉXITO: Score suficiente
        finalStatus = 'completed'
        
        if (!ineStatus || !curpStatus) {
          console.log('⚠️ WARNING: Validaciones INE/CURP fallaron, pero el score general es de éxito.')
          failureReason = `Éxito (Score: ${result}), pero falló INE/CURP. INE: ${ineStatus}, CURP: ${curpStatus}`
        }

      } else {
        // ❌ FALLO: Score bajo
        finalStatus = 'failed'
        failureReason = `Verificación fallida. Score bajo: ${result}`
      }
    } else if (status === 'FAILED') {
      // ❌ FALLO: Verificamex reportó fallo
      finalStatus = 'failed'
      failureReason = webhookData.errors?.join(', ') || 'El proceso de Verificamex falló (FAILED status)'
    } else if (status === 'VERIFYING') {
      finalStatus = 'VERIFYING'
    } else if (status === 'OPEN') {
      finalStatus = 'OPEN'
    } else if (status === 'CANCELLED') {
      finalStatus = 'cancelled'
      failureReason = 'El usuario canceló el proceso'
    }

    const updateData: any = {
      status: finalStatus,
      verification_result: result,
      ine_status: ineStatus,
      curp_status: curpStatus,
      verification_data: webhookData,
      updated_at: new Date().toISOString(),
    }

    if (failureReason) updateData.failure_reason = failureReason
    if (finalStatus === 'completed') updateData.completed_at = new Date().toISOString()

    await supabaseClient.from('identity_verifications').update(updateData).eq('session_id', sessionId)

    console.log('✅ BD actualizada exitosamente')
    console.log('✅ Status final:', finalStatus)

    return new Response(
      JSON.stringify({
        success: true,
        message: 'Webhook procesado correctamente',
        session_id: sessionId,
        verification_status: finalStatus,
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error: any) {
    console.error('💥 Error en handleVerificamexWebhook:', error)
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
}