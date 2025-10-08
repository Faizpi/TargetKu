// lib/screens/target_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:targetku/models/target_model.dart';
import 'package:targetku/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TargetDetailScreen extends StatefulWidget {
  final TargetModel target;
  const TargetDetailScreen({super.key, required this.target});

  @override
  State<TargetDetailScreen> createState() => _TargetDetailScreenState();
}

class _TargetDetailScreenState extends State<TargetDetailScreen> {
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _addSavings() async {
    final amountToAdd = double.tryParse(_amountController.text);
    if (amountToAdd == null || amountToAdd <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nominal yang valid.')),
      );
      return;
    }

    Navigator.of(context).pop('update_success');

    try {
      await FirestoreService().updateTargetAmount(
        targetId: widget.target.id,
        amountToAdd: amountToAdd,
      );
    } catch (e) {
      print("Gagal mengupdate tabungan: $e");
    }
  }

  // Helper method untuk styling input, disamakan dengan AddTargetScreen
  InputDecoration _buildInputDecoration(String label) {
    const Color accentColor = Color(0xFFF6C634);
    return InputDecoration(
      labelText: label,
      prefixText: 'Rp ',
      labelStyle: GoogleFonts.plusJakartaSans(color: Colors.grey),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: accentColor, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color darkColor = Color(0xFF4A4A4A);
    const Color accentColor = Color(0xFFF6C634);

    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('targets')
            .doc(widget.target.id)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }
          final updatedTarget = TargetModel.fromFirestore(snapshot.data!);
          final currencyFormatter = NumberFormat.currency(
              locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
          final double progress = (updatedTarget.targetAmount > 0)
              ? (updatedTarget.currentAmount / updatedTarget.targetAmount)
              : 0;
          final int percentage = (progress * 100).toInt();

          return Scaffold(
            backgroundColor: Colors.white, // DIUBAH: Latar belakang putih
            appBar: AppBar(
              title: Text(updatedTarget.title,
                  style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold, color: darkColor)),
              backgroundColor: Colors.white, // DIUBAH: AppBar putih
              foregroundColor: darkColor,
              elevation: 0, // DIUBAH: Hilangkan bayangan
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(updatedTarget.title,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: darkColor)),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 12,
                    borderRadius: BorderRadius.circular(6),
                    backgroundColor: accentColor.withOpacity(0.2), // DIUBAH
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(accentColor), // DIUBAH
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(currencyFormatter.format(updatedTarget.currentAmount),
                          style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold)),
                      Text('$percentage%',
                          style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold, color: accentColor)), // DIUBAH
                    ],
                  ),
                  Text(
                      'dari ${currencyFormatter.format(updatedTarget.targetAmount)}',
                      style: GoogleFonts.plusJakartaSans(color: Colors.grey[600])),
                  const SizedBox(height: 48),
                  Text('Tambah Tabungan',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration:
                              _buildInputDecoration('Masukkan Nominal'), // DIUBAH
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _addSavings,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              accentColor, // DIUBAH: Tombol jadi kuning
                          foregroundColor: darkColor, // DIUBAH: Ikon jadi gelap
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 24),
                        ),
                        child: const Icon(Icons.add),
                      )
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }
}