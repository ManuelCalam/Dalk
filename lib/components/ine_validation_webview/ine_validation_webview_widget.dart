import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'ine_validation_webview_model.dart';
import 'package:url_launcher/url_launcher.dart';
export 'ine_validation_webview_model.dart';

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

    debugPrint('🌐 WebView inicializado con VerificaMex');
    debugPrint('🔗 URL: ${widget.formUrl}');
    debugPrint('🆔 Session ID: ${widget.sessionId}');

    // ⏰ Timeout automático a los 20 minutos
    _timeoutTimer = Timer(const Duration(minutes: 20), () {
      if (mounted) {
        debugPrint('⏰ Tiempo de espera agotado (20 minutos)');
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

  /// Cierra el WebView devolviendo el resultado (true = éxito, false = cancelado/timeout)
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
        if (shouldClose == true) _closeWithResult(false);
      },
      child: Scaffold(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).secondary,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async {
              final shouldClose = await _showCancelDialog();
              if (shouldClose == true) _closeWithResult(false);
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
                          },
                          onLoadStart: (controller, url) {
                            if (mounted) setState(() => _isLoading = true);
                          },
                          onLoadStop: (controller, url) async {
                            if (mounted) setState(() => _isLoading = false);
                            debugPrint('✅ Página cargada: ${url?.toString()}');
                          },
                          onProgressChanged: (controller, progress) {
                            if (mounted) setState(() => _progress = progress / 100.0);
                          },
                          shouldOverrideUrlLoading: (controller, navigationAction) async {
  final uri = navigationAction.request.url;
  
  if (uri != null) {
    final uriString = uri.toString();
    debugPrint('🌐 Navegación detectada: $uriString');

    // 🔑 DETECTAR REDIRECCIÓN A VERCEL (PROCESO TERMINADO)
    if (uriString.contains('dalk-legal-git-main-noe-ibarras-projects.vercel.app') ||
        uriString.contains('redirect_url.html')) {
      debugPrint('✅ Proceso de VerificaMex completado');
      
      // Esperar 2 segundos para que el webhook procese
      await Future.delayed(const Duration(seconds: 2));
      
      debugPrint('🔙 Cerrando WebView y retornando TRUE');
      _closeWithResult(true);
      return NavigationActionPolicy.CANCEL;
    }

    // 🔑 NO NECESITAS DETECTAR DEEP LINK AQUÍ
    // El sistema operativo lo maneja automáticamente
  }

  return NavigationActionPolicy.ALLOW;
},

                          onPermissionRequest: (controller, permissionRequest) async {
                            // 🔓 Permitir cámara y micrófono dentro del WebView
                            return PermissionResponse(
                              resources: permissionRequest.resources,
                              action: PermissionResponseAction.GRANT,
                            );
                          },
                          onReceivedError: (controller, request, error) {
                            debugPrint('💥 Error en WebView: ${error.description}');
                            if (mounted) setState(() => _isLoading = false);
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

  /// Pantalla de error si no se pasa una URL válida
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
              onPressed: () => _closeWithResult(false),
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

  /// Diálogo de confirmación al intentar cancelar
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
                  child: const Text('Continuar', style: TextStyle(color: Colors.white70)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
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