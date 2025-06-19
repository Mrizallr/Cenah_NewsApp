import 'package:cenah_news/src/models/news_model.dart';
import 'package:cenah_news/src/services/news_services.dart'; // <-- 2. Import service
import 'package:cenah_news/src/pages/detail/news_detail_screen.dart';
import 'package:cenah_news/src/pages/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Disarankan untuk menambahkan package 'timeago' untuk format waktu yang lebih baik
// import 'package:timeago/timeago.dart' as timeago;

// -----------------------------------------------------------------------------
// WIDGET UTAMA: Pengontrol Halaman (Page Controller)
// -----------------------------------------------------------------------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _bottomNavIndex = 0;

  // Daftar halaman tetap sama
  final List<Widget> _pages = [
    const HomeFeed(),
    const CategoriesPage(),
    const SavedPage(),
    const AlertsPage(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_bottomNavIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: (index) {
          setState(() {
            _bottomNavIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue[600],
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Saved'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// KONTEN HALAMAN HOME (NEWS FEED)
// -----------------------------------------------------------------------------
class HomeFeed extends StatefulWidget {
  const HomeFeed({super.key});

  @override
  State<HomeFeed> createState() => _HomeFeedState();
}

class _HomeFeedState extends State<HomeFeed> {
  final ScrollController _headlinesScrollController = ScrollController();
  final NewsService _newsService =
      NewsService(); // <-- 3. Inisialisasi NewsService

  // --- State untuk menampung data dari API ---
  List<NewsArticle> _topHeadlines = [];
  List<NewsArticle> _latestNews = [];
  bool _isLoading = true;
  String? _errorMessage;

  // --- DATA DUMMY (Hanya untuk User, karena tidak ada di API) ---
  final Map<String, dynamic> userData = const {
    "name": "Sarah",
    "avatarUrl": "assets/images/avatar.png",
  };

  // --- Kategori tetap, bisa juga diambil dari API jika tersedia ---
  final List<String> categories = const [
    "All",
    "Technology",
    "Sports",
    "Health",
    "Business",
    "Entertainment",
    "Politics",
  ];
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    // 4. Panggil fungsi untuk mengambil data saat halaman pertama kali dimuat
    _fetchNewsData();
  }

  // --- 5. Fungsi untuk mengambil dan memproses data berita dari API ---
  Future<void> _fetchNewsData({String? category}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String apiUrl = '${_newsService.baseApiUrl}/news';
      if (category != null && category != 'All') {
        apiUrl += '?category=$category';
      }

      final newsResponse = await _newsService.fetchNews(apiUrl);

      setState(() {
        if (newsResponse.success) {
          final allArticles = newsResponse.data.articles;
          // Pisahkan antara berita trending (untuk top headlines) dan lainnya
          _topHeadlines = allArticles.where((a) => a.isTrending).toList();
          _latestNews = allArticles; // Tampilkan semua di latest news

          // Jika ada filter kategori, sembunyikan top headlines dan tampilkan semua di latest
          if (category != null && category != 'All') {
            _topHeadlines = [];
            _latestNews = allArticles;
          }
        } else {
          _errorMessage = newsResponse.message;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst("Exception: ", "");
      });
    }
  }

  @override
  void dispose() {
    _headlinesScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(),
              ) // Tampilkan loading
              : _errorMessage != null
              ? Center(child: Text('Error: $_errorMessage')) // Tampilkan error
              : RefreshIndicator(
                onRefresh:
                    () => _fetchNewsData(
                      category: categories[_selectedCategoryIndex],
                    ),
                child: CustomScrollView(
                  slivers: [
                    _buildAppBar(),
                    _buildSearchBar(),
                    // Tampilkan Top Headlines hanya jika tidak ada kategori yang dipilih
                    if (_selectedCategoryIndex == 0 &&
                        _topHeadlines.isNotEmpty) ...[
                      _buildSectionTitle('Top Headlines'),
                      _buildTopHeadlines(),
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    ],
                    _buildCategories(),
                    _buildSectionTitle('Latest News'),
                    _latestNews.isEmpty
                        ? SliverToBoxAdapter(
                          child: Container(
                            height: 200,
                            alignment: Alignment.center,
                            child: const Text(
                              'Tidak ada berita untuk kategori ini.',
                            ),
                          ),
                        )
                        : _buildLatestNewsList(),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                ),
              ),
    );
  }

  // --- Widget Helper untuk HomeFeed (Beberapa bagian dimodifikasi) ---

  Widget _buildAppBar() {
    // Tidak ada perubahan signifikan di sini
    return SliverAppBar(
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      automaticallyImplyLeading: false,
      title: Image.asset('assets/images/logo2.png', height: 40),
      actions: [
        Row(
          children: [
            Text(
              'Hello, ${userData["name"]}',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundImage: AssetImage(userData["avatarUrl"]!),
              radius: 20,
            ),
            const SizedBox(width: 16),
          ],
        ),
      ],
      backgroundColor: Colors.white,
      floating: true,
      pinned: true,
      elevation: 0,
    );
  }

  Widget _buildSearchBar() {
    // Tidak ada perubahan di sini
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search news...',
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            filled: true,
            fillColor: Colors.grey[200],
            contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    // Tidak ada perubahan di sini
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // --- 6. MODIFIKASI: _buildTopHeadlines menggunakan data API ---
  Widget _buildTopHeadlines() {
    return SliverToBoxAdapter(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: 250,
            child: ListView.builder(
              controller: _headlinesScrollController,
              scrollDirection: Axis.horizontal,
              itemCount: _topHeadlines.length,
              itemBuilder: (context, index) {
                final headline = _topHeadlines[index];
                return GestureDetector(
                  onTap: () {
                    // Kirim objek NewsArticle ke halaman detail
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                NewsDetailScreen(newsArticle: headline),
                      ),
                    );
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    margin: EdgeInsets.only(
                      left: 16,
                      right: index == _topHeadlines.length - 1 ? 16 : 0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      // Gunakan Image.network untuk memuat dari URL
                      image: DecorationImage(
                        image: NetworkImage(headline.imageUrl),
                        fit: BoxFit.cover,
                        onError:
                            (exception, stackTrace) => const Icon(Icons.error),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.8),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                headline.title, // <-- Data dari API
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                headline.publishedAt, // <-- Data dari API
                                // Anda bisa menggunakan package 'timeago' untuk format seperti "2 hours ago"
                                // contoh: timeago.format(headline.createdAt)
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            left: 25,
            child: _buildNavigationButton(Icons.arrow_back_ios_new, () {
              // Logika navigasi scroll tetap sama
              final itemWidth = MediaQuery.of(context).size.width * 0.8;
              if (_headlinesScrollController.offset > 0) {
                _headlinesScrollController.animateTo(
                  _headlinesScrollController.offset - itemWidth,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            }),
          ),
          Positioned(
            right: 25,
            child: _buildNavigationButton(Icons.arrow_forward_ios, () {
              // Logika navigasi scroll tetap sama
              final itemWidth = MediaQuery.of(context).size.width * 0.8;
              if (_headlinesScrollController.offset <
                  _headlinesScrollController.position.maxScrollExtent) {
                _headlinesScrollController.animateTo(
                  _headlinesScrollController.offset + itemWidth,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton(IconData icon, VoidCallback onPressed) {
    // Tidak ada perubahan di sini
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  // --- 7. MODIFIKASI: _buildCategories untuk memicu fetch data baru ---
  Widget _buildCategories() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                setState(() => _selectedCategoryIndex = index);
                // Panggil fetch data lagi dengan kategori yang dipilih
                _fetchNewsData(category: categories[index]);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                margin: EdgeInsets.only(
                  left: 16,
                  right: index == categories.length - 1 ? 16 : 0,
                ),
                decoration: BoxDecoration(
                  color:
                      _selectedCategoryIndex == index
                          ? Colors.blue[600]
                          : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    categories[index],
                    style: TextStyle(
                      color:
                          _selectedCategoryIndex == index
                              ? Colors.white
                              : Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- 8. MODIFIKASI: _buildLatestNewsList menggunakan data API ---
  Widget _buildLatestNewsList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final news = _latestNews[index];
        return GestureDetector(
          onTap: () {
            // Kirim objek NewsArticle ke halaman detail
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewsDetailScreen(newsArticle: news),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  // Gunakan Image.network untuk memuat dari URL
                  child: Image.network(
                    news.imageUrl,
                    width: 110,
                    height: 90,
                    fit: BoxFit.cover,
                    // Tambahkan error builder untuk menangani jika gambar gagal dimuat
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 110,
                        height: 90,
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        news.title, // <-- Data dari API
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        news.content, // <-- Data dari API (gunakan content sebagai snippet)
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }, childCount: _latestNews.length),
    );
  }
}

// -----------------------------------------------------------------------------
// HALAMAN PLACEHOLDER (Tidak ada perubahan)
// -----------------------------------------------------------------------------

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kategori')),
      body: const Center(child: Text('Halaman Kategori')),
    );
  }
}

class SavedPage extends StatelessWidget {
  const SavedPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Artikel Tersimpan')),
      body: const Center(child: Text('Halaman Artikel Tersimpan')),
    );
  }
}

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifikasi')),
      body: const Center(child: Text('Halaman Notifikasi')),
    );
  }
}
