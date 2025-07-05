import 'package:cenah_news/src/pages/onboarding/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// Gunakan 'SingleTickerProviderStateMixin' untuk mengontrol animasi
class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  // Definisikan warna utama agar konsisten dengan halaman lain
  static final Color _primaryColor = Colors.blueAccent;

  @override
  void initState() {
    super.initState();

    // Inisialisasi AnimationController dengan durasi yang lebih lama
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 3,
      ), // Durasi animasi diperpanjang menjadi 3 detik
    );

    // Definisikan jenis animasi yang diinginkan
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    // Jalankan animasi
    _controller.forward();

    // Atur timer untuk navigasi setelah waktu yang lebih lama
    Timer(const Duration(seconds: 5), () {
      // Waktu tunggu diperpanjang menjadi 5 detik
      _navigateToOnboarding();
    });
  }

  void _navigateToOnboarding() {
    // Gunakan PageRouteBuilder untuk transisi fade yang mulus
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                const Introductionscreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(
          milliseconds: 1000,
        ), // Durasi transisi juga bisa disesuaikan
      ),
    );
  }

  @override
  void dispose() {
    // Hapus controller untuk mencegah kebocoran memori
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dapatkan ukuran layar untuk layout yang lebih responsif
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation, // Terapkan animasi fade ke seluruh konten
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Terapkan animasi scale ke logo
              ScaleTransition(
                scale: _scaleAnimation,
                child: Image.asset(
                  'assets/images/logo.png',
                  // Gunakan sebagian kecil dari lebar layar agar responsif
                  width: screenWidth * 0.6,
                ),
              ),
              const SizedBox(height: 24),
              // Tambahkan tagline dengan animasi fade
              FadeTransition(
                opacity: _fadeAnimation,
                child: const Text(
                  'Berita Terkini dan Terpercaya',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 80),
              SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  color: _primaryColor, // Gunakan warna tema utama
                  strokeWidth: 3.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
