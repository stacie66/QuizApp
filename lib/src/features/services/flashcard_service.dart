// lib/src/features/services/flashcard_service.dart
import 'package:flashcards/src/features/models/flashcards_model.dart';
import 'package:flashcards/src/features/services/flashcard_provider.dart';
import 'ai_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flashcards/main.dart'; // For supabase global client

class FlashcardService {
  final String _collectionsTable = 'flashcard_collections';
  final String _flashcardsTable = 'flashcards';
  
  // Get all collections
  Future<List<FlashcardCollection>> getAllCollections() async {
    try {
      // Get collections
      final collectionsData = await supabase
          .from(_collectionsTable)
          .select()
          .order('created_at', ascending: false);
      
      List<FlashcardCollection> collections = [];
      
      // For each collection, get its flashcards
      for (final collectionMap in collectionsData) {
        final String collectionId = collectionMap['id'];
        
        // Get flashcards for this collection
        final flashcardsData = await supabase
            .from(_flashcardsTable)
            .select()
            .eq('collection_id', collectionId);
        
        // Convert to Flashcard objects
        final flashcards = flashcardsData.map((card) => Flashcard.fromMap(card)).toList();
        
        // Create the FlashcardCollection object
        collections.add(FlashcardCollection.fromMap(collectionMap, flashcards));
      }
      
      return collections;
    } catch (e) {
      throw Exception('Failed to load collections: $e');
    }
  }
  
  // Get flashcards for a specific collection
  Future<List<Flashcard>> getFlashcardsForCollection(String collectionId) async {
    try {
      final data = await supabase
          .from(_flashcardsTable)
          .select()
          .eq('collection_id', collectionId);
      
      return data.map((card) => Flashcard.fromMap(card)).toList();
    } catch (e) {
      throw Exception('Failed to load flashcards: $e');
    }
  }
  
  // Save a new collection and its flashcards
  Future<void> saveCollection(FlashcardCollection collection) async {
    try {
      // Insert collection
      await supabase.from(_collectionsTable).insert(collection.toMap());
      
      // Insert all flashcards
      for (final flashcard in collection.flashcards) {
        await supabase.from(_flashcardsTable).insert({
          ...flashcard.toMap(),
          'collection_id': collection.id,
        });
      }
    } catch (e) {
      throw Exception('Failed to save collection: $e');
    }
  }
  
  // Update flashcard memorization status
  Future<void> updateFlashcardMemorizationStatus(String flashcardId, bool isMemorized) async {
    try {
      await supabase
          .from(_flashcardsTable)
          .update({'is_memorized': isMemorized})
          .eq('id', flashcardId);
    } catch (e) {
      throw Exception('Failed to update flashcard: $e');
    }
  }
  
  // Delete a collection and all its flashcards
  Future<void> deleteCollection(String collectionId) async {
    try {
      // Delete flashcards first (due to foreign key constraints)
      await supabase
          .from(_flashcardsTable)
          .delete()
          .eq('collection_id', collectionId);
      
      // Then delete the collection
      await supabase
          .from(_collectionsTable)
          .delete()
          .eq('id', collectionId);
    } catch (e) {
      throw Exception('Failed to delete collection: $e');
    }
  }
}