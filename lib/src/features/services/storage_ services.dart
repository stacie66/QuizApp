// lib/src/features/services/storage_services.dart
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:flashcards/src/features/models/flashcards_model.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Upload file to Supabase storage
  Future<String?> uploadFile(File file) async {
    try {
      final fileName = '${const Uuid().v4()}${path.extension(file.path)}';
      final storageResponse = await _supabase
          .storage
          .from('flashcard_documents')
          .upload(fileName, file);
      
      return _supabase
          .storage
          .from('flashcard_documents')
          .getPublicUrl(fileName);
    } catch (e) {
      print("Storage service upload error: $e");
      return null;
    }
  }
  
  // Get all flashcard collections for user
  Future<List<FlashcardCollection>> getFlashcardCollections(String userId) async {
    try {
      final collectionsResponse = await _supabase
          .from('flashcard_collections')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      List<FlashcardCollection> collections = [];
      
      for (var collectionData in collectionsResponse) {
        // Get flashcards for this collection
        final flashcardsResponse = await _supabase
            .from('flashcards')
            .select()
            .eq('collection_id', collectionData['id']);
        
        List<Flashcard> flashcards = flashcardsResponse
            .map<Flashcard>((map) => Flashcard.fromMap(map))
            .toList();
        
        collections.add(FlashcardCollection.fromMap(collectionData, flashcards));
      }
      
      return collections;
    } catch (e) {
      print("Error getting flashcard collections: $e");
      return [];
    }
  }
  
  // Update flashcard
  Future<void> updateFlashcard(String collectionId, Flashcard flashcard) async {
    try {
      await _supabase
          .from('flashcards')
          .update(flashcard.toMap())
          .eq('id', flashcard.id)
          .eq('collection_id', collectionId);
    } catch (e) {
      print("Error updating flashcard: $e");
      throw e;
    }
  }
  
  // Add new collection with flashcards
  Future<String> addCollection(String userId, String title, String category, 
      String summary, String filePath, List<Flashcard> flashcards) async {
    try {
      final collectionId = const Uuid().v4();
      
      // Create collection
      await _supabase.from('flashcard_collections').insert({
        'id': collectionId,
        'title': title,
        'category': category,
        'summary': summary,
        'file_path': filePath,
        'user_id': userId,
        'created_at': DateTime.now().toIso8601String(),
      });
      
      // Add flashcards to collection
      for (var flashcard in flashcards) {
        await _supabase.from('flashcards').insert({
          ...flashcard.toMap(),
          'collection_id': collectionId,
        });
      }
      
      return collectionId;
    } catch (e) {
      print("Error adding collection: $e");
      throw e;
    }
  }
}