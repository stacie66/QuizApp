import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flashcards/src/utils/constants/colors.dart';
import 'package:flashcards/src/features/home/widgets/category_card.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flashcards/src/features/services/ai_service.dart';
import 'package:flashcards/src/utils/theme/theme_service.dart';
import 'package:flashcards/src/features/profile/screens/profile_screen.dart';
import 'package:flashcards/src/features/services/user_service.dart';
import 'package:flashcards/src/features/models/user_model.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final UserService _userService = UserService();
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final user = await _userService.getCurrentUser();
      if (mounted) {
        setState(() {
          _currentUser = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      _showErrorSnackBar("Error loading user data: $e");
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade800,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _pickAndProcessFile() async {
    try {
      // Pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'pdf', 'png', 'docx'],
      );
      
      if (result == null || result.files.single.path == null) return;
      
      // Show loading dialog
      _showLoadingDialog('Processing document...');
      
      // Get file path and name
      final path = result.files.single.path!;
      final fileName = result.files.single.name;
      final file = File(path);
      
      // 1. Upload to Firebase Storage
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Navigator.pop(context); // Close loading dialog
        _showErrorSnackBar('User not authenticated');
        return;
      }
      
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('documents/${user.uid}/$fileName');
      
      final uploadTask = storageRef.putFile(file);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      // 2. Process with OpenAI
      final aiService = AIService();
      final processedData = await aiService.processDocument(file, fileName);
      
      // 3. Save to Firestore
      final docRef = await FirebaseFirestore.instance.collection('userContent').add({
        'userId': user.uid,
        'fileName': fileName,
        'fileUrl': downloadUrl,
        'dateCreated': Timestamp.now(),
       
      });
      
      // Close loading dialog
      if (mounted) Navigator.pop(context);
      
      // Show success message
      _showSuccessSnackBar('Document processed successfully!');
      
      // Navigate to the new flashcard set
      Navigator.pushNamed(context, '/flashcards', arguments: {'docId': docRef.id});
      
    } catch (e) {
      // Close loading dialog if it's open
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.pop(context);
      }
      
      // Show error message
      _showErrorSnackBar('Error: ${e.toString()}');
    }
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(message)
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.white;
    final searchColor = isDarkMode ? Colors.grey[800] : Colors.grey[200];
    final hintColor = isDarkMode ? Colors.grey[400] : Colors.grey;
  
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "FlashCards AI",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            if (!_isLoading && _currentUser != null)
              Text(
                "${_getGreeting()}, ${_currentUser!.name}",
                style: TextStyle(
                  fontSize: 14,
                  color: textColor.withOpacity(0.6),
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            color: textColor,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications coming soon!')),
              );
            },
          ),
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            color: textColor,
            onPressed: () {
              themeService.toggleTheme();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar & profile
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: searchColor,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          if (!isDarkMode)
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(25),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Search coming soon!')),
                            );
                          },
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Icon(Icons.search, color: hintColor),
                              ),
                              Text(
                                "Search",
                                style: TextStyle(color: hintColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => const ProfileScreen()),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          if (!isDarkMode)
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: _isLoading || _currentUser == null || _currentUser!.profilePicture.isEmpty
                        ? CircleAvatar(
                            backgroundColor: searchColor,
                            child: Icon(
                              Icons.person_outline,
                              color: hintColor,
                            ),
                          )
                        : CircleAvatar(
                            backgroundImage: NetworkImage(_currentUser!.profilePicture),
                          ),
                    ),
                  ),
                ],
              ),
              
              // Featured banner
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [TColors.primary, TColors.primary.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: TColors.primary.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -10,
                      bottom: -10,
                      child: Icon(
                        Icons.auto_awesome,
                        size: 100,
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Create flashcards instantly",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Upload any document and AI will generate flashcards for you",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _pickAndProcessFile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: TColors.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text("Upload Document"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Categories
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Browse categories",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/categories');
                    },
                    child: Text(
                      "View all",
                      style: TextStyle(
                        color: TColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: const [
                    CategoryCard(
                      icon: Icons.language,
                      title: "Language",
                      color: Color(0xFFE6F4F1),
                      iconColor: Color(0xFF5D8A84),
                    ),
                    CategoryCard(
                      icon: Icons.science_outlined,
                      title: "Science",
                      color: Color(0xFFF8F2E9),
                      iconColor: Color(0xFFC1A87D),
                    ),
                    CategoryCard(
                      icon: Icons.calculate_outlined,
                      title: "Mathematics",
                      color: Color(0xFFECEDF8),
                      iconColor: Color(0xFF8E94C4),
                    ),
                    CategoryCard(
                      icon: Icons.history_edu_outlined,
                      title: "History",
                      color: Color(0xFFF9ECEC),
                      iconColor: Color(0xFFB87878),
                    ),
                    CategoryCard(
                      icon: Icons.psychology_outlined,
                      title: "Psychology",
                      color: Color(0xFFE6F3FF),
                      iconColor: Color(0xFF6F9AC8),
                    ),
                    CategoryCard(
                      icon: Icons.biotech_outlined,
                      title: "Biology",
                      color: Color(0xFFE9F8EF),
                      iconColor: Color(0xFF7BC295),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickAndProcessFile,
        backgroundColor: TColors.primary,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          
          // Handle navigation
          switch (index) {
            case 0: // Home - already here
              break;
            case 1: // Flash Cards
              Navigator.pushNamed(context, '/flashcards');
              break;
            case 2: // Collections
              Navigator.pushNamed(context, '/collections');
              break;
            case 3: // Profile
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: TColors.primary,
        unselectedItemColor: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        items: const [
        
  
        ],
      ),
    );
  }
}