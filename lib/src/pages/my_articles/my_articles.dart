import 'package:cenah_news/src/configs/app_routes.dart';
import 'package:cenah_news/src/services/news_services.dart';
import 'package:cenah_news/src/widgets/empty_widgets.dart';
import 'package:flutter/material.dart';
import 'package:cenah_news/src/models/news_model.dart';
import 'package:cenah_news/src/widgets/article_card.dart';
import 'package:cenah_news/src/widgets/loading_indicator.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MyArticlesScreen extends StatefulWidget {
  const MyArticlesScreen({super.key});

  @override
  _MyArticlesScreenState createState() => _MyArticlesScreenState();
}

class _MyArticlesScreenState extends State<MyArticlesScreen> {
  final NewsService _newsService = NewsService();
  final RefreshController _refreshController = RefreshController();
  late Future<NewsResponse> _myArticlesFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _muatArtikelSaya();
  }

  void _muatArtikelSaya() {
    setState(() {
      _myArticlesFuture = _newsService.fetchMyArticles();
    });
  }

  Future<void> _muatUlangArtikel() async {
    try {
      await _newsService.fetchMyArticles();
      _refreshController.refreshCompleted();
    } catch (e) {
      _refreshController.refreshFailed();
    }
  }

  Future<void> _hapusArtikel(String articleId) async {
    final dikonfirmasi = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Hapus Artikel'),
            content: const Text(
              'Apakah Anda yakin ingin menghapus artikel ini? Tindakan ini tidak dapat dibatalkan.',
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (dikonfirmasi == true) {
      setState(() => _isLoading = true);
      try {
        final berhasil = await _newsService.deleteArticle(articleId);
        if (berhasil) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Artikel berhasil dihapus'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          _muatArtikelSaya();
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus artikel: $e'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigasiKeHalamanEdit(NewsArticle article) {
    Navigator.pushNamed(
      context,
      AppRoutes.editArticle,
      arguments: article.id,
    ).then((_) => _muatArtikelSaya());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Artikel Saya'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Buat artikel baru',
            onPressed:
                () => Navigator.pushNamed(
                  context,
                  AppRoutes.createArticle,
                ).then((_) => _muatArtikelSaya()),
          ),
        ],
        elevation: 0,
      ),
      body:
          _isLoading
              ? const LoadingIndicator()
              : SmartRefresher(
                controller: _refreshController,
                onRefresh: _muatUlangArtikel,
                header: WaterDropMaterialHeader(
                  backgroundColor: theme.colorScheme.primary,
                  color: theme.colorScheme.onPrimary,
                ),
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
                          message: 'Gagal memuat artikel\n${snapshot.error}',
                          action: ElevatedButton(
                            onPressed: _muatUlangArtikel,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text('Coba Lagi'),
                          ),
                        ),
                      );
                    }

                    if (!snapshot.hasData ||
                        snapshot.data!.data.articles.isEmpty) {
                      return Center(
                        child: EmptyState(
                          icon: Icons.article,
                          message: 'Anda belum membuat artikel apapun',
                          action: ElevatedButton(
                            onPressed:
                                () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.createArticle,
                                ),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text('Buat Artikel Pertama'),
                          ),
                        ),
                      );
                    }

                    final articles = snapshot.data!.data.articles;
                    return AnimationLimiter(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: articles.length,
                        itemBuilder: (context, index) {
                          final article = articles[index];
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: ArticleCard(
                                    article: article,
                                    onTap:
                                        () => _navigasiKeHalamanEdit(article),
                                    actions: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          size: 20,
                                          color: theme.colorScheme.primary,
                                        ),
                                        onPressed:
                                            () =>
                                                _navigasiKeHalamanEdit(article),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          size: 20,
                                          color: Colors.red,
                                        ),
                                        onPressed:
                                            () => _hapusArtikel(article.id),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => Navigator.pushNamed(
              context,
              AppRoutes.createArticle,
            ).then((_) => _muatArtikelSaya()),
        child: const Icon(Icons.add),
        tooltip: 'Buat artikel baru',
        elevation: 4,
      ),
    );
  }
}
