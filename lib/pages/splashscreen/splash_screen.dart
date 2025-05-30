import 'package:flutter/material.dart';
import 'package:cenah_news/pages/onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigasi ke halaman intro setelah 3 detik
    Future.delayed(const Duration(seconds: 3), () {
      // PERBAIKAN: Tambahkan pemeriksaan 'mounted'
      if (!mounted) return; // Jika widget sudah tidak ada, jangan lakukan navigasi

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const IntroductionScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Sesuaikan warna latar belakang jika perlu
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Cenah News
            Image.asset(
              'assets/images/logo.png', // Pastikan nama file cocok dengan yang di pubspec.yaml
              width: 150, // Sesuaikan ukuran logo
              height: 150, // Sesuaikan ukuran logo
            ),
            const SizedBox(height: 30), // Spasi antara logo dan indikator
            // Indikator loading
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue), // Sesuaikan warna indikator
            ),
          ],
        ),
      ),
    );
  }
}