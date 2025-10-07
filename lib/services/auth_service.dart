// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Stream untuk memantau status login pengguna
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Fungsi untuk Daftar dengan Email & Password
  Future<String?> createUserWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Setelah berhasil mendaftar, update nama pengguna
      await userCredential.user?.updateDisplayName(name);
      return null; // Sukses
    } on FirebaseAuthException catch (e) {
      // Mengembalikan pesan error yang lebih mudah dimengerti
      if (e.code == 'weak-password') {
        return 'Password yang dimasukkan terlalu lemah.';
      } else if (e.code == 'email-already-in-use') {
        return 'Akun dengan email ini sudah ada.';
      }
      return 'Terjadi kesalahan. Silakan coba lagi.';
    } catch (e) {
      return e.toString();
    }
  }

  // Fungsi untuk Masuk dengan Email & Password
  Future<String?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Sukses
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        return 'Email atau password salah.';
      }
      return 'Terjadi kesalahan. Silakan coba lagi.';
    } catch (e) {
      return e.toString();
    }
  }

  // Fungsi untuk Masuk dengan Google
  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return 'Login Google dibatalkan.'; // Pengguna membatalkan login
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      return null; // Sukses
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // Fungsi untuk Keluar (Logout)
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}