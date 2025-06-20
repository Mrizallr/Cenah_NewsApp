import 'package:cenah_news/src/configs/app_routes.dart';
// ignore: unused_import
import 'package:cenah_news/src/pages/edit_article/edit_article_screen.dart';
import 'package:cenah_news/src/services/news_services.dart';
import 'package:cenah_news/src/widgets/empty_widgets.dart';
import 'package:flutter/material.dart';
import 'package:cenah_news/src/models/news_model.dart';
import 'package:cenah_news/src/widgets/article_card.dart';
import 'package:cenah_news/src/widgets/loading_indicator.dart';

class MyArticlesScreen extends StatefulWidget {
  const MyArticlesScreen({super.key});

  @override
  _MyArticlesScreenState createState() => _MyArticlesScreenState();
}

class _MyArticlesScreenState extends State<MyArticlesScreen> {
  final NewsService _newsService = NewsService();
  late Future<NewsResponse> _myArticlesFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMyArticles();
  }

  void _loadMyArticles() {
    setState(() {
      _myArticlesFuture = _newsService.fetchMyArticles();
    });
  }

  Future<void> _refreshArticles() async {
    _loadMyArticles();
  }

  Future<void> _deleteArticle(String articleId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Article'),
            content: const Text(
              'Are you sure you want to delete this article?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        final success = await _newsService.deleteArticle(articleId);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Article deleted successfully')),
          );
          _loadMyArticles();
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete article: $e')));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToEditScreen(NewsArticle article) {
    Navigator.pushNamed(context, AppRoutes.editArticle, arguments: article.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Articles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed:
                () => {Navigator.pushNamed(context, AppRoutes.createArticle)},
          ),
        ],
      ),
      body:
          _isLoading
              ? const LoadingIndicator()
              : RefreshIndicator(
                onRefresh: _refreshArticles,
                child: FutureBuilder<NewsResponse>(
                  future: _myArticlesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LoadingIndicator();
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: EmptyState(
                          icon: Icons.error_outline,
                          message: 'Failed to load articles\n${snapshot.error}',
                          action: ElevatedButton(
                            onPressed: _refreshArticles,
                            child: const Text('Retry'),
                          ),
                        ),
                      );
                    }

                    if (!snapshot.hasData ||
                        snapshot.data!.data.articles.isEmpty) {
                      return Center(
                        child: EmptyState(
                          icon: Icons.article,
                          message: 'You haven\'t created any articles yet',
                          action: ElevatedButton(
                            onPressed: () {},
                            child: const Text('Create First Article'),
                          ),
                        ),
                      );
                    }

                    final articles = snapshot.data!.data.articles;
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: articles.length,
                      itemBuilder: (context, index) {
                        final article = articles[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ArticleCard(
                            article: article,
                            onTap: () => _navigateToEditScreen(article),
                            actions: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => _navigateToEditScreen(article),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  size: 20,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteArticle(article.id),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
    );
  }
}
