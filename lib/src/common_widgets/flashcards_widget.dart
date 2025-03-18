// lib/src/features/flashcards/widgets/flashcard_widget.dart
import 'package:flutter/material.dart';
import 'package:flashcards/src/features/models/flashcards_model.dart';
import 'dart:math' as math;

class FlashcardWidget extends StatefulWidget {
  final List<Flashcard> flashcards;
  final Function(String, bool) onCardMemorized;

  const FlashcardWidget({
    Key? key,
    required this.flashcards,
    required this.onCardMemorized,
  }) : super(key: key);

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget> {
  int _currentIndex = 0;
  bool _showAnswer = false;
  List<Flashcard> _filteredCards = [];
  bool _showOnlyUnmemorized = false;

  @override
  void initState() {
    super.initState();
    _filterCards();
  }

  @override
  void didUpdateWidget(FlashcardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.flashcards != widget.flashcards) {
      _filterCards();
    }
  }

  void _filterCards() {
    setState(() {
      _filteredCards = _showOnlyUnmemorized
          ? widget.flashcards.where((card) => !card.isMemorized).toList()
          : List.from(widget.flashcards);
      
      // Reset current index if necessary
      if (_currentIndex >= _filteredCards.length) {
        _currentIndex = _filteredCards.isEmpty ? 0 : _filteredCards.length - 1;
      }
      _showAnswer = false;
    });
  }

  void _nextCard() {
    if (_filteredCards.isEmpty) return;
    
    setState(() {
      _currentIndex = (_currentIndex + 1) % _filteredCards.length;
      _showAnswer = false;
    });
  }

  void _previousCard() {
    if (_filteredCards.isEmpty) return;
    
    setState(() {
      _currentIndex = (_currentIndex - 1 + _filteredCards.length) % _filteredCards.length;
      _showAnswer = false;
    });
  }

  void _toggleAnswer() {
    setState(() {
      _showAnswer = !_showAnswer;
    });
  }

  void _toggleMemorized() {
    if (_filteredCards.isEmpty) return;
    
    final card = _filteredCards[_currentIndex];
    widget.onCardMemorized(card.id, !card.isMemorized);
    
    // Move to next card if this was the last unmemorized card
    if (_showOnlyUnmemorized && _filteredCards.length == 1) {
      setState(() {
        _filteredCards = [];
      });
    }
  }

  void _shuffleCards() {
    if (_filteredCards.isEmpty) return;
    
    setState(() {
      _filteredCards.shuffle();
      _currentIndex = 0;
      _showAnswer = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_filteredCards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'No flashcards available',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            if (_showOnlyUnmemorized)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showOnlyUnmemorized = false;
                    _filterCards();
                  });
                },
                child: const Text('Show All Cards'),
              ),
          ],
        ),
      );
    }

    final card = _filteredCards[_currentIndex];

    return Column(
      children: [
        // Filter and shuffle controls
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  FilterChip(
                    label: const Text('Unmemorized Only'),
                    selected: _showOnlyUnmemorized,
                    onSelected: (selected) {
                      setState(() {
                        _showOnlyUnmemorized = selected;
                        _filterCards();
                      });
                    },
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.shuffle),
                onPressed: _shuffleCards,
                tooltip: 'Shuffle Cards',
              ),
            ],
          ),
        ),
        
        // Card counter
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Card ${_currentIndex + 1} of ${_filteredCards.length}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        
        // Flashcard
        Expanded(
          child: GestureDetector(
            onTap: _toggleAnswer,
            child: _buildFlipCard(card),
          ),
        ),
        
        // Navigation controls
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _previousCard,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Previous'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: Colors.black,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _toggleMemorized,
                icon: Icon(
                  card.isMemorized ? Icons.star : Icons.star_border,
                  color: card.isMemorized ? Colors.amber : null,
                ),
                label: Text(card.isMemorized ? 'Unmark' : 'Mark as Memorized'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: card.isMemorized ? Colors.amber.shade100 : Colors.blue.shade100,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _nextCard,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Next'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFlipCard(Flashcard card) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: FlipCard(
        isFlipped: _showAnswer,
        frontWidget: _buildCardSide(
          card.question,
          Colors.blue.shade50,
          'Question',
        ),
        backWidget: _buildCardSide(
          card.answer,
          Colors.green.shade50,
          'Answer',
        ),
      ),
    );
  }

  Widget _buildCardSide(String content, Color backgroundColor, String label) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: backgroundColor,
      ),
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const Divider(),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    content,
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          if (!_showAnswer)
            const Text(
              'Tap to see answer',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
        ],
      ),
    );
  }
}

// Custom FlipCard Implementation
class FlipCard extends StatefulWidget {
  final Widget frontWidget;
  final Widget backWidget;
  final bool isFlipped;

  const FlipCard({
    Key? key,
    required this.frontWidget,
    required this.backWidget,
    required this.isFlipped,
  }) : super(key: key);

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _frontRotation;
  late Animation<double> _backRotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _frontRotation = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: math.pi / 2)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50.0,
      ),
      TweenSequenceItem(
        tween: ConstantTween(math.pi / 2),
        weight: 50.0,
      ),
    ]).animate(_controller);
    
    _backRotation = TweenSequence([
      TweenSequenceItem(
        tween: ConstantTween(math.pi / 2),
        weight: 50.0,
      ),
      TweenSequenceItem(
        tween: Tween(begin: math.pi / 2, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50.0,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFlipped != oldWidget.isFlipped) {
      if (widget.isFlipped) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Front side
        AnimatedBuilder(
          animation: _frontRotation,
          builder: (context, child) {
            final transform = Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Perspective
              ..rotateY(_frontRotation.value);
            return Transform(
              transform: transform,
              alignment: Alignment.center,
              child: child,
            );
          },
          child: _frontRotation.value < math.pi / 2
              ? widget.frontWidget
              : const SizedBox.shrink(),
        ),
        
        // Back side
        AnimatedBuilder(
          animation: _backRotation,
          builder: (context, child) {
            final transform = Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Perspective
              ..rotateY(_backRotation.value + math.pi);
            return Transform(
              transform: transform,
              alignment: Alignment.center,
              child: child,
            );
          },
          child: _backRotation.value < math.pi / 2
              ? widget.backWidget
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}