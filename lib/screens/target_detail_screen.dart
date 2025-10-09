// lib/screens/target_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:targetku/models/target_model.dart';
import 'package:targetku/screens/edit_target_screen.dart';
import 'package:targetku/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:targetku/widgets/custom_notification.dart';

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

  // Fungsi untuk menampilkan notifikasi custom
  void _showSuccessNotification({
    required String title,
    required String message,
  }) {
    final overlay = Overlay.of(context);
    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 60,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: SlideTransitionNotification(
            title: title,
            message: message,
            onRemove: () {
              overlayEntry?.remove();
            },
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
  }

  // Fungsi untuk menambah tabungan
  Future<void> _addSavings() async {
    // Sembunyikan keyboard
    FocusScope.of(context).unfocus();

    final amountToAdd = double.tryParse(_amountController.text);
    if (amountToAdd == null || amountToAdd <= 0) {
      // Tampilkan notifikasi jika input tidak valid
      _showSuccessNotification(
        title: "Input Tidak Valid",
        message: "Silakan masukkan nominal yang benar.",
      );
      return;
    }

    // Tampilkan notifikasi optimis
    _showSuccessNotification(
        title: "Tabungan Ditambahkan!", message: "Progresmu sedang diperbarui.");

    try {
      await FirestoreService().updateTargetAmount(
        targetId: widget.target.id,
        amountToAdd: amountToAdd,
      );
      // Setelah berhasil, bersihkan input field
      if (mounted) {
        _amountController.clear();
      }
    } catch (e) {
      print("Gagal mengupdate tabungan: $e");
      if (mounted) {
        _showSuccessNotification(
          title: "Gagal Menyimpan",
          message: "Terjadi kesalahan. Coba lagi.",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color darkColor = Color(0xFF2D3748);
    const Color accentColor = Color(0xFFF4C634);

    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('targets')
            .doc(widget.target.id)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
                backgroundColor: Colors.white,
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
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(updatedTarget.title,
                  style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold, color: darkColor)),
              backgroundColor: Colors.white,
              foregroundColor: darkColor,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            EditTargetScreen(target: updatedTarget),
                      ),
                    );
                    if (result == 'edit_success' && mounted) {
                      _showSuccessNotification(
                          title: "Target Diperbarui!",
                          message: "Detail target berhasil diubah.");
                    }
                  },
                  tooltip: 'Edit Target',
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset(updatedTarget.iconName,
                              fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(updatedTarget.title,
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: darkColor)),
                            const SizedBox(height: 8),
                            Text(
                                'dari ${currencyFormatter.format(updatedTarget.targetAmount)}',
                                style: GoogleFonts.plusJakartaSans(
                                    color: Colors.grey[600], fontSize: 16)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 12,
                    borderRadius: BorderRadius.circular(6),
                    backgroundColor: accentColor.withOpacity(0.2),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(accentColor),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          currencyFormatter.format(updatedTarget.currentAmount),
                          style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('$percentage%',
                          style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                              fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 48),
                  Text('Tambah Tabungan',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: darkColor)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration:
                              _buildInputDecoration('Masukkan Nominal'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _addSavings,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: darkColor,
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

  InputDecoration _buildInputDecoration(String label) {
    const Color accentColor = Color(0xFFF5C634);
    return InputDecoration(
      labelText: label,
      prefixText: 'Rp ',
      labelStyle: GoogleFonts.plusJakartaSans(color: Colors.grey),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentColor, width: 2)),
    );
  }
}