import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// ✅ OBTENER SECRETS
const VERIFICAMEX_API_URL = 'https://api.verificamex.com/identity/v2/identity/sessions'
const VERIFICAMEX_SECRET_KEY = Deno.env.get('VERIFICAMEX_SECRET_KEY')
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')
const SERVICE_ROLE_KEY = Deno.env.get('SERVICE_ROLE_KEY')
const SUPABASE_ANON_KEY = Deno.env.get('SUPABASE_ANON_KEY')

// ✅ VALIDAR QUE LAS SECRETS EXISTAN
if (!VERIFICAMEX_SECRET_KEY) {
  console.error('❌ VERIFICAMEX_SECRET_KEY no configurada')
}
if (!SUPABASE_URL) {
  console.error('❌ SUPABASE_URL no configurada')
}
if (!SERVICE_ROLE_KEY) {
  console.error('❌ SERVICE_ROLE_KEY no configurada')
}
if (!SUPABASE_ANON_KEY) {
  console.error('❌ SUPABASE_ANON_KEY no configurada')
}

serve(async (req) => {
  // ✅ MANEJAR OPTIONS (CORS)
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const body = await req.json()
    
    console.log('📥 ========================================')
    console.log('📥 REQUEST RECIBIDO')
    console.log('📥 Method:', req.method)
    console.log('📥 Headers:', Object.fromEntries(req.headers))
    console.log('📥 Body:', JSON.stringify(body, null, 2))
    console.log('📥 ========================================')

    // ✅ DETECTAR SI ES WEBHOOK (sin Authorization header)
    const authHeader = req.headers.get('authorization')
    const isWebhook = !authHeader && body.data?.id

    console.log('🔍 Tipo de request:', isWebhook ? 'WEBHOOK' : 'CREATE_SESSION')
    console.log('🔍 Authorization header presente:', !!authHeader)

    // ✅ CREAR CLIENTE SUPABASE (siempre con SERVICE_ROLE_KEY para permisos completos)
    const supabase = createClient(SUPABASE_URL!, SERVICE_ROLE_KEY!)

    // ✅ ========================================
    // ✅ RUTA 1: CREAR SESIÓN (desde Flutter)
    // ✅ ========================================
    if (body.action === 'create_session') {
      console.log('🆕 ACCIÓN: CREAR SESIÓN DE VERIFICACIÓN')
      
      // ✅ VALIDAR AUTHORIZATION HEADER
      if (!authHeader) {
        console.error('❌ No hay Authorization header para crear sesión')
        return new Response(
          JSON.stringify({ 
            success: false,
            error: 'Missing authorization header' 
          }),
          { 
            status: 401, 
            headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
          }
        )
      }

      const { user_uuid, email } = body

      if (!user_uuid || !email) {
        throw new Error('Faltan parámetros requeridos: user_uuid y email')
      }

      console.log('🆔 User UUID:', user_uuid)
      console.log('📧 Email:', email)

      // ✅ VERIFICAR QUE EL USUARIO EXISTA
      const { data: userExists, error: userError } = await supabase
        .from('users')
        .select('uuid, verification_status')
        .eq('uuid', user_uuid)
        .single()

      if (userError || !userExists) {
        console.error('❌ Usuario no encontrado:', userError)
        throw new Error(`Usuario no encontrado: ${userError?.message || 'Sin datos'}`)
      }

      console.log('✅ Usuario encontrado:', userExists)

      // ✅ VERIFICAR SI YA EXISTE UNA VERIFICACIÓN PREVIA
      const { data: existingVerification } = await supabase
        .from('identity_verifications')
        .select('id')
        .eq('user_uuid', user_uuid)
        .single()

      if (existingVerification) {
        console.log('⚠️ Ya existe una verificación previa, eliminándola...')
        await supabase
          .from('identity_verifications')
          .delete()
          .eq('user_uuid', user_uuid)
      }

      // ✅ CREAR REGISTRO EN identity_verifications
      const { error: dbError } = await supabase
        .from('identity_verifications')
        .insert({
          user_uuid: user_uuid,
          email: email,
          status: 'pending',
        })

      if (dbError) {
        console.error('❌ Error insertando en identity_verifications:', dbError)
        throw new Error(`Error en base de datos: ${dbError.message}`)
      }

      console.log('✅ Registro creado en identity_verifications')

      // ✅ PREPARAR PAYLOAD PARA VERIFICAMEX
      const verificamexPayload = {
        validations: ["INE", "CURP"],
        redirect_url: `dalkpaseos://verificamex/${user_uuid}/PENDING`,
        webhook: `${SUPABASE_URL}/functions/v1/ine-validation`,
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
          user_uuid: user_uuid,
          email: email,
          created_at: new Date().toISOString()
        }
      }

      console.log('📡 ========================================')
      console.log('📡 LLAMANDO A VERIFICAMEX API')
      console.log('📡 URL:', VERIFICAMEX_API_URL)
      console.log('📡 Payload:', JSON.stringify(verificamexPayload, null, 2))
      console.log('📡 ========================================')

      // ✅ LLAMAR A VERIFICAMEX
      const verificamexResponse = await fetch(VERIFICAMEX_API_URL, {
        method: 'POST',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${VERIFICAMEX_SECRET_KEY}`,
        },
        body: JSON.stringify(verificamexPayload)
      })

      console.log('📊 Verificamex Status:', verificamexResponse.status)

      if (!verificamexResponse.ok) {
        const errorText = await verificamexResponse.text()
        console.error('❌ Verificamex Error:', errorText)
        throw new Error(`Verificamex error: ${verificamexResponse.status} - ${errorText}`)
      }

      const verificamexData = await verificamexResponse.json()
      console.log('✅ Verificamex Response:', JSON.stringify(verificamexData, null, 2))

      const sessionData = verificamexData.data || verificamexData
      const sessionId = sessionData.id
      const formUrl = sessionData.form_url || sessionData.url

      if (!sessionId || !formUrl) {
        throw new Error('Verificamex no retornó session ID o form_url')
      }

      console.log('🆔 Session ID:', sessionId)
      console.log('🔗 Form URL:', formUrl)

      // ✅ ACTUALIZAR BD CON SESSION ID
      const { error: updateError } = await supabase
        .from('identity_verifications')
        .update({
          verificamex_session_id: sessionId,
          status: 'OPEN',
        })
        .eq('user_uuid', user_uuid)

      if (updateError) {
        console.error('⚠️ Error actualizando session_id:', updateError)
      } else {
        console.log('✅ Session ID guardado en BD')
      }

      // ✅ RETORNAR RESPUESTA
      return new Response(
        JSON.stringify({
          success: true,
          form_url: formUrl,
          session_id: sessionId,
          message: 'Sesión creada exitosamente'
        }),
        { 
          status: 200, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // ✅ ========================================
    // ✅ RUTA 2: WEBHOOK DE VERIFICAMEX (sin auth)
    // ✅ ========================================
    if (isWebhook) {
      console.log('📨 ========================================')
      console.log('📨 WEBHOOK RECIBIDO DE VERIFICAMEX')
      console.log('📨 ========================================')

      const webhookData = body
      const sessionData = webhookData.data || webhookData
      
      console.log('📊 Session Data:', JSON.stringify(sessionData, null, 2))

      const verificamexSessionId = sessionData.id
      const status = sessionData.status
      const result = sessionData.result
      const ine = sessionData.ine
      const renapo = sessionData.renapo || sessionData.curp
      const optionals = sessionData.optionals || {}

      console.log('📊 Verificamex Session ID:', verificamexSessionId)
      console.log('📊 Status:', status)
      console.log('📊 Result:', result)

      if (!verificamexSessionId) {
        throw new Error('Webhook sin session ID')
      }

      // ✅ BUSCAR REGISTRO EN BD
      const { data: verificationRecord, error: fetchError } = await supabase
        .from('identity_verifications')
        .select('*')
        .eq('verificamex_session_id', verificamexSessionId)
        .single()

      if (fetchError || !verificationRecord) {
        console.error('❌ Sesión no encontrada en BD:', fetchError)
        throw new Error('Sesión no encontrada en base de datos')
      }

      const userUuid = verificationRecord.user_uuid
      console.log('✅ Registro encontrado para user_uuid:', userUuid)

      // ✅ DETERMINAR SI LA VERIFICACIÓN FUE EXITOSA
      const isSuccess = (
        status === 'FINISHED' &&
        result >= 90 &&
        ine?.status === true &&
        (renapo?.status === true || renapo?.valid === true)
      )

      const newVerificationStatus = isSuccess ? 'verified' : 'rejected'

      console.log('🎯 Resultado:', isSuccess ? '✅ EXITOSA' : '❌ RECHAZADA')
      console.log('🎯 Nuevo status:', newVerificationStatus)

      // ✅ ACTUALIZAR identity_verifications
      await supabase
        .from('identity_verifications')
        .update({
          status: status,
          verification_result: result,
          ine_status: ine?.status || false,
          curp_status: renapo?.status || renapo?.valid || false,
          verification_data: webhookData,
          completed_at: status === 'FINISHED' ? new Date().toISOString() : null,
          updated_at: new Date().toISOString(),
        })
        .eq('verificamex_session_id', verificamexSessionId)

      console.log('✅ identity_verifications actualizado')

      // ✅ ACTUALIZAR users.verification_status
      const { error: updateUserError } = await supabase
        .from('users')
        .update({
          verification_status: newVerificationStatus,
        })
        .eq('uuid', userUuid)

      if (updateUserError) {
        console.error('❌ Error actualizando users:', updateUserError)
        throw new Error(`Error actualizando usuario: ${updateUserError.message}`)
      }

      console.log(`✅ Usuario actualizado a: ${newVerificationStatus}`)
      console.log('✅ WEBHOOK PROCESADO EXITOSAMENTE')

      return new Response(
        JSON.stringify({ 
          success: true,
          message: 'Webhook procesado correctamente',
          user_uuid: userUuid,
          verification_status: newVerificationStatus
        }),
        { 
          status: 200, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // ✅ SI NO ES NI CREATE_SESSION NI WEBHOOK
    throw new Error('Acción no reconocida')

  } catch (error) {
    console.error('💥 ========================================')
    console.error('💥 ERROR EN EDGE FUNCTION')
    console.error('💥 Error:', error.message)
    console.error('💥 Stack:', error.stack)
    console.error('💥 ========================================')
    
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
})