import 'package:flutter/material.dart';
import 'dart:async';

import 'package:shadowboxing_game/widgets/realistic_character.dart';

class RealisticGameScreen extends StatefulWidget {
  const RealisticGameScreen({Key? key}) : super(key: key);

  @override
  State<RealisticGameScreen> createState() => _RealisticGameScreenState();
}

class _RealisticGameScreenState extends State<RealisticGameScreen>
    with TickerProviderStateMixin {
  bool isPlayer1Turn = true;
  Direction? player1MoveDirection;
  Direction? player2GuessDirection;
  bool isAnimating = false;
  int consecutiveCorrectGuesses = 0;
  bool isCorrectGuess = false;

  late AnimationController _feedbackAnimationController;
  late Animation<double> _feedbackAnimation;

  @override
  void initState() {
    super.initState();
    _feedbackAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _feedbackAnimation = CurvedAnimation(
      parent: _feedbackAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _feedbackAnimationController.dispose();
    super.dispose();
  }

  void makeMove(Direction direction) {
    if (isAnimating) return;

    setState(() {
      if (isPlayer1Turn) {
        player1MoveDirection = direction;
        isAnimating = true;

        // Simulate the move animation
        Timer(const Duration(milliseconds: 800), () {
          setState(() {
            isAnimating = false;
            isPlayer1Turn = false;
          });
        });
      } else {
        player2GuessDirection = direction;
        isAnimating = true;

        // Check if guess is correct
        isCorrectGuess = player2GuessDirection == player1MoveDirection;

        if (isCorrectGuess) {
          // Correct guess
          consecutiveCorrectGuesses++;
          _feedbackAnimationController.forward().then((_) {
            _feedbackAnimationController.reverse();
          });

          Timer(const Duration(milliseconds: 1200), () {
            setState(() {
              isAnimating = false;

              if (consecutiveCorrectGuesses >= 3) {
                // Player 2 wins
                _showWinDialog("Player 2 wins!");
                _resetGame();
              } else {
                // Continue, but switch back to player 1
                isPlayer1Turn = true;
                player1MoveDirection = null;
                player2GuessDirection = null;
              }
            });
          });
        } else {
          // Incorrect guess, switch roles
          _feedbackAnimationController.forward().then((_) {
            _feedbackAnimationController.reverse();
          });

          Timer(const Duration(milliseconds: 1200), () {
            setState(() {
              isAnimating = false;
              consecutiveCorrectGuesses = 0;
              _switchRoles();
            });
          });
        }
      }
    });
  }

  void _switchRoles() {
    setState(() {
      isPlayer1Turn = true;
      player1MoveDirection = null;
      player2GuessDirection = null;
    });
  }

  void _resetGame() {
    setState(() {
      isPlayer1Turn = true;
      player1MoveDirection = null;
      player2GuessDirection = null;
      consecutiveCorrectGuesses = 0;
    });
  }

  void _showWinDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Game Over"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Play Again"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey.shade800, Colors.grey.shade900],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Game header and status
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "SHADOW BOXING",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Streak: $consecutiveCorrectGuesses/3",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Turn indicator
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                color:
                    isPlayer1Turn ? Colors.blue.shade700 : Colors.red.shade700,
                child: Text(
                  isPlayer1Turn
                      ? "Player 1: Choose your move"
                      : "Player 2: Guess the move",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),

              // Feedback animation for correct/incorrect
              AnimatedBuilder(
                animation: _feedbackAnimation,
                builder: (context, child) {
                  return Container(
                    color: isCorrectGuess
                        ? Colors.green
                            .withOpacity(_feedbackAnimation.value * 0.3)
                        : Colors.red
                            .withOpacity(_feedbackAnimation.value * 0.3),
                    height: 4,
                    width: double.infinity,
                  );
                },
              ),

              // Characters area
              Expanded(
                child: Stack(
                  children: [
                    // Background boxing ring
                    Positioned.fill(
                      child: Image.asset(
                        'assets/boxing_ring.png', // You'll need to add this image
                        fit: BoxFit.cover,
                      ),
                    ),

                    // Characters
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Player 1 character
                        RealisticCharacter(
                          isPlayerOne: true,
                          moveDirection: player1MoveDirection,
                          isMoving: isAnimating && isPlayer1Turn,
                          characterAsset:
                              'assets/player1.png', // You'll need to add this image
                        ),

                        // VS indicator
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Text(
                            "VS",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),

                        // Player 2 character
                        RealisticCharacter(
                          isPlayerOne: false,
                          moveDirection: player2GuessDirection,
                          isMoving: isAnimating && !isPlayer1Turn,
                          characterAsset:
                              'assets/player2.png', // You'll need to add this image
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Controls
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      isPlayer1Turn ? "SELECT YOUR MOVE:" : "GUESS THE MOVE:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildDirectionButton(Direction.left, Icons.arrow_back),
                        const SizedBox(width: 16),
                        Column(
                          children: [
                            _buildDirectionButton(
                                Direction.up, Icons.arrow_upward),
                            const SizedBox(height: 16),
                            _buildDirectionButton(
                                Direction.down, Icons.arrow_downward),
                          ],
                        ),
                        const SizedBox(width: 16),
                        _buildDirectionButton(
                            Direction.right, Icons.arrow_forward),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDirectionButton(Direction direction, IconData icon) {
    final Color baseColor = isPlayer1Turn ? Colors.blue : Colors.red;

    return ElevatedButton(
      onPressed: isAnimating ? null : () => makeMove(direction),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(20),
        backgroundColor: baseColor,
        shape: const CircleBorder(),
        elevation: 8,
        shadowColor: baseColor.withOpacity(0.6),
      ),
      child: Icon(icon, size: 32),
    );
  }
}
