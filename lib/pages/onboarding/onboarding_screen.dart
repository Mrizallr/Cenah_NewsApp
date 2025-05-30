import 'package:flutter/material.dart';

import 'package:cenah_news/pages/auth/login_screen.dart';

class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({super.key});

  @override
  State<IntroductionScreen> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _skipIntro() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()), // Navigasi ke Login
    );
  }

  void _nextPage() {
    if (_currentPage < 1) { // Karena ada 2 slide (indeks 0 dan 1)
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      _skipIntro(); // Jika sudah slide terakhir, langsung ke login
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: const [
              // Slide 1
              IntroPage(
                imagePath: 'assets/images/intro1.png', // Pastikan nama file cocok
                title: 'Everything You Need to Know',
                description: 'Get all the latest information, from politics, social, culinary and even occult information',
              ),
              // Slide 2 (sesuai UI yang Anda berikan, saya asumsikan ini slide terakhir sebelum Get Started)
              IntroPage(
                imagePath: 'assets/images/intro2.png', // Pastikan nama file cocok
                title: "It's all here",
                description: 'You can get all the latest gossip and news from various sources, all in one place',
              ),
              // Saya tidak menambahkan slide 3 karena Anda ingin hanya 2 slide
              // Jika nanti ada perubahan dan perlu 3 slide, Anda bisa menambahkannya di sini.
            ],
          ),
          // Dots Indicator
          Align(
            alignment: const Alignment(0, 0.7), // Sesuaikan posisi vertikal dots
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                2, // Jumlah slide
                (index) => buildDot(index, _currentPage),
              ),
            ),
          ),
          // Buttons (Skip / Next / Get Started)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40.0, left: 20.0, right: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Skip Button
                  TextButton(
                    onPressed: _skipIntro,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  // Next / Get Started Button
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Warna tombol
                      foregroundColor: Colors.white, // Warna teks tombol
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      _currentPage == 1 ? 'Get Started' : 'Next',
                      style: const TextStyle(fontSize: 16),
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

  Widget buildDot(int index, int currentPage) {
    return Container(
      height: 8,
      width: currentPage == index ? 24 : 8, // Dot yang aktif lebih panjang
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: currentPage == index ? Colors.blue : Colors.grey, // Warna dot aktif/tidak aktif
      ),
    );
  }
}

// Widget pembantu untuk setiap halaman intro
class IntroPage extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;

  const IntroPage({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            height: 250, // Sesuaikan ukuran gambar
          ),
          const SizedBox(height: 50),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}