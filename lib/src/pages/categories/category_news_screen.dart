import 'package:flutter/material.dart';
import 'package:cenah_news/src/models/news_model.dart';
import 'package:cenah_news/src/services/news_services.dart';
import 'package:cenah_news/src/pages/detail/news_detail_screen.dart';

class CategoryNewsScreen extends StatefulWidget {
  final String categoryName;

  const CategoryNewsScreen({super.key, required this.categoryName});

  @override
  State<CategoryNewsScreen> createState() => _CategoryNewsScreenState();
}

class _CategoryNewsScreenState extends State<CategoryNewsScreen> {
  final NewsService _newsService = NewsService();
  late Future<NewsResponse> _newsFuture;

  @override
  void initState() {
    super.initState();
    // Buat URL API berdasarkan nama kategori yang diterima
    final apiUrl =
        '${_newsService.baseApiUrl}/news?category=${widget.categoryName}';
    // Panggil API saat halaman dibuka
    _newsFuture = _newsService.fetchNews(apiUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black, // Warna ikon dan teks di AppBar
        elevation: 1,
      ),
      body: FutureBuilder<NewsResponse>(
        future: _newsFuture,
        builder: (context, snapshot) {
          // Saat data sedang dimuat
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Jika terjadi error koneksi atau lainnya
          if (snapshot.hasError) {
            return Center(
              child: Text('Gagal memuat berita: ${snapshot.error}'),
            );
          }

          // Jika data berhasil dimuat
          if (snapshot.hasData) {
            final newsResponse = snapshot.data!;
            if (!newsResponse.success || newsResponse.data.articles.isEmpty) {
              return Center(
                child: Text(
                  'Tidak ada berita untuk kategori "${widget.categoryName}".',
                ),
              );
            }

            final articles = newsResponse.data.articles;

            // Tampilkan daftar berita
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return _buildNewsCard(context, article);
              },
            );
          }

          // Kondisi default
          return const Center(child: Text('Tidak ada berita.'));
        },
      ),
    );
  }

  /// Widget untuk membangun satu kartu berita dalam daftar
  Widget _buildNewsCard(BuildContext context, NewsArticle article) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navigasi ke halaman detail berita
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewsDetailScreen(newsArticle: article),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  article.imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                        ),
                      ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      article
                          .publishedAt, // Ganti dengan format waktu yang lebih baik jika perlu
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
