import 'package:flutter/material.dart';
import 'package:flashcards/src/features/models/flashcards_model.dart';
import 'package:flashcards/src/features/services/flashcard_service.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

class FlashcardStudyScreen extends StatefulWidget {
  final String collectionId;
  final String collectionName;
  final List<Flashcard>? initialFlashcards;

  const FlashcardStudyScreen({
    Key? key,
    required this.collectionId,
    required this.collectionName,
    this.initialFlashcards,
  }) : super(key: key);

  @override
  _FlashcardStudyScreenState createState() => _FlashcardStudyScreenState();
}

class _FlashcardStudyScreenState extends State<FlashcardStudyScreen> {
  final FlashcardService _flashcardService = FlashcardService();
  late Future<List<Flashcard>> _flashcardsFuture;
  late PageController _pageController;
  int _currentIndex = 0;
  bool _showAnswer = false;
  List<Flashcard> _flashcards = [];
  
  // Track progress
  int _totalFlashcards = 0;
  int _memorizedFlashcards = 0;
  
  // Colors for card backgrounds (pastel colors)
  final List<Color> _cardColors = [
    Color(0xFFFFD6D6), // Light red
    Color(0xFFD6FFD6), // Light green
    Color(0xFFD6D6FF), // Light blue
    Color(0xFFFFD6FF), // Light purple
    Color(0xFFFFFFD6), // Light yellow
    Color(0xFFD6FFFF), // Light cyan
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    if (widget.initialFlashcards != null && widget.initialFlashcards!.isNotEmpty) {
      _flashcards = widget.initialFlashcards!;
      _totalFlashcards = _flashcards.length;
      _updateMemorizedCount();
      _flashcardsFuture = Future.value(_flashcards);
    } else {
      _loadFlashcards();
    }
  }
  
  void _loadFlashcards() {
    _flashcardsFuture = _flashcardService.getFlashcardsForCollection(widget.collectionId);
    _flashcardsFuture.then((flashcards) {
      setState(() {
        _flashcards = flashcards;
        _totalFlashcards = flashcards.length;
        _updateMemorizedCount();
      });
    });
  }

  void _updateMemorizedCount() {
    _memorizedFlashcards = _flashcards.where((card) => card.isMemorized).length;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Color _getRandomColor() {
    return _cardColors[math.Random().nextInt(_cardColors.length)];
  }

  void _toggleAnswer() {
    setState(() {
      _showAnswer = !_showAnswer;
    });
  }

  void _markAsMemorized(bool value) async {
    final currentCard = _flashcards[_currentIndex];
    await _flashcardService.updateFlashcardMemorizationStatus(currentCard.id, value);
    
    setState(() {
      _flashcards[_currentIndex].isMemorized = value;
      _updateMemorizedCount();
    });
    
    // Move to the next card if marked as memorized
    if (value && _currentIndex < _flashcards.length - 1) {
      _nextCard();
    }
  }

  void _nextCard() {
    if (_currentIndex < _flashcards.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _showAnswer = false;
      });
    }
  }

  void _previousCard() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _showAnswer = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.collectionName),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              Navigator.pop(context);
            },
            tooltip: 'Save and return',
          ),
        ],
      ),
      body: FutureBuilder<List<Flashcard>>(
        future: _flashcardsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('No flashcards found in this collection.'),
            );
          }
          
          return Column(
            children: [
              // Progress indicator
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress: $_memorizedFlashcards/$_totalFlashcards',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Card ${_currentIndex + 1}/$_totalFlashcards',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _totalFlashcards > 0 ? _memorizedFlashcards / _totalFlashcards : 0,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ],
                ),
              ),
              
              // Flashcards
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _flashcards.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                      _showAnswer = false;
                    });
                  },
                  itemBuilder: (context, index) {
                    final flashcard = _flashcards[index];
                    final cardColor = _getRandomColor();
                    
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: cardColor,
                        child: InkWell(
                          onTap: _toggleAnswer,
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Center(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            _showAnswer ? 'Answer:' : 'Question:',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          SizedBox(height: 16),
                                          Text(
                                            _showAnswer ? flashcard.answer : flashcard.question,
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Tap to ${_showAnswer ? 'see question' : 'reveal answer'}',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      flashcard.isMemorized ? Icons.check_circle : Icons.check_circle_outline,
                                      color: flashcard.isMemorized ? Colors.green : Colors.grey,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      flashcard.isMemorized ? 'Memorized' : 'Not memorized',
                                      style: TextStyle(
                                        color: flashcard.isMemorized ? Colors.green : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Bottom controls
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _previousCard,
                      icon: Icon(Icons.arrow_back),
                      label: Text('Previous'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black87,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _markAsMemorized(!_flashcards[_currentIndex].isMemorized),
                      icon: Icon(_flashcards[_currentIndex].isMemorized ? Icons.close : Icons.check),
                      label: Text(_flashcards[_currentIndex].isMemorized ? 'Unmark' : 'Memorized'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _flashcards[_currentIndex].isMemorized ? Colors.orange : Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _nextCard,
                      icon: Icon(Icons.arrow_forward),
                      label: Text('Next'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}