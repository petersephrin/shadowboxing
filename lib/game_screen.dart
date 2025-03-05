import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
import 'widgets/move_buttons.dart';
import 'widgets/guess_buttons.dart';
import 'widgets/hit_animation.dart';
import 'widgets/scoreboard.dart';

enum Move { up, down, left, right, none }

enum PlayerRole { headMover, guesser }

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  // Game state
  PlayerRole player1Role = PlayerRole.headMover;
  PlayerRole player2Role = PlayerRole.guesser;
  Move selectedMove = Move.none;
  Move guessedMove = Move.none;
  int correctStreak = 0;
  bool isPlayer1Turn = true;
  bool isGameOver = false;
  bool isAnimating = false;
  String winnerName = "";

  // Audio players
  final AudioPlayer hitSoundPlayer = AudioPlayer();
  final AudioPlayer missSoundPlayer = AudioPlayer();
  final AudioPlayer victorySoundPlayer = AudioPlayer();

  // Animation controller for screen shake
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Create a curved animation for the shake effect
    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticOut),
    );

    // Preload audio files
    _loadAudioAssets();
  }

  void _loadAudioAssets() async {
    await hitSoundPlayer.setSource(AssetSource('sounds/hit.mp3'));
    await missSoundPlayer.setSource(AssetSource('sounds/miss.mp3'));
    await victorySoundPlayer.setSource(AssetSource('sounds/victory.mp3'));
  }

  @override
  void dispose() {
    _shakeController.dispose();
    hitSoundPlayer.dispose();
    missSoundPlayer.dispose();
    victorySoundPlayer.dispose();
    super.dispose();
  }

  // Handle move selection by the Head Mover
  void onMoveSelected(Move move) {
    if (isAnimating || isGameOver) return;

    setState(() {
      selectedMove = move;
      // Automatically switch to Guesser's turn
      isPlayer1Turn = !isPlayer1Turn;
    });
  }

  // Handle guess by the Guesser
  void onGuessSelected(Move move) {
    if (isAnimating || isGameOver || selectedMove == Move.none) return;

    setState(() {
      guessedMove = move;
      isAnimating = true;
    });

    // Check if guess is correct
    if (guessedMove == selectedMove) {
      _handleCorrectGuess();
    } else {
      _handleIncorrectGuess();
    }
  }

  void _handleCorrectGuess() async {
    // Play hit sound
    await hitSoundPlayer.resume();

    // Increment streak
    setState(() {
      correctStreak++;
    });

    // Trigger shake animation
    _shakeController.reset();
    _shakeController.forward();

    // Check if the Guesser has won (3 correct guesses in a row)
    if (correctStreak >= 3) {
      // Play victory sound
      await victorySoundPlayer.resume();

      // Set winner and end game
      setState(() {
        winnerName =
            player1Role == PlayerRole.guesser ? "Player 1" : "Player 2";
        isGameOver = true;
      });
    } else {
      // Reset for next round with same roles
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            selectedMove = Move.none;
            guessedMove = Move.none;
            isAnimating = false;
          });
        }
      });
    }
  }

  void _handleIncorrectGuess() async {
    // Play miss sound
    await missSoundPlayer.resume();

    // Swap roles and reset streak
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          // Swap roles
          var tempRole = player1Role;
          player1Role = player2Role;
          player2Role = tempRole;

          // Reset game state
          correctStreak = 0;
          selectedMove = Move.none;
          guessedMove = Move.none;
          isAnimating = false;
        });
      }
    });
  }

  // Reset the game to start over
  void _resetGame() {
    setState(() {
      player1Role = PlayerRole.headMover;
      player2Role = PlayerRole.guesser;
      selectedMove = Move.none;
      guessedMove = Move.none;
      correctStreak = 0;
      isPlayer1Turn = true;
      isGameOver = false;
      isAnimating = false;
      winnerName = "";
    });
  }

  // Get background color based on streak
  Color _getBackgroundColor() {
    if (isGameOver) {
      return Colors.black;
    } else if (correctStreak == 2) {
      return Colors.red.shade800;
    } else {
      return Colors.blueGrey.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPlayerRole = isPlayer1Turn ? player1Role : player2Role;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        color: _getBackgroundColor(),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _shakeAnimation,
            builder: (context, child) {
              // Apply screen shake effect when animation is active
              final offset = _shakeController.isAnimating
                  ? sin(_shakeAnimation.value * 4 * pi) * 10
                  : 0.0;

              return Transform.translate(
                offset: Offset(offset, 0),
                child: child,
              );
            },
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Header section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'SHADOWBOXING',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildPlayerInfo("Player 1", player1Role),
                            _buildPlayerInfo("Player 2", player2Role),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Scoreboard
                  Scoreboard(correctStreak: correctStreak),

                  // Hit animation (middle section)
                  HitAnimation(
                    isAnimating: isAnimating && guessedMove == selectedMove,
                    isGameOver: isGameOver,
                    winnerName: winnerName,
                  ),

                  // Game controls (bottom section)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Instruction text
                        Text(
                          isGameOver
                              ? "Game Over!"
                              : currentPlayerRole == PlayerRole.headMover
                                  ? "Select your move"
                                  : selectedMove == Move.none
                                      ? "Waiting for Head Mover..."
                                      : "Guess the move",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 24),

                        // Control buttons
                        !isGameOver
                            ? Padding(
                                padding: const EdgeInsets.only(bottom: 32.0),
                                child: currentPlayerRole == PlayerRole.headMover
                                    ? MoveButtons(
                                        onMoveSelected: onMoveSelected,
                                      )
                                    : GuessButtons(
                                        onGuessSelected: onGuessSelected,
                                        enabled: selectedMove != Move.none,
                                      ),
                              )
                            :
                            // Reset game button
                            Padding(
                                padding: const EdgeInsets.only(bottom: 32.0),
                                child: ElevatedButton(
                                  onPressed: _resetGame,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 16,
                                    ),
                                    textStyle: TextStyle(fontSize: 20),
                                  ),
                                  child: Text("PLAY AGAIN"),
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerInfo(String playerName, PlayerRole role) {
    final isCurrentPlayer = (playerName == "Player 1" && isPlayer1Turn) ||
        (playerName == "Player 2" && !isPlayer1Turn);

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentPlayer
            ? Colors.deepPurple
            : Colors.deepPurple.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            playerName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            role == PlayerRole.headMover ? "Head Mover" : "Guesser",
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
