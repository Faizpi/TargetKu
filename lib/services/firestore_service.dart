// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // BARU: Fungsi untuk mengupdate jumlah tabungan
  Future<void> updateTargetAmount({
    required String targetId,
    required double amountToAdd,
  }) async {
    // Gunakan FieldValue.increment untuk operasi yang aman
    await _db.collection('targets').doc(targetId).update({
      'currentAmount': FieldValue.increment(amountToAdd),
    });
  }
    // BARU: Fungsi untuk menghapus target
  Future<void> deleteTarget(String targetId) async {
    await _db.collection('targets').doc(targetId).delete();
  }

  // Fungsi untuk menambah target baru
  Future<void> addTarget({
    required String title,
    required double targetAmount,
    String iconName = 'assets/icons/default.png', // Default icon
  }) async {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception("Pengguna belum login!");
    }

    await _db.collection('targets').add({
      'userId': user.uid,
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': 0.0, // Selalu mulai dari 0
      'iconName': iconName,
      'createdAt': Timestamp.now(),
    });
  }

  // Stream untuk mendapatkan semua target milik pengguna yang sedang login
  Stream<QuerySnapshot> getTargetsStream() {
    final User? user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return _db
        .collection('targets')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true) // Tampilkan yang terbaru di atas
        .snapshots();
  }
}