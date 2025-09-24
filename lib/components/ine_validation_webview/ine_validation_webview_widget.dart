import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ine_validation_webview_model.dart';
export 'ine_validation_webview_model.dart';

class IneValidationWebviewWidget extends StatefulWidget {
  
  static const String routeName = 'ineValidationWebview';
  static const String routePath = '/ine-validation-webview';

  const IneValidationWebviewWidget({
    super.key,
    required this.formUrl,
    required this.onValidationComplete,
    required this.onValidationFailed,
  });

  final String formUrl;
  final VoidCallback onValidationComplete;
  final VoidCallback onValidationFailed;

  @override
  State<IneValidationWebviewWidget> createState() =>
      _IneValidationWebviewWidgetState();
}

class _IneValidationWebviewWidgetState
    extends State<IneValidationWebviewWidget> {
  late IneValidationWebviewModel _model;
  late WebViewController _webViewController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => IneValidationWebviewModel());
    _initializeWebView();
    
    debugPrint('🌐 WebView inicializado con URL: ${widget.formUrl}');
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            debugPrint('📥 Cargando página: $url');
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            debugPrint('✅ Página cargada: $url');
            setState(() {
              _isLoading = false;
            });
            
            // ✅ VERIFICAR URLs DE CALLBACK SEGÚN VERIFICAMEX
            if (url.contains('verification-callback')) {
              debugPrint('🎉 Callback de verificación detectado');
              
              // Extraer session_id de la URL si está presente
              final uri = Uri.parse(url);
              final sessionId = uri.queryParameters['session_id'];
              
              if (sessionId != null) {
                debugPrint('🆔 Session ID del callback: $sessionId');
                // El webhook ya habrá actualizado el estado, solo cerramos
                widget.onValidationComplete();
              } else {
                debugPrint('❌ No se encontró session_id en callback');
                widget.onValidationFailed();
              }
            } else if (url.contains('error') || url.contains('cancelled')) {
              debugPrint('❌ Verificación cancelada o con error');
              widget.onValidationFailed();
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('🔄 Navegación solicitada: ${request.url}');
            
            // ✅ INTERCEPTAR CALLBACKS
            if (request.url.contains('verification-callback')) {
              debugPrint('🎉 Interceptando callback de éxito');
              widget.onValidationComplete();
              return NavigationDecision.prevent;
            } else if (request.url.contains('error') || 
                       request.url.contains('cancelled') ||
                       request.url.contains('failed')) {
              debugPrint('❌ Interceptando callback de error');
              widget.onValidationFailed();
              return NavigationDecision.prevent;
            }
            
            return NavigationDecision.navigate;
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('💥 Error en WebView: ${error.description}');
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.formUrl));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).secondary,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async {
              // ✅ DIALOG DE CONFIRMACIÓN MEJORADO
              final shouldClose = await showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: Color(0xFF1A2332),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    title: Row(
                      children: [
                        Icon(Icons.warning_amber, color: Colors.orange),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '¿Cancelar verificación?',
                            style: FlutterFlowTheme.of(context).headlineSmall.override(
                              font: GoogleFonts.lexend(),
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    content: Text(
                      'Si cancelas la verificación, no podrás completar tu registro como paseador y tendrás que volver a empezar.',
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
                  );
                },
              );

              if (shouldClose == true) {
                debugPrint('🚫 Usuario canceló la verificación');
                widget.onValidationFailed();
              }
            },
          ),
          title: Text(
            'Verificación de Identidad - Verificamex',
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
        body: Stack(
          children: [
            // ✅ WEBVIEW CON MANEJO DE ERRORES MEJORADO
            Container(
              width: double.infinity,
              height: double.infinity,
              child: widget.formUrl.isEmpty 
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: FlutterFlowTheme.of(context).error,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'URL de verificación no válida',
                          style: FlutterFlowTheme.of(context).bodyMedium,
                        ),
                        SizedBox(height: 16),
                        FFButtonWidget(
                          onPressed: () => widget.onValidationFailed(),
                          text: 'Regresar',
                          options: FFButtonOptions(
                            color: FlutterFlowTheme.of(context).error,
                            textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : WebViewWidget(controller: _webViewController),
            ),
            
            // ✅ LOADING INDICATOR MEJORADO
            if (_isLoading)
              Container(
                color: FlutterFlowTheme.of(context).primaryBackground,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          FlutterFlowTheme.of(context).primary,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Cargando verificación de Verificamex...',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.lexend(),
                          color: FlutterFlowTheme.of(context).primaryText,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Esto puede tardar unos segundos',
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
    );
  }
}