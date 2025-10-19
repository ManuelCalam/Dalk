import 'package:dalk/cards/article_card/article_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ArticleWebView extends StatefulWidget {
  const ArticleWebView({super.key});

  @override
  State<ArticleWebView> createState() => _ArticleWebViewState();
}

class _ArticleWebViewState extends State<ArticleWebView> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> articles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchArticles();
  }

  Future<void> fetchArticles() async {
    try {
      final response = await supabase
        .from('content_links')
        .select('*')
        .order('id', ascending: false);

      print('📦 Todos los artículos: $response');
      setState(() {
        articles = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });

        print('Artículos cargados: ${articles.length}');
      } catch (error) {
        print('Error al obtener artículos: $error');
        setState(() => isLoading = false);
      }
    }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: articles.map((article) {
          return ArticleCardWidget(
            title: article['title'] ?? '[Sin título]',
            subtitle: article['subtitle'] ?? '',
            imageUrl: article['image_url'] ?? 'https://via.placeholder.com/200x100',
            actionUrl: article['action_url'] ?? '',
            isActive: article['isActive'] ?? false,
          );
        }).toList(),
      ),
    );
  }
}