import 'package:cenah_news/src/models/news_model.dart';
import 'package:cenah_news/src/services/news_services.dart';
import 'package:flutter/material.dart';

class NewsDetailScreen extends StatefulWidget {
  // Menerima satu objek NewsArticle lengkap dari halaman sebelumnya
  final NewsArticle newsArticle;

  const NewsDetailScreen({super.key, required this.newsArticle});

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  // Inisialisasi service untuk digunakan di halaman ini
  final NewsService _newsService = NewsService();

  // State untuk mengelola status bookmark dan berita terkait
  bool _isBookmarked = false;
  bool _isLoadingBookmark = true;

  List<NewsArticle> _relatedArticles = [];
  bool _isLoadingRelated = true;

  @override
  void initState() {
    super.initState();
    // Panggil fungsi untuk memuat data dinamis saat halaman dibuka
    _loadInitialData();
  }

  // Fungsi untuk memuat semua data yang dibutuhkan (bookmark & berita terkait)
  void _loadInitialData() {
    _checkBookmarkStatus();
    _fetchRelatedArticles();
  }

  // 1. Fungsi untuk mengecek status bookmark dari API
  Future<void> _checkBookmarkStatus() async {
    // Reset state loading
    setState(() {
      _isLoadingBookmark = true;
    });

    try {
      final status = await _newsService.checkBookmarkStatus(
        widget.newsArticle.id,
      );
      if (mounted) {
        // Pastikan widget masih ada di tree
        setState(() {
          _isBookmarked = status;
          _isLoadingBookmark = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isBookmarked = false;
          _isLoadingBookmark = false;
        });
        // Tampilkan pesan error jika user belum login, dll.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error checking bookmark: ${e.toString().replaceFirst("Exception: ", "")}',
            ),
          ),
        );
      }
    }
  }

  // 2. Fungsi untuk menambah/menghapus bookmark
  Future<void> _toggleBookmark() async {
    // Tampilkan state loading di tombol bookmark
    setState(() {
      _isLoadingBookmark = true;
    });

    try {
      bool success;
      if (_isBookmarked) {
        // Jika sudah di-bookmark, panggil fungsi remove
        success = await _newsService.removeBookmark(widget.newsArticle.id);
      } else {
        // Jika belum, panggil fungsi add
        success = await _newsService.addBookmark(widget.newsArticle.id);
      }

      if (success && mounted) {
        // Jika berhasil, ubah state bookmark
        setState(() {
          _isBookmarked = !_isBookmarked;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isBookmarked ? 'Artikel disimpan' : 'Simpanan dihapus',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal: ${e.toString().replaceFirst("Exception: ", "")}',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingBookmark = false;
        });
      }
    }
  }

  // 3. Fungsi untuk mengambil berita terkait berdasarkan kategori
  Future<void> _fetchRelatedArticles() async {
    setState(() {
      _isLoadingRelated = true;
    });
    try {
      final articles = await _newsService.fetchRelatedArticles(
        widget.newsArticle.category,
        limit: 3,
      );
      if (mounted) {
        setState(() {
          // Filter artikel saat ini agar tidak muncul di list terkait
          _relatedArticles =
              articles.where((a) => a.id != widget.newsArticle.id).toList();
          _isLoadingRelated = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingRelated = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Berita'),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          // Tombol Bookmark Dinamis
          _isLoadingBookmark
              ? const Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
              : IconButton(
                icon: Icon(
                  _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: Colors.blue[600],
                ),
                onPressed: _toggleBookmark,
              ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kategori
              Chip(
                label: Text(widget.newsArticle.category),
                backgroundColor: Colors.blue.withOpacity(0.1),
                labelStyle: TextStyle(
                  color: Colors.blue[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Judul
              Text(
                widget.newsArticle.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),

              // Info Penulis
              _buildAuthorInfo(),
              const SizedBox(height: 20),

              // Gambar Utama
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.newsArticle.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                          size: 50,
                        ),
                      ),
                ),
              ),
              const SizedBox(height: 20),

              // Konten Berita
              Text(
                widget.newsArticle.content,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // Berita Terkait
              _buildRelatedArticlesSection(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget helper untuk menampilkan info penulis
  Widget _buildAuthorInfo() {
    final author = widget.newsArticle.author;
    return Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundImage: NetworkImage(author.avatar),
          onBackgroundImageError:
              (exception, stackTrace) => const Icon(Icons.person),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              author.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 2),
            Text(
              author.title,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
        const Spacer(),
        Text(
          widget.newsArticle.readTime,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }

  // Widget helper untuk menampilkan list berita terkait
  Widget _buildRelatedArticlesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Berita Terkait',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _isLoadingRelated
            ? const Center(child: CircularProgressIndicator())
            : _relatedArticles.isEmpty
            ? const Center(child: Text('Tidak ada berita terkait.'))
            : ListView.builder(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(), // Agar tidak konflik dengan SingleChildScrollView
              itemCount: _relatedArticles.length,
              itemBuilder: (context, index) {
                final relatedArticle = _relatedArticles[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 1,
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        relatedArticle.imageUrl,
                        width: 80,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      relatedArticle.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(relatedArticle.category),
                    onTap: () {
                      // Navigasi ke halaman detail berita terkait (mengganti halaman saat ini)
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  NewsDetailScreen(newsArticle: relatedArticle),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      ],
    );
  }
}