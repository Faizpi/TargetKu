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
  void _showSuccessNotification(
      {required String title, required String message}) {
    final overlay = Overlay.of(context);
    OverlayEntry? overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: SlideTransitionNotification(
            title: title,
            message: message,
            onRemove: () => overlayEntry?.remove(),
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
    const Color darkColor = Color(0xFF4A4A4A);

    return Scaffold(
      backgroundColor: const Color(0xFFF6C634),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Halo, ${user?.displayName ?? 'Pengguna'}!',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: darkColor)),
            Text('Ayo lanjutkan progres tabunganmu',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 14, color: Colors.grey[700])),
          ],
        ),
        backgroundColor: const Color(0xFFF6C634),
        elevation: 0,
        toolbarHeight: 80,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: darkColor),
            onPressed: () => AuthService().signOut(),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService().getTargetsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          List<TargetModel> targets = snapshot.data?.docs
              .map((doc) => TargetModel.fromFirestore(doc))
              .toList() ?? [];

          double totalCurrentAmount =
              targets.fold(0.0, (sum, target) => sum + target.currentAmount);
          double totalTargetAmount =
              targets.fold(0.0, (sum, target) => sum + target.targetAmount);
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                TotalSavingsCard(
                  totalCurrentAmount: totalCurrentAmount,
                  totalTargetAmount: totalTargetAmount,
                  onAddNewTargetPressed: _navigateAndAddNewTarget,
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text('Targetmu',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: darkColor)),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: targets.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.savings_outlined,
                                  size: 80, color: Colors.black.withOpacity(0.2)),
                              const SizedBox(height: 16),
                              Text('Belum ada target',
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 18, color: Colors.black54)),
                              const Text(
                                  'Silahkan tambah target baru',
                                  style: TextStyle(color: Colors.black54)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
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