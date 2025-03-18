// lib/src/features/models/flashcards_model.dart
import 'package:uuid/uuid.dart';

class Flashcard {
  final String id;
  final String question;
  final String answer;
  bool isMemorized;

  Flashcard({
    required this.id,
    required this.question, 
    required this.answer,
    this.isMemorized = false,
  });

  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
      id: map['id'] ?? const Uuid().v4(),
      question: map['question'] ?? '',
      answer: map['answer'] ?? '',
      isMemorized: map['is_memorized'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'is_memorized': isMemorized,
    };
  }
}

class FlashcardCollection {
  final String id;
  final String title;
  final String category;
  final String summary;
  final String filePath;
  final DateTime createdAt;
  final List<Flashcard> flashcards;

  FlashcardCollection({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.filePath,
    required this.createdAt,
    required this.flashcards,
  });

  factory FlashcardCollection.fromMap(Map<String, dynamic> map, List<Flashcard> cards) {
    return FlashcardCollection(
      id: map['id'] ?? const Uuid().v4(),
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      summary: map['summary'] ?? '',
      filePath: map['file_path'] ?? '',
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at']) 
          : DateTime.now(),
      flashcards: cards,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'summary': summary,
      'file_path': filePath,
      'created_at': createdAt.toIso8601String(),
    };
  }
}