import 'dart:async';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'redirect_verificamex_model.dart';
export 'redirect_verificamex_model.dart';

class RedirectVerificamexWidget extends StatefulWidget {
  const RedirectVerificamexWidget({
    super.key,
    required this.userId,
  });

  final String userId;

  static const String routeName = 'redirect_verificamex';
  static const String routePath = '/redirect_verificamex';

  @override
  State<RedirectVerificamexWidget> createState() =>
      _RedirectVerificamexWidgetState();
}

class _RedirectVerificamexWidgetState
    extends State<RedirectVerificamexWidget> {
  late RedirectVerificamexModel _model;
  late WebViewController _webViewController;
  Timer? _pollingTimer;
  int _pollingAttempts = 0;
  static const int _maxPollingAttempts = 100; // 5 minutos (100 x 3s)
  bool _isProcessing = false; // ✅ Evitar múltiples redirecciones

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RedirectVerificamexModel());

    debugPrint('✅ RedirectVerificamexWidget iniciado');
    debugPrint('   User ID: ${widget.userId}');

    // ✅ CONFIGURAR WEBVIEW CONTROLLER
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            debugPrint('📄 WebView cargado: $url');
          },
        ),
      )
      ..loadHtmlString(_getEmbeddedHtml());

    // ✅ INICIAR POLLING
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _model.dispose();
    super.dispose();
  }

  /// ✅ INICIAR POLLING CADA 3 SEGUNDOS
  void _startPolling() {
    debugPrint('🔄 Iniciando polling cada 3 segundos...');

    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      _pollingAttempts++;
      debugPrint('🔄 Polling intento $_pollingAttempts/$_maxPollingAttempts');

      if (_pollingAttempts >= _maxPollingAttempts) {
        // ❌ TIMEOUT (5 minutos sin respuesta)
        debugPrint('⏰ Timeout alcanzado - Sin respuesta de Verificamex');
        timer.cancel();
        await _handleTimeout();
        return;
      }

      await _checkVerificationStatus();
    });
  }

  /// ✅ CONSULTAR STATUS EN BD
  Future<void> _checkVerificationStatus() async {
    // ✅ Evitar múltiples ejecuciones simultáneas
    if (_isProcessing) {
      debugPrint('⚠️ Ya está procesando, saltando polling...');
      return;
    }

    try {
      final response = await SupaFlow.client
          .from('users')
          .select('verification_status')
          .eq('uuid', widget.userId)
          .single();

      final status = response['verification_status'] as String?;

      debugPrint('📊 verification_status actual: $status');

      if (mounted) {
        setState(() {
          _model.verificationStatus = status ?? 'pending_verification';
        });

        // ✅ ACTUALIZAR WEBVIEW CON STATUS
        _updateWebViewStatus(status ?? 'pending_verification');
      }

      // ✅ VERIFICACIÓN EXITOSA
      if (status == 'verified') {
        _isProcessing = true;
        _pollingTimer?.cancel();
        debugPrint('✅ Verificación EXITOSA - Redirigiendo al Home');
        await _handleVerificationSuccess();
      }
      // ❌ VERIFICACIÓN FALLIDA
      else if (status == 'rejected') {
        _isProcessing = true;
        _pollingTimer?.cancel();
        debugPrint('❌ Verificación FALLIDA - Eliminando usuario');
        await _handleVerificationFailed();
      }
      // ⏳ AÚN PENDIENTE
      else {
        debugPrint('⏳ Status aún es: $status - Continuando polling...');
      }
    } catch (e) {
      debugPrint('❌ Error consultando status: $e');
    }
  }

  /// ✅ ACTUALIZAR STATUS EN WEBVIEW VIA JAVASCRIPT
  void _updateWebViewStatus(String status) {
    final jsCode = '''
      const progressElement = document.getElementById('progress-text');
      const statusElement = document.getElementById('status-value');
      
      if (statusElement) {
        statusElement.textContent = '$status';
      }
      
      if (progressElement) {
        const messages = {
          'pending_verification': 'Analizando documentos...',
          'verified': '✅ Verificación exitosa',
          'rejected': '❌ Verificación rechazada',
          'expired': '⏰ Tiempo de espera agotado'
        };
        progressElement.textContent = messages['$status'] || 'Procesando...';
      }
      
      console.log('📊 Status actualizado a: $status');
    ''';

    _webViewController.runJavaScript(jsCode);
  }

  /// ✅ MANEJAR VERIFICACIÓN EXITOSA
  Future<void> _handleVerificationSuccess() async {
    if (!mounted) return;

    try {
      debugPrint('✅ Iniciando proceso de verificación exitosa...');

      // Actualizar WebView con mensaje de éxito
      await _webViewController.runJavaScript('''
        document.body.innerHTML = `
          <div style="text-align: center; padding: 60px 20px; font-family: 'Segoe UI', sans-serif;
                      background: linear-gradient(135deg, #163143 0%, #0080C4 100%);
                      min-height: 100vh; display: flex; align-items: center; justify-content: center;">
            <div style="background: rgba(22, 49, 67, 0.9); border-radius: 20px; padding: 40px 30px;
                        box-shadow: 0 8px 32px rgba(0, 128, 196, 0.3);">
              <div style="width: 100px; height: 100px; background: #4CAF50; border-radius: 50%; 
                          display: flex; align-items: center; justify-content: center; margin: 0 auto 30px;
                          animation: pulse 1s infinite;">
                <span style="font-size: 50px; color: white;">✓</span>
              </div>
              <h1 style="color: #E0ECFF; font-size: 28px; margin-bottom: 20px;">¡Verificación Exitosa!</h1>
              <p style="color: #CCDBFF; font-size: 16px; margin-bottom: 30px;">
                Tu identidad ha sido verificada correctamente.<br>
                Redirigiendo al inicio...
              </p>
            </div>
          </div>
          <style>
            @keyframes pulse {
              0%, 100% { transform: scale(1); }
              50% { transform: scale(1.1); }
            }
          </style>
        `;
      ''');

      // Esperar 2 segundos para mostrar mensaje
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      debugPrint('✅ Redirigiendo a homeDogWalker...');

      // ✅ REDIRIGIR AL HOME DEL PASEADOR
      context.pushReplacementNamed('homeDogWalker');

    } catch (e) {
      debugPrint('❌ Error en _handleVerificationSuccess: $e');
    }
  }

  /// ❌ MANEJAR VERIFICACIÓN FALLIDA
  Future<void> _handleVerificationFailed() async {
    if (!mounted) return;

    try {
      debugPrint('🗑️ Iniciando eliminación de usuario...');

      // Actualizar WebView con mensaje de error
      await _webViewController.runJavaScript('''
        document.body.innerHTML = `
          <div style="text-align: center; padding: 60px 20px; font-family: 'Segoe UI', sans-serif;
                      background: linear-gradient(135deg, #163143 0%, #0080C4 100%);
                      min-height: 100vh; display: flex; align-items: center; justify-content: center;">
            <div style="background: rgba(22, 49, 67, 0.9); border-radius: 20px; padding: 40px 30px;
                        box-shadow: 0 8px 32px rgba(0, 128, 196, 0.3);">
              <div style="width: 100px; height: 100px; background: #f44336; border-radius: 50%; 
                          display: flex; align-items: center; justify-content: center; margin: 0 auto 30px;">
                <span style="font-size: 50px; color: white;">✗</span>
              </div>
              <h1 style="color: #E0ECFF; font-size: 28px; margin-bottom: 20px;">Verificación No Exitosa</h1>
              <p style="color: #CCDBFF; font-size: 16px; margin-bottom: 30px;">
                No se pudo verificar tu identidad.<br>
                Por favor intenta nuevamente con documentos válidos.
              </p>
            </div>
          </div>
        `;
      ''');

      // Esperar 2 segundos para mostrar mensaje
      await Future.delayed(const Duration(seconds: 2));

      // ✅ 1. ELIMINAR DE users (CASCADE eliminará addresses automáticamente)
      debugPrint('🗑️ Eliminando de tabla users...');
      await SupaFlow.client.from('users').delete().eq('uuid', widget.userId);
      debugPrint('✅ Eliminado de users y addresses (CASCADE)');

      // ✅ 2. ELIMINAR DE identity_verifications
      debugPrint('🗑️ Eliminando de identity_verifications...');
      await SupaFlow.client
          .from('identity_verifications')
          .delete()
          .eq('user_uuid', widget.userId);
      debugPrint('✅ Eliminado de identity_verifications');

      // ✅ 3. ELIMINAR DE auth.users usando Admin API
      debugPrint('🗑️ Eliminando de auth.users...');
      await Supabase.instance.client.auth.admin.deleteUser(widget.userId);
      debugPrint('✅ Eliminado de auth.users');

      if (!mounted) return;

      // ✅ 4. CERRAR SESIÓN
      debugPrint('🔓 Cerrando sesión...');
      await authManager.signOut();

      if (!mounted) return;

      // ✅ 5. MOSTRAR SNACKBAR Y REDIRIGIR A LOGIN
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Verificación no exitosa. Por favor intenta nuevamente con documentos válidos.',
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );

      debugPrint('✅ Redirigiendo a signIn...');

      // ✅ REDIRIGIR AL LOGIN
      context.pushReplacementNamed('signIn');

    } catch (e) {
      debugPrint('❌ Error eliminando usuario: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );

        // Intentar redirigir al login de todas formas
        context.pushReplacementNamed('signIn');
      }
    }
  }

  /// ⏰ MANEJAR TIMEOUT
  Future<void> _handleTimeout() async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      debugPrint('⏰ Timeout - Marcando usuario como expired...');

      // Marcar como 'expired' en BD
      await SupaFlow.client
          .from('users')
          .update({'verification_status': 'expired'})
          .eq('uuid', widget.userId);

      debugPrint('✅ Usuario marcado como expired');

      // Eliminar usuario (mismo proceso que rejected)
      await _handleVerificationFailed();
    } catch (e) {
      debugPrint('❌ Error en timeout: $e');
      await _handleVerificationFailed();
    }
  }

  /// ✅ GENERAR HTML EMBEBIDO
  String _getEmbeddedHtml() {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Verificación Completada - Dalk</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
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
      <strong>Estado:</strong> <span id="status-value">Procesando verificación...</span><br>
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
  </div>
  
  <script>
    console.log('🎉 ========================================');
    console.log('🎉 USUARIO COMPLETÓ CAPTURA DE FOTOS');
    console.log('🎉 Verificamex procesando en background...');
    console.log('🎉 Esperando resultado del webhook...');
    console.log('🎉 ========================================');
    
    // ✅ ANIMACIÓN DE PROGRESO
    const progressMessages = [
      'Analizando documentos...',
      'Verificando INE...',
      'Validando CURP...',
      'Comparando datos...',
      'Finalizando verificación...'
    ];
    
    let currentMessage = 0;
    const progressElement = document.getElementById('progress-text');
    
    // Cambiar mensaje cada 30 segundos
    setInterval(() => {
      currentMessage = (currentMessage + 1) % progressMessages.length;
      if (progressElement) {
        progressElement.textContent = progressMessages[currentMessage];
      }
    }, 30000);
    
    // ✅ HEARTBEAT PARA MANTENER CONEXIÓN
    setInterval(() => {
      console.log('💓 Heartbeat - Polling activo en Flutter...');
    }, 60000); // Cada minuto
    
    console.log('🔄 Flutter está consultando BD cada 3 segundos para detectar cambios');
  </script>
</body>
</html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: const Color(0xFF163143),
          automaticallyImplyLeading: false,
          title: Text(
            'Verificación de Identidad',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Outfit',
                  color: Colors.white,
                  fontSize: 22,
                ),
          ),
          centerTitle: true,
          elevation: 2,
        ),
        body: SafeArea(
          child: Column(
            children: [
              // ✅ DEBUG INFO (solo en desarrollo)
              if (kDebugMode)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: Colors.black87,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🔧 DEBUG INFO',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Readex Pro',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'User ID: ${widget.userId}',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              fontFamily: 'Readex Pro',
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                      ),
                      Text(
                        'Status: ${_model.verificationStatus}',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              fontFamily: 'Readex Pro',
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                      ),
                      Text(
                        'Polling: $_pollingAttempts/$_maxPollingAttempts',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              fontFamily: 'Readex Pro',
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                      ),
                    ],
                  ),
                ),

              // ✅ WEBVIEW CON HTML
              Expanded(
                child: WebViewWidget(controller: _webViewController),
              ),
            ],
          ),
        ),
      ),
    );
  }
}