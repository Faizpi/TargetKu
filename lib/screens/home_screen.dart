// lib/screens/home_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:targetku/models/target_model.dart';
import 'package:targetku/screens/add_target_screen.dart';
import 'package:targetku/screens/target_detail_screen.dart';
import 'package:targetku/services/auth_service.dart';
import 'package:targetku/services/firestore_service.dart';
import 'dart:ui'; // Diperlukan untuk ImageFilter.blur jika digunakan

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  // Fungsi untuk navigasi ke halaman tambah target
  Future<void> _navigateAndAddNewTarget() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddTargetScreen()),
    );
    if (result == true && mounted) {
      _showSuccessNotification(
          title: "Target Tersimpan!", message: "Semangat menabung!");
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    const Color darkColor = Color(0xFF4A4A4A);

    return Scaffold(
      appBar: AppBar(
        title: Text('TargetKu',
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold, color: darkColor)),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: darkColor),
            onPressed: () => AuthService().signOut(),
            tooltip: 'Logout',
          ),
        ],
      ),
      // PERBAIKAN: Gunakan satu StreamBuilder untuk efisiensi
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService().getTargetsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          List<TargetModel> targets = [];
          if (snapshot.hasData) {
            targets = snapshot.data!.docs
                .map((doc) => TargetModel.fromFirestore(doc))
                .toList();
          }

          double totalCurrentAmount =
              targets.fold(0.0, (sum, target) => sum + target.currentAmount);
          double totalTargetAmount =
              targets.fold(0.0, (sum, target) => sum + target.targetAmount);
          
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Halo, ${user?.displayName ?? 'Pengguna'}!',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: darkColor)),
                Text('Ayo lanjutkan progres tabunganmu.',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 16, color: Colors.grey[600])),
                const SizedBox(height: 24),
                TotalSavingsCard(
                  totalCurrentAmount: totalCurrentAmount,
                  totalTargetAmount: totalTargetAmount,
                  onAddNewTargetPressed: _navigateAndAddNewTarget,
                ),
                const SizedBox(height: 24),
                Text('Targetmu',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: darkColor)),
                const SizedBox(height: 16),
                Expanded(
                  child: targets.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.savings_outlined,
                                  size: 80, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              Text('Belum ada target',
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 18, color: Colors.grey)),
                              const Text(
                                  'Tekan tombol + untuk menambah target baru',
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: targets.length,
                          itemBuilder: (context, index) {
                            return TargetCard(
                              target: targets[index],
                              showNotification: _showSuccessNotification,
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// =============================================================================
// WIDGET BARU: Total Savings Card (dengan warna yang disesuaikan)
// =============================================================================
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
    const Color accentColor = Color(0xFFF6C634); // Kuning

    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    final double totalProgress =
        (totalTargetAmount > 0) ? (totalCurrentAmount / totalTargetAmount) : 0;
    final int totalPercentage = (totalProgress * 100).toInt();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Tabungan',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currencyFormatter.format(totalCurrentAmount),
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: darkColor),
                    ),
                    Text(
                      '/ ${currencyFormatter.format(totalTargetAmount)}',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 18, color: Colors.grey[600]),
                    ),
                  ],
                ),
                SizedBox(
                  width: 60,
                  height: 60,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: totalProgress,
                        strokeWidth: 6,
                        backgroundColor: accentColor.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(accentColor),
                      ),
                      Text(
                        '$totalPercentage%',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: darkColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onAddNewTargetPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Buat Target Baru',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// WIDGET NOTIFIKASI
// =============================================================================
class SlideTransitionNotification extends StatefulWidget {
  final VoidCallback onRemove;
  final String title;
  final String message;
  const SlideTransitionNotification({
    super.key,
    required this.onRemove,
    required this.title,
    required this.message,
  });

  @override
  State<SlideTransitionNotification> createState() =>
      _SlideTransitionNotificationState();
}

class _SlideTransitionNotificationState
    extends State<SlideTransitionNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));

    _slideAnimation =
        Tween(begin: const Offset(0, -2.0), end: const Offset(0, 0)).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 2, milliseconds: 500), () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onRemove();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color darkColor = Color(0xFF4A4A4A);
    return SlideTransition(
      position: _slideAnimation,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: darkColor,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: darkColor, size: 18),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title,
                      style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  Text(widget.message,
                      style: GoogleFonts.plusJakartaSans(
                          color: Colors.white70, fontSize: 13)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// WIDGET KARTU TARGET
// =============================================================================
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

    const Color accentColor = Color(0xFFF6C634); // Warna kuning aksen

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Dismissible(
        key: Key(target.id),
        direction: DismissDirection.endToStart,
        background: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            color: Colors.redAccent,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerRight,
            child: const Icon(Icons.delete_forever, color: Colors.white, size: 30),
          ),
        ),
        onDismissed: (direction) {
          FirestoreService().deleteTarget(target.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${target.title} dihapus')),
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
          borderRadius: BorderRadius.circular(12),
          child: Card(
            elevation: 4,
            margin: EdgeInsets.zero,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
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
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      Text('$percentage%',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: accentColor)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[200],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(accentColor),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Text('$currentFormatted / $targetFormatted',
                      style: GoogleFonts.plusJakartaSans(
                          color: Colors.grey[600])),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}