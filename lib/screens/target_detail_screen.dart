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

  // DIUBAH: Logika baru yang lebih responsif
  Future<void> _addSavings() async {
    final amountToAdd = double.tryParse(_amountController.text);
    if (amountToAdd == null || amountToAdd <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nominal yang valid.')),
      );
      return;
    }

    // 1. Langsung kembali ke Home dan kirim sinyal 'update_success'
    Navigator.of(context).pop('update_success');

    // 2. Proses update berjalan di latar belakang
    try {
      await FirestoreService().updateTargetAmount(
        targetId: widget.target.id,
        amountToAdd: amountToAdd,
      );
    } catch (e) {
      print("Gagal mengupdate tabungan: $e");
      // Di sini bisa ditambahkan notifikasi error global jika perlu
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color darkColor = Color(0xFF4A4A4A);
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('targets').doc(widget.target.id).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final updatedTarget = TargetModel.fromFirestore(snapshot.data!);
        final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
        final double progress = (updatedTarget.targetAmount > 0) ? (updatedTarget.currentAmount / updatedTarget.targetAmount) : 0;
        final int percentage = (progress * 100).toInt();

        return Scaffold(
          appBar: AppBar(
            title: Text(updatedTarget.title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: darkColor)),
            backgroundColor: Colors.white,
            foregroundColor: darkColor,
            elevation: 1,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(updatedTarget.title, style: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.bold, color: darkColor)),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: progress, minHeight: 12, borderRadius: BorderRadius.circular(6),
                  backgroundColor: Colors.grey[200], valueColor: const AlwaysStoppedAnimation<Color>(const Color(0xFFF6C634)),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(currencyFormatter.format(updatedTarget.currentAmount), style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                    Text('$percentage%', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: const Color(0xFFF6C634))),
                  ],
                ),
                Text('dari ${currencyFormatter.format(updatedTarget.targetAmount)}', style: GoogleFonts.plusJakartaSans(color: Colors.grey[600])),
                const SizedBox(height: 48),
                Text('Tambah Tabungan', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Masukkan Nominal', prefixText: 'Rp ',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // DIUBAH: Tombol tidak lagi memiliki state loading
                    ElevatedButton(
                      onPressed: _addSavings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      ),
                      child: const Icon(Icons.add, color: Colors.white),
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}