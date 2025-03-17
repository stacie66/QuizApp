import 'package:flutter/material.dart';

class FlashcardsScreen extends StatelessWidget {
  const FlashcardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Add search functionality
              _showSearchDialog(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Choose Your Model Section
            const Text(
              'Choose Your Model',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildModelButton(
                    context,
                    Icons.format_list_bulleted,
                    "Multiple",
                    onPressed: () {
                      _showModelSelectedDialog(context, "Multiple");
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildModelButton(
                    context,
                    Icons.layers,
                    "Flashcards",
                    onPressed: () {
                      _showModelSelectedDialog(context, "Flashcards");
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Study Guide Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Study Guide',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to the "View All/Edit" screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StudyGuideScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'View All/Edit',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  _buildStudyGuideItem(
                    context,
                    "Step 1: Create a new flashcard",
                    onTap: () {
                      _showStepDetails(context, "Step 1: Create a new flashcard");
                    },
                  ),
                  _buildStudyGuideItem(
                    context,
                    "Step 2: Organize your flashcards",
                    onTap: () {
                      _showStepDetails(context, "Step 2: Organize your flashcards");
                    },
                  ),
                  _buildStudyGuideItem(
                    context,
                    "Step 3: Review and practice",
                    onTap: () {
                      _showStepDetails(context, "Step 3: Review and practice");
                    },
                  ),
                  _buildStudyGuideItem(
                    context,
                    "Step 4: Track your progress",
                    onTap: () {
                      _showStepDetails(context, "Step 4: Track your progress");
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the "Create New Flashcard" screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateFlashcardScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Helper method to build model buttons
  Widget _buildModelButton(
      BuildContext context,
      IconData icon,
      String label, {
        required VoidCallback onPressed,
      }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.blue.shade100),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build study guide items
  Widget _buildStudyGuideItem(
      BuildContext context,
      String text, {
        required VoidCallback onTap,
      }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.check_circle_outline, color: Colors.green),
        title: Text(text),
        onTap: onTap,
      ),
    );
  }

  // Show a dialog when a model is selected
  void _showModelSelectedDialog(BuildContext context, String model) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$model Selected'),
        content: Text('You have chosen the $model mode.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Show a dialog with step details
  void _showStepDetails(BuildContext context, String step) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(step),
        content: Text('Details for $step will be shown here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Show a search dialog
  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search'),
        content: const Text('Search functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// Placeholder screen for "View All/Edit"
class StudyGuideScreen extends StatelessWidget {
  const StudyGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Guide'),
      ),
      body: const Center(
        child: Text('View All/Edit functionality will be implemented here.'),
      ),
    );
  }
}

// Placeholder screen for "Create New Flashcard"
class CreateFlashcardScreen extends StatelessWidget {
  const CreateFlashcardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Flashcard'),
      ),
      body: const Center(
        child: Text('Create New Flashcard functionality will be implemented here.'),
      ),
    );
  }
}