import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// ✅ USAR TUS SECRETS DE SUPABASE
const VERIFICAMEX_API_URL = 'https://api.verificamex.com/identity/v2/identity/sessions'
const VERIFICAMEX_API_TOKEN = Deno.env.get('VERIFICAMEX_SECRET_KEY') ?? ''

serve(async (req) => {
  console.log('🚀 Edge Function iniciada - Método:', req.method, 'URL:', req.url)
  console.log('🔍 Headers recibidos:', Object.fromEntries(req.headers.entries()))
  
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SERVICE_ROLE_KEY') ?? ''
    )

    // ✅ LEER EL BODY UNA SOLA VEZ
    const requestBody = await req.json()
    console.log('📥 Body recibido:', requestBody)

    // 🎯 DETECTAR TIPO DE REQUEST
    const userAgent = req.headers.get('user-agent') || ''
    console.log('🔍 User-Agent:', userAgent)

    // ✅ VERIFICAR SI ES WEBHOOK DE VERIFICAMEX
    if (requestBody.id && requestBody.status !== undefined && userAgent.includes('Verificamex')) {
      console.log('📨 Webhook recibido de Verificamex')
      return await handleVerificamexWebhook(requestBody, supabaseClient)
    }

    // ✅ VERIFICAR SI ES SOLICITUD DE FLUTTER APP
    if (requestBody.action) {
      console.log('📱 Solicitud recibida desde Flutter App')
      
      if (requestBody.action === 'create_session') {
        console.log('🎯 Acción: create_session')
        return await createVerificationSession(requestBody, supabaseClient)
      } else {
        console.log('❌ Acción no reconocida:', requestBody.action)
        return new Response(
          JSON.stringify({ error: 'Acción no válida' }),
          { 
            status: 400,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' }
          }
        )
      }
    }

    // ✅ SI NO COINCIDE CON NINGÚN PATRÓN
    console.log('❓ Tipo de request no reconocido')
    return new Response(
      JSON.stringify({ error: 'Tipo de request no reconocido' }),
      { 
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )

  } catch (error) {
    console.error('💥 Error en Edge Function:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { 
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )
  }
})

async function createVerificationSession(data: any, supabaseClient: any) {
  console.log('🏗️ Iniciando createVerificationSession con datos:', data)
  
  const { user_id, email } = data
  console.log('👤 Temp User ID:', user_id, 'Email:', email)
  
  // ✅ VALIDAR DATOS DE ENTRADA
  if (!user_id || !email) {
    console.error('❌ Faltan datos requeridos: user_id o email')
    return new Response(
      JSON.stringify({ 
        success: false,
        error: 'Faltan datos requeridos: user_id o email' 
      }),
      { 
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )
  }

  // ✅ VALIDAR TOKEN DE VERIFICAMEX
  if (!VERIFICAMEX_API_TOKEN) {
    console.error('❌ VERIFICAMEX_SECRET_KEY no configurado')
    return new Response(
      JSON.stringify({ 
        success: false,
        error: 'Token de Verificamex no configurado' 
      }),
      { 
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )
  }
  
  try {
    // ✅ CREAR SESIÓN EN BASE DE DATOS LOCAL
    const sessionId = `session_${Date.now()}_${Math.random().toString(36).substring(2, 15)}`
    console.log('🆔 Session ID generado:', sessionId)
    
    const { data: verificationRecord, error: insertError } = await supabaseClient
      .from('identity_verifications')
      .insert({
        session_id: sessionId,
        temp_user_id: user_id,
        email: email,
        status: 'pending',
        created_at: new Date().toISOString()
      })
      .select()
      .single()

    if (insertError) {
      console.error('❌ Error insertando verificación:', insertError)
      return new Response(
        JSON.stringify({ 
          success: false,
          error: `Error en base de datos: ${insertError.message}` 
        }),
        { 
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    console.log('✅ Registro de verificación creado:', verificationRecord)

    // ✅ OBTENER URL REAL DE TU PROYECTO SUPABASE
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
    console.log('🔗 Supabase URL:', supabaseUrl)

    // ✅ LLAMAR A VERIFICAMEX API
    console.log('📡 Creando sesión con Verificamex...')
    
    const verificamexPayload = {
      validations: ["INE", "CURP"],
      // ✅ WEBHOOK - Verificamex enviará el resultado aquí automáticamente
      webhook: `${supabaseUrl}/functions/v1/ine-validation`,
      // ✅ REDIRECT - Para cerrar WebView después de completar
      redirect_url: `data:text/html,<script>window.close();</script>`,
      only_mobile_devices: false,
      customization: {
        button_color: "#00A8CC",
        background_color: "#1A2332"
      },
      metadata: {
        session_id: sessionId,
        temp_user_id: user_id,
        email: email
      }
    }

    console.log('📡 Payload para Verificamex:', JSON.stringify(verificamexPayload, null, 2))

    const verificamexResponse = await fetch(VERIFICAMEX_API_URL, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${VERIFICAMEX_API_TOKEN}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(verificamexPayload)
    })

    console.log('📊 Verificamex Response Status:', verificamexResponse.status)

    if (!verificamexResponse.ok) {
      const errorText = await verificamexResponse.text()
      console.error('❌ Error de Verificamex:', errorText)
      return new Response(
        JSON.stringify({ 
          success: false,
          error: `Error de Verificamex: ${verificamexResponse.status} - ${errorText}` 
        }),
        { 
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    const verificamexData = await verificamexResponse.json()
    console.log('✅ Respuesta de Verificamex:', verificamexData)

    // ✅ CORREGIR: Extraer datos correctamente
    const sessionData = verificamexData.data || verificamexData
    const formUrl = sessionData.form_url
    const verificamexId = sessionData.id

    console.log('🔍 Session Data extraído:', sessionData)
    console.log('🔗 Form URL extraído:', formUrl)
    console.log('🆔 Verificamex ID extraído:', verificamexId)

    if (!formUrl) {
      console.error('❌ No se pudo obtener form_url de Verificamex')
      return new Response(
        JSON.stringify({ 
          success: false,
          error: 'No se pudo obtener form_url de Verificamex' 
        }),
        { 
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    // ✅ ACTUALIZAR SESIÓN CON ID DE VERIFICAMEX
    const { error: updateError } = await supabaseClient
      .from('identity_verifications')
      .update({
        verificamex_session_id: verificamexId,
        verification_data: verificamexData
      })
      .eq('session_id', sessionId)

    if (updateError) {
      console.error('❌ Error actualizando sesión:', updateError)
    }

    // ✅ RESPUESTA CORREGIDA
    const response = {
      success: true,
      session_id: sessionId,
      form_url: formUrl,  // ✅ USAR LA VARIABLE EXTRAÍDA
      verificamex_session_id: verificamexId,  // ✅ USAR LA VARIABLE EXTRAÍDA
      message: 'Sesión de verificación creada exitosamente'
    }

    console.log('✅ Respuesta final que se enviará:', response)

    return new Response(
      JSON.stringify(response),
      { 
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )

  } catch (error) {
    console.error('💥 Error en createVerificationSession:', error)
    return new Response(
      JSON.stringify({ 
        success: false,
        error: error.message 
      }),
      { 
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )
  }
}

async function handleVerificamexWebhook(webhookData: any, supabaseClient: any) {
  console.log('🔄 Procesando webhook de Verificamex:', webhookData)
  
  // ✅ CORREGIR: Acceder a los datos correctamente
  const sessionData = webhookData.data || webhookData
  const verificamexSessionId = sessionData.id
  const status = sessionData.status
  const result = sessionData.result
  const ine = sessionData.ine
  const renapo = sessionData.renapo || sessionData.curp  // Puede ser 'curp' en lugar de 'renapo'
  const metadata = sessionData.metadata

  console.log('🔍 Datos extraídos del webhook:')
  console.log('  🆔 Session ID:', verificamexSessionId)
  console.log('  📊 Status:', status)
  console.log('  🎯 Result:', result)
  console.log('  📄 INE:', ine)
  console.log('  📝 RENAPO/CURP:', renapo)
  
  try {
    // ✅ BUSCAR SESIÓN POR VERIFICAMEX SESSION ID
    const { data: sessionRecord, error: findError } = await supabaseClient
      .from('identity_verifications')
      .select('*')
      .eq('verificamex_session_id', verificamexSessionId)
      .single()

    if (findError || !sessionRecord) {
      console.error('❌ Sesión no encontrada:', verificamexSessionId)
      return new Response(
        JSON.stringify({ error: 'Sesión no encontrada' }),
        { 
          status: 404,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    console.log('📋 Sesión encontrada:', sessionRecord)

    // ✅ DETERMINAR SI LA VERIFICACIÓN FUE EXITOSA
    const isVerificationSuccessful = (
      status === 'FINISHED' &&
      result === 100 &&
      ine?.status === true &&
      (renapo?.status === true || renapo?.valid === true)  // Verificar ambas propiedades
    )

    const newStatus = isVerificationSuccessful ? 'completed' : 'failed'
    const failureReason = !isVerificationSuccessful ? 
      `Status: ${status}, Result: ${result}, INE: ${ine?.status}, RENAPO/CURP: ${renapo?.status || renapo?.valid}` : 
      null

    console.log(`🎯 Verificación ${isVerificationSuccessful ? 'EXITOSA' : 'FALLIDA'}`)
    console.log(`📊 Nuevo status: ${newStatus}`)

    // ✅ ACTUALIZAR ESTADO DE VERIFICACIÓN
    const { error: updateError } = await supabaseClient
      .from('identity_verifications')
      .update({
        status: newStatus,
        verification_result: result,
        verification_data: webhookData,
        ine_status: ine?.status || false,
        curp_status: renapo?.status || renapo?.valid || false,
        failure_reason: failureReason,
        completed_at: new Date().toISOString()
      })
      .eq('session_id', sessionRecord.session_id)

    if (updateError) {
      console.error('❌ Error actualizando verificación:', updateError)
      return new Response(
        JSON.stringify({ error: updateError.message }),
        { 
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    console.log(`✅ Verificación ${newStatus} para sesión:`, sessionRecord.session_id)

    return new Response(
      JSON.stringify({ success: true, status: newStatus }),
      { 
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )

  } catch (error) {
    console.error('💥 Error en handleVerificamexWebhook:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { 
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )
  }
}