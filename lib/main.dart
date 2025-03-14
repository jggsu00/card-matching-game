import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


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
