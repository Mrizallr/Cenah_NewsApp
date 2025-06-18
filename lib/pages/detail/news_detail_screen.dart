import 'package:flutter/material.dart';

class NewsDetailScreen extends StatefulWidget {
  // Halaman ini akan menerima sebuah Map yang berisi data berita.
  final Map<String, dynamic> newsData;

  const NewsDetailScreen({
    super.key,
    required this.newsData,
  });

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  // State untuk melacak apakah berita sudah di-bookmark atau belum.
  bool _isBookmarked = false;

  @override
  Widget build(BuildContext context) {
    // Mengambil data dari widget untuk kemudahan akses.
    final String title = widget.newsData['title'] ?? 'Judul Tidak Tersedia';
    final String imageUrl = widget.newsData['imageUrl'] ?? 'assets/images/placeholder.png';
    // Dummy data untuk konten lengkap, penulis, dan kategori
    final String content = widget.newsData['content'] ?? 'Isi berita tidak tersedia... Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.';
    final String author = widget.newsData['author'] ?? 'Admin';
    final String category = widget.newsData['category'] ?? 'Berita';
    final String date = widget.newsData['time'] ?? 'Baru saja';


    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // --- AppBar dengan gambar yang bisa mengecil ---
          SliverAppBar(
            pinned: true,
            stretch: true,
            backgroundColor: Colors.white,
            expandedHeight: 250.0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withOpacity(0.5),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _isBookmarked = !_isBookmarked;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_isBookmarked
                          ? 'Artikel disimpan'
                          : 'Penyimpanan artikel dibatalkan'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.5),
                ),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Image.asset(
                imageUrl,
                fit: BoxFit.cover,
                // Error handling jika gambar tidak ditemukan
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: Colors.grey[300], child: const Icon(Icons.broken_image, color: Colors.grey, size: 50));
                },
              ),
            ),
          ),
          // --- Konten Berita ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kategori
                  Text(
                    category.toUpperCase(),
                    style: TextStyle(
                      color: Colors.blue[600],
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Judul Berita
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      height: 1.3, // Jarak antar baris
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Informasi Penulis dan Tanggal
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.grey[300],
                        child: const Icon(Icons.person, size: 20, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            author,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            date,
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Divider
                  const Divider(),
                  const SizedBox(height: 16),
                  // Isi Berita
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 17,
                      height: 1.6, // Jarak antar baris untuk kenyamanan membaca
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
