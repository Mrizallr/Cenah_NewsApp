import 'package:cenah_news/src/pages/auth/login_screen.dart';
import 'package:flutter/material.dart';

class Introductionscreen extends StatefulWidget {
  const Introductionscreen({super.key});

  @override
  State<Introductionscreen> createState() => _IntroductionscreenState();
}

class _IntroductionscreenState extends State<Introductionscreen> {
  int _currentPage = 0;

  final List<Map<String, String>> introData = [
    {
      "image": "assets/images/slide_1.png",
      "title": "Selalu Update, Gak Kudet!",
      "desc":
          "Baca berita terkini dari berbagai topik — dari politik sampai gosip artis — semua langsung di genggamanmu.",
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

  void _nextPage() {
    if (_currentPage < introData.length - 1) {
      setState(() => _currentPage++);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
    }
  }

  Widget _buildDotIndicator(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 14 : 8,
      height: 8,
      decoration: BoxDecoration(
        color:
            _currentPage == index ? const Color(0xFF007BFF) : Colors.grey[400],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = introData[_currentPage];
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  SizedBox(
                    height: screenHeight * 0.4,
                    child: Image.asset(item['image']!, fit: BoxFit.contain),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      item['title']!,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      item['desc']!,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      introData.length,
                      _buildDotIndicator,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _prevPage,
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007BFF),
                          minimumSize: const Size(double.infinity, 60),
                        ),
                        label: const Text(
                          "Back",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007BFF),
                        minimumSize: const Size(double.infinity, 60),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentPage == introData.length - 1
                                ? "Get Started"
                                : "Next",
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _currentPage == introData.length - 1
                                ? Icons.check
                                : Icons.arrow_forward,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
