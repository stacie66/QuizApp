import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';
import 'package:uuid/uuid.dart';
import 'firebase_options.dart';
import 'dart:typed_data';
import 'package:firebase_core/firebase_core.dart';
import 'package:flashcards/src/features/home/screens/home_screen.dart';
import 'package:flashcards/src/features/flashcards/screens/collection.dart';
import 'package:flashcards/src/features/chats/screens/chat_screen.dart';
import 'package:flashcards/src/features/profile/screens/profile_screen.dart';
import 'package:flashcards/src/utils/constants/colors.dart';
import 'package:flashcards/src/utils/theme/theme.dart';
import 'package:flashcards/src/utils/theme/theme_service.dart';
import 'package:flashcards/src/common_widgets/uploadWidget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Create a global Supabase client to use throughout the app
late final SupabaseClient supabase;
// After setting the global supabase client
late final SupabaseStorageService supabaseStorage;

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://futfeizoegjlpejfnpex.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ1dGZlaXpvZWdqbHBlamZucGV4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIxMzM2NTgsImV4cCI6MjA1NzcwOTY1OH0.H9qD-e_tF3pQDieR_aQZc7GOrKGGwgd9lQmNPeZTl4E',
  );
  
  // Set global instances
  supabase = Supabase.instance.client;
  supabaseStorage = SupabaseStorageService();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Run the app with ThemeService as a provider
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    
    return MaterialApp(
      title: 'QuizApp',
      debugShowCheckedModeBanner: false,
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
      themeMode: themeService.themeMode,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);
  
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const HomeScreen(),
    const FlashcardsScreen(),
    const ChatScreen(),
    const ProfileScreen(),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      floatingActionButton: _currentIndex == 1 ? FloatingActionButton(
        onPressed: () {
          // Handle upload action
          showModalBottomSheet(
            context: context,
            builder: (context) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: FileUploadWidget(
                onFileUploaded: (fileUrl) {
                  // Handle the uploaded file URL
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('File uploaded: $fileUrl')),
                  );
                },
              ),
            ),
          );
        },
        tooltip: 'Upload Flash Card',
        child: const Icon(Icons.add),
      ) : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: TColors.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: "Flash Cards",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: "Chat",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

// Utility class for Supabase storage operations
class SupabaseStorageService {
  final String bucketName = 'flashcards-pdfs'; // Corrected bucket name to match your Supabase project

// Modified SupabaseStorageService class
Future<String?> uploadFile(File file) async {
  try {
    // Generate a unique filename
    final String fileName = '${const Uuid().v4()}${path.extension(file.path)}';
    
    // Get the MIME type of the file
    final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
    
    // Upload the file to Supabase storage
    await supabase.storage.from(bucketName).upload(
      fileName,
      file.readAsBytesSync(),
      fileOptions: FileOptions(
        contentType: mimeType,
        upsert: true, // Allow overwriting existing files
      ),
    );
    
    // Get the URL
    final String fileUrl = supabase.storage.from(bucketName).getPublicUrl(fileName);
    
    return fileUrl;
  } catch (error) {
    print('Error uploading file: $error');
    return null;
  }
}
  
  // Download file
  Future<Uint8List?> downloadFile(String fileName) async {
    try {
      final data = await supabase.storage.from(bucketName).download(fileName);
      return data;
    } catch (error) {
      print('Error downloading file: $error');
      return null;
    }
  }
  
  // Delete file
  Future<void> deleteFile(String fileName) async {
    try {
      await supabase.storage.from(bucketName).remove([fileName]);
    } catch (error) {
      print('Error deleting file: $error');
    }
  }
  
  // List all files in bucket
  Future<List<FileObject>?> listFiles() async {
    try {
      final response = await supabase.storage.from(bucketName).list();
      return response;
    } catch (error) {
      print('Error listing files: $error');
      return null;
    }
  }
}