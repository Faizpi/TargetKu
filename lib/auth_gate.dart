// lib/auth_gate.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:targetku/screens/home_screen.dart';
import 'package:targetku/screens/login_screen.dart';
import 'package:targetku/services/auth_service.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Memantau perubahan status autentikasi dari AuthService
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        // 1. Menunggu koneksi
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Tampilkan loading indicator saat memeriksa status login
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Jika pengguna sudah login (ada data user)
        if (snapshot.hasData) {
          return const HomeScreen(); // Arahkan ke Halaman Home
        }

        // 3. Jika pengguna belum login (tidak ada data user)
        return const LoginScreen(); // Arahkan ke Halaman Login
      },
    );
  }
}