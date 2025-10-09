// lib/screens/home_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:targetku/models/target_model.dart';
import 'package:targetku/screens/add_target_screen.dart';
import 'package:targetku/services/auth_service.dart';
import 'package:targetku/services/firestore_service.dart';
import 'package:targetku/widgets/custom_notification.dart';
import 'package:targetku/widgets/home_cards.dart';

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

  Future<void> _navigateAndAddNewTarget() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddTargetScreen()),
    );
    if (result == true && mounted) {
      _showSuccessNotification(
          title: "Target Tersimpan!", message: "Progresmu telah dimulai.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    const Color darkColor = Color(0xFF2D3748);
    const Color accentColor = Color(0xFFF6C634);
    const Color backgroundColor = Color.fromARGB(255, 255, 255, 255);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Hi, ${user?.displayName ?? 'Pengguna'} 👋',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 20, color: darkColor, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: darkColor),
                  children: const [
                    TextSpan(text: 'Closer to your '),
                    TextSpan(
                        text: 'goal',
                        style: TextStyle(color: accentColor)),
                    TextSpan(text: ' today?'),
                  ],
                ),
              ),
          ],
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        toolbarHeight: 80,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded, color: darkColor),
              onPressed: () => AuthService().signOut(),
              tooltip: 'Logout',
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService().getTargetsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: darkColor));
          }

          List<TargetModel> targets = snapshot.data?.docs
              .map((doc) => TargetModel.fromFirestore(doc))
              .toList() ??
              [];

          double totalCurrentAmount =
              targets.fold(0.0, (sum, target) => sum + target.currentAmount);
          double totalTargetAmount =
              targets.fold(0.0, (sum, target) => sum + target.targetAmount);

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: TotalSavingsCard(
                    totalCurrentAmount: totalCurrentAmount,
                    totalTargetAmount: totalTargetAmount,
                    onAddNewTargetPressed: _navigateAndAddNewTarget,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                sliver: SliverToBoxAdapter(
                  child: Text('Target Aktifmu',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: darkColor)),
                ),
              ),
              if (targets.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.savings_outlined,
                            size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('Belum ada target',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 18, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text('Tekan tombol + untuk menambah target baru',
                            style:
                                GoogleFonts.plusJakartaSans(color: Colors.grey)),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return TargetCard(
                          target: targets[index],
                          showNotification: _showSuccessNotification,
                        );
                      },
                      childCount: targets.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateAndAddNewTarget,
        backgroundColor: accentColor,
        foregroundColor: darkColor,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}