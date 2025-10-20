import 'package:dalk/dog_walker/home_dog_walker/home_dog_walker_widget.dart';

import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'redirect_verificamex_model.dart';
export 'redirect_verificamex_model.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:go_router/go_router.dart';

/// Added fallback constants to avoid undefined reference to FFAppConstants.
class FFAppConstants {
  static const bool isDevelopment = !kReleaseMode;
}

class RedirectVerificamexWidget extends StatefulWidget {
  const RedirectVerificamexWidget({
    super.key,
    required this.sessionId,
    required this.userId,
    required this.accessToken,
  });

  final String sessionId;
  final String userId;
  final String accessToken;

  static const String routeName = 'redirect_verificamex';
  static const String routePath = '/redirect_verificamex';

  @override
  State<RedirectVerificamexWidget> createState() =>
      _RedirectVerificamexWidgetState();
}

class _RedirectVerificamexWidgetState
    extends State<RedirectVerificamexWidget> {
  late RedirectVerificamexModel _model;
  Timer? _pollingTimer;
  int _pollingAttempts = 0;
  static const int _maxPollingAttempts = 120; // 10 minutos (cada 5 segundos)

  final scaffoldKey = GlobalKey<ScaffoldState>();

@override
void initState() {
  super.initState();
  _model = createModel(context, () => RedirectVerificamexModel());

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    debugPrint('🔑 ========================================');
    debugPrint('🔑 INICIO DE RESTAURACIÓN DE SESIÓN');
    debugPrint('🔑 ========================================');
    
    // 🔑 OBTENER TOKEN CON PRIORIDAD
    String tokenToUse = widget.accessToken;
    
    debugPrint('📊 Información Inicial:');
    debugPrint('   Session ID: ${widget.sessionId}');
    debugPrint('   User ID: ${widget.userId}');
    debugPrint('   widget.accessToken presente: ${widget.accessToken.isNotEmpty}');
    debugPrint('   widget.accessToken length: ${widget.accessToken.length}');
    
    // Intentar obtener del Deep Link como segunda fuente
    final deepLinkUrl = Uri.base.toString();
    debugPrint('📱 Deep Link URL: $deepLinkUrl');
    
    final deepLinkAccessToken = Uri.parse(deepLinkUrl).queryParameters['access_token'];
    
    debugPrint('📊 Fuentes de Token:');
    debugPrint('   1️⃣ Token del widget: ${widget.accessToken.isEmpty ? "❌ VACÍO" : "✅ Presente (${widget.accessToken.length} chars)"}');
    debugPrint('   2️⃣ Token del Deep Link: ${deepLinkAccessToken?.isEmpty ?? true ? "❌ VACÍO" : "✅ Presente (${deepLinkAccessToken?.length} chars)"}');
    
    // Si el widget.accessToken está vacío, usar el del deep link
    if (tokenToUse.isEmpty && deepLinkAccessToken != null && deepLinkAccessToken.isNotEmpty) {
      debugPrint('⚠️ widget.accessToken vacío, usando token del Deep Link');
      tokenToUse = deepLinkAccessToken;
    }
    
    debugPrint('🎯 Token Final Seleccionado:');
    debugPrint('   Fuente: ${tokenToUse == widget.accessToken ? "Widget" : "Deep Link"}');
    debugPrint('   Presente: ${tokenToUse.isNotEmpty ? "✅ SÍ" : "❌ NO"}');
    debugPrint('   Length: ${tokenToUse.length}');
    
    if (tokenToUse.isNotEmpty) {
      debugPrint('   Preview: ${tokenToUse.substring(0, min(30, tokenToUse.length))}...');
    }

    // 🔑 VALIDAR QUE HAYA TOKEN
    if (tokenToUse.isEmpty) {
      debugPrint('❌ ========================================');
      debugPrint('❌ ERROR CRÍTICO: NO HAY ACCESS TOKEN');
      debugPrint('❌ ========================================');
      debugPrint('❌ No se puede restaurar la sesión sin token');
      debugPrint('❌ El usuario quedará sin autenticar');
      debugPrint('❌ El polling fallará al intentar actualizar la BD');
      debugPrint('❌ ========================================');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error crítico: No se pudo restaurar la sesión de autenticación.\nPor favor, contacta a soporte.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 10),
          ),
        );
      }
      
      // NO iniciar polling sin sesión - mostrar error y regresar
      await Future.delayed(const Duration(seconds: 3));
      
      if (mounted) {
        await _handleFailure(
          'No se pudo restaurar la sesión de autenticación. Token no disponible.',
          true, // Eliminar usuario
        );
      }
      
      return;
    }

    // 🔑 RESTAURAR SESIÓN CON SUPABASE
    try {
      debugPrint('🔄 ========================================');
      debugPrint('🔄 RESTAURANDO SESIÓN CON SUPABASE');
      debugPrint('🔄 ========================================');
      debugPrint('🔄 Llamando a Supabase.auth.setSession()...');
      debugPrint('🔄 Token length: ${tokenToUse.length}');
      
      final sessionResponse = await Supabase.instance.client.auth.setSession(tokenToUse);

      if (sessionResponse.session != null) {
        debugPrint('✅ ========================================');
        debugPrint('✅ SESIÓN RESTAURADA EXITOSAMENTE');
        debugPrint('✅ ========================================');
        debugPrint('✅ User ID: ${sessionResponse.session!.user.id}');
        debugPrint('✅ Email: ${sessionResponse.session!.user.email}');
        debugPrint('✅ Access Token presente: ${sessionResponse.session!.accessToken.isNotEmpty}');
        debugPrint('✅ Access Token length: ${sessionResponse.session!.accessToken.length}');
        
        // Esperar a que el AuthManager se actualice
        await Future.delayed(const Duration(milliseconds: 500));
        
        debugPrint('✅ Verificando currentUserUid...');
        debugPrint('   currentUserUid: ${currentUserUid.isEmpty ? "❌ VACÍO (PROBLEMA)" : "✅ $currentUserUid"}');
        debugPrint('   currentUserEmail: ${currentUserEmail.isEmpty ? "❌ VACÍO" : "✅ $currentUserEmail"}');
        
        if (currentUserUid.isEmpty) {
          debugPrint('⚠️ WARNING: currentUserUid aún está vacío después de restaurar sesión');
          debugPrint('⚠️ Esperando 1 segundo más...');
          await Future.delayed(const Duration(seconds: 1));
          debugPrint('   currentUserUid ahora: ${currentUserUid.isEmpty ? "❌ SIGUE VACÍO" : "✅ $currentUserUid"}');
        }
        
        debugPrint('✅ ========================================');
        
        // ✅ INICIAR POLLING SOLO SI LA SESIÓN SE RESTAURÓ
        _startPolling();
      } else {
        debugPrint('❌ ========================================');
        debugPrint('❌ FALLO AL RESTAURAR SESIÓN');
        debugPrint('❌ ========================================');
        debugPrint('❌ sessionResponse.session es NULL');
        debugPrint('❌ El token proporcionado puede ser inválido o haber expirado');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: No se pudo restaurar la sesión. Token inválido.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
          
          await _handleFailure(
            'No se pudo restaurar la sesión. El token de autenticación es inválido.',
            true,
          );
        }
      }
    } catch(e, stackTrace) {
      debugPrint('❌ ========================================');
      debugPrint('❌ EXCEPCIÓN DURANTE RESTAURACIÓN DE SESIÓN');
      debugPrint('❌ ========================================');
      debugPrint('❌ Error: $e');
      debugPrint('❌ Tipo: ${e.runtimeType}');
      debugPrint('❌ StackTrace:');
      debugPrint(stackTrace.toString());
      debugPrint('❌ ========================================');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al restaurar sesión: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
        
        await _handleFailure(
          'Error técnico al restaurar la sesión: ${e.toString()}',
          true,
        );
      }
    }
  });
}



  @override
  void dispose() {
    _pollingTimer?.cancel();
    _model.dispose();
    super.dispose();
  }

  /// ✅ GENERAR HTML EMBEBIDO CON SESSION_ID
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
  </div>
  
  <script>
    console.log('🎉 ========================================');
    console.log('🎉 USUARIO COMPLETÓ CAPTURA DE FOTOS');
    console.log('🎉 Session ID: ${widget.sessionId}');
    console.log('🎉 User ID: ${widget.userId}');
    console.log('🎉 Verificamex procesando en background...');
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
      console.log('💓 Heartbeat - esperando resultado del webhook...');
    }, 60000);
    
    console.log('🔄 WebView se mantendrá abierto hasta recibir resultado final');
  </script>
</body>
</html>
    ''';
  }

  /// ✅ INICIAR POLLING A SUPABASE
  void _startPolling() {
    debugPrint('🔄 Iniciando polling para session_id: ${widget.sessionId}');
    
    setState(() {
      _model.isPolling = true;
    });

    _pollingTimer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) async {
        _pollingAttempts++;
        
        debugPrint(
          '🔍 Polling intento $_pollingAttempts/$_maxPollingAttempts'
        );

        if (_pollingAttempts >= _maxPollingAttempts) {
          debugPrint('⏱️ Tiempo máximo de polling alcanzado');
          _stopPolling();
          _handleTimeout();
          return;
        }

        await _checkVerificationStatus();
      },
    );
  }

  /// ✅ VERIFICAR STATUS EN SUPABASE (VERSIÓN CORREGIDA)
Future<void> _checkVerificationStatus() async {
  try {
    debugPrint('🔍 === INICIO POLLING ===');
    debugPrint('🔍 Session ID: ${widget.sessionId}');
    debugPrint('🔍 User ID: ${widget.userId}');

    // ✅ Consultar registro en identity_verifications
    final iv = await SupaFlow.client
        .from('identity_verifications')
        .select('status, verification_result, failure_reason, user_uuid, updated_at')
        .eq('session_id', widget.sessionId)
        .maybeSingle();

    if (iv == null) {
      debugPrint('❌ No se encontró la sesión: ${widget.sessionId}');
      return;
    }

    final status = (iv['status'] ?? '').toString().toLowerCase();
    final result = iv['verification_result'] ?? 0;

    debugPrint('📊 === DATOS DE IDENTITY_VERIFICATIONS ===');
    debugPrint('📊 Status: $status');
    debugPrint('📊 Result: $result');
    debugPrint('📊 Updated At: ${iv['updated_at']}');
    debugPrint('📊 User UUID: ${iv['user_uuid']}');

    // ✅ Verificar si cumple condiciones de éxito
    if ((status == 'completed' || status == 'finished') && result >= 90) {
      debugPrint('✅ Verificación completada con éxito. Redirigiendo...');
      _stopPolling();
      await _handleSuccess();
      return;
    }

    // ❌ Si falló
    if (status == 'failed' || status == 'cancelled' || result < 90) {
      debugPrint('❌ Verificación fallida. Razón: ${iv['failure_reason']}');
      _stopPolling();
      await _handleFailure(iv['failure_reason']);
      return;
    }

    // ⏳ Si sigue en proceso
    if (status == 'pending' || status == 'open' || status == 'verifying') {
      debugPrint('⏳ Verificación en proceso... esperando siguiente intento');
      return;
    }

    // ⚠️ Si estado desconocido
    debugPrint('⚠️ Estado desconocido en verificación: $status');
  } catch (e, stackTrace) {
    debugPrint('💥 Error en _checkVerificationStatus: $e');
    debugPrint(stackTrace.toString());
  }
}


  /// ✅ DETENER POLLING
  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    
    setState(() {
      _model.isPolling = false;
    });
    
    debugPrint('⏹️ Polling detenido');
  }

  /// ✅ MANEJAR ÉXITO
  Future<void> _handleSuccess() async {
    debugPrint('🎉 ========================================');
    debugPrint('🎉 VERIFICACIÓN EXITOSA');
    debugPrint('🎉 ========================================');

    try {
      // ✅ ACTUALIZAR VERIFICATION_STATUS EN TABLA USERS
      debugPrint('💾 Actualizando verification_status a "verified"...');
      
      await Supabase.instance.client
          .from('users')
          .update({'verification_status': 'verified'})
          .eq('uuid', widget.userId);

      debugPrint('✅ Usuario verificado en BD');
      

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Verificación completada exitosamente!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          context.goNamed('homeDogWalker');
        }

      }
      
    } catch (e) {
      debugPrint('❌ Error actualizando usuario: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// ❌ MANEJAR FALLO (ahora con flag para borrar usuario)
  Future<void> _handleFailure(String? reason, [bool deleteUser = true]) async {
    debugPrint('❌ ========================================');
    debugPrint('❌ VERIFICACIÓN FALLIDA - deleteUser: $deleteUser');
    debugPrint('❌ Razón: $reason');
    debugPrint('❌ ========================================');

    if (!mounted) return;

    try {
      if (deleteUser) {
        debugPrint('🗑️ Eliminando usuario fallido (direcciones + users + logout)...');

        await Supabase.instance.client
            .from('addresses')
            .delete()
            .eq('uuid', widget.userId);

        await Supabase.instance.client
            .from('users')
            .delete()
            .eq('uuid', widget.userId);

        await authManager.signOut();

        debugPrint('✅ Usuario eliminado correctamente');
      } else {
        debugPrint('⚠️ No se borrará al usuario (flujo de registro existente). Solo redirigiendo a login.');
        // opcional: enviar notificación o dejar registro en DB con status rejected
        await Supabase.instance.client
            .from('users')
            .update({'verification_status': 'rejected'})
            .eq('uuid', widget.userId);
      }

      if (mounted) {
        _showErrorDialog(
          'Verificación Fallida',
          reason ?? 'No se pudo completar la verificación de identidad.\n\nPor favor, intenta nuevamente o contacta a soporte.',
        );
      }
    } catch (e) {
      debugPrint('❌ Error procesando fallo: $e');
      if (mounted) {
        _showErrorDialog('Error', 'Ocurrió un error al procesar el resultado.\nPor favor, contacta a soporte.');
      }
    }
  }

  /// ⏱️ MANEJAR TIMEOUT
  Future<void> _handleTimeout() async {
    debugPrint('⏱️ ========================================');
    debugPrint('⏱️ TIMEOUT - VERIFICACIÓN TARDANDO MUCHO');
    debugPrint('⏱️ ========================================');

    if (!mounted) return;

    // ❌ ELIMINAR USUARIO (timeout = fallo)
    try {
      await Supabase.instance.client
          .from('addresses')
          .delete()
          .eq('uuid', widget.userId);
      
      await Supabase.instance.client
          .from('users')
          .delete()
          .eq('uuid', widget.userId);
      
      await authManager.signOut();
      
    } catch (e) {
      debugPrint('❌ Error eliminando usuario en timeout: $e');
    }

    if (mounted) {
      _showErrorDialog(
        'Tiempo de Espera Agotado',
        'La verificación está tomando más tiempo del esperado.\n\n'
        'ID de sesión: ${widget.sessionId}\n\n'
        'Por favor, contacta a soporte o intenta registrarte nuevamente.',
      );
    }
  }

  /// 🚨 MOSTRAR DIÁLOGO DE ERROR
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A2332),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Text(
            title,
            style: FlutterFlowTheme.of(context).headlineSmall.override(
                  fontFamily: 'Outfit',
                  color: Colors.white,
                ),
          ),
          content: Text(
            message,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Readex Pro',
                  color: Colors.white70,
                ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.goNamed('singInDogWalker'); // ✅ Volver al registro
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: FlutterFlowTheme.of(context).primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Volver al Registro',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              // ❌ REMOVIDO: Bloque de DEBUG INFO en producción
              /*
              if (FFAppConstants.isDevelopment)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
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
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Session ID: ${widget.sessionId}',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              fontFamily: 'Readex Pro',
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                      ),
                      // ... (resto de info de debug)
                    ],
                  ),
                ),
              */

              // ✅ HTML EMBEBIDO
              Expanded(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(),
                  child: _buildEmbeddedHtmlView(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ CONSTRUIR VISTA HTML EMBEBIDO
  Widget _buildEmbeddedHtmlView() {
    // Usar el HTML embebido directamente
    final htmlContent = _getEmbeddedHtml();

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Aquí puedes renderizar el HTML usando un paquete como flutter_html
            // o simplemente mostrar un placeholder
            // Por simplicidad, mostramos un Container con el diseño similar
            _buildCustomVerificationUI(),
          ],
        ),
      ),
    );
  }

  /// ✅ UI PERSONALIZADO (ALTERNATIVA A HTML)
  Widget _buildCustomVerificationUI() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF163143), Color(0xFF0080C4)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0080C4).withOpacity(0.3),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF163143).withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE0ECFF).withOpacity(0.2),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ ICONO DE ÉXITO
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFF0080C4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                size: 40,
                color: Color(0xFFE0ECFF),
              ),
            ),
            const SizedBox(height: 24),

            // ✅ TÍTULO
            Text(
              '¡Fotos Enviadas Exitosamente!',
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                    fontFamily: 'Outfit',
                    color: const Color(0xFFE0ECFF),
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // ✅ SUBTÍTULO
            Text(
              'Hemos recibido las fotos de tu INE y CURP.\nVerificamex está analizando tus documentos.',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Readex Pro',
                    color: const Color(0xFFCCDBFF),
                    fontSize: 16,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // ✅ LOADING SPINNER
            const SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0080C4)),
                strokeWidth: 4,
              ),
            ),
            const SizedBox(height: 24),

            // ✅ ESTADO
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0080C4).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF0080C4).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  _buildStatusRow('Estado:', 'Procesando verificación...'),
                  const SizedBox(height: 8),
                  _buildStatusRow('Tiempo estimado:', '0-4 minutos'),
                  const SizedBox(height: 8),
                  _buildStatusRow('Progreso:', _getProgressMessage()),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ✅ ADVERTENCIA
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFCCDBFF),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Importante: No cierres esta ventana.\nEl resultado se mostrará automáticamente.',
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily: 'Readex Pro',
                          color: const Color(0xFFCCDBFF),
                          fontSize: 12,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ✅ MENSAJE FINAL
            Text(
              'Esta ventana se cerrará automáticamente al completarse',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Readex Pro',
                    color: const Color(0xFF0080C4),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ CONSTRUIR FILA DE STATUS
  Widget _buildStatusRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: FlutterFlowTheme.of(context).bodySmall.override(
                fontFamily: 'Readex Pro',
                color: const Color(0xFFCCDBFF),
                fontWeight: FontWeight.bold,
              ),
        ),
        Flexible(
          child: Text(
            value,
            style: FlutterFlowTheme.of(context).bodySmall.override(
                  fontFamily: 'Readex Pro',
                  color: const Color(0xFFCCDBFF),
                ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  /// ✅ OBTENER MENSAJE DE PROGRESO DINÁMICO
  String _getProgressMessage() {
    final messages = [
      'Analizando documentos... संधि',
      'Verificando INE...',
      'Validando CURP...',
      'Comparando datos...',
      'Finalizando verificación...'
    ];

    final index = (_pollingAttempts ~/ 6) % messages.length;
    return messages[index];
  }
}
