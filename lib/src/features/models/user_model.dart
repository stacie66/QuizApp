import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String profession;
  final String profilePicture;
  final int cardsCompleted;
  final int cardsMemorized;
  final int streakDays;
  final List<Map<String, dynamic>> collections;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.profession,
    required this.profilePicture,
    required this.cardsCompleted,
    required this.cardsMemorized,
    required this.streakDays,
    required this.collections,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data();
    if (data == null) {
      throw Exception('Document data is null');
    }
    final map = data as Map<String, dynamic>;
    final stats = map['stats'] as Map<String, dynamic>? ?? {};
    return UserModel(
      id: doc.id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      profession: map['profession'] ?? '',
      profilePicture: map['profilePicture'] ?? '',
      cardsCompleted: stats['cardsCompleted'] ?? 0,
      cardsMemorized: stats['cardsMemorized'] ?? 0,
      streakDays: stats['streakDays'] ?? 0,
      collections: List<Map<String, dynamic>>.from(map['collections'] ?? []),
    );
  }
}

