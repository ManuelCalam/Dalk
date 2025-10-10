import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
}

const VERIFICAMEX_API_URL = 'https://api.verificamex.com/identity/v2/identity/sessions'
const VERIFICAMEX_API_TOKEN = Deno.env.get('VERIFICAMEX_SECRET_KEY') ?? ''

serve(async (req) => {
  const timestamp = new Date().toISOString()
  const url = new URL(req.url)
  
  console.log('🚀 ========================================')
  console.log('🚀 EDGE FUNCTION INICIADA')
  console.log('🚀 Timestamp:', timestamp)
  console.log('🚀 Método:', req.method)
  console.log('🚀 URL completa:', req.url)
  console.log('🚀 Path:', url.pathname)
  console.log('🚀 ========================================')

  // ✅ MANEJAR OPTIONS (CORS PREFLIGHT)
  if (req.method === 'OPTIONS') {
    console.log('✅ Respondiendo a CORS preflight')
    return new Response('ok', { 
      status: 204,
      headers: corsHeaders 
    })
  }

  // ✅ ENDPOINT GET PARA CHECK STATUS (usado por GitHub Pages)
  if (req.method === 'GET' && url.pathname.includes('/check-status')) {
    console.log('📊 ENDPOINT: CHECK STATUS')
    
    const sessionId = url.searchParams.get('session_id')
    
    if (!sessionId) {
      return new Response(
        JSON.stringify({ error: 'Missing session_id parameter' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    try {
      const supabaseClient = createClient(
        Deno.env.get('SUPABASE_URL') ?? '',
        Deno.env.get('SERVICE_ROLE_KEY') ?? ''
      )

      const { data, error } = await supabaseClient
        .from('identity_verifications')
        .select('session_id, status, verification_result, failure_reason, completed_at')
        .eq('session_id', sessionId)
        .single()

      if (error) {
        return new Response(
          JSON.stringify({ error: 'Session not found', session_id: sessionId }),
          { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      console.log('✅ Sesión encontrada:', data.status)

      return new Response(
        JSON.stringify(data),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )

    } catch (error) {
      console.error('💥 Error en check-status:', error)
      return new Response(
        JSON.stringify({ error: error.message }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }
  }

  // ✅ SOLO ACEPTAR POST PARA WEBHOOK Y CREATE_SESSION
  if (req.method !== 'POST') {
    console.log('❌ Método no permitido:', req.method)
    return new Response(
      JSON.stringify({ error: `Método ${req.method} no permitido. Use POST` }),
      { status: 405, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }

  // ✅ LEER BODY
  let requestBody: any = {}
  
  try {
    const bodyText = await req.text()
    console.log('📥 Body recibido:', bodyText)
    
    if (bodyText) {
      requestBody = JSON.parse(bodyText)
    }
  } catch (parseError) {
    console.error('❌ Error parseando JSON:', parseError)
    return new Response(
      JSON.stringify({ error: 'JSON inválido' }),
      { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SERVICE_ROLE_KEY') ?? ''
    )

    console.log('🎯 Body keys:', Object.keys(requestBody))

    // ✅ 1. DETECTAR WEBHOOK DE VERIFICAMEX (por estructura del body)
    const isVerificamexWebhook = (
      requestBody.object === 'VerificationSession' ||
      (requestBody.data?.object === 'VerificationSession') ||
      (requestBody.id && requestBody.status && requestBody.result !== undefined)
    )

    if (isVerificamexWebhook) {
      console.log('📨 WEBHOOK DE VERIFICAMEX DETECTADO')
      return await handleVerificamexWebhook(requestBody, supabaseClient)
    }

    // ✅ 2. DETECTAR CREATE_SESSION
    const isCreateSession = (
      requestBody.action === 'create_session' &&
      requestBody.user_id &&
      requestBody.email
    )

    if (isCreateSession) {
      console.log('🎯 CREATE_SESSION DETECTADO')
      return await createVerificationSession(requestBody, supabaseClient)
    }

    // ✅ 3. REQUEST NO RECONOCIDO
    console.log('❓ Tipo de request no reconocido')
    
    return new Response(
      JSON.stringify({ 
        error: 'Tipo de request no reconocido',
        help: 'Use: {"action":"create_session","user_id":"xxx","email":"xxx@xxx.com"}'
      }),
      { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('💥 Error general:', error)
    
    return new Response(
      JSON.stringify({ error: 'Error interno del servidor' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})

// ========================================
// CREATE VERIFICATION SESSION
// ========================================
async function createVerificationSession(data: any, supabaseClient: any) {
  console.log('🏗️ CREANDO SESIÓN CON VERIFICAMEX')
  
  const { user_id, email } = data
  
  if (!user_id || !email) {
    return new Response(
      JSON.stringify({ success: false, error: 'Faltan datos requeridos' }),
      { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }

  if (!VERIFICAMEX_API_TOKEN) {
    return new Response(
      JSON.stringify({ success: false, error: 'Token no configurado' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }

  try {
    const sessionId = `session_${Date.now()}_${Math.random().toString(36).substring(2, 15)}`
    console.log('🆔 Session ID:', sessionId)
    
    // ✅ CREAR REGISTRO EN BD
    await supabaseClient.from('identity_verifications').insert({
      session_id: sessionId,
      temp_user_id: user_id,
      email: email,
      status: 'pending',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    })

    // ✅ CONFIGURAR URLs
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
    const webhookUrl = `${supabaseUrl}/functions/v1/ine-validation`
    
    // ✅ USAR INTENT URL DIRECTO (como lo tienes ahora)
    const redirectUrl = `intent://verificamex/success?session_id=${sessionId}&user_id=${user_id}#Intent;scheme=dalkpaseos;package=com.dalk.app;end`
    
    console.log('🌐 Webhook:', webhookUrl)
    console.log('🔗 Redirect:', redirectUrl)

    // ✅ LLAMAR A VERIFICAMEX API
    const verificamexResponse = await fetch(VERIFICAMEX_API_URL, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${VERIFICAMEX_API_TOKEN}`,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: JSON.stringify({
        validations: ["INE", "CURP"],
        webhook: webhookUrl,
        redirect_url: redirectUrl,
        only_mobile_devices: true,
        with_webhook_binaries: true,
        customization: {
          button_color: "#0080C4",
          background_color: "#163143",
          primary_color: "#0080C4",
          secondary_color: "#CCDBFF",
          button_text_color: "#E0ECFF"
        },
        optionals: {
          session_id: sessionId,
          temp_user_id: user_id,
          email: email,
          timestamp: new Date().toISOString()
        }
      })
    })

    const responseText = await verificamexResponse.text()
    console.log('📊 Verificamex Status:', verificamexResponse.status)

    if (!verificamexResponse.ok) {
      await supabaseClient
        .from('identity_verifications')
        .update({
          status: 'failed',
          failure_reason: `API Error: ${verificamexResponse.status}`,
          updated_at: new Date().toISOString()
        })
        .eq('session_id', sessionId)

      return new Response(
        JSON.stringify({ success: false, error: 'Error del servicio de verificación' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const verificamexData = JSON.parse(responseText)
    const sessionData = verificamexData.data || verificamexData
    const formUrl = sessionData.form_url || verificamexData.form_url
    const verificamexId = sessionData.id || verificamexData.id

    if (!formUrl) {
      return new Response(
        JSON.stringify({ success: false, error: 'No se obtuvo URL de verificación' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // ✅ ACTUALIZAR BD
    await supabaseClient
      .from('identity_verifications')
      .update({
        verificamex_session_id: verificamexId,
        verification_data: verificamexData,
        updated_at: new Date().toISOString()
      })
      .eq('session_id', sessionId)

    console.log('✅ Sesión creada exitosamente')

    return new Response(
      JSON.stringify({
        success: true,
        session_id: sessionId,
        form_url: formUrl,
        verificamex_session_id: verificamexId,
        message: 'Sesión creada exitosamente'
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('💥 Error:', error)
    
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
}

// ========================================
// HANDLE VERIFICAMEX WEBHOOK
// ========================================
async function handleVerificamexWebhook(webhookData: any, supabaseClient: any) {
  console.log('📨 PROCESANDO WEBHOOK DE VERIFICAMEX')
  console.log('📦 Data:', JSON.stringify(webhookData, null, 2))
  
  // ✅ EXTRAER DATOS (según estructura de Verificamex)
  let verificamexSessionId, status, result, ine, renapo, optionals;
  
  if (webhookData.data) {
    // Estructura: { data: { object: "VerificationSession", ... } }
    const sessionData = webhookData.data
    verificamexSessionId = sessionData.id
    status = sessionData.status
    result = sessionData.result
    ine = webhookData.meta?.include?.includes('ine') ? webhookData.ine : null
    renapo = webhookData.meta?.include?.includes('renapo') ? webhookData.renapo : null
    optionals = sessionData.optionals
  } else {
    // Estructura directa: { object: "VerificationSession", ... }
    verificamexSessionId = webhookData.id
    status = webhookData.status
    result = webhookData.result
    ine = webhookData.ine
    renapo = webhookData.renapo
    optionals = webhookData.optionals
  }
  
  console.log('🔍 Datos extraídos:')
  console.log('  ID:', verificamexSessionId)
  console.log('  Status:', status)
  console.log('  Result:', result)
  console.log('  INE Status:', ine?.data?.status)
  console.log('  RENAPO Status:', renapo?.data?.status)
  
  try {
    // ✅ BUSCAR SESIÓN EN BD
    let sessionRecord;
    
    if (verificamexSessionId) {
      const { data } = await supabaseClient
        .from('identity_verifications')
        .select('*')
        .eq('verificamex_session_id', verificamexSessionId)
        .maybeSingle()
      
      if (data) sessionRecord = data
    }
    
    if (!sessionRecord && optionals?.session_id) {
      const { data } = await supabaseClient
        .from('identity_verifications')
        .select('*')
        .eq('session_id', optionals.session_id)
        .maybeSingle()
      
      if (data) sessionRecord = data
    }

    if (!sessionRecord) {
      console.log('❌ Sesión no encontrada')
      return new Response(
        JSON.stringify({ error: 'Sesión no encontrada' }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    console.log('✅ Sesión encontrada:', sessionRecord.session_id)

    // ✅ DETERMINAR ÉXITO O FALLO
    const isSuccess = (
      status === 'FINISHED' &&
      result >= 90 &&
      ine?.data?.status === true &&
      renapo?.data?.status === true
    )

    const newStatus = isSuccess ? 'completed' : 'failed'
    console.log(`🎯 Resultado: ${isSuccess ? 'ÉXITO ✅' : 'FALLO ❌'}`)

    // ✅ ACTUALIZAR BD
    await supabaseClient
      .from('identity_verifications')
      .update({
        status: newStatus,
        verification_result: result,
        verification_data: webhookData,
        ine_status: ine?.data?.status || false,
        curp_status: renapo?.data?.status || false,
        failure_reason: isSuccess ? null : `Status: ${status}, Result: ${result}`,
        completed_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      })
      .eq('session_id', sessionRecord.session_id)

    console.log('✅ Webhook procesado exitosamente')

    return new Response(
      JSON.stringify({ 
        success: true, 
        status: newStatus, 
        session_id: sessionRecord.session_id 
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('💥 Error:', error)
    
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
}