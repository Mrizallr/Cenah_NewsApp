import 'package:flutter/material.dart';
// Menggunakan NewsService dari controllers karena memiliki fungsi fetchBookmarkedArticles
import 'package:cenah_news/src/controllers/news_controller.dart';
import 'package:cenah_news/src/models/news_model.dart';
import 'package:cenah_news/src/pages/detail/news_detail_screen.dart';

// SavedArticlesScreen adalah halaman untuk menampilkan artikel yang disimpan (bookmarked)
class SavedArticlesScreen extends StatefulWidget {
  const SavedArticlesScreen({super.key});

  @override
  State<SavedArticlesScreen> createState() => _SavedArticlesScreenState();
}

class _SavedArticlesScreenState extends State<SavedArticlesScreen> {
  // Inisialisasi NewsService untuk berinteraksi dengan API berita
  final NewsService _newsService = NewsService();
  
  // Future yang akan menampung hasil pemanggilan API untuk daftar artikel yang disimpan
  late Future<List<NewsArticle>> _savedArticlesFuture;

  @override
  void initState() {
    super.initState();
    // Memuat daftar artikel yang disimpan saat halaman pertama kali dibuka
    _fetchSavedArticles();
  }

  // Fungsi untuk memuat ulang daftar artikel yang disimpan dari API
  Future<void> _fetchSavedArticles() async {
    setState(() {
      // Menginisialisasi ulang future untuk memicu pemuatan data baru
      _savedArticlesFuture = _newsService.fetchBookmarkedArticles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Artikel Tersimpan', // Judul halaman
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1, // Memberi sedikit bayangan di bawah AppBar
      ),
      body: RefreshIndicator(
        onRefresh: _fetchSavedArticles, // Mengaktifkan pull-to-refresh
        child: FutureBuilder<List<NewsArticle>>(
          future: _savedArticlesFuture,
          builder: (context, snapshot) {
            // Menampilkan indikator loading saat data sedang dimuat
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // Menangani error jika terjadi masalah saat memuat data
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red[700],
                        size: 50,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Gagal memuat artikel: ${snapshot.error.toString().replaceFirst("Exception: ", "")}',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchSavedArticles, // Tombol untuk mencoba memuat ulang
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Menangani kasus jika tidak ada data atau daftar artikel kosong
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bookmark_border,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Belum ada artikel yang disimpan.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Simpan artikel favoritmu untuk membacanya nanti!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            }

            // Jika data berhasil dimuat dan ada artikel, tampilkan dalam ListView
            final savedArticles = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: savedArticles.length,
              itemBuilder: (context, index) {
                final article = savedArticles[index];
                return _buildSavedArticleCard(context, article);
              },
            );
          },
        ),
      ),
    );
  }

  // Widget helper untuk membangun kartu artikel yang disimpan
  Widget _buildSavedArticleCard(BuildContext context, NewsArticle article) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2.0, // Sedikit bayangan untuk efek kedalaman
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Sudut membulat
      ),
      child: InkWell(
        onTap: () {
          // Navigasi ke halaman detail berita saat kartu diklik
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewsDetailScreen(newsArticle: article),
            ),
          ).then((_) {
            // Setelah kembali dari detail, muat ulang daftar artikel
            // untuk merefleksikan perubahan status bookmark (misal: dihapus)
            _fetchSavedArticles();
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar artikel
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  article.imageUrl,
                  width: 100,
                  height: 90,
                  fit: BoxFit.cover,
                  // Penanganan error jika gambar gagal dimuat
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 100,
                    height: 90,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 16), // Jarak antara gambar dan teks

              // Bagian teks (judul, kategori, tanggal)
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
                      maxLines: 2, // Maksimal 2 baris untuk judul
                      overflow: TextOverflow.ellipsis, // Menambahkan "..." jika teks terlalu panjang
                    ),
                    const SizedBox(height: 8),
                    // Menampilkan kategori sebagai Chip
                    Chip(
                      label: Text(
                        article.category,
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      article.publishedAt, // Tanggal publikasi
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
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
