import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:targetku/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Semua field harus diisi')));
      return;
    }
    setState(() => _isLoading = true);
    final authService = AuthService();
    final result = await authService.createUserWithEmailAndPassword(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (result == null) {
        print("PENDAFTARAN BERHASIL!");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color darkColor = Color(0xFF4A4A4A);
    return Scaffold(
      backgroundColor: const Color(0xFFF6C634),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6C634),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Buat Akun Baru', style: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.black87)),
              const SizedBox(height: 8),
              Text('Daftar untuk mulai menabung impianmu.', style: GoogleFonts.plusJakartaSans(fontSize: 16, color: Colors.black54)),
              const SizedBox(height: 48),
              TextField(controller: _nameController, decoration: _buildInputDecoration('Nama Lengkap')),
              const SizedBox(height: 20),
              TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: _buildInputDecoration('Email')),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: _buildInputDecoration('Password').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility, color: Colors.black54),
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('Daftar', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Sudah punya akun?', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.black87)),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Masuk di sini',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.plusJakartaSans(color: Colors.black54),
      filled: true,
      fillColor: Colors.white.withOpacity(0.4),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white, width: 2)),
    );
  }
}