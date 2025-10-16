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
  // ✅ MANEJAR OPTIONS (CORS PREFLIGHT)
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders, status: 204 })
  }

  try {
    console.log('📨 ========================================')
    console.log('📨 NUEVA SOLICITUD RECIBIDA')
    console.log('📨 Método:', req.method)
    console.log('📨 ========================================')

    // ✅ INICIALIZAR SUPABASE CLIENT
    const supabaseClient = createClient(SUPABASE_URL, SERVICE_ROLE_KEY, {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
      },
    })

    // ✅ PARSEAR BODY
    let bodyText = await req.text();
    let body: any = {};

    try {
      body = JSON.parse(bodyText);
    } catch {
      console.warn('⚠️ No se pudo parsear JSON, body recibido como texto:', bodyText);
      body = {};
    }

    console.log('📦 Body recibido:', JSON.stringify(body, null, 2));


    // ✅ DETECTAR SI ES WEBHOOK DE VERIFICAMEX
    if (body.data && body.data.id) {
      console.log('🔔 WEBHOOK DE VERIFICAMEX DETECTADO')
      return await handleVerificamexWebhook(body, supabaseClient)
    }

    // ✅ DETECTAR SI ES SOLICITUD PARA CREAR SESIÓN
    if (body.action === 'create_session') {
      console.log('🏗️ SOLICITUD PARA CREAR SESIÓN')
      return await createVerificationSession(body, supabaseClient)
    }

    // ❌ ACCIÓN NO RECONOCIDA
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

  // ✅ NO usar temp_user_id, usar user_uuid directamente
  const { user_id, email } = body

  // ✅ VALIDAR DATOS REQUERIDOS
  if (!user_id || !email) {
    console.log('❌ Faltan datos requeridos:', { user_id, email })
    return new Response(
      JSON.stringify({ success: false, error: 'Faltan user_id o email' }),
      { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }

  try {
    const sessionId = `session_${Date.now()}_${Math.random().toString(36).substring(2, 15)}`
    
    // ✅ CREAR REGISTRO EN BD (user_uuid es el UUID real del usuario)
    await supabaseClient
      .from('identity_verifications')
      .insert({
        session_id: sessionId,
        user_uuid: user_id, // ✅ CORRECTO
        email: email,
        status: 'pending',
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      })

    const redirectUrl = `https://dalk-legal-git-main-noe-ibarras-projects.vercel.app/redirect_url.html?session_id=${sessionId}&user_id=${user_id}`;

    const webhookUrl = `${SUPABASE_URL}/functions/v1/ine-validation`

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

    // ✅ LLAMAR A VERIFICAMEX API (POST)
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

    // ✅ VALIDAR RESPUESTA
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

    // ✅ PARSEAR RESPUESTA
    const verificamexData = JSON.parse(responseText)
    const sessionData = verificamexData.data || verificamexData
    const formUrl = sessionData.form_url
    const verificamexSessionId = sessionData.id

    if (!formUrl) {
      throw new Error('No se obtuvo form_url de Verificamex')
    }

    console.log('✅ Verificamex Session creada:')
    console.log('  - ID:', verificamexSessionId)
    console.log('  - Form URL:', formUrl)

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

    // ✅ RETORNAR RESPUESTA A FLUTTER
    return new Response(
      JSON.stringify({
        success: true,
        session_id: sessionId,
        form_url: formUrl,
        verificamex_session_id: verificamexSessionId,
        redirect_url: redirectUrl,
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
  const status = webhookData.status // "OPEN", "VERIFYING", "FAILED", "FINISHED"
  const result = webhookData.result // 0-100
  const ineStatus = webhookData.ine?.data?.status || false
  const curpStatus = webhookData.renapo?.data?.status || false
  const optionals = webhookData.optionals || {}
  const errors = webhookData.errors || []

  console.log('📊 Webhook Data:')
  console.log('  - Verificamex Session ID:', verificamexSessionId)
  console.log('  - Status:', status)
  console.log('  - Result:', result)
  console.log('  - INE Status:', ineStatus)
  console.log('  - CURP Status:', curpStatus)
  console.log('  - Optionals:', optionals)

  try {
    // ✅ BUSCAR SESIÓN EN BD
    const { data: verification, error: findError } = await supabaseClient
      .from('identity_verifications')
      .select('*')
      .eq('verificamex_session_id', verificamexSessionId)
      .maybeSingle()

    if (findError || !verification) {
      console.log('❌ No se encontró sesión con verificamex_session_id:', verificamexSessionId)
      
      // ✅ INTENTAR BUSCAR POR SESSION_ID EN OPTIONALS
      const sessionId = optionals.session_id
      const userId = optionals.user_id // ✅ AGREGAR ESTA LÍNEA
      
      if (sessionId) {
        const { data: verification2, error: findError2 } = await supabaseClient
          .from('identity_verifications')
          .select('*')
          .eq('session_id', sessionId)
          .maybeSingle()

        if (findError2 || !verification2) {
          // ✅ INTENTAR BUSCAR POR USER_UUID SI TENEMOS userId
          if (userId) {
            console.log('🔍 Buscando por user_uuid:', userId)
            const { data: verification3, error: findError3 } = await supabaseClient
              .from('identity_verifications')
              .select('*')
              .eq('user_uuid', userId)
              .order('created_at', { ascending: false })
              .limit(1)
              .maybeSingle()

            if (findError3 || !verification3) {
              throw new Error('Sesión no encontrada en BD')
            }
            
            // Actualizar con verificamex_session_id
            await supabaseClient
              .from('identity_verifications')
              .update({ verificamex_session_id: verificamexSessionId })
              .eq('user_uuid', userId)
              
            console.log('✅ Sesión encontrada por user_uuid')
          } else {
            throw new Error('Sesión no encontrada')
          }
        } else {
          await supabaseClient
            .from('identity_verifications')
            .update({ verificamex_session_id: verificamexSessionId })
            .eq('session_id', sessionId)
            
          console.log('✅ Sesión encontrada por session_id')
        }
      } else {
        throw new Error('Sesión no encontrada')
      }
    }

    const sessionId = verification?.session_id || optionals.session_id
    
    // ✅ DETERMINAR RESULTADO FINAL
    let finalStatus = 'pending'
    let failureReason = null

    if (status === 'FINISHED') {
      if (result >= 90 && ineStatus && curpStatus) {
        finalStatus = 'completed'
        console.log('✅ Verificación EXITOSA')
      } else {
        finalStatus = 'failed'
        failureReason = `Verificación fallida. Result: ${result}, INE: ${ineStatus}, CURP: ${curpStatus}`
        console.log('❌ Verificación FALLIDA:', failureReason)
      }
    } else if (status === 'FAILED') {
      finalStatus = 'failed'
      failureReason = webhookData.comments || 'Verificación fallida por Verificamex'
    } else if (status === 'VERIFYING') {
      finalStatus = 'VERIFYING'
    } else if (status === 'OPEN') {
      finalStatus = 'OPEN'
    }

    // ✅ ACTUALIZAR BD
    const updateData: any = {
      status: finalStatus,
      verification_result: result,
      ine_status: ineStatus,
      curp_status: curpStatus,
      verification_data: webhookData,
      updated_at: new Date().toISOString(),
    }

    if (failureReason) {
      updateData.failure_reason = failureReason
    }

    if (finalStatus === 'completed') {
      updateData.completed_at = new Date().toISOString()
    }

    const { error: updateError } = await supabaseClient
      .from('identity_verifications')
      .update(updateData)
      .eq('session_id', sessionId)

    if (updateError) {
      throw new Error(`Error actualizando BD: ${updateError.message}`)
    }

    console.log('✅ BD actualizada exitosamente')

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