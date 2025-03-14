import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';


void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => GameState(),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CardMatchingGame(),
      theme: ThemeData.dark(), // Ensures the default theme is dark
    );
  }
}

class CardModel {
  final String id;
  final String content;
  bool isFlipped;
  bool isMatched;

  CardModel({required this.id, required this.content, this.isFlipped = false, this.isMatched = false});
}

class GameState extends ChangeNotifier {
  List<CardModel> cards = [];
  CardModel? firstCard;
  bool isProcessing = false;

  GameState() {
    _initializeGame();
  }

  void _initializeGame() {
    List<String> symbols = ['🍎', '🍌', '🍒', '🍇', '🍉', '🍓', '🥝', '🍍'];
    List<CardModel> tempCards = [];
    for (var symbol in symbols) {
      tempCards.add(CardModel(id: UniqueKey().toString(), content: symbol));
      tempCards.add(CardModel(id: UniqueKey().toString(), content: symbol));
    }
    tempCards.shuffle();
    cards = tempCards;
    notifyListeners();
  }

  void flipCard(CardModel card) {
    if (isProcessing || card.isFlipped || card.isMatched) return;

    card.isFlipped = true;
    notifyListeners();

    if (firstCard == null) {
      firstCard = card;
    } else {
      isProcessing = true;
      notifyListeners();

      Future.delayed(Duration(seconds: 1), () {
        if (firstCard!.content == card.content) {
          firstCard!.isMatched = true;
          card.isMatched = true;
        } else {
          firstCard!.isFlipped = false;
          card.isFlipped = false;
        }
        firstCard = null;
        isProcessing = false;
        notifyListeners();
      });
    }
  }

  bool hasWon() {
    return cards.every((card) => card.isMatched);
  }

  void resetGame() {
    _initializeGame();
  }
}

class CardMatchingGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set background to black
      appBar: AppBar(
        title: Text('Card Matching Game', style: TextStyle(color: Colors.blue)),
        backgroundColor: Colors.black,
      ),
      body: Consumer<GameState>(
        builder: (context, gameState, child) {
          return Column(
            children: [
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.all(20),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: gameState.cards.length,
                  itemBuilder: (context, index) {
                    return CardWidget(
                      card: gameState.cards[index],
                      onTap: () => gameState.flipCard(gameState.cards[index]),
                    );
                  },
                ),
              ),
              if (gameState.hasWon())
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        'You Win!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue, // Set "You Win!" text to blue
                        ),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => gameState.resetGame(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, // Set button to blue
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                        child: Text('New Game', style: TextStyle(color: Colors.white)),
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

class CardWidget extends StatefulWidget {
  final CardModel card;
  final VoidCallback onTap;

  CardWidget({required this.card, required this.onTap});

  @override
  _CardWidgetState createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
