// lib/src/services/ai_service.dart
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:uuid/uuid.dart';
import 'package:flashcards/src/features/models/flashcards_model.dart';
import 'package:flashcards/src/features/services/flashcard_service.dart';
import 'package:flashcards/main.dart'; // For supabase global client

class AIService {
  // Get API key from .env file
  static String get _apiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';
  
  final FlashcardService _flashcardService = FlashcardService();

  Future<FlashcardCollection> processDocument(File file, String filePath) async {
    try {
      // Upload file to Supabase
      String? fileUrl = await supabaseStorage.uploadFile(file);
      if (fileUrl == null) {
        throw Exception('Failed to upload file to storage');
      }
      
      // Extract text based on file type
      String fileContent = await _extractTextFromFile(file, filePath);
      
      // Truncate content to avoid token limits (adjust as needed)
      if (fileContent.length > 6000) {
        fileContent = fileContent.substring(0, 6000) + "...";
      }
      
      // Call OpenAI API
      Map<String, dynamic> result = await _generateFlashcardsFromContent(fileContent, path.basename(filePath));
      
      // Create new FlashcardCollection
      String collectionId = const Uuid().v4();
      List<Flashcard> flashcards = [];
      
      // Process flashcards from API response
      for (var card in result['flashcards']) {
        flashcards.add(
          Flashcard(
            id: const Uuid().v4(),
            question: card['question'],
            answer: card['answer'],
            isMemorized: false,
          )
        );
      }
      
      FlashcardCollection collection = FlashcardCollection(
        id: collectionId,
        title: path.basenameWithoutExtension(filePath),
        category: result['category'] ?? 'General',
        summary: result['summary'] ?? 'No summary available',
        filePath: fileUrl,
        createdAt: DateTime.now(),
        flashcards: flashcards,
      );
      
      // Save to Supabase database
      await _flashcardService.saveCollection(collection);
      
      return collection;
    } catch (e) {
      debugPrint('Error processing document: $e');
      throw Exception('Failed to process document: $e');
    }
  }

  Future<String> _extractTextFromFile(File file, String filePath) async {
    final extension = path.extension(filePath).toLowerCase();
    
    try {
      switch (extension) {
        case '.pdf':
          return await _extractTextFromPDF(file);
        case '.txt':
          return await file.readAsString();
        case '.docx':
          // Add docx parsing later
          return "DOCX parsing not implemented. Please use PDF or TXT.";
        default:
          return await file.readAsString();
      }
    } catch (e) {
      debugPrint('Error extracting text: $e');
      return "Error extracting text from file: $e";
    }
  }

  Future<String> _extractTextFromPDF(File file) async {
    try {
      // Load the PDF document
      final bytes = await file.readAsBytes();
      final document = PdfDocument(inputBytes: bytes);
      
      final StringBuilder = StringBuffer();
      
      // Extract text from all pages
      for (int i = 0; i < document.pages.count; i++) {
        final page = document.pages[i];
        final text = PdfTextExtractor(document).extractText(startPageIndex: i);
        StringBuilder.write(text);
        StringBuilder.write('\n\n');
      }
      
      // Dispose the document
      document.dispose();
      
      return StringBuilder.toString();
    } catch (e) {
      debugPrint('Error in PDF extraction: $e');
      return "Error extracting text from PDF: $e";
    }
  }

  Future<Map<String, dynamic>> _generateFlashcardsFromContent(String content, String filename) async {
    try {
      if (_apiKey.isEmpty) {
        debugPrint('OpenAI API key not found in .env file');
        return _getDummyFlashcards(filename);
      }
      
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'You are an educational assistant that creates flashcards from learning content.'
            },
            {
              'role': 'user',
              'content': '''
              Create 10-15 flashcards in question/answer format and a brief summary from the following content.
              Return your response as JSON with the following structure:
              {
                "flashcards": [
                  {"question": "Question text", "answer": "Answer text"},
                  ...
                ],
                "summary": "Brief summary of the content",
                "category": "Subject category (e.g., History, Mathematics, Science)"
              }
              
              Content:
              $content
              '''
            }
          ],
          'temperature': 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final content = jsonResponse['choices'][0]['message']['content'];
        
        try {
          final Map<String, dynamic> parsedJson = jsonDecode(content);
          return {
            'flashcards': parsedJson['flashcards'] ?? [],
            'summary': parsedJson['summary'] ?? '',
            'category': parsedJson['category'] ?? 'General',
          };
        } catch (e) {
          debugPrint('Error parsing AI response: $e');
          return _getDummyFlashcards(filename);
        }
      } else {
        debugPrint('OpenAI API error: ${response.body}');
        return _getDummyFlashcards(filename);
      }
    } catch (e) {
      debugPrint('Error calling OpenAI API: $e');
      return _getDummyFlashcards(filename);
    }
  }
  
  // Provide dummy data in case OpenAI API is not available
  Map<String, dynamic> _getDummyFlashcards(String filename) {
    return {
      'flashcards': [
        {
          'question': 'What is this document about?',
          'answer': 'This is a placeholder since OpenAI API is not configured.'
        },
        {
          'question': 'How can I enable AI-generated flashcards?',
          'answer': 'Add your OpenAI API key to the .env file.'
        },
      ],
      'summary': 'This is a placeholder summary for $filename. Please add your OpenAI API key to enable AI-generated content.',
      'category': 'General',
    };
  }
}