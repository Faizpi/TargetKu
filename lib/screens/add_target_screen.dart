// lib/screens/add_target_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:targetku/services/firestore_service.dart';

class AddTargetScreen extends StatefulWidget {
  const AddTargetScreen({super.key});

  @override
  State<AddTargetScreen> createState() => _AddTargetScreenState();
}

class _AddTargetScreenState extends State<AddTargetScreen> {
  final _titleController = TextEditingController();
  final _targetAmountController = TextEditingController();

  String? _selectedIconPath;

  final List<String> _iconList = [
    'assets/images/saving.jpeg',
    'assets/images/car.jpeg',
    'assets/images/holiday.jpeg',
    'assets/images/rumah.jpeg',
    'assets/images/hp.jpeg',
    'assets/images/laptop.jpeg',
    'assets/images/bike.jpeg',
    'assets/images/edu.jpeg',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }

  Future<void> _saveTarget() async {
    final title = _titleController.text;
    final targetAmount = double.tryParse(_targetAmountController.text);

    if (title.isEmpty ||
        targetAmount == null ||
        targetAmount <= 0 ||
        _selectedIconPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Semua field termasuk ikon harus diisi.')),
      );
      return;
    }

    Navigator.of(context).pop(true);

    try {
      await FirestoreService().addTarget(
        title: title,
        targetAmount: targetAmount,
        iconName: _selectedIconPath!,
      );
    } catch (e) {
      print("Gagal menyimpan target di latar belakang: $e");
    }
  }

  void _showIconPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _iconList.length,
          itemBuilder: (context, index) {
            final iconPath = _iconList[index];
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedIconPath = iconPath;
                });
                Navigator.of(context).pop();
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: _selectedIconPath == iconPath
                      ? Border.all(color: const Color(0xFFF6C634), width: 2)
                      : null,
                ),
                // DIUBAH: Bungkus Image.asset dengan ClipRRect
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(iconPath, fit: BoxFit.cover),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color darkColor = Color(0xFF4A4A4A);

    return Scaffold(
      appBar: AppBar(
        title: Text('Target Baru',
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold, color: darkColor)),
        backgroundColor: Colors.white,
        foregroundColor: darkColor,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Apa impianmu selanjutnya?',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 24, fontWeight: FontWeight.w700)),
            const SizedBox(height: 32),
            TextField(
              controller: _titleController,
              decoration:
                  _buildInputDecoration('Judul Target (Contoh: Beli Laptop)'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _targetAmountController,
              decoration:
                  _buildInputDecoration('Nominal Target (Contoh: 15000000)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),
            Text('Pilih Ikon:',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 16, color: Colors.grey[700])),
            const SizedBox(height: 12),
            InkWell(
              onTap: _showIconPicker,
              child: Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _selectedIconPath == null
                    ? const Icon(Icons.add_photo_alternate_outlined,
                        color: Colors.grey, size: 40)
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        // DIUBAH: Bungkus Image.asset dengan ClipRRect
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Image.asset(_selectedIconPath!, fit: BoxFit.cover),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveTarget,
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Simpan Target',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.plusJakartaSans(color: Colors.grey),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}