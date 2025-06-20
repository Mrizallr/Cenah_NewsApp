// Sesuaikan path import dengan struktur proyek Anda
import 'package:cenah_news/src/models/news_model.dart';
import 'package:cenah_news/src/services/news_services.dart';
import 'package:cenah_news/src/pages/detail/news_detail_screen.dart';
import 'package:cenah_news/src/pages/profile/profile_screen.dart';
import 'package:cenah_news/src/pages/categories/categories_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  final List<Widget> _pages = [
    const HomeFeed(),
    const CategoriesScreen(),
    const PlaceholderPage(title: 'Saved'), 
    const PlaceholderPage(title: 'Alerts'), 
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
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Categories'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
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
  final NewsService _newsService = NewsService();

  // --- State untuk Berita ---
  List<NewsArticle> _topHeadlines = [];
  List<NewsArticle> _latestNews = [];
  bool _isNewsLoading = true;
  String? _newsErrorMessage;

  // --- State untuk Kategori ---
  List<String> _categories = [];
  bool _isCategoriesLoading = true;
  int _selectedCategoryIndex = 0;

  // --- DATA DUMMY (Hanya untuk User) ---
  final Map<String, dynamic> userData = const {
    "name": "Sarah",
    "avatarUrl": "assets/images/avatar.png",
  };

  @override
  void initState() {
    super.initState();
    // Panggil kedua fungsi untuk mengambil data secara bersamaan
    _fetchInitialData();
  }
  
  Future<void> _fetchInitialData() async {
    await _fetchCategories();
    // Ambil berita "All" setelah kategori berhasil dimuat
    if (_categories.isNotEmpty) {
      await _fetchNewsData(category: _categories[0]);
    }
  }

  // --- Fungsi untuk mengambil kategori dari API ---
  Future<void> _fetchCategories() async {
    setState(() {
      _isCategoriesLoading = true;
    });
    try {
      final fetchedCategories = await _newsService.fetchCategoriesFromNews();
      if (mounted) {
        setState(() {
          // Selalu tambahkan "All" di depan
          _categories = ["All", ...fetchedCategories];
          _isCategoriesLoading = false;
        });
      }
    } catch (e) {
       if (mounted) {
        setState(() {
          // Jika gagal, setidaknya tampilkan "All"
          _categories = ["All"];
          _isCategoriesLoading = false;
        });
       }
    }
  }

  // --- Fungsi untuk mengambil berita dari API ---
  Future<void> _fetchNewsData({String? category}) async {
    setState(() {
      _isNewsLoading = true;
      _newsErrorMessage = null;
    });

    try {
      String apiUrl = '${_newsService.baseApiUrl}/news';
      if (category != null && category != 'All') {
        apiUrl += '?category=$category';
      }

      final newsResponse = await _newsService.fetchNews(apiUrl);

      if (mounted) {
        setState(() {
          if (newsResponse.success) {
            final allArticles = newsResponse.data.articles;
            _topHeadlines = allArticles.where((a) => a.isTrending).toList();
            _latestNews = allArticles;

            if (category != null && category != 'All') {
              _topHeadlines = [];
              _latestNews = allArticles;
            }
          } else {
            _newsErrorMessage = newsResponse.message;
          }
          _isNewsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isNewsLoading = false;
          _newsErrorMessage = e.toString().replaceFirst("Exception: ", "");
        });
      }
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Tampilkan loading utama jika berita atau kategori masih dimuat
    if (_isNewsLoading || _isCategoriesLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_newsErrorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $_newsErrorMessage',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red[700])),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _fetchNewsData(category: _categories[_selectedCategoryIndex]),
                child: const Text('Coba Lagi'),
              )
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _fetchNewsData(category: _categories[_selectedCategoryIndex]),
      child: CustomScrollView(
        slivers: [
          _buildAppBar(),
          _buildSearchBar(),
          if (_selectedCategoryIndex == 0 && _topHeadlines.isNotEmpty) ...[
            _buildSectionTitle('Top Headlines'),
            _buildTopHeadlines(),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
          _buildCategories(), // Widget ini sekarang akan menggunakan state _categories
          _buildSectionTitle('Latest News'),
          _latestNews.isEmpty
              ? SliverToBoxAdapter(
                  child: Container(
                    height: 200,
                    alignment: Alignment.center,
                    child: const Text('Tidak ada berita untuk kategori ini.'),
                  ),
                )
              : _buildLatestNewsList(),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  // --- Widget Builders (AppBar, SearchBar, dll) ---
  
  Widget _buildAppBar() {
    return SliverAppBar(
      systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light),
      automaticallyImplyLeading: false,
      title: Image.asset('assets/images/logo2.png', height: 40),
      actions: [
        Row(
          children: [
            Text('Hello, ${userData["name"]}',
                style: const TextStyle(fontSize: 14, color: Colors.black54)),
            const SizedBox(width: 8),
            CircleAvatar(
                backgroundImage: AssetImage(userData["avatarUrl"]!),
                radius: 20),
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
                borderSide: BorderSide.none),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Text(title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    );
  }

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
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                NewsDetailScreen(newsArticle: headline)));
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    margin: EdgeInsets.only(
                        left: 16,
                        right: index == _topHeadlines.length - 1 ? 16 : 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(headline.imageUrl),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) =>
                            const Icon(Icons.error),
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
                                      Colors.transparent
                                    ]))),
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(headline.title,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 8),
                              Text(headline.publishedAt,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 12)),
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
              final itemWidth = MediaQuery.of(context).size.width * 0.8;
              if (_headlinesScrollController.offset > 0) {
                _headlinesScrollController.animateTo(
                    _headlinesScrollController.offset - itemWidth,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut);
              }
            }),
          ),
          Positioned(
            right: 25,
            child: _buildNavigationButton(Icons.arrow_forward_ios, () {
              final itemWidth = MediaQuery.of(context).size.width * 0.8;
              if (_headlinesScrollController.offset <
                  _headlinesScrollController.position.maxScrollExtent) {
                _headlinesScrollController.animateTo(
                    _headlinesScrollController.offset + itemWidth,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut);
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildCategories() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _categories.length, // Menggunakan state _categories
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                setState(() => _selectedCategoryIndex = index);
                // Panggil fetch data lagi dengan kategori yang dipilih
                _fetchNewsData(category: _categories[index]);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                margin: EdgeInsets.only(
                    left: 16, right: index == _categories.length - 1 ? 16 : 0),
                decoration: BoxDecoration(
                  color: _selectedCategoryIndex == index
                      ? Colors.blue[600]
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    _categories[index], // Menggunakan state _categories
                    style: TextStyle(
                      color: _selectedCategoryIndex == index
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

  Widget _buildLatestNewsList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final news = _latestNews[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          NewsDetailScreen(newsArticle: news)));
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      news.imageUrl,
                      width: 110,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                          width: 110,
                          height: 90,
                          color: Colors.grey[200],
                          child:
                              const Icon(Icons.broken_image, color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(news.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 6),
                        Text(news.content,
                            style:
                                const TextStyle(color: Colors.grey, fontSize: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        childCount: _latestNews.length,
      ),
    );
  }
}


// HALAMAN PLACEHOLDER GENERIC
class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Halaman $title')),
      body: Center(child: Text('Tampilan untuk $title')),
    );
  }
}
