import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ine_validation_webview_model.dart';
export 'ine_validation_webview_model.dart';

class IneValidationWebviewWidget extends StatefulWidget {
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

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => IneValidationWebviewModel());
    debugPrint('🌐 InAppWebView inicializado');
    debugPrint('🔗 URL: ${widget.formUrl}');
    debugPrint('🆔 Session ID: ${widget.sessionId}');
  }

  @override
  void dispose() {
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
              fontFamily: 'Lexend',
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
            // ✅ BARRA DE PROGRESO
            if (_progress > 0 && _progress < 1.0)
              LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  FlutterFlowTheme.of(context).primary,
                ),
              ),
            
            // ✅ WEBVIEW
            Expanded(
              child: Stack(
                children: [
                  widget.formUrl.isEmpty
                    ? _buildErrorWidget()
                    : InAppWebView(
                        initialUrlRequest: URLRequest(
                          url: WebUri(widget.formUrl),
                        ),
                        
                        initialSettings: InAppWebViewSettings(
                          javaScriptEnabled: true,
                          domStorageEnabled: true,
                          databaseEnabled: true,
                          mediaPlaybackRequiresUserGesture: false,
                          allowsInlineMediaPlayback: true,
                          useWideViewPort: true,
                          loadWithOverviewMode: true,
                          supportMultipleWindows: false,
                          userAgent: 'Mozilla/5.0 (Linux; Android 11; SM-G998B) AppleWebKit/537.36',
                        ),

                        onWebViewCreated: (controller) {
                          _webViewController = controller;
                          debugPrint('✅ InAppWebView creado exitosamente');
                        },

                        onLoadStart: (controller, url) {
                          debugPrint('📥 Cargando: ${url?.toString()}');
                          if (mounted) setState(() => _isLoading = true);
                        },

                        onLoadStop: (controller, url) async {
                          debugPrint('✅ Cargado: ${url?.toString()}');
                          if (mounted) setState(() => _isLoading = false);
                        },

                        onProgressChanged: (controller, progress) {
                          if (mounted) {
                            setState(() => _progress = progress / 100.0);
                          }
                        },

                        onPermissionRequest: (controller, request) async {
                          debugPrint('🔓 Solicitud de permisos: ${request.resources}');
                          
                          return PermissionResponse(
                            resources: request.resources,
                            action: PermissionResponseAction.GRANT,
                          );
                        },

                        onReceivedError: (controller, request, error) {
                          debugPrint('💥 Error: ${error.description}');
                          if (mounted) setState(() => _isLoading = false);
                        },
                      ),

                  // ✅ LOADING OVERLAY
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
                            SizedBox(height: 24),
                            Text(
                              'Cargando verificación...',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Lexend',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
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

  // ✅ WIDGET DE ERROR
  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: FlutterFlowTheme.of(context).error,
            ),
            SizedBox(height: 24),
            Text(
              'URL de verificación no válida',
              style: FlutterFlowTheme.of(context).bodyLarge.override(
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            FFButtonWidget(
              onPressed: () => _closeWithResult(false),
              text: 'Regresar',
              options: FFButtonOptions(
                height: 44,
                padding: EdgeInsets.symmetric(horizontal: 32),
                color: FlutterFlowTheme.of(context).error,
                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                  fontFamily: 'Lexend',
                  color: Colors.white,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ DIÁLOGO DE CANCELACIÓN
  Future<bool?> _showCancelDialog() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Color(0xFF1A2332),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: Text(
          '¿Cancelar verificación?',
          style: FlutterFlowTheme.of(context).headlineSmall.override(
            fontFamily: 'Lexend',
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        content: Text(
          'Si cancelas, no podrás completar tu registro.',
          style: FlutterFlowTheme.of(context).bodyMedium.override(
            fontFamily: 'Lexend',
            color: Colors.white70,
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(
                    'Continuar',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
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