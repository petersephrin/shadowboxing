import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flame_audio/flame_audio.dart';
import 'dart:math' as math;

void main() {
  runApp(
    const MaterialApp(
      title: 'Shadow Boxing',
      home: GameWrapper(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class GameWrapper extends StatelessWidget {
  const GameWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: ShadowBoxingGame(),
        overlayBuilderMap: {
          'main_menu': (context, game) =>
              MainMenuOverlay(game as ShadowBoxingGame),
          'head_mover': (context, game) =>
              HeadMoverOverlay(game as ShadowBoxingGame),
          'guesser': (context, game) =>
              GuesserOverlay(game as ShadowBoxingGame),
          'result': (context, game) => ResultOverlay(game as ShadowBoxingGame),
          'game_over': (context, game) =>
              GameOverOverlay(game as ShadowBoxingGame),
        },
        initialActiveOverlays: const ['main_menu'],
      ),
    );
  }
}

class ShadowBoxingGame extends FlameGame {
  // Game states
  bool isPlayer1Mover = true;
  String? selectedMove;
  String? guessedMove;
  int consecutiveCorrectGuesses = 0;
  bool isGameOver = false;
  String winner = '';

  // Game visual elements
  late BackgroundComponent background;
  late HeadComponent opponentHead;

  // Effects
  final math.Random _random = math.Random();

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load sound effects
    await FlameAudio.audioCache.loadAll([
      'hit.mp3',
      'miss.mp3',
      'victory.mp3',
    ]);

    // Add background
    background = BackgroundComponent()..size = size;
    add(background);

    // Add opponent head
    opponentHead = HeadComponent(
      position: Vector2(size.x / 2, size.y / 2),
      size: Vector2(200, 200),
    );
    add(opponentHead);

    // Initialize overlays
    overlays.add('main_menu');
  }

  void startGame() {
    // Reset game state
    isPlayer1Mover = true;
    selectedMove = null;
    guessedMove = null;
    consecutiveCorrectGuesses = 0;
    isGameOver = false;
    winner = '';

    // Reset background intensity
    background.intensity = 0.0;

    // Reset head position
    opponentHead.resetPosition();

    // Start with head mover screen
    overlays.remove('main_menu');
    overlays.add('head_mover');
  }

  void selectMove(String move) {
    selectedMove = move;

    // Store the move but don't animate yet
    opponentHead.setSelectedMove(move);

    // Show guesser screen
    overlays.remove('head_mover');
    overlays.add('guesser');
  }

  void guessMove(String move) {
    guessedMove = move;

    // Now animate the head movement to reveal the actual move
    opponentHead.animateMove();

    // Process the result
    if (guessedMove == selectedMove) {
      // Correct guess
      consecutiveCorrectGuesses++;
      FlameAudio.play('hit.mp3');

      // Show hit effect
      addHitEffect();

      // Update background intensity
      background.intensity = math.min(1.0, consecutiveCorrectGuesses / 3);

      // Check for win condition
      if (consecutiveCorrectGuesses >= 3) {
        isGameOver = true;
        winner = isPlayer1Mover ? 'Player 2' : 'Player 1';
        FlameAudio.play('victory.mp3');
      }
    } else {
      // Incorrect guess
      consecutiveCorrectGuesses = 0;
      FlameAudio.play('miss.mp3');
      background.intensity = 0.0;

      // Switch roles
      isPlayer1Mover = !isPlayer1Mover;
    }

    // Show result after a short delay to allow animation to complete
    Future.delayed(const Duration(milliseconds: 1000), () {
      overlays.remove('guesser');

      if (isGameOver) {
        overlays.add('game_over');
      } else {
        overlays.add('result');
      }
    });
  }

  void nextRound() {
    selectedMove = null;
    guessedMove = null;

    // Reset head position
    opponentHead.resetPosition();

    overlays.remove('result');
    overlays.add('head_mover');
  }

  void resetGame() {
    overlays.remove('game_over');
    startGame();
  }

  void addHitEffect() {
    final centerX = size.x / 2;
    final centerY = size.y / 2;

    // Add a flash effect
    add(
      ParticleSystemComponent(
        particle: Particle.generate(
          count: 30,
          lifespan: 0.8,
          generator: (i) => AcceleratedParticle(
            acceleration: Vector2(0, 40),
            speed: Vector2(
              _random.nextDouble() * 300 - 150,
              _random.nextDouble() * -250,
            ),
            position: Vector2(centerX, centerY),
            child: CircleParticle(
              radius: _random.nextDouble() * 12 + 5,
              paint: Paint()..color = Colors.yellow.withOpacity(0.7),
            ),
          ),
        ),
      ),
    );

    // Add impact text
    final impactTexts = ['POW!', 'BAM!', 'WHAM!', 'BOOM!'];
    final randomText = impactTexts[_random.nextInt(impactTexts.length)];

    final textComponent = TextComponent(
      text: randomText,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 60,
          fontWeight: FontWeight.bold,
          color: Colors.yellow,
        ),
      ),
      position: Vector2(centerX, centerY),
      anchor: Anchor.center,
    );

    textComponent.add(
      SequenceEffect([
        ScaleEffect.by(
          Vector2.all(1.5),
          EffectController(duration: 0.3, curve: Curves.elasticOut),
        ),
        ScaleEffect.by(
          Vector2.all(0.5),
          EffectController(duration: 0.5),
        ),
        RemoveEffect(),
      ]),
    );

    add(textComponent);

    // Add screen shake effect
    //camera.shake(duration: 0.3, intensity: 10);
  }
}

class HeadComponent extends PositionComponent {
  String? selectedMove;
  late Sprite headSprite;
  bool useSprite = true;
  final Paint _paint = Paint();
  final Vector2 initialPosition;
  final double moveDistance = 50.0;

  HeadComponent({
    required Vector2 position,
    required Vector2 size,
  })  : initialPosition = position.clone(),
        super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Try to load head sprite
    try {
      headSprite = await Sprite.load('boxer_head.png');
      useSprite = true;
    } catch (e) {
      print('Could not load head sprite: $e');
      useSprite = false;
    }
  }

  void setSelectedMove(String move) {
    selectedMove = move;
  }

  void resetPosition() {
    position = initialPosition.clone();
  }

  void animateMove() {
    if (selectedMove == null) return;

    Vector2 targetPosition;

    switch (selectedMove) {
      case 'Up':
        targetPosition = initialPosition + Vector2(0, -moveDistance);
        break;
      case 'Down':
        targetPosition = initialPosition + Vector2(0, moveDistance);
        break;
      case 'Left':
        targetPosition = initialPosition + Vector2(-moveDistance, 0);
        break;
      case 'Right':
        targetPosition = initialPosition + Vector2(moveDistance, 0);
        break;
      default:
        targetPosition = initialPosition;
    }

    // Animate the head movement
    add(
      MoveEffect.to(
        targetPosition,
        EffectController(
          duration: 0.5,
          curve: Curves.easeOutBack,
        ),
      ),
    );

    // Add a slight bounce back effect
    Future.delayed(const Duration(milliseconds: 600), () {
      add(
        MoveEffect.to(
          initialPosition,
          EffectController(
            duration: 0.3,
            curve: Curves.elasticOut,
          ),
        ),
      );
    });
  }

  @override
  void render(Canvas canvas) {
    if (useSprite) {
      // Render the head sprite
      headSprite.render(
        canvas,
        position: Vector2.zero(),
        size: size,
      );
    } else {
      // Fallback to a simple circle head if sprite can't be loaded
      _paint.color = Colors.brown;
      canvas.drawCircle(
        Offset(size.x / 2, size.y / 2),
        size.x / 2,
        _paint,
      );

      // Draw eyes
      _paint.color = Colors.black;
      canvas.drawCircle(
        Offset(size.x / 2 - 20, size.y / 2 - 10),
        10,
        _paint,
      );
      canvas.drawCircle(
        Offset(size.x / 2 + 20, size.y / 2 - 10),
        10,
        _paint,
      );

      // Draw mouth
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(size.x / 2, size.y / 2 + 20),
          width: 40,
          height: 30,
        ),
        0,
        math.pi,
        false,
        _paint,
      );
    }
  }
}

class BackgroundComponent extends PositionComponent {
  double intensity = 0.0;
  final Paint _paint = Paint();
  late Sprite backgroundSprite;
  bool useSprite = true;
  late Timer pulseTimer;
  final math.Random _random = math.Random();

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Load background sprite
    try {
      backgroundSprite = await Sprite.load('boxing_ring.webp');
      useSprite = true;
    } catch (e) {
      print('Could not load background sprite: $e');
      useSprite = false;
    }

    // Setup pulse animation timer
    pulseTimer = Timer(
      0.05,
      onTick: () {
        // This will be called every 0.05 seconds to update the animation
      },
      repeat: true,
    );
  }

  @override
  void render(Canvas canvas) {
    if (useSprite) {
      // Render the sprite background
      backgroundSprite.render(
        canvas,
        position: Vector2.zero(),
        size: size,
      );

      // Add intensity overlay based on game state
      if (intensity > 0) {
        _paint.color = Colors.red.withOpacity(intensity * 0.5);
        canvas.drawRect(
          Rect.fromLTWH(0, 0, size.x, size.y),
          _paint,
        );
      }
    } else {
      // Fallback to a boxing ring background if sprite can't be loaded
      // Draw ring floor
      _paint.color = Colors.grey[800]!;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.x, size.y),
        _paint,
      );

      // Draw ring ropes
      _paint.color = Colors.red;
      _paint.style = PaintingStyle.stroke;
      _paint.strokeWidth = 10;

      // Top rope
      canvas.drawLine(
        Offset(0, size.y * 0.2),
        Offset(size.x, size.y * 0.2),
        _paint,
      );

      // Middle rope
      canvas.drawLine(
        Offset(0, size.y * 0.4),
        Offset(size.x, size.y * 0.4),
        _paint,
      );

      // Bottom rope
      canvas.drawLine(
        Offset(0, size.y * 0.6),
        Offset(size.x, size.y * 0.6),
        _paint,
      );

      // Reset paint style
      _paint.style = PaintingStyle.fill;

      // Add intensity overlay
      if (intensity > 0) {
        _paint.color = Colors.red.withOpacity(intensity * 0.5);
        canvas.drawRect(
          Rect.fromLTWH(0, 0, size.x, size.y),
          _paint,
        );

        // Add pulsing effect when intensity is high
        if (intensity > 0.5) {
          final pulseIntensity = (math.sin(intensity * 10) + 1) / 2 * 0.3;

          _paint.color = Colors.red.withOpacity(pulseIntensity);
          canvas.drawRect(
            Rect.fromLTWH(0, 0, size.x, size.y),
            _paint,
          );
        }
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    pulseTimer.update(dt);

    // Add dynamic lighting effects or animations here
    if (intensity > 0.5) {
      // Add more intense effects as the game progresses
    }
  }
}

// Overlay Widgets

class MainMenuOverlay extends StatelessWidget {
  final ShadowBoxingGame game;

  const MainMenuOverlay(this.game, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'SHADOW BOXING',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'A two-player boxing prediction game\n\n'
              'Player 1 selects a move direction\n'
              'Player 2 tries to guess the direction\n\n'
              'First to guess 3 moves in a row wins!',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: game.startGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
              ),
              child: const Text(
                'START GAME',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HeadMoverOverlay extends StatelessWidget {
  final ShadowBoxingGame game;

  const HeadMoverOverlay(this.game, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Game Info
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'SHADOW BOXING',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    game.isPlayer1Mover
                        ? 'Player 1: Head Mover\nPlayer 2: Guesser'
                        : 'Player 1: Guesser\nPlayer 2: Head Mover',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Streak: ${game.consecutiveCorrectGuesses}/3',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.yellow,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Head Mover Interface
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Head Mover: Select your move',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Direction buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDirectionButton('Up', Icons.arrow_upward),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDirectionButton('Left', Icons.arrow_back),
                      const SizedBox(width: 100),
                      _buildDirectionButton('Right', Icons.arrow_forward),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDirectionButton('Down', Icons.arrow_downward),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // POV explanation
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: const Text(
                "Your opponent will see your head move in this direction",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectionButton(String direction, IconData icon) {
    return GestureDetector(
      onTap: () => game.selectMove(direction),
      child: Container(
        width: 90,
        height: 90,
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue, Colors.blueAccent],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: Colors.white,
            ),
            const SizedBox(height: 5),
            Text(
              direction,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GuesserOverlay extends StatelessWidget {
  final ShadowBoxingGame game;

  const GuesserOverlay(this.game, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Game Info
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'SHADOW BOXING',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    game.isPlayer1Mover
                        ? 'Player 1: Head Mover\nPlayer 2: Guesser'
                        : 'Player 1: Guesser\nPlayer 2: Head Mover',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Streak: ${game.consecutiveCorrectGuesses}/3',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.yellow,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Guesser Interface
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Guesser: Predict their move',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Direction buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDirectionButton('Up', Icons.arrow_upward),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDirectionButton('Left', Icons.arrow_back),
                      const SizedBox(width: 100),
                      _buildDirectionButton('Right', Icons.arrow_forward),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDirectionButton('Down', Icons.arrow_downward),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // POV explanation
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: const Text(
                "Watch carefully to see which way your opponent's head moves",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectionButton(String direction, IconData icon) {
    return GestureDetector(
      onTap: () => game.guessMove(direction),
      child: Container(
        width: 90,
        height: 90,
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.purple,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.purple, Colors.deepPurple],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: Colors.white,
            ),
            const SizedBox(height: 5),
            Text(
              direction,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultOverlay extends StatelessWidget {
  final ShadowBoxingGame game;

  const ResultOverlay(this.game, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isCorrect = game.guessedMove == game.selectedMove;

    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
          color: isCorrect
              ? Colors.green.withOpacity(0.9)
              : Colors.red.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isCorrect ? 'HIT!' : 'MISS!',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Head Mover: ${game.selectedMove}\nGuesser: ${game.guessedMove}',
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              isCorrect
                  ? 'Current Streak: ${game.consecutiveCorrectGuesses}/3'
                  : 'Switching Roles!',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: game.nextRound,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
              ),
              child: Text(
                isCorrect ? 'Next Move' : 'Continue',
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GameOverOverlay extends StatelessWidget {
  final ShadowBoxingGame game;

  const GameOverOverlay(this.game, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(30),
        margin: const EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'GAME OVER',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '${game.winner} WINS!',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '3 Correct Guesses In A Row!',
              style: TextStyle(
                fontSize: 22,
                fontStyle: FontStyle.italic,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    game.resetGame();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    'Play Again',
                    style: TextStyle(fontSize: 22),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    game.overlays.remove('game_over');
                    game.overlays.add('main_menu');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    'Main Menu',
                    style: TextStyle(fontSize: 22),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
