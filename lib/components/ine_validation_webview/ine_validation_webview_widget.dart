import 'package:dalk/auth/supabase_auth/auth_util.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'ine_validation_webview_model.dart';
export 'ine_validation_webview_model.dart';
import 'package:dalk/auth/supabase_auth/auth_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/backend/supabase/supabase.dart';

class IneValidationWebviewWidget extends StatefulWidget {
  static const String routeName = 'ineValidationWebview';
  static const String routePath = '/ine-validation-webview';

  const IneValidationWebviewWidget({
    super.key,
    required this.formUrl,
    required this.sessionId,
  });

  final String formUrl;
  final String sessionId;

  @override
  State<IneValidationWebviewWidget> createState() => _IneValidationWebviewWidgetState();
}

class _IneValidationWebviewWidgetState extends State<IneValidationWebviewWidget> {
  late IneValidationWebviewModel _model;
  InAppWebViewController? _webViewController;
  bool _isLoading = true;
  double _progress = 0.0;
  Timer? _timeoutTimer;

  /// URL de retorno que VerificaMex abrirá al finalizar
  String get redirectUrl =>
      "https://dalk-legal-git-main-noe-ibarras-projects.vercel.app/redirect_url.html";

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => IneValidationWebviewModel());
        debugPrint('✅✅✅✅✅✅✅✅✅✅✅ userID en INE Validation en InitState: $currentUserUid');


    debugPrint('🌐 WebView inicializado con VerificaMex');
    debugPrint('🔗 URL: ${widget.formUrl}');
    debugPrint('🆔 Session ID: ${widget.sessionId}');

    // ⏰ Timeout automático a los 20 minutos
    _timeoutTimer = Timer(const Duration(minutes: 20), () {
      if (mounted) {
        debugPrint('⏰ Tiempo de espera agotado (20 minutos)');
        _closeWebView();
      }
    });
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _model.dispose();
    super.dispose();
  }

  void _closeWebView() async {
    if (!mounted) return;

    debugPrint('🔙 Cerrando WebView - Usuario canceló verificación');
    
    final userId = currentUserUid;
    debugPrint('👤 User ID a eliminar: $userId');

    // 1️⃣ CERRAR SESIÓN DE SUPABASE
    try {
      await Supabase.instance.client.auth.signOut();
      debugPrint('🔓 Sesión de Supabase cerrada');
    } catch (e) {
      debugPrint('⚠️ Error cerrando sesión: $e');
    }

    // 2️⃣ LIMPIAR CACHÉ
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      debugPrint('🗑️ Caché limpiado');
    } catch (e) {
      debugPrint('⚠️ Error limpiando caché: $e');
    }

    // 3️⃣ ELIMINAR USUARIO DE BD Y AUTH
    if (userId.isNotEmpty) {
      await _deleteUnverifiedUser(userId);
      debugPrint('🚫 Usuario eliminado completamente desde WebView');
    } else {
      debugPrint('⚠️ No se pudo obtener userId para eliminar');
    }

    // 4️⃣ CERRAR WEBVIEW Y REDIRIGIR
    if (mounted) {
      Navigator.of(context).pop(false); // Retornar false al cerrar
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes verificar tu identidad para continuar'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );

      // Esperar un momento para mostrar el SnackBar
      await Future.delayed(const Duration(milliseconds: 500));
      
      context.go('/login');
    }
  }

Future<void> _deleteUnverifiedUser(String userId) async {
    try {
      debugPrint('🗑️ Eliminando usuario no verificado: $userId');

      final response = await SupaFlow.client.functions.invoke(
        'delete-unverified-user',
        body: {'userId': userId},
      );

      if (response.status == 200) {
        debugPrint('✅ Usuario eliminado exitosamente desde WebView');
      } else {
        debugPrint('⚠️ Error eliminando usuario: ${response.data}');
      }
    } catch (e) {
      debugPrint('💥 Error llamando a delete-unverified-user: $e');
    }
  }




  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldClose = await _showCancelDialog();
        if (shouldClose == true) _closeWebView();
      },
      child: Scaffold(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).secondary,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async {
              debugPrint('🔙 Usuario presionó botón de retroceso');
              final shouldClose = await _showCancelDialog();
              if (shouldClose == true) {
                debugPrint('✅ Usuario confirmó cerrar - Ejecutando eliminación');
                _closeWebView();
              } else {
                debugPrint('❌ Usuario canceló cierre - Continúa en WebView');
              }
            },
          ),
          title: Text(
            'Verificación de Identidad',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.lexend(),
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
          ),
          centerTitle: true,
          elevation: 2.0,
        ),
        body: Column(
          children: [
            if (_progress > 0 && _progress < 1.0)
              LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  FlutterFlowTheme.of(context).primary,
                ),
              ),
            Expanded(
              child: Stack(
                children: [
                  widget.formUrl.isEmpty
                      ? _buildErrorWidget()
                      : InAppWebView(
  initialUrlRequest: URLRequest(url: WebUri(widget.formUrl)),
  initialSettings: InAppWebViewSettings(
    javaScriptEnabled: true,
    domStorageEnabled: true,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    useWideViewPort: true,
    loadWithOverviewMode: true,
    supportMultipleWindows: false,
  ),
  onWebViewCreated: (controller) {
    _webViewController = controller;
    debugPrint('✅ WebView creado exitosamente');
        debugPrint('✅✅✅✅✅✅✅✅✅✅✅ userId en WebViewCreated: $currentUserUid');

  },

  onLoadStart: (controller, url) async {

    
    if (mounted) setState(() => _isLoading = true);

    final current = url?.toString() ?? "";
    debugPrint("🔍 onLoadStart URL: $current");

    // 🔑 DETECTAR REDIRECCIÓN A VERCEL (PROCESO TERMINADO)
    if (current.contains('dalk-legal-git-main-noe-ibarras-projects.vercel.app') ||
        current.contains('redirect_url.html')) {
      debugPrint('✅ Proceso de VerificaMex completado');
      debugPrint('🔗 URL de redirect detectada: $current');
      
      final uri = Uri.parse(current);
      final userId = uri.queryParameters['user_id'];
      final sessionId = uri.queryParameters['session_id'];
      
      debugPrint('📋 User ID extraído: $userId');
      debugPrint('📋 Session ID extraído: $sessionId');
      
      // Esperar 2 segundos para que el webhook procese
      debugPrint('⏳ Esperando 2 segundos para que el webhook actualice la BD...');
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        Navigator.of(context).pop();
        
        if (userId != null && sessionId != null) {
          debugPrint('🔗 Navegando a VerificationCallbackPage');
          context.pushNamed(
            'verificationCallback',
            queryParameters: {
              'user_id': userId,
              'session_id': sessionId,
            },
          );
        } else {
          debugPrint('❌ ERROR: No se encontraron user_id o session_id en la URL');
          context.pushNamed(
            'verificationCallback',
            queryParameters: {
              'user_id': currentUserUid,
              'session_id': widget.sessionId,
            },
          );
        }
      }
      return;
    }

    // 🔑 DETECTAR DEEP LINK (por si acaso)
    if (current.startsWith('dalkpaseos://verification_callback')) {
      debugPrint('🔗 Deep link detectado en WebView: $current');
      
      final uri = Uri.parse(current);
      final userId = uri.queryParameters['user_id'];
      final sessionId = uri.queryParameters['session_id'];
      
      if (mounted) {
        Navigator.of(context).pop();
        
        if (userId != null && sessionId != null) {
          debugPrint('🔗 Navegando desde deep link');
          context.pushNamed(
            'verificationCallback',
            queryParameters: {
              'user_id': userId,
              'session_id': sessionId,
            },
          );
        }
      }
      return;
    }

    debugPrint('🌍 Permitiendo navegación: $current');
  },

  // ✅ AGREGAR ESTE CALLBACK (ERA EL QUE FALTABA)
  onLoadStop: (controller, url) async {
    if (mounted) setState(() => _isLoading = false);
    debugPrint('✅ Página cargada completamente: ${url?.toString()}');
  },

  onProgressChanged: (controller, progress) {
    if (mounted) setState(() => _progress = progress / 100.0);
  },

  onPermissionRequest: (controller, permissionRequest) async {
    return PermissionResponse(
      resources: permissionRequest.resources,
      action: PermissionResponseAction.GRANT,
    );
  },

  onReceivedError: (controller, request, error) {
    debugPrint('💥 Error en WebView: ${error.description}');
    if (mounted) setState(() => _isLoading = false);  // ✅ También ocultar en error
  },
),

                  if (_isLoading)
                    Container(
                      color: FlutterFlowTheme.of(context)
                          .primaryBackground
                          .withOpacity(0.9),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                FlutterFlowTheme.of(context).primary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Cargando VerificaMex...',
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.lexend(),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Por favor, completa tu verificación de identidad',
                              style: FlutterFlowTheme.of(context).bodySmall.override(
                                    font: GoogleFonts.lexend(),
                                    color: FlutterFlowTheme.of(context).secondaryText,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: 64, color: FlutterFlowTheme.of(context).error),
            const SizedBox(height: 24),
            Text(
              'URL de verificación no válida',
              style: FlutterFlowTheme.of(context).bodyLarge.override(
                    font: GoogleFonts.lexend(),
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'No se pudo cargar la página de verificación',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.lexend(),
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FFButtonWidget(
              onPressed: () => _closeWebView(),
              text: 'Regresar',
              options: FFButtonOptions(
                color: FlutterFlowTheme.of(context).error,
                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                      color: Colors.white,
                  font: GoogleFonts.lexend(),
                ),
                borderRadius: BorderRadius.circular(8),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showCancelDialog() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2332),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        title: Text(
          '¿Cancelar verificación?',
          style: FlutterFlowTheme.of(context).headlineSmall.override(
                font: GoogleFonts.lexend(),
                color: Colors.white,
                fontSize: 18,
              ),
        ),
        content: Text(
          'Si cancelas, no podrás completar tu registro como paseador y tu cuenta será eliminada.',
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.lexend(),
                color: Colors.white70,
              ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    debugPrint('✅ Usuario decidió continuar con la verificación');
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Continuar', style: TextStyle(color: Colors.white70)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    debugPrint('❌ Usuario confirmó cancelación de verificación');
                    Navigator.of(context).pop(true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
