// lib/widgets/home_cards.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:targetku/models/target_model.dart';
import 'package:targetku/screens/target_detail_screen.dart';
import 'package:targetku/services/firestore_service.dart';
import 'dart:ui';

// WIDGET TOTAL SAVINGS CARD (GLASSMORPHISM)
class TotalSavingsCard extends StatelessWidget {
  final double totalCurrentAmount;
  final double totalTargetAmount;
  final VoidCallback onAddNewTargetPressed;

  const TotalSavingsCard({
    super.key,
    required this.totalCurrentAmount,
    required this.totalTargetAmount,
    required this.onAddNewTargetPressed,
  });

  @override
  Widget build(BuildContext context) {
    const Color darkColor = Color(0xFF4A4A4A);
    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final double totalProgress =
        (totalTargetAmount > 0) ? (totalCurrentAmount / totalTargetAmount) : 0;
    final int totalPercentage = (totalProgress * 100).toInt();

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.3),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Tabungan',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: darkColor.withOpacity(0.8)),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // DIUBAH: Bungkus Column dengan Expanded
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currencyFormatter.format(totalCurrentAmount),
                          // BARU: Atur agar teks bisa mengecil jika tidak muat
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: darkColor),
                        ),
                        Text(
                          '/ ${currencyFormatter.format(totalTargetAmount)}',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 18, color: darkColor.withOpacity(0.7)),
                        ),
                      ],
                    ),
                  ),
                  // Beri sedikit jarak antara teks dan lingkaran
                  const SizedBox(width: 16),
                  
                  // Bagian SizedBox dan Stack ini tidak berubah
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 150,
                          height: 150,
                          child: CircularProgressIndicator(
                          value: totalProgress,
                          strokeWidth: 14,
                          backgroundColor: darkColor.withOpacity(0.1),
                          valueColor: const AlwaysStoppedAnimation<Color>(const Color(0xFFF6C634)),
                          ),
                        ),
                        Text(
                          '$totalPercentage%',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: darkColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// WIDGET KARTU TARGET (DIUBAH MENJADI GLASSMORPHISM)
class TargetCard extends StatelessWidget {
  final TargetModel target;
  final Function({required String title, required String message})
      showNotification;
  const TargetCard(
      {super.key, required this.target, required this.showNotification});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final String currentFormatted =
        currencyFormatter.format(target.currentAmount);
    final String targetFormatted =
        currencyFormatter.format(target.targetAmount);
    final double progress = (target.targetAmount > 0)
        ? (target.currentAmount / target.targetAmount)
        : 0;
    final int percentage = (progress * 100).toInt();

    const Color darkColor = Color(0xFF4A4A4A);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Dismissible(
        key: Key(target.id),
        direction: DismissDirection.endToStart,
        background: ClipRRect(
          borderRadius: BorderRadius.circular(20), // Samakan radiusnya
          child: Container(
            color: Colors.redAccent,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerRight,
            child: const Icon(Icons.delete_forever, color: Colors.white, size: 30),
          ),
        ),
        onDismissed: (direction) {
          FirestoreService().deleteTarget(target.id);
          showNotification(
            title: "Target Dihapus",
            message: "'${target.title}' telah berhasil dihapus."
          );
        },
        child: InkWell(
          onTap: () async {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => TargetDetailScreen(target: target)),
            );
            if (result == 'update_success') {
              showNotification(
                  title: "Tabungan Ditambahkan!",
                  message: "Kamu semakin dekat dengan tujuanmu!");
            }
          },
          borderRadius: BorderRadius.circular(20), // Samakan radiusnya
          // DIUBAH: Terapkan efek Glassmorphism
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.3), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.asset(target.iconName, fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(target.title,
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18, fontWeight: FontWeight.bold, color: darkColor)),
                        ),
                        Text('$percentage%',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: darkColor)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: darkColor.withOpacity(0.1),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(const Color(0xFFF6C634)),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    Text('$currentFormatted / $targetFormatted',
                        style: GoogleFonts.plusJakartaSans(
                            color: darkColor.withOpacity(0.7))),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}