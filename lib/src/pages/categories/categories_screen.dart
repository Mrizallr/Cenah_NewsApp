import 'package:cenah_news/src/pages/categories/category_news_screen.dart';
import 'package:flutter/material.dart';
import 'package:cenah_news/src/services/news_services.dart';
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  // Instance dari service untuk memanggil API
  final NewsService _newsService = NewsService();
  // Future untuk menampung hasil dari API call
  late Future<List<String>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    // Panggil API saat halaman pertama kali dibuka
    _categoriesFuture = _newsService.fetchCategoriesFromNews();
  }

  // Daftar ikon dan warna untuk visualisasi, bisa disesuaikan
  final Map<String, IconData> _categoryIcons = {
    'Teknologi': Icons.computer,
    'Olahraga': Icons.sports_soccer,
    'Politik': Icons.account_balance,
    'Kesehatan': Icons.local_hospital,
    'Bisnis': Icons.business_center,
    'Hiburan': Icons.movie_filter,
    'Internasional': Icons.public,
    'Pendidikan': Icons.school,
    'Default': Icons.article, // Ikon default jika tidak ada yang cocok
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori Berita'),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.grey[100],
      body: FutureBuilder<List<String>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          // 1. Saat data sedang dimuat
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Jika terjadi error
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Gagal memuat kategori: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red[700]),
                ),
              ),
            );
          }

          // 3. Jika data berhasil dimuat
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final categories = snapshot.data!;

            // Tampilkan data dalam bentuk Grid
            return RefreshIndicator(
              onRefresh: () async {
                // Tambahkan fungsi refresh untuk memuat ulang data
                setState(() {
                  _categoriesFuture = _newsService.fetchCategoriesFromNews();
                });
              },
              child: GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 kolom
                  crossAxisSpacing: 16, // Jarak horizontal antar item
                  mainAxisSpacing: 16, // Jarak vertikal antar item
                  childAspectRatio: 1.2, // Rasio lebar-tinggi setiap item
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final categoryName = categories[index];
                  return _buildCategoryCard(
                    context,
                    name: categoryName,
                    icon:
                        _categoryIcons[categoryName] ??
                        _categoryIcons['Default']!,
                  );
                },
              ),
            );
          }

          // 4. Kondisi jika tidak ada data atau data kosong
          return const Center(
            child: Text('Tidak ada kategori yang ditemukan.'),
          );
        },
      ),
    );
  }

  /// Widget untuk membangun satu kartu kategori
  Widget _buildCategoryCard(
    BuildContext context, {
    required String name,
    required IconData icon,
  }) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navigasi ke halaman daftar berita untuk kategori ini
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryNewsScreen(categoryName: name),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Theme.of(context).primaryColor),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
