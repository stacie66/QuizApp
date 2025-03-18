import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flashcards/src/features/models/user_model.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user data
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;
    
    return UserModel.fromFirestore(doc);
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? name,
    String? profession,
    String? profilePicture,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (profession != null) updates['profession'] = profession;
    if (profilePicture != null) updates['profilePicture'] = profilePicture;

    await _firestore.collection('users').doc(user.uid).update(updates);
  }

  // Update user stats
  Future<void> updateUserStats({
    int? cardsCompleted,
    int? cardsMemorized,
    int? streakDays,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    final updates = <String, dynamic>{};
    if (cardsCompleted != null) updates['stats.cardsCompleted'] = cardsCompleted;
    if (cardsMemorized != null) updates['stats.cardsMemorized'] = cardsMemorized;
    if (streakDays != null) updates['stats.streakDays'] = streakDays;

    await _firestore.collection('users').doc(user.uid).update(updates);
  }

  // Add a new collection
  Future<void> addCollection(String name, int cardCount) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    await _firestore.collection('users').doc(user.uid).update({
      'collections': FieldValue.arrayUnion([
        {
          'name': name,
          'cardCount': cardCount,
          'createdAt': Timestamp.now(),
        }
      ])
    });
  }
}