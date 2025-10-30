import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WalkerStripeWebview extends StatefulWidget {
  final String onboardingUrl;
  final String returnUrl;
  final String refreshUrl;

  const WalkerStripeWebview({
    Key? key,
    required this.onboardingUrl,
    required this.returnUrl,
    required this.refreshUrl,
  }) : super(key: key);

  @override
  State<WalkerStripeWebview> createState() => _StripeOnboardingScreenState();
}

class _StripeOnboardingScreenState extends State<WalkerStripeWebview> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (!mounted) return;
            setState(() => _isLoading = true);

            if (url.startsWith(widget.returnUrl)) {
              Navigator.of(context).pop(true);
            } else if (url.startsWith(widget.refreshUrl)) {
              Navigator.of(context).pop(false);
              debugPrint('Onboarding reiniciado/cancelado');
            }
          },
          onPageFinished: (url) {
            if (!mounted) return;
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.onboardingUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de pagos'),
        centerTitle: true,
        backgroundColor: const Color(0xFF4F46E5),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF4F46E5)),
                  SizedBox(height: 16),
                  Text('Cargando Stripe...', style: TextStyle(color: Color(0xFF4F46E5))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
