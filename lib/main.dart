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
