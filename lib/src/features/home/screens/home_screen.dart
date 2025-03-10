import 'package:flutter/material.dart';
import 'package:flashcards/src/utils/constants/colors.dart';
import 'package:flashcards/src/features/home/widgets/category_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "QuizApp",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Icon(Icons.search, color: Colors.grey),
                          ),
                          Text(
                            "Search",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  CircleAvatar(
                    backgroundColor: Colors.grey[200],
                    child: const Icon(Icons.person_outline, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                "Browse flash cards",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
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
        onPressed: () {},
        backgroundColor: TColors.primary,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
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
        ],
      ),
    );
  }
}