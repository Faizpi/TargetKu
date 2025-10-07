// lib/models/target_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TargetModel {
  final String id;
  final String userId;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final String iconName;
  final Timestamp createdAt;

  TargetModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.iconName,
    required this.createdAt,
  });

  // Factory constructor untuk membuat instance dari Firestore document
  factory TargetModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return TargetModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      targetAmount: (data['targetAmount'] ?? 0).toDouble(),
      currentAmount: (data['currentAmount'] ?? 0).toDouble(),
      iconName: data['iconName'] ?? 'assets/icons/default.png', // Sediakan ikon default
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}