import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';


// Definimos el widget principal que recibirá las URLs.
class StripeCheckoutScreen extends StatefulWidget {
  // URL generada por el backend (la página de pago de Stripe)
  final String checkoutUrl;
  // URL que Stripe usa para redirigir si el pago es exitoso
  final String successUrl;
  // URL que Stripe usa para redirigir si el pago es cancelado
  final String cancelUrl;

  const StripeCheckoutScreen({
    Key? key,
    required this.checkoutUrl,
    required this.successUrl,
    required this.cancelUrl,
  }) : super(key: key);

  @override
  State<StripeCheckoutScreen> createState() => _StripeCheckoutScreenState();
}

class _StripeCheckoutScreenState extends State<StripeCheckoutScreen> {
  // Controlador para el WebView
  late final WebViewController _controller;
  // Bandera para mostrar un indicador de carga mientras el WebView se inicializa
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    // 1. Configuración del controlador
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      // 2. Definición del Navigation Delegate (El Escuchador de URLs)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Puedes mostrar el progreso de la carga si lo deseas
            debugPrint('WebView está cargando (Progress: $progress%)');
          },
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
            debugPrint('Navegación iniciada a: $url');
            
            // 3. Lógica de Intercepción: Aquí detectamos el final del flujo de Stripe
            if (url.startsWith(widget.successUrl)) {
              // Pago exitoso: cerramos la pantalla y devolvemos 'true' (éxito)
              Navigator.of(context).pop(true);
              debugPrint('Pago exitoso detectado. Cerrando WebView.');
            } else if (url.startsWith(widget.cancelUrl)) {
              // Pago cancelado: cerramos la pantalla y devolvemos 'false' (cancelación)
              Navigator.of(context).pop(false);
              debugPrint('Pago cancelado detectado. Cerrando WebView.');
            }
          },
          onPageFinished: (String url) {
            // Una vez que la página (ya sea Stripe o la de retorno) termina de cargar
            setState(() => _isLoading = false);
            debugPrint('Navegación finalizada: $url');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('Error de recurso web: ${error.description}');
            // En caso de error crítico, puedes cerrar la pantalla o mostrar un mensaje
          },
        ),
      )
      // 4. Cargar la URL de la sesión de Stripe
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completar Pago'),
        centerTitle: true,
        backgroundColor: const Color(0xFF4f46e5),
      ),
      body: Stack(
        children: [
          // 5. El componente WebView que muestra la página de Stripe
          WebViewWidget(controller: _controller),
          
          // 6. Indicador de carga (para una mejor UX)
          if (_isLoading)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF4f46e5)),
                  SizedBox(height: 16),
                  Text('Cargando página de Stripe...', style: TextStyle(color: Color(0xFF4f46e5))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}


