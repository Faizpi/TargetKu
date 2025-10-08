// lib/screens/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:targetku/auth_gate.dart';
import 'package:animate_do/animate_do.dart'; // <-- Import package animasi

class OnboardingPageData {
  final String title;
  final String body;
  final String imagePath;
  final Color color;

  OnboardingPageData({
    required this.title,
    required this.body,
    required this.imagePath,
    required this.color,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // DIUBAH: Kita kembalikan warna yang berbeda untuk setiap halaman
  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      title: "Catat Target Impianmu",
      body: "Mulai dari hal kecil. Catat dan rencanakan tabunganmu untuk wujudkan impian besar.",
      imagePath: 'assets/images/celengan.png',
      color: const Color(0xFFF6C634), // Kuning
    ),
    OnboardingPageData(
      title: "Lacak Progresmu",
      body: "Pantau setiap langkah menuju tujuanmu lewat visual progres yang memotivasi.",
      imagePath: 'assets/images/celengan.png',
      color: const Color(0xFFF6C634), // Kuning
    ),
    OnboardingPageData(
      title: "Wujudkan Satu per Satu",
      body: "Nikmati hasil kerja kerasmu. Satu per satu impian akan tercapai dengan konsistensi.",
      imagePath: 'assets/images/celengan.png',
      color: const Color(0xFFF6C634), // Biru
    ),
  ];

  // BARU: Variabel untuk animasi warna latar belakang
  late Color _backgroundColor;

  @override
  void initState() {
    super.initState();
    _backgroundColor = _pages[0].color; // Set warna awal
    _pageController.addListener(() {
      int nextPage = _pageController.page!.round();
      if (_currentPage != nextPage) {
        setState(() {
          _currentPage = nextPage;
          _backgroundColor = _pages[_currentPage].color; // Update warna saat halaman berubah
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  void _navigateToAuthGate() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AuthGate()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // BARU: Gunakan AnimatedContainer untuk transisi warna yang halus
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      color: _backgroundColor,
      child: Scaffold(
        backgroundColor: Colors.transparent, // Buat Scaffold transparan
        body: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                // Kirim currentPage agar animasi tahu kapan harus berjalan
                return _OnboardingPage(data: _pages[index], isCurrentPage: index == _currentPage);
              },
            ),
            Positioned(
              top: 40.0,
              right: 20.0,
              child: FadeIn( // Animasi fade-in untuk tombol
                delay: const Duration(milliseconds: 500),
                child: TextButton(
                  onPressed: _navigateToAuthGate,
                  child: Text(
                    'Skip',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 30.0,
              left: 30.0,
              right: 30.0,
              child: FadeInUp( // Animasi fade-in dan slide-up untuk kontrol bawah
                delay: const Duration(milliseconds: 500),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.black12,
                      child: Icon(Icons.savings, color: Colors.white),
                    ),
                    InkWell(
                      onTap: () {
                        if (_currentPage < _pages.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _navigateToAuthGate();
                        }
                      },
                      child: Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Icon(
                            _currentPage < _pages.length - 1 
                              ? Icons.arrow_forward_ios_rounded
                              : Icons.check_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget terpisah untuk tampilan satu halaman
class _OnboardingPage extends StatelessWidget {
  final OnboardingPageData data;
  final bool isCurrentPage; // Terima info apakah ini halaman aktif

  const _OnboardingPage({required this.data, required this.isCurrentPage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 2),
          Center(
            // BARU: Animasi gambar (Zoom & Fade)
            child: ZoomIn(
              animate: isCurrentPage, // Hanya animasi saat halaman aktif
              duration: const Duration(milliseconds: 800),
              child: Image.asset(data.imagePath, height: 250),
            ),
          ),
          const SizedBox(height: 50),
          // BARU: Animasi teks judul (Fade & Slide)
          FadeInUp(
            animate: isCurrentPage,
            delay: const Duration(milliseconds: 200),
            duration: const Duration(milliseconds: 600),
            child: Text(
              data.title,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 32,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 15),
          // BARU: Animasi teks body (Fade & Slide)
          FadeInUp(
            animate: isCurrentPage,
            delay: const Duration(milliseconds: 400),
            duration: const Duration(milliseconds: 600),
            child: Text(
              data.body,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w500,
                fontSize: 18,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}