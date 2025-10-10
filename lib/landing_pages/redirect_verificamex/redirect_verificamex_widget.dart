import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'redirect_verificamex_model.dart';
export 'redirect_verificamex_model.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;

/// Added fallback constants to avoid undefined reference to FFAppConstants.
class FFAppConstants {
  static const bool isDevelopment = !kReleaseMode;
}

class RedirectVerificamexWidget extends StatefulWidget {
  const RedirectVerificamexWidget({
    super.key,
    required this.sessionId,
    required this.userId,
  });

  final String sessionId;
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
  Timer? _pollingTimer;
  int _pollingAttempts = 0;
  static const int _maxPollingAttempts = 120; // 10 minutos (cada 5 segundos)

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RedirectVerificamexModel());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startPolling();
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

  /// ✅ VERIFICAR STATUS EN SUPABASE
  Future<void> _checkVerificationStatus() async {
    try {
      final response = await SupaFlow.client
          .from('identity_verifications')
          .select('status, verification_result, failure_reason')
          .eq('session_id', widget.sessionId)
          .maybeSingle();

      if (response == null) {
        debugPrint('❌ No se encontró la sesión: ${widget.sessionId}');
        return;
      }

      final status = response['status'] as String?;
      final result = response['verification_result'] as int?;
      final failureReason = response['failure_reason'] as String?;

      debugPrint('📊 Status actual: $status (result: $result)');

      setState(() {
        _model.verificationStatus = status ?? 'pending';
      });

      // ✅ VERIFICACIÓN COMPLETADA CON ÉXITO
      if (status == 'completed' && result != null && result >= 90) {
        debugPrint('✅ Verificación exitosa (result: $result)');
        _stopPolling();
        await _handleSuccess();
        return;
      }

      // ❌ VERIFICACIÓN FALLIDA
      if (status == 'failed') {
        debugPrint('❌ Verificación fallida: $failureReason');
        _stopPolling();
        await _handleFailure(failureReason);
        return;
      }

    } catch (e) {
      debugPrint('💥 Error en polling: $e');
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
    debugPrint('🎉 Creando usuario en Supabase Auth...');

    try {
      // Crear usuario en Supabase Auth (si no existe)
      // Aquí deberías tener el email del usuario
      // Por ahora, asumimos que ya está autenticado o se maneja en otro lugar

      if (mounted) {
        // Navegar al Home del Dog Walker
        context.goNamed(
          'home_dog_walker',
          extra: <String, dynamic>{
            kTransitionInfoKey: const TransitionInfo(
              hasTransition: true,
              transitionType: PageTransitionType.fade,
              duration: Duration(milliseconds: 300),
            ),
          },
        );
      }
    } catch (e) {
      debugPrint('❌ Error al crear usuario: $e');
      _showErrorDialog('Error al crear cuenta', e.toString());
    }
  }

  /// ❌ MANEJAR FALLO
  Future<void> _handleFailure(String? reason) async {
    if (!mounted) return;

    _showErrorDialog(
      'Verificación Fallida',
      reason ?? 'No se pudo completar la verificación de identidad',
    );
  }

  /// ⏱️ MANEJAR TIMEOUT
  Future<void> _handleTimeout() async {
    if (!mounted) return;

    _showErrorDialog(
      'Tiempo de Espera Agotado',
      'La verificación está tomando más tiempo del esperado.\n\n'
      'Por favor, contacta a soporte con tu ID de sesión:\n'
      '${widget.sessionId}',
    );
  }

  /// 🚨 MOSTRAR DIÁLOGO DE ERROR
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.goNamed('sing_in_dog_walker');
              },
              child: const Text('Volver al Login'),
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
              // ✅ HEADER CON INFO DE DEBUG (solo en desarrollo)
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
                        'Polling: ${_model.isPolling ? "Activo" : "Inactivo"} ($_pollingAttempts/$_maxPollingAttempts)',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              fontFamily: 'Readex Pro',
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                      ),
                    ],
                  ),
                ),

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
      'Analizando documentos...',
      'Verificando INE...',
      'Validando CURP...',
      'Comparando datos...',
      'Finalizando verificación...'
    ];

    final index = (_pollingAttempts ~/ 6) % messages.length;
    return messages[index];
  }
}