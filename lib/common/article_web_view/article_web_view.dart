import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ArticleWebViewWidget extends StatefulWidget {
  const ArticleWebViewWidget({
    super.key,
    required this.url,
    required this.title,
  });

  final String url;
  final String title;

  @override
  State<ArticleWebViewWidget> createState() => _ArticleWebViewWidgetState();
}

class _ArticleWebViewWidgetState extends State<ArticleWebViewWidget> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}