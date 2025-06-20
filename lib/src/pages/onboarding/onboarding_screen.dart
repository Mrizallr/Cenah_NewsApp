import 'package:cenah_news/src/pages/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class Introductionscreen extends StatefulWidget {
  const Introductionscreen({super.key});

  @override
  State<Introductionscreen> createState() => _IntroductionscreenState();
}

class _IntroductionscreenState extends State<Introductionscreen> {
  // Controller untuk mengelola state dari PageView
  late PageController _pageController;
  int _currentPage = 0;

  // Warna utama yang konsisten
  static final Color _primaryColor = Colors.blueAccent[400]!;

  final List<Map<String, String>> introData = [
    {
      "image": "assets/images/slide_1.png",
      "title": "Selalu Update, Gak Kudet!",
      "desc":
          "Baca berita terkini dari berbagai topik—dari politik sampai gosip artis—semua langsung di genggamanmu.",
    },
    {
      "image": "assets/images/slide_2.png",
      "title": "Berita Valid, Bukan Katanya",
      "desc":
          "Kami pilihkan berita dari sumber terpercaya, biar kamu gak salah info dan tetap jadi yang paling tahu.",
    },
    {
      "image": "assets/images/slide_3.png",
      "title": "Topik Favorit? Langsung Ada!",
      "desc":
          "Suka bola? Teknologi? Kuliner? Kamu bisa pilih topik favorit, dan kami kasih berita yang kamu banget.",
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Fungsi untuk navigasi ke halaman login
  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Tombol "Lewati" di pojok kanan atas
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _navigateToLogin,
                child: Text(
                  'Lewati',
                  style: TextStyle(color: _primaryColor, fontSize: 16),
                ),
              ),
            ),
            // Expanded agar PageView mengisi ruang yang tersedia
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: introData.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  final item = introData[index];
                  return _buildPageContent(
                    image: item['image']!,
                    title: item['title']!,
                    desc: item['desc']!,
                  );
                },
              ),
            ),
            // Kontrol Bawah (Indikator & Tombol)
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  // Widget untuk membangun konten setiap halaman dengan animasi
  Widget _buildPageContent({
    required String image,
    required String title,
    required String desc,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image, height: MediaQuery.of(context).size.height * 0.35)
              .animate()
              .fade(duration: 500.ms)
              .scale(
                delay: 200.ms,
                duration: 400.ms,
                curve: Curves.easeOutBack,
              ),
          const SizedBox(height: 48),
          Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF333333),
                ),
              )
              .animate()
              .fade(delay: 400.ms, duration: 500.ms)
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: 16),
          Text(
                desc,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              )
              .animate()
              .fade(delay: 600.ms, duration: 500.ms)
              .slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  // Widget untuk membangun kontrol bawah
  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          // Indikator Titik
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              introData.length,
              (index) => _buildDotIndicator(index),
            ),
          ),
          const SizedBox(height: 40),
          // Tombol Aksi Utama
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                if (_currentPage < introData.length - 1) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                } else {
                  _navigateToLogin();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _currentPage < introData.length - 1 ? 'Lanjut' : 'Mulai',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Indikator titik yang dianimasikan
  Widget _buildDotIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      height: 10,
      width: _currentPage == index ? 25 : 10, // Lebar berubah saat aktif
      decoration: BoxDecoration(
        color: _currentPage == index ? _primaryColor : Colors.grey[300],
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
