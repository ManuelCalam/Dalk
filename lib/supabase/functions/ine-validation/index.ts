import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

const VERIFICAMEX_API_URL = 'https://api.verificamex.com/identity/v2/identity/sessions'
const VERIFICAMEX_API_TOKEN = Deno.env.get('VERIFICAMEX_SECRET_KEY') ?? ''

serve(async (req) => {
  
  const timestamp = new Date().toISOString()
  console.log('🚀 ========================================')
  console.log('🚀 EDGE FUNCTION INICIADA')
  console.log('🚀 Timestamp:', timestamp)
  console.log('🚀 Método:', req.method)
  console.log('🚀 URL completa:', req.url)
  
  // ✅ LOGS ESPECÍFICOS PARA IDENTIFICAR TIPO DE REQUEST
  console.log('🔍 ========================================')
  console.log('🔍 ANÁLISIS DE REQUEST:')
  console.log('🔍 User-Agent:', req.headers.get('user-agent'))
  console.log('🔍 Referer:', req.headers.get('referer'))
  console.log('🔍 Content-Type:', req.headers.get('content-type'))
  console.log('🔍 Origin:', req.headers.get('origin'))
  console.log('🔍 X-Forwarded-For:', req.headers.get('x-forwarded-for'))
  console.log('🔍 ========================================')

  let bodyText = ''
  try {
    bodyText = await req.text()
    console.log('🚀 Body raw:', bodyText)
  } catch (e) {
    console.log('🚀 Sin body o error leyendo body:', e)
  }
  
  console.log('🚀 ========================================')
  
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SERVICE_ROLE_KEY') ?? ''
    )

    // ✅ PARSEAR BODY DESDE EL TEXTO
    let requestBody;
    try {
      requestBody = bodyText ? JSON.parse(bodyText) : {}
    } catch (e) {
      console.error('❌ Error parseando JSON:', e)
      return new Response(
        JSON.stringify({ error: 'JSON inválido' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }
    
    console.log('📥 Body parseado:', JSON.stringify(requestBody, null, 2))

    // ✅ OBTENER USER-AGENT DEL HEADER
    const userAgent = req.headers.get('user-agent') || ''
    console.log('🤖 User-Agent:', userAgent)

    // ✅ DETECTAR WEBHOOK DE VERIFICAMEX MEJORADO
    const isWebhook = (
      userAgent.includes('Verificamex') ||
      userAgent.includes('verificamex') ||
      userAgent.toLowerCase().includes('webhook') ||
      req.headers.get('x-webhook-source') === 'verificamex' ||
      // Estructura típica según documentación oficial
      (requestBody.object === 'VerificationSession') ||
      (requestBody.data && requestBody.data.id && requestBody.data.status !== undefined) ||
      (requestBody.id && requestBody.status !== undefined && requestBody.result !== undefined)
    )

    console.log('🔍 ¿Es webhook?', isWebhook)
    console.log('🔍 ========================================')
  console.log('🔍 DETECTANDO WEBHOOK:')
  console.log('🔍 User-Agent:', userAgent)
  console.log('🔍 Content-Type:', req.headers.get('content-type'))
  console.log('🔍 Body structure:', requestBody ? Object.keys(requestBody) : 'No body')
  console.log('🔍 Has object field:', requestBody?.object)
  console.log('🔍 Has data field:', !!requestBody?.data)
  console.log('🔍 Has id field:', !!requestBody?.id)
  console.log('🔍 Has status field:', !!requestBody?.status)
  console.log('🔍 Is webhook?', isWebhook)
  console.log('🔍 ========================================')

    if (isWebhook) {
      console.log('📨 WEBHOOK DE VERIFICAMEX DETECTADO')
      return await handleVerificamexWebhook(requestBody, supabaseClient)
    }

    // ✅ CREAR SESIÓN
    if (requestBody.action === 'create_session') {
      console.log('📱 CREANDO SESIÓN CON VERIFICAMEX')
      return await createVerificationSession(requestBody, supabaseClient)
    }

    console.log('❓ Tipo de request no reconocido')
    return new Response(
      JSON.stringify({ error: 'Tipo de request no reconocido' }),
      { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('💥 Error en Edge Function:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})

async function createVerificationSession(data: any, supabaseClient: any) {
  console.log('🏗️ ========================================')
  console.log('🏗️ CREANDO SESIÓN CON VERIFICAMEX')
  console.log('🏗️ ========================================')
  
  const { user_id, email } = data
  
  if (!user_id || !email) {
    console.error('❌ Faltan datos requeridos')
    return new Response(
      JSON.stringify({ success: false, error: 'Faltan datos requeridos' }),
      { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }

  if (!VERIFICAMEX_API_TOKEN) {
    console.error('❌ Token de Verificamex no configurado')
    return new Response(
      JSON.stringify({ success: false, error: 'Servicio de verificación no disponible' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }

  try {
    const sessionId = `session_${Date.now()}_${Math.random().toString(36).substring(2, 15)}`
    console.log('🆔 Session ID generado:', sessionId)
    
    // ✅ CREAR REGISTRO EN BD
    const { error: insertError } = await supabaseClient
      .from('identity_verifications')
      .insert({
        session_id: sessionId,
        temp_user_id: user_id,
        email: email,
        status: 'pending',
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      })

    if (insertError) {
      console.error('❌ Error insertando verificación:', insertError)
      return new Response(
        JSON.stringify({ success: false, error: insertError.message }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    console.log('✅ Registro creado en BD')

    // ✅ URL WEBHOOK CORRECTA (TU EDGE FUNCTION)
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
    const webhookUrl = `${supabaseUrl}/functions/v1/ine-validation`
    
    console.log('🌐 Webhook URL que se enviará:', webhookUrl)
    
    if (!webhookUrl.startsWith('https://')) {
      console.error('❌ URL del webhook debe ser HTTPS:', webhookUrl)
      return new Response(
        JSON.stringify({ success: false, error: 'URL del webhook inválida' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }
    
    // ✅ CAMBIAR línea ~150 para manejar éxito y fallo
    const successUrl = `dalkpaseos://verificamex/success?session_id=${sessionId}&user_id=${user_id}`;
    const failureUrl = `dalkpaseos://verificamex/failed?session_id=${sessionId}&user_id=${user_id}&reason=verification_failed`;

    const verificamexPayload = {
      validations: ["INE", "CURP"],
      webhook: webhookUrl,
      redirect_url: successUrl,  // ✅ Verificamex usa esta para éxito
      // redirect_url_failure: failureUrl,  // ✅ Si Verificamex lo soporta
      only_mobile_devices: true,
      with_webhook_binaries: true,
      customization: {
        button_color: "#0080C4",
        background_color: "#163143",
        primary_color: "#0080C4",
        secondary_color: "#CCDBFF",
        button_text_color: "#E0ECFF"
      },
      metadata: {
        session_id: sessionId,
        temp_user_id: user_id,
        email: email,
        success_url: successUrl,
        failure_url: failureUrl,
        timestamp: new Date().toISOString()
      }
    }

    console.log('📡 ========================================')
    console.log('📡 LLAMANDO A VERIFICAMEX API CON PAYLOAD COMPLETO')
    console.log('📡 URL:', VERIFICAMEX_API_URL)
    console.log('📡 Payload:', JSON.stringify(verificamexPayload, null, 2))
    console.log('📡 ========================================')

    const verificamexResponse = await fetch(VERIFICAMEX_API_URL, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${VERIFICAMEX_API_TOKEN}`,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: JSON.stringify(verificamexPayload)
    })

    const responseText = await verificamexResponse.text()
    console.log('📊 ========================================')
    console.log('📊 RESPUESTA DE VERIFICAMEX')
    console.log('📊 Status:', verificamexResponse.status)
    console.log('📊 Headers:', JSON.stringify(Object.fromEntries(verificamexResponse.headers.entries()), null, 2))
    console.log('📊 Body:', responseText)
    console.log('📊 ========================================')

    if (!verificamexResponse.ok) {
      console.error('❌ Error de Verificamex API:', responseText)
      
      await supabaseClient
        .from('identity_verifications')
        .update({
          status: 'failed',
          failure_reason: `API Error: ${verificamexResponse.status} - ${responseText}`,
          updated_at: new Date().toISOString()
        })
        .eq('session_id', sessionId)

      return new Response(
        JSON.stringify({ 
          success: false, 
          error: `Error del servicio de verificación: ${verificamexResponse.status}`,
          details: responseText,
          status_code: verificamexResponse.status
        }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    let verificamexData
    try {
      verificamexData = JSON.parse(responseText)
    } catch (e) {
      console.error('❌ Error parseando respuesta JSON:', e)
      console.error('❌ Respuesta raw:', responseText)
      return new Response(
        JSON.stringify({ success: false, error: 'Respuesta inválida de Verificamex', raw_response: responseText }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    console.log('✅ Respuesta exitosa de Verificamex:', JSON.stringify(verificamexData, null, 2))

    // ✅ EXTRAER DATOS SEGÚN DOCUMENTACIÓN OFICIAL
    const sessionData = verificamexData.data || verificamexData
    const formUrl = sessionData.form_url || verificamexData.form_url
    const verificamexId = sessionData.id || verificamexData.id

    console.log('🔍 Datos extraídos:')
    console.log('  📋 Session Data:', JSON.stringify(sessionData, null, 2))
    console.log('  🔗 Form URL:', formUrl)
    console.log('  🆔 Verificamex ID:', verificamexId)
    console.log('  📊 Object Type:', verificamexData.object)
    console.log('  📈 Status:', verificamexData.status)

    if (!formUrl) {
      console.error('❌ Verificamex no devolvió form_url')
      console.error('❌ Estructura completa recibida:', JSON.stringify(verificamexData, null, 2))
      return new Response(
        JSON.stringify({ 
          success: false, 
          error: 'No se obtuvo URL de verificación',
          received_data: verificamexData
        }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // ✅ ACTUALIZAR BD CON DATOS COMPLETOS DE VERIFICAMEX
    const { error: updateError } = await supabaseClient
      .from('identity_verifications')
      .update({
        verificamex_session_id: verificamexId,
        verification_data: verificamexData,
        updated_at: new Date().toISOString()
      })
      .eq('session_id', sessionId)

    if (updateError) {
      console.error('❌ Error actualizando sesión:', updateError)
    } else {
      console.log('✅ Sesión actualizada con datos de Verificamex')
    }

    const response = {
      success: true,
      session_id: sessionId,
      form_url: formUrl,
      verificamex_session_id: verificamexId,
      message: 'Sesión creada exitosamente con Verificamex'
    }

    console.log('✅ ========================================')
    console.log('✅ SESIÓN CREADA EXITOSAMENTE')
    console.log('✅ Response:', JSON.stringify(response, null, 2))
    console.log('✅ ========================================')

    return new Response(
      JSON.stringify(response),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('💥 Error en createVerificationSession:', error)
    
    try {
      await supabaseClient
        .from('identity_verifications')
        .update({
          status: 'failed',
          failure_reason: `System Error: ${error.message}`,
          updated_at: new Date().toISOString()
        })
        .eq('temp_user_id', data.user_id)
    } catch (dbError) {
      console.error('❌ Error adicional actualizando BD:', dbError)
    }

    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
}

// ✅ WEBHOOK HANDLER MEJORADO
async function handleVerificamexWebhook(webhookData: any, supabaseClient: any) {
  console.log('📨 ========================================')
  console.log('📨 WEBHOOK DE VERIFICAMEX DETECTADO')
  console.log('📨 Timestamp:', new Date().toISOString())
  console.log('📨 ========================================')
  
  // ✅ LOG DETALLADO DEL WEBHOOK COMPLETO
  console.log('📦 WEBHOOK DATA COMPLETO:')
  console.log(JSON.stringify(webhookData, null, 2))
  
  // ✅ VERIFICAR ESTRUCTURA SEGÚN DOCUMENTACIÓN
  let sessionData, verificamexSessionId, status, result, ine, renapo, metadata;
  
  if (webhookData.object === 'VerificationSession') {
    console.log('📋 ✅ Estructura oficial detectada: VerificationSession')
    verificamexSessionId = webhookData.id
    status = webhookData.status
    result = webhookData.result
    ine = webhookData.ine
    renapo = webhookData.renapo
    metadata = webhookData.optionals || webhookData.metadata
  } else if (webhookData.data) {
    console.log('📋 ✅ Estructura con wrapper "data" detectada')
    sessionData = webhookData.data
    verificamexSessionId = sessionData.id
    status = sessionData.status
    result = sessionData.result
    ine = sessionData.ine
    renapo = sessionData.renapo
    metadata = sessionData.metadata || sessionData.optionals
  } else {
    console.log('📋 ❌ Estructura no reconocida')
    console.log('📋 Keys disponibles:', Object.keys(webhookData))
    // Continuar con fallback
    verificamexSessionId = webhookData.id
    status = webhookData.status
    result = webhookData.result
    ine = webhookData.ine
    renapo = webhookData.renapo
    metadata = webhookData.metadata || webhookData.optionals
  }
  
  console.log('🔍 ========================================')
  console.log('🔍 DATOS EXTRAÍDOS DEL WEBHOOK:')
  console.log('🆔 Verificamex Session ID:', verificamexSessionId)
  console.log('📊 Status:', status)
  console.log('🎯 Result Score:', result)
  console.log('📄 INE Status:', ine?.status)
  console.log('📝 RENAPO Status:', renapo?.status)
  console.log('🏷️ Metadata:', JSON.stringify(metadata, null, 2))
  console.log('🔍 ========================================')
  
  try {
    // ✅ BUSCAR SESIÓN CON MÚLTIPLES CRITERIOS
    let sessionRecord;
    
    // 1. Por verificamex_session_id
    if (verificamexSessionId) {
      console.log(`🔍 Buscando por verificamex_session_id: ${verificamexSessionId}`)
      const { data: record1, error: error1 } = await supabaseClient
        .from('identity_verifications')
        .select('*')
        .eq('verificamex_session_id', verificamexSessionId)
        .maybeSingle()
      
      if (!error1 && record1) {
        sessionRecord = record1;
        console.log('✅ Sesión encontrada por verificamex_session_id')
      } else {
        console.log('❌ No encontrada por verificamex_session_id:', error1?.message)
      }
    }
    
    // 2. Por session_id en metadata
    if (!sessionRecord && metadata?.session_id) {
      console.log(`🔍 Buscando por metadata.session_id: ${metadata.session_id}`)
      const { data: record2, error: error2 } = await supabaseClient
        .from('identity_verifications')
        .select('*')
        .eq('session_id', metadata.session_id)
        .maybeSingle()
      
      if (!error2 && record2) {
        sessionRecord = record2;
        console.log('✅ Sesión encontrada por metadata.session_id')
      } else {
        console.log('❌ No encontrada por metadata.session_id:', error2?.message)
      }
    }

    // 3. Por email pendiente más reciente
    if (!sessionRecord && metadata?.email) {
      console.log(`🔍 Buscando por email pendiente: ${metadata.email}`)
      const { data: record3, error: error3 } = await supabaseClient
        .from('identity_verifications')
        .select('*')
        .eq('email', metadata.email)
        .eq('status', 'pending')
        .order('created_at', { ascending: false })
        .limit(1)
        .maybeSingle()
      
      if (!error3 && record3) {
        sessionRecord = record3;
        console.log('✅ Sesión encontrada por email')
      } else {
        console.log('❌ No encontrada por email:', error3?.message)
      }
    }

    if (!sessionRecord) {
      console.log('❌ ========================================')
      console.log('❌ SESIÓN NO ENCONTRADA EN BD')
      console.log('❌ Criterios de búsqueda usados:')
      console.log('❌   verificamex_session_id:', verificamexSessionId)
      console.log('❌   metadata.session_id:', metadata?.session_id)
      console.log('❌   metadata.email:', metadata?.email)
      console.log('❌ ========================================')
      
      // ✅ LISTAR SESIONES PENDIENTES PARA DEBUG
      const { data: pendingSessions } = await supabaseClient
        .from('identity_verifications')
        .select('session_id, verificamex_session_id, email, status, created_at')
        .eq('status', 'pending')
        .order('created_at', { ascending: false })
        .limit(10)
      
      console.log('📋 SESIONES PENDIENTES EN BD:')
      console.log(JSON.stringify(pendingSessions, null, 2))
      
      return new Response(
        JSON.stringify({ 
          error: 'Sesión no encontrada',
          debug_info: {
            searched_verificamex_id: verificamexSessionId,
            searched_session_id: metadata?.session_id,
            searched_email: metadata?.email,
            pending_sessions: pendingSessions
          }
        }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    console.log('✅ ========================================')
    console.log('✅ SESIÓN ENCONTRADA EN BD')
    console.log('✅ Session ID:', sessionRecord.session_id)
    console.log('✅ Email:', sessionRecord.email)
    console.log('✅ Status actual:', sessionRecord.status)
    console.log('✅ ========================================')

    // ✅ DETERMINAR ÉXITO SEGÚN DOCUMENTACIÓN
    const isSuccess = (
      status === 'FINISHED' &&
      result >= 90 &&
      ine?.status === true &&
      renapo?.status === true
    )

    const newStatus = isSuccess ? 'completed' : 'failed'
    const failureReason = !isSuccess ? 
      `Status: ${status}, Result: ${result}, INE: ${ine?.status}, RENAPO: ${renapo?.status}` : 
      null

    console.log('🎯 ========================================')
    console.log('🎯 RESULTADO DE VERIFICACIÓN:')
    console.log(`🎯 Éxito: ${isSuccess ? 'SÍ ✅' : 'NO ❌'}`)
    console.log(`🎯 Nuevo status: ${newStatus}`)
    console.log(`🎯 Razón (si falló): ${failureReason || 'N/A'}`)
    console.log('🎯 ========================================')

    // ✅ ACTUALIZAR BD
    const updateData = {
      status: newStatus,
      verification_result: result,
      verification_data: webhookData,
      ine_status: ine?.status || false,
      curp_status: renapo?.status || false,
      failure_reason: failureReason,
      completed_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    }

    console.log('💾 ========================================')
    console.log('💾 ACTUALIZANDO BD CON:')
    console.log(JSON.stringify(updateData, null, 2))
    console.log('💾 ========================================')

    const { error: updateError } = await supabaseClient
      .from('identity_verifications')
      .update(updateData)
      .eq('session_id', sessionRecord.session_id)

    if (updateError) {
      console.log('❌ Error actualizando BD:', updateError)
      return new Response(
        JSON.stringify({ error: updateError.message }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    console.log('✅ ========================================')
    console.log('✅ WEBHOOK PROCESADO EXITOSAMENTE')
    console.log(`✅ Sesión: ${sessionRecord.session_id}`)
    console.log(`✅ Status final: ${newStatus}`)
    console.log(`✅ Timestamp: ${new Date().toISOString()}`)
    console.log('✅ El polling detectará este cambio automáticamente')
    console.log('✅ ========================================')

    return new Response(
      JSON.stringify({ success: true, status: newStatus }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.log('💥 Error procesando webhook:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
}

