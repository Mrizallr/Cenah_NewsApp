import 'package:cenah_news/src/pages/detail/news_detail_screen.dart'; // <-- 1. Import halaman detail
import 'package:cenah_news/src/pages/profile/profile_screen.dart';
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

  // --- DATA DUMMY (Nantinya akan diganti dari Firebase) ---
  final Map<String, dynamic> userData = const {
    "name": "Sarah",
    "avatarUrl": "assets/images/avatar.png",
  };
  final List<Map<String, dynamic>> topHeadlines = const [
    {
      "title": "Resident Evil 9 Dikonfirmasi Akan Segera Rilis Tahun Depan",
      "time": "2 jam lalu",
      "imageUrl": "assets/images/headline_1.png",
      "category": "Teknologi",
      "author": "Gamespot",
      "content":
          "Capcom secara resmi mengumumkan kehadiran Resident Evil 9. Game ini dijadwalkan akan meluncur pada kuartal ketiga tahun depan dengan membawa kembali karakter ikonik dan gameplay yang lebih mencekam.",
    },
    {
      "title": "Timnas Indonesia Lolos ke Putaran Tiga Kualifikasi Piala Dunia",
      "time": "4 jam lalu",
      "imageUrl": "assets/images/headline_2.png",
      "category": "Olahraga",
      "author": "PSSI",
      "content":
          "Timnas Indonesia berhasil memastikan satu tempat di putaran ketiga Kualifikasi Piala Dunia 2026 zona Asia setelah mengalahkan Filipina dengan skor 2-0 di Stadion Utama Gelora Bung Karno.",
    },
    {
      "title": "Dedi Mulyadi Usul Barak Militer Jadi Solusi Atasi Geng Motor",
      "time": "8 jam lalu",
      "imageUrl": "assets/images/headline_3.png",
      "category": "Politik",
      "author": "Jabar News",
      "content":
          "Calon Gubernur Jawa Barat, Dedi Mulyadi, mengusulkan solusi kontroversial untuk mengatasi maraknya geng motor dengan memasukkan anggotanya ke dalam barak militer untuk pembinaan disiplin.",
    },
    {
      "title": "Israel Melancarkan Serangan Udara Balasan ke Wilayah Iran",
      "time": "1 hari lalu",
      "imageUrl": "assets/images/headline_4.png",
      "category": "Internasional",
      "author": "Reuters",
      "content":
          "Ketegangan di Timur Tengah kembali memanas setelah Israel dilaporkan melancarkan serangan udara balasan ke beberapa lokasi strategis di wilayah Iran. Komunitas internasional menyerukan de-eskalasi.",
    },
  ];
  final List<Map<String, dynamic>> latestNews = const [
    {
      "title": "Kenaikan Ekonomi Global Mendorong Optimisme Pasar Saham",
      "snippet": "Dana Moneter Internasional (IMF) merevisi...",
      "imageUrl": "assets/images/latest_1.png",
      "category": "Bisnis",
      "time": "3 jam lalu",
    },
    {
      "title":
          "Waspada, Kasus COVID-19 Varian Baru Mulai Meningkat di Indonesia",
      "snippet": "Kementerian Kesehatan mengimbau masyarakat untuk...",
      "imageUrl": "assets/images/latest_2.png",
      "category": "Kesehatan",
      "time": "5 jam lalu",
    },
    {
      "title": "Kabar Duka, Musisi Bertalenta Gustiwiw Meninggal Dunia",
      "snippet": "Dunia musik tanah air berduka atas kepergian...",
      "imageUrl": "assets/images/latest_3.png",
      "category": "Hiburan",
      "time": "9 jam lalu",
    },
    {
      "title": "Manfaat Kopi Tanpa Gula Menurut dr. Tirta untuk Kesehatan",
      "snippet": "Dalam sebuah unggahan edukatif, dr. Tirta...",
      "imageUrl": "assets/images/latest_4.png",
      "category": "Kesehatan",
      "time": "1 hari lalu",
    },
    {
      "title": "Ujian Nasional SMA Diubah Menjadi Tes Kemampuan Akademik (TKA)",
      "snippet": "Nadiem Makarim mengumumkan perubahan besar dalam...",
      "imageUrl": "assets/images/latest_5.png",
      "category": "Pendidikan",
      "time": "2 hari lalu",
    },
  ];
  final List<String> categories = const [
    "All",
    "Politics",
    "Technology",
    "Sports",
    "Health",
    "Business",
    "Entertainment",
  ];
  int _selectedCategoryIndex = 0;

  @override
  void dispose() {
    _headlinesScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          _buildSearchBar(),
          _buildSectionTitle('Top Headlines'),
          _buildTopHeadlines(),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          _buildCategories(),
          _buildSectionTitle('Latest News'),
          _buildLatestNewsList(),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  // --- Widget Helper untuk HomeFeed ---

  Widget _buildAppBar() {
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
              itemCount: topHeadlines.length,
              itemBuilder: (context, index) {
                final headline = topHeadlines[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => NewsDetailScreen(newsData: headline),
                      ),
                    );
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    margin: EdgeInsets.only(
                      left: 16,
                      right: index == topHeadlines.length - 1 ? 16 : 0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: AssetImage(headline["imageUrl"]),
                        fit: BoxFit.cover,
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
                                headline["title"],
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
                                headline["time"],
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

  Widget _buildCategories() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => setState(() => _selectedCategoryIndex = index),
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

  Widget _buildLatestNewsList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final news = latestNews[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewsDetailScreen(newsData: news),
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
                  child: Image.asset(
                    news["imageUrl"],
                    width: 110,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        news["title"],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        news["snippet"],
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
      }, childCount: latestNews.length),
    );
  }
}

// -----------------------------------------------------------------------------
// HALAMAN PLACEHOLDER (SEMENTARA)
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
