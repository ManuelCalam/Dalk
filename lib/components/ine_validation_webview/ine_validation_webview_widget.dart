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

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => IneValidationWebviewModel());
    debugPrint('🌐 InAppWebView inicializado');
    debugPrint('🔗 URL: ${widget.formUrl}');
    debugPrint('🆔 Session ID: ${widget.sessionId}');
    
      
    // ✅ TIMEOUT DE 15 MINUTOS
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
      Navigator.of(context).pop(success);
    }
  }

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
                          useShouldOverrideUrlLoading: true,
                        ),

                        onWebViewCreated: (controller) {
                          _webViewController = controller;
                          debugPrint('✅ InAppWebView creado exitosamente');
                          controller.addJavaScriptHandler(
                            handlerName: 'verification_success',
                            callback: (args) {
                              debugPrint('✅ Verificación exitosa detectada: ${args.first}');
                              Future.delayed(Duration(seconds: 1), () {
                                if (mounted) _closeWithResult(true);
                              });
                            },
                          );
                          
                          controller.addJavaScriptHandler(
                            handlerName: 'verification_failed',
                            callback: (args) {
                              debugPrint('❌ Verificación fallida detectada: ${args.first}');
                              Future.delayed(Duration(seconds: 1), () {
                                if (mounted) _closeWithResult(false);
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
                          
                          // ✅ SOLO LOG - NO ACTIVAR POLLING AQUÍ
                          final urlString = url?.toString() ?? '';
                          if (urlString.contains('verificamex.com/verification/')) {
                            debugPrint('📸 Usuario en página de captura de fotos');
                          }
                        },

                      
                        onProgressChanged: (controller, progress) {
                          if (mounted) setState(() => _progress = progress / 100.0);
                        },

                        onPermissionRequest: (controller, permissionRequest) async {
                          debugPrint('🔓 ========================================');
                          debugPrint('🔓 SOLICITUD DE PERMISOS DEL WEBVIEW');
                          debugPrint('🔓 Resources: ${permissionRequest.resources}');
                          debugPrint('🔓 ========================================');
                          
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
                          
                          // ✅ SOLO LOG - NO CERRAR AUTOMÁTICAMENTE POR CONSOLE MESSAGES
                          final message = consoleMessage.message.toLowerCase();
                          if (message.contains('fotos completadas')) {
                            debugPrint('📸 Fotos completadas - continuando en WebView hasta redirección');
                          }
                          if (message.contains('verificación exitosa')) {
                            debugPrint('✅ Verificación reportada como exitosa - esperando redirección');
                          }
                          // NO CERRAR WEBVIEW AQUÍ - ESPERAR DEEP LINK O WEBHOOK
                        },

                        onLoadResource: (controller, resource) {
                          final url = resource.url?.toString() ?? '';
                          debugPrint('📄 Recurso cargado: $url');
                          
                          // ❌ REMOVER DETECCIÓN AUTOMÁTICA DE CIERRE
                          // NO cerrar por data:text/html - esperar deep link específico
                        },

                        onReceivedError: (controller, request, error) {
                          debugPrint('💥 Error en WebView: ${error.description}');
                          if (mounted) setState(() => _isLoading = false);
                        },

                        shouldOverrideUrlLoading: (controller, navigationAction) async {
                          final url = navigationAction.request.url?.toString() ?? '';
                          debugPrint('🔄 Navegación interceptada: $url');
                          
                          if (url.startsWith('dalkpaseos://redirect/verificamex')) {
                            debugPrint('🎉 Deep link detectado - cerrando WebView');
                            _timeoutTimer?.cancel();
                            
                            _closeWithResult(true);
                            return NavigationActionPolicy.CANCEL;
                          }
                          
                          return NavigationActionPolicy.ALLOW;
                        },

                        
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
                              'Por favor, completa la verificación',
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
          'Si cancelas, no podrás completar tu registro.',
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
                  child: Text('Continuar', style: TextStyle(color: Colors.white70)),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Cancelar', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _isCompletionUrl(String url) {
    return url.contains('success') || 
           url.contains('complete') || 
           url.contains('callback') ||
           url.startsWith('data:text/html');
  }

  
}