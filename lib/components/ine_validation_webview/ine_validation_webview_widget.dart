import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/backend/supabase/supabase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'ine_validation_webview_model.dart';
export 'ine_validation_webview_model.dart';
import 'dart:math';
import '/auth/supabase_auth/auth_util.dart';
import 'package:permission_handler/permission_handler.dart';


class IneValidationWebviewWidget extends StatefulWidget {
  static const String routeName = 'ineValidationWebview';
  static const String routePath = '/ine-validation-webview';

  const IneValidationWebviewWidget({
    super.key,
    required this.formUrl,
    required this.sessionId,
    required this.accessToken, 
  });

  final String formUrl;
  final String sessionId;
  final String accessToken;

  @override
  State<IneValidationWebviewWidget> createState() => _IneValidationWebviewWidgetState();
}

class _IneValidationWebviewWidgetState extends State<IneValidationWebviewWidget> {
  late IneValidationWebviewModel _model;
  InAppWebViewController? _webViewController;
  bool _isLoading = true;
  double _progress = 0.0;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => IneValidationWebviewModel());
    
    debugPrint('🌐 InAppWebView inicializado');
    debugPrint('🔗 URL: ${widget.formUrl}');
    debugPrint('🆔 Session ID: ${widget.sessionId}');
    debugPrint('🔑 Access Token length: ${widget.accessToken.length}');
    
    // ✅ TIMEOUT DE 20 MINUTOS
    _timeoutTimer = Timer(Duration(minutes: 20), () {
      if (mounted) {
        debugPrint('⏰ Timeout alcanzado');
        _closeWithResult(false);
      }
    });
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _model.dispose();
    super.dispose();
  }

  void _closeWithResult(bool success) {
  debugPrint('🔚 Cerrando WebView con resultado: $success');
  if (mounted) {
    // 🔑 CORRECCIÓN: Usar pop con el resultado directamente
    Navigator.of(context).pop(success);
  }
}

// Removed stray onLoadStop handler (duplicate) that was outside the widget tree.
// The WebView's onLoadStop handler is already defined inside the InAppWebView below.

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldClose = await _showCancelDialog();
        if (shouldClose == true) {
          _closeWithResult(false);
        }
      },
      child: Scaffold(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).secondary,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async {
              final shouldClose = await _showCancelDialog();
              if (shouldClose == true) {
                _closeWithResult(false);
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
                valueColor: AlwaysStoppedAnimation<Color>(FlutterFlowTheme.of(context).primary),
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
                          databaseEnabled: true,
                          mediaPlaybackRequiresUserGesture: false,
                          allowsInlineMediaPlayback: true,
                          useWideViewPort: true,
                          loadWithOverviewMode: true,
                          supportMultipleWindows: false,
                          userAgent: 'Mozilla/5.0 (Linux; Android 11; SM-G998B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.164 Mobile Safari/537.36',
                          useShouldOverrideUrlLoading: false, // 🔑 DESACTIVADO - ya no interceptamos URLs
                        ),

                        onWebViewCreated: (controller) {
                          _webViewController = controller;
                          debugPrint('✅ InAppWebView creado exitosamente');
                          
                          // 🔑 MANEJADORES JAVASCRIPT PARA COMUNICACIÓN CON VERIFICAMEX
                          controller.addJavaScriptHandler(
                            handlerName: 'verification_success',
                            callback: (args) {
                              debugPrint('✅ Verificación exitosa detectada via JavaScript');
                              _timeoutTimer?.cancel();
                              Future.delayed(Duration(seconds: 1), () {
                                if (mounted) _closeWithResult(true);
                              });
                            },
                          );
                          
                          controller.addJavaScriptHandler(
                            handlerName: 'verification_failed',
                            callback: (args) {
                              debugPrint('❌ Verificación fallida detectada via JavaScript');
                              _timeoutTimer?.cancel();
                              Future.delayed(Duration(seconds: 1), () {
                                if (mounted) _closeWithResult(false);
                              });
                            },
                          );

                          controller.addJavaScriptHandler(
                            handlerName: 'verification_completed',
                            callback: (args) {
                              debugPrint('✅ Verificación completada via JavaScript');
                              _timeoutTimer?.cancel();
                              Future.delayed(Duration(seconds: 1), () {
                                if (mounted) _closeWithResult(true);
                              });
                            },
                          );
                        },

                        onLoadStart: (controller, url) {
                          debugPrint('📥 Cargando: ${url?.toString()}');
                          if (mounted) setState(() => _isLoading = true);
                        },

                        onLoadStop: (controller, url) async {
                          debugPrint('✅ Página cargada: ${url?.toString()}');
                          if (mounted) setState(() => _isLoading = false);
                          
                          // 🔑 DETECTAR PÁGINAS DE VERIFICAMEX PARA DEBUG
                          final urlString = url?.toString() ?? '';
                          if (urlString.contains('verificamex.com/verification/')) {
                            debugPrint('📸 Usuario en página de captura de fotos');
                          }
                          
                          if (urlString.contains('success') || urlString.contains('completed')) {
                            debugPrint('✅ URL de éxito detectada');
                            _timeoutTimer?.cancel();
                            Future.delayed(Duration(seconds: 2), () {
                              if (mounted) _closeWithResult(true);
                            });
                          }
                          
                          if (urlString.contains('error') || urlString.contains('failed')) {
                            debugPrint('❌ URL de error detectada');
                            _timeoutTimer?.cancel();
                            Future.delayed(Duration(seconds: 2), () {
                              if (mounted) _closeWithResult(false);
                            });
                          }
                        },

                        onProgressChanged: (controller, progress) {
                          if (mounted) setState(() => _progress = progress / 100.0);
                        },

                        onPermissionRequest: (controller, permissionRequest) async {
                          debugPrint('🔓 SOLICITUD DE PERMISOS DEL WEBVIEW');
                          debugPrint('🔓 Resources: ${permissionRequest.resources}');
                          
                          final grantedResources = <PermissionResourceType>[];
                          
                          for (final resource in permissionRequest.resources) {
                            if (resource == PermissionResourceType.CAMERA) {
                              debugPrint('✅ CONCEDIENDO permiso de CÁMARA');
                              grantedResources.add(resource);
                            } else if (resource == PermissionResourceType.MICROPHONE) {
                              debugPrint('✅ CONCEDIENDO permiso de MICRÓFONO');
                              grantedResources.add(resource);
                            } else {
                              debugPrint('✅ CONCEDIENDO permiso: $resource');
                              grantedResources.add(resource);
                            }
                          }
                          
                          return PermissionResponse(
                            resources: grantedResources,
                            action: PermissionResponseAction.GRANT,
                          );
                        },

                        onConsoleMessage: (controller, consoleMessage) {
                          debugPrint('🖥️ Console WebView: ${consoleMessage.message}');
                          
                          // 🔑 DETECTAR MENSAJES DE CONSOLA PARA VERIFICACIÓN
                          final message = consoleMessage.message.toLowerCase();
                          if (message.contains('verification_success') || 
                              message.contains('verificación exitosa') ||
                              message.contains('completed')) {
                            debugPrint('✅ Verificación exitosa detectada en consola');
                            _timeoutTimer?.cancel();
                            Future.delayed(Duration(seconds: 1), () {
                              if (mounted) _closeWithResult(true);
                            });
                          }
                          
                          if (message.contains('verification_failed') || 
                              message.contains('verificación fallida') ||
                              message.contains('error')) {
                            debugPrint('❌ Verificación fallida detectada en consola');
                            _timeoutTimer?.cancel();
                            Future.delayed(Duration(seconds: 1), () {
                              if (mounted) _closeWithResult(false);
                            });
                          }
                        },

                        onReceivedError: (controller, request, error) {
                          debugPrint('💥 Error en WebView: ${error.description}');
                          if (mounted) setState(() => _isLoading = false);
                        },

                        // 🔑 ELIMINADA LA LÓGICA DE INTERCEPTACIÓN DE DEEP LINKS
                        // Ya no usamos shouldOverrideUrlLoading
                      ),

                  if (_isLoading)
                    Container(
                      color: FlutterFlowTheme.of(context).primaryBackground.withOpacity(0.9),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(FlutterFlowTheme.of(context).primary),
                            ),
                            SizedBox(height: 24),
                            Text(
                              'Cargando verificación...',
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                font: GoogleFonts.lexend(),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Por favor, completa la verificación en VerificaMex',
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
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: FlutterFlowTheme.of(context).error),
            SizedBox(height: 24),
            Text(
              'URL de verificación no válida',
              style: FlutterFlowTheme.of(context).bodyLarge.override(
                font: GoogleFonts.lexend(),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'No se pudo cargar la página de verificación',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.lexend(),
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            FFButtonWidget(
              onPressed: () => _closeWithResult(false),
              text: 'Regresar',
              options: FFButtonOptions(
                color: FlutterFlowTheme.of(context).error,
                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                  color: Colors.white,
                  font: GoogleFonts.lexend(),
                ),
                borderRadius: BorderRadius.circular(8),
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
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
        backgroundColor: Color(0xFF1A2332),
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
          'Si cancelas, no podrás completar tu registro como paseador.',
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
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Continuar',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}