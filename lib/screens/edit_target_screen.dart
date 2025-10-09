import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:targetku/models/target_model.dart';
import 'package:targetku/services/firestore_service.dart';

class EditTargetScreen extends StatefulWidget {
  final TargetModel target;
  const EditTargetScreen({super.key, required this.target});

  @override
  State<EditTargetScreen> createState() => _EditTargetScreenState();
}

class _EditTargetScreenState extends State<EditTargetScreen> {
  late TextEditingController _titleController;
  late TextEditingController _targetAmountController;
  // DIHAPUS: State untuk tanggal tidak diperlukan lagi

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.target.title);
    _targetAmountController = TextEditingController(text: widget.target.targetAmount.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }

  Future<void> _updateTarget() async {
    final title = _titleController.text;
    final targetAmount = double.tryParse(_targetAmountController.text);

    // DIHAPUS: Validasi tanggal
    if (title.isEmpty || targetAmount == null || targetAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul dan Nominal Target harus diisi.')),
      );
      return;
    }

    try {
      await FirestoreService().editTarget(
        targetId: widget.target.id,
        newTitle: title,
        newTargetAmount: targetAmount,
        // DIHAPUS: Pengiriman data tanggal
      );
      if (mounted) {
      // DIUBAH: Kirim sinyal 'edit_success' saat kembali
      Navigator.of(context).pop('edit_success');
      }
    } catch (e) {
      print("Gagal mengupdate target: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color darkColor = Color(0xFF2D3748);
    const Color accentColor = Color(0xFFF4C634);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Edit Target', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: darkColor)),
        backgroundColor: Colors.white,
        foregroundColor: darkColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ikon Target', style: GoogleFonts.plusJakartaSans(fontSize: 16, color: Colors.grey[700])),
            const SizedBox(height: 12),
            Container(
              height: 80, width: 80,
              decoration: BoxDecoration(color: accentColor.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: ClipRRect(borderRadius: BorderRadius.circular(8.0), child: Image.asset(widget.target.iconName, fit: BoxFit.cover)),
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _titleController,
              decoration: _buildInputDecoration('Judul Target'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _targetAmountController,
              decoration: _buildInputDecoration('Nominal Target'),
              keyboardType: TextInputType.number,
            ),
            // DIHAPUS: Seluruh UI untuk memilih tanggal
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateTarget,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: darkColor,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Simpan Perubahan', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    const Color accentColor = Color(0xFFF4C634);
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.plusJakartaSans(color: Colors.grey),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: accentColor, width: 2)),
    );
  }
}