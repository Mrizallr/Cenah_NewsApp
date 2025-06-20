import 'package:flutter/material.dart';
import 'package:cenah_news/src/pages/categories/category_news_screen.dart';
import 'package:cenah_news/src/services/news_services.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final NewsService _newsService = NewsService();
  late Future<List<String>> _categoriesFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _newsService.fetchCategoriesFromNews();
  }

  final Map<String, IconData> _categoryIcons = {
    'Teknologi': Icons.computer,
    'Olahraga': Icons.sports_soccer,
    'Politik': Icons.account_balance,
    'Kesehatan': Icons.local_hospital,
    'Bisnis': Icons.business_center,
    'Hiburan': Icons.movie_filter,
    'Internasional': Icons.public,
    'Pendidikan': Icons.school,
    'Default': Icons.article,
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
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari kategori...',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
              ),
              onChanged:
                  (value) => setState(() => _searchQuery = value.toLowerCase()),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<String>>(
              future: _categoriesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(strokeWidth: 2),
                        SizedBox(height: 16),
                        Text(
                          'Memuat kategori...',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.red),
                        SizedBox(height: 16),
                        Text(
                          'Gagal memuat kategori',
                          style: TextStyle(fontSize: 18, color: Colors.red),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Silakan coba lagi nanti',
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _categoriesFuture =
                                  _newsService.fetchCategoriesFromNews();
                            });
                          },
                          child: Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  final categories =
                      snapshot.data!
                          .where(
                            (category) =>
                                category.toLowerCase().contains(_searchQuery),
                          )
                          .toList();

                  if (categories.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Kategori tidak ditemukan',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      setState(() {
                        _categoriesFuture =
                            _newsService.fetchCategoriesFromNews();
                      });
                    },
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.2,
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

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.article, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Tidak ada kategori yang ditemukan',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required String name,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final cardColor = _getCategoryColor(name, colorScheme);

    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      CategoryNewsScreen(categoryName: name),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [cardColor.withOpacity(0.8), cardColor],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category, ColorScheme colorScheme) {
    switch (category.toLowerCase()) {
      case 'teknologi':
        return colorScheme.primary;
      case 'olahraga':
        return Colors.green;
      case 'politik':
        return Colors.blue;
      case 'kesehatan':
        return Colors.pink;
      case 'bisnis':
        return Colors.purple;
      case 'hiburan':
        return Colors.orange;
      case 'internasional':
        return Colors.indigo;
      case 'pendidikan':
        return Colors.teal;
      default:
        return colorScheme.secondary;
    }
  }
}
