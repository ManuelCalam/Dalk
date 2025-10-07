import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  console.log('🌐 ========================================')
  console.log('🌐 VERIFICAMEX REDIRECT FUNCTION - PÚBLICA')
  console.log('🌐 Timestamp:', new Date().toISOString())
  console.log('🌐 Método:', req.method)
  console.log('🌐 URL:', req.url)
  console.log('🌐 ========================================')

  // ✅ MANEJAR OPTIONS para CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // ✅ EXTRAER PARÁMETROS DE LA URL
    const url = new URL(req.url)
    const sessionId = url.searchParams.get('sessionId') || 'unknown'
    const tempUserId = url.searchParams.get('tempUserId') || ''
    const email = url.searchParams.get('email') || ''
    
    console.log('🆔 Session ID:', sessionId)
    console.log('👤 Temp User ID:', tempUserId)
    console.log('📧 Email:', email)

    // ✅ GENERAR HTML DINÁMICO CON TU BRANDING EXACTO
    const htmlContent = `<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Verificación Completada - Dalk</title>
  <style>
    body { 
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
      text-align: center; 
      padding: 40px 20px; 
      background: linear-gradient(135deg, #163143 0%, #0080C4 100%);
      color: #E0ECFF; 
      margin: 0;
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    
    .container { 
      max-width: 400px; 
      background: rgba(22, 49, 67, 0.9);
      border-radius: 20px;
      padding: 40px 30px;
      box-shadow: 0 8px 32px rgba(0, 128, 196, 0.3);
      border: 1px solid rgba(224, 236, 255, 0.2);
    }
    
    .success-icon {
      width: 80px;
      height: 80px;
      background: #0080C4;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      margin: 0 auto 24px;
      animation: pulse 2s infinite;
    }
    
    .success-icon::before {
      content: '✓';
      font-size: 40px;
      color: #E0ECFF;
      font-weight: bold;
    }
    
    .title { 
      color: #E0ECFF;
      font-size: 24px;
      font-weight: 600;
      margin-bottom: 16px;
    }
    
    .subtitle {
      color: #CCDBFF;
      font-size: 16px;
      margin-bottom: 32px;
      line-height: 1.5;
    }
    
    .loading { 
      width: 60px; 
      height: 60px; 
      border: 4px solid rgba(0, 128, 196, 0.2); 
      border-top: 4px solid #0080C4; 
      border-radius: 50%; 
      animation: spin 1s linear infinite; 
      margin: 24px auto; 
    }
    
    .status-text {
      color: #CCDBFF;
      font-size: 14px;
      margin-top: 24px;
      padding: 16px;
      background: rgba(0, 128, 196, 0.1);
      border-radius: 12px;
      border: 1px solid rgba(0, 128, 196, 0.3);
    }
    
    .warning-text {
      color: #CCDBFF;
      font-size: 12px;
      margin-top: 16px;
      opacity: 0.8;
    }
    
    @keyframes spin { 
      0% { transform: rotate(0deg); } 
      100% { transform: rotate(360deg); } 
    }
    
    @keyframes pulse {
      0%, 100% { transform: scale(1); }
      50% { transform: scale(1.05); }
    }
    
    .countdown {
      color: #0080C4;
      font-weight: bold;
      font-size: 16px;
    }

    .debug-info {
      margin-top: 20px;
      padding: 12px;
      background: rgba(0, 0, 0, 0.3);
      border-radius: 8px;
      font-size: 10px;
      opacity: 0.7;
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="success-icon"></div>
    
    <h2 class="title">¡Fotos Enviadas Exitosamente!</h2>
    
    <p class="subtitle">
      Hemos recibido las fotos de tu INE y CURP.<br>
      Verificamex está analizando tus documentos.
    </p>
    
    <div class="loading"></div>
    
    <div class="status-text">
      <strong>Estado:</strong> Procesando verificación...<br>
      <strong>Tiempo estimado:</strong> 0-4 minutos<br>
      <strong>Progreso:</strong> <span id="progress-text">Analizando documentos...</span>
    </div>
    
    <p class="warning-text">
      ⚠️ <strong>Importante:</strong> No cierres esta ventana.<br>
      El resultado se mostrará automáticamente.
    </p>
    
    <div style="margin-top: 24px;">
      <div class="countdown">
        Esta ventana se cerrará automáticamente al completarse
      </div>
    </div>

    <div class="debug-info">
      <strong>Debug:</strong><br>
      Session: ${sessionId}<br>
      Function: PUBLIC ✅<br>
      Time: ${new Date().toISOString()}
    </div>
  </div>
  
  <script>
    const sessionId = '${sessionId}';
    const tempUserId = '${tempUserId}';
    const email = '${email}';
    
    console.log('🎉 ========================================');
    console.log('🎉 USUARIO COMPLETÓ CAPTURA DE FOTOS');
    console.log('🎉 Session ID:', sessionId);
    console.log('🎉 Temp User ID:', tempUserId);
    console.log('🎉 Email:', email);
    console.log('🎉 Verificamex procesando en background...');
    console.log('🎉 ========================================');
    
    if (window.flutter_inappwebview) {
      try {
        window.flutter_inappwebview.callHandler('photos_completed', {
          session_id: sessionId,
          temp_user_id: tempUserId,
          email: email,
          status: 'photos_uploaded',
          timestamp: new Date().toISOString(),
          message: 'Fotos enviadas exitosamente'
        });
        console.log('✅ Handler de Flutter llamado exitosamente');
      } catch (e) {
        console.log('❌ Error llamando handler de Flutter:', e);
      }
    }
    
    const progressMessages = [
      'Analizando documentos...',
      'Verificando INE...',
      'Validando CURP...',
      'Comparando datos...',
      'Finalizando verificación...'
    ];
    
    let currentMessage = 0;
    const progressElement = document.getElementById('progress-text');
    
    setInterval(() => {
      currentMessage = (currentMessage + 1) % progressMessages.length;
      if (progressElement) {
        progressElement.textContent = progressMessages[currentMessage];
      }
    }, 30000);
    
    setInterval(() => {
      console.log('💓 Heartbeat - esperando resultado del webhook...');
      console.log('💓 Session:', sessionId);
    }, 60000);
    
    console.log('🔄 WebView se mantendrá abierto hasta recibir resultado final');
  </script>
</body>
</html>`

    console.log('✅ ========================================')
    console.log('✅ SIRVIENDO HTML DE CONFIRMACIÓN RENDERIZADO')
    console.log('✅ Session ID incluido:', sessionId)
    console.log('✅ Content-Type: text/html con UTF-8')
    console.log('✅ ========================================')

    // ✅ HEADERS CORRECTOS PARA RENDERIZAR HTML
    return new Response(htmlContent, {
      status: 200,
      headers: { 
        'Content-Type': 'text/html; charset=utf-8',
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        'Pragma': 'no-cache',
        'Expires': '0',
        ...corsHeaders 
      }
    })

  } catch (error) {
    console.error('💥 Error en verificamex-redirect:', error)
    
    const errorHtml = `<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Error - Dalk</title>
  <style>
    body { 
      font-family: Arial, sans-serif; 
      text-align: center; 
      padding: 50px; 
      background-color: #163143; 
      color: #E0ECFF; 
    }
    .error { color: #ff4444; }
  </style>
</head>
<body>
  <h2 class="error">Error en la verificación</h2>
  <p>Ha ocurrido un problema. Por favor, inténtalo de nuevo.</p>
  <p style="font-size: 12px; opacity: 0.7;">Error: ${error.message}</p>
</body>
</html>`

    return new Response(errorHtml, {
      status: 500,
      headers: { 
        'Content-Type': 'text/html; charset=utf-8',
        ...corsHeaders 
      }
    })
  }
})