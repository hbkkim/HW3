import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(MemoryGameApp());
}

class MemoryGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memory Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MemoryGame(),
    );
  }
}

class MemoryGame extends StatefulWidget {
  @override
  _MemoryGameState createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {
  List<CardModel> _cards = [];
  CardModel? _firstSelectedCard;
  CardModel? _secondSelectedCard;
  bool _canFlip = true;

  @override
  void initState() {
    super.initState();
    _generateCards();
  }

  void _generateCards() {
    List<int> identifiers = List<int>.generate(8, (index) => index); // 8 pairs
    List<CardModel> cards = [];

    for (int id in identifiers) {
      cards.add(CardModel(id, false, false));
      cards.add(CardModel(id, false, false));
    }

    // Shuffle cards
    cards.shuffle(Random());
    setState(() {
      _cards = cards;
    });
  }

  void _flipCard(CardModel card) {
    if (!_canFlip || card.isMatched || card == _firstSelectedCard) {
      return;
    }

    setState(() {
      card.isFaceUp = true;
    });

    if (_firstSelectedCard == null) {
      _firstSelectedCard = card;
    } else {
      _secondSelectedCard = card;
      _canFlip = false;

      // Check for match after a brief delay
      Timer(Duration(seconds: 1), () {
        setState(() {
          if (_firstSelectedCard?.identifier == _secondSelectedCard?.identifier) {
            _firstSelectedCard!.isMatched = true;
            _secondSelectedCard!.isMatched = true;
          } else {
            _firstSelectedCard!.isFaceUp = false;
            _secondSelectedCard!.isFaceUp = false;
          }
          _firstSelectedCard = null;
          _secondSelectedCard = null;
          _canFlip = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Memory Game"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _generateCards();
                _firstSelectedCard = null;
                _secondSelectedCard = null;
                _canFlip = true;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: _cards.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => _flipCard(_cards[index]),
              child: CardWidget(card: _cards[index]),
            );
          },
        ),
      ),
    );
  }
}

class CardModel {
  final int identifier;
  bool isFaceUp;
  bool isMatched;

  CardModel(this.identifier, this.isFaceUp, this.isMatched);
}

class CardWidget extends StatelessWidget {
  final CardModel card;

  const CardWidget({Key? key, required this.card}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        final rotateAnimation = Tween(begin: pi, end: 0.0).animate(animation);
        return AnimatedBuilder(
          animation: rotateAnimation,
          child: child,
          builder: (context, child) {
            final isFront = rotateAnimation.value < pi / 2;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(rotateAnimation.value),
              child: isFront ? child : _buildCardBack(),
            );
          },
        );
      },
      child: card.isFaceUp || card.isMatched
          ? _buildCardFront(card)
          : _buildCardBack(),
    );
  }

  Widget _buildCardFront(CardModel card) {
    return Container(
      key: ValueKey(card.identifier),
      color: Colors.blueAccent,
      child: Center(
        child: Text(
          card.identifier.toString(),
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildCardBack() {
    return Container(
      key: ValueKey("back"),
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: AssetImage('assets/Card.jpg'), // Add an image to the project
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
