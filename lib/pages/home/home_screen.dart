import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- STATE & CONTROLLERS ---

  /// Controller untuk mengelola posisi scroll pada daftar Top Headlines.
  /// Diperlukan agar kita bisa mengontrol scroll lewat tombol.
  final ScrollController _headlinesScrollController = ScrollController();

  // --- DATA DUMMY (Contoh Data) ---

  /// Data statis untuk informasi pengguna yang sedang login.
  /// Nantinya akan diganti dengan data dari database.
  final Map<String, dynamic> userData = {
    "name": "Sarah",
    "avatarUrl": "assets/images/avatar.png",
  };

  /// Daftar berita yang akan ditampilkan di bagian "Top Headlines".
  final List<Map<String, dynamic>> topHeadlines = [
    {
      "title": "Resident Evil 9 Dikonfirmasi Akan Segera Rilis Tahun Depan",
      "time": "2 jam lalu",
      "imageUrl": "assets/images/headline_1.png",
    },
    {
      "title": "Timnas Indonesia Lolos ke Putaran Tiga Kualifikasi Piala Dunia",
      "time": "4 jam lalu",
      "imageUrl": "assets/images/headline_2.png",
    },
    {
      "title": "Dedi Mulyadi Usul Barak Militer Jadi Solusi Atasi Geng Motor",
      "time": "8 jam lalu",
      "imageUrl": "assets/images/headline_3.png",
    },
    {
      "title": "Israel Melancarkan Serangan Udara Balasan ke Wilayah Iran",
      "time": "1 hari lalu",
      "imageUrl": "assets/images/headline_4.png",
    },
  ];

  /// Daftar berita yang akan ditampilkan di bagian "Latest News".
  final List<Map<String, dynamic>> latestNews = [
    {
      "title": "Kenaikan Ekonomi Global Mendorong Optimisme Pasar Saham",
      "snippet": "Dana Moneter Internasional (IMF) merevisi...",
      "imageUrl": "assets/images/latest_1.png",
    },
    {
      "title": "Waspada, Kasus COVID-19 Varian Baru Mulai Meningkat di Indonesia",
      "snippet": "Kementerian Kesehatan mengimbau masyarakat untuk...",
      "imageUrl": "assets/images/latest_2.png",
    },
    {
      "title": "Kabar Duka, Musisi Bertalenta Gustiwiw Meninggal Dunia",
      "snippet": "Dunia musik tanah air berduka atas kepergian...",
      "imageUrl": "assets/images/latest_3.png",
    },
    {
      "title": "Manfaat Kopi Tanpa Gula Menurut dr. Tirta untuk Kesehatan",
      "snippet": "Dalam sebuah unggahan edukatif, dr. Tirta...",
      "imageUrl": "assets/images/latest_4.png",
    },
    {
      "title": "Ujian Nasional SMA Diubah Menjadi Tes Kemampuan Akademik (TKA)",
      "snippet": "Nadiem Makarim mengumumkan perubahan besar dalam...",
      "imageUrl": "assets/images/latest_5.png",
    },
  ];

  /// Daftar kategori berita yang tersedia.
  final List<String> categories = [
    "All", "Politics", "Technology", "Sports", "Health", "Business", "Entertainment"
  ];

  /// Menyimpan index dari kategori yang sedang aktif/dipilih.
  int _selectedCategoryIndex = 0;
  
  /// Menyimpan index dari menu Bottom Navigation Bar yang sedang aktif.
  int _bottomNavIndex = 0;

  /// Metode `dispose` dipanggil saat widget ini dihancurkan.
  /// Digunakan untuk membersihkan controller agar tidak terjadi memory leak.
  @override
  void dispose() {
    _headlinesScrollController.dispose();
    super.dispose();
  }

  // --- WIDGET BUILDERS ---

  /// Fungsi ini membangun bagian AppBar (bilah atas) aplikasi.
  /// Menggunakan [SliverAppBar] agar bisa terintegrasi dengan [CustomScrollView].
  /// Isinya adalah logo aplikasi, sapaan untuk pengguna, dan avatar pengguna.
  Widget _buildAppBar() {
    return SliverAppBar(
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      automaticallyImplyLeading: false, // Menghilangkan tombol back otomatis
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
              backgroundImage: AssetImage(userData["avatarUrl"]),
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

  /// Fungsi ini membangun kolom pencarian (search bar).
  /// Ditempatkan dalam [SliverToBoxAdapter] agar bisa masuk ke dalam [CustomScrollView].
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

  /// Fungsi ini adalah widget pembantu (helper) untuk membuat judul setiap seksi.
  /// Contoh: "Top Headlines", "Latest News".
  Widget _buildSectionTitle(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Fungsi ini membangun seksi "Top Headlines".
  /// Menggunakan [Stack] untuk menumpuk tombol navigasi di atas daftar berita.
  /// Daftar berita dibangun menggunakan [ListView.builder] dengan scroll horizontal.
  Widget _buildTopHeadlines() {
    return SliverToBoxAdapter(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Daftar Berita
          SizedBox(
            height: 250,
            child: ListView.builder(
              controller: _headlinesScrollController,
              scrollDirection: Axis.horizontal,
              itemCount: topHeadlines.length,
              itemBuilder: (context, index) {
                final headline = topHeadlines[index];
                return Container(
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
                );
              },
            ),
          ),
          // Tombol Navigasi Kiri dan Kanan
          Positioned(
            left: 25,
            child: _buildNavigationButton(Icons.arrow_back_ios_new, () {
              final itemWidth = MediaQuery.of(context).size.width * 0.8;
              final newOffset = _headlinesScrollController.offset - itemWidth;
              if (newOffset >= 0) {
                _headlinesScrollController.animateTo(
                  newOffset,
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
              final maxScroll = _headlinesScrollController.position.maxScrollExtent;
              final newOffset = _headlinesScrollController.offset + itemWidth;
              if (newOffset <= maxScroll) {
                _headlinesScrollController.animateTo(
                  newOffset,
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

  /// Widget pembantu untuk membuat tombol navigasi (kiri/kanan) pada Top Headlines.
  /// Tombol ini semi-transparan dan berbentuk lingkaran.
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

  /// Fungsi ini membangun daftar kategori berita yang bisa di-scroll horizontal.
  /// Menggunakan [ListView.builder] dan mengubah tampilan kategori yang
  /// sedang dipilih berdasarkan state [_selectedCategoryIndex].
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
                setState(() {
                  _selectedCategoryIndex = index;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                margin: EdgeInsets.only(
                  left: 16,
                  right: index == categories.length - 1 ? 16 : 0,
                ),
                decoration: BoxDecoration(
                  color: _selectedCategoryIndex == index
                      ? Colors.blue[600]
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    categories[index],
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

  /// Fungsi ini membangun daftar berita vertikal untuk seksi "Latest News".
  /// Menggunakan [SliverList] dan [SliverChildBuilderDelegate] untuk performa
  /// yang lebih baik di dalam [CustomScrollView].
  Widget _buildLatestNewsList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final news = latestNews[index];
          return Padding(
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
          );
        },
        childCount: latestNews.length,
      ),
    );
  }

  /// Fungsi `build` adalah metode utama yang dipanggil untuk merender UI halaman ini.
  /// Menggunakan [Scaffold] sebagai kerangka utama.
  /// Isinya adalah [CustomScrollView] yang menampung semua seksi (slivers)
  /// dan sebuah [BottomNavigationBar] di bagian bawah.
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