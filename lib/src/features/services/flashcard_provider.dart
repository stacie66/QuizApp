// lib/src/features/services/flashcard_provider.dart
import 'package:flutter/material.dart';
import 'package:flashcards/src/features/models/flashcards_model.dart';
import 'package:flashcards/src/features/services/storage_ services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FlashcardProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final List<FlashcardCollection> _collections = [];
  bool _isLoading = false;
  
  // Add the missing getter for flashcards
  List<FlashcardCollection> get collections => _collections;
  List<Flashcard> get flashcards {
    List<Flashcard> allFlashcards = [];
    for (var collection in _collections) {
      allFlashcards.addAll(collection.flashcards);
    }
    return allFlashcards;
  }
  
  bool get isLoading => _isLoading;

  // Add the missing refreshFlashcards method
  Future<void> refreshFlashcards() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        _collections.clear();
        return;
      }
      
      final fetchedCollections = await _storageService.getFlashcardCollections(userId);
      _collections.clear();
      _collections.addAll(fetchedCollections);
    } catch (e) {
      print("Error refreshing flashcards: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Add method to mark flashcard as memorized
  Future<void> toggleFlashcardMemorized(String collectionId, String flashcardId, bool isMemorized) async {
    try {
      final collectionIndex = _collections.indexWhere((c) => c.id == collectionId);
      if (collectionIndex < 0) return;
      
      final flashcardIndex = _collections[collectionIndex].flashcards.indexWhere((f) => f.id == flashcardId);
      if (flashcardIndex < 0) return;
      
      _collections[collectionIndex].flashcards[flashcardIndex].isMemorized = isMemorized;
      
      await _storageService.updateFlashcard(
        collectionId,
        _collections[collectionIndex].flashcards[flashcardIndex],
      );
      
      notifyListeners();
    } catch (e) {
      print("Error toggling flashcard memorized status: $e");
    }
  }
}