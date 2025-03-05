import 'package:flutter/material.dart';
import 'dart:math' as math;

class RealisticCharacter extends StatefulWidget {
  final bool isPlayerOne;
  final Direction? moveDirection;
  final bool isMoving;
  final String characterAsset; // Path to the base character image

  const RealisticCharacter({
    Key? key,
    required this.isPlayerOne,
    this.moveDirection,
    this.isMoving = false,
    required this.characterAsset,
  }) : super(key: key);

  @override
  State<RealisticCharacter> createState() => _RealisticCharacterState();
}

class _RealisticCharacterState extends State<RealisticCharacter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _headAnimation;
  late Animation<double> _bodyAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _setupAnimations();
  }

  void _setupAnimations() {
    // Default animations (idle state)
    _headAnimation = Tween<double>(begin: 0, end: 0).animate(_controller);
    _bodyAnimation = Tween<double>(begin: 0, end: 0).animate(_controller);

    // Configure animations based on direction
    if (widget.isMoving && widget.moveDirection != null) {
      switch (widget.moveDirection!) {
        case Direction.up:
          _headAnimation =
              Tween<double>(begin: 0, end: -10).animate(_controller);
          break;
        case Direction.down:
          _headAnimation = Tween<double>(begin: 0, end: 5).animate(_controller);
          break;
        case Direction.left:
          _bodyAnimation =
              Tween<double>(begin: 0, end: -15).animate(_controller);
          break;
        case Direction.right:
          _bodyAnimation =
              Tween<double>(begin: 0, end: 15).animate(_controller);
          break;
      }
      _controller.forward();
    } else {
      _controller.reset();
    }
  }

  @override
  void didUpdateWidget(RealisticCharacter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.moveDirection != widget.moveDirection ||
        oldWidget.isMoving != widget.isMoving) {
      _setupAnimations();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: 200,
          height: 350,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Character body with slight rotation or movement
              Positioned(
                bottom: 0,
                child: Transform.translate(
                  offset: Offset(_bodyAnimation.value, 0),
                  child: Transform.rotate(
                    angle:
                        _bodyAnimation.value * math.pi / 360, // Slight rotation
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        widget.characterAsset,
                        width: 180,
                        height: 320,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),

              // Overlay shadow effect for movement
              if (widget.isMoving)
                Positioned(
                  bottom: 0,
                  child: Transform.translate(
                    offset: Offset(_bodyAnimation.value * -0.5, 0),
                    child: Opacity(
                      opacity: 0.3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          widget.characterAsset,
                          width: 180,
                          height: 320,
                          fit: BoxFit.cover,
                          color: widget.isPlayerOne ? Colors.blue : Colors.red,
                          colorBlendMode: BlendMode.srcATop,
                        ),
                      ),
                    ),
                  ),
                ),

              // Direction indicator
              if (widget.moveDirection != null)
                Positioned(
                  top: 20,
                  right: widget.isPlayerOne ? 10 : null,
                  left: widget.isPlayerOne ? null : 10,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.isPlayerOne ? Colors.blue : Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: _getDirectionIcon(widget.moveDirection!),
                  ),
                ),

              // Shadow boxing effect
              if (widget.isMoving) _buildPunchEffect(widget.moveDirection),
            ],
          ),
        );
      },
    );
  }

  Widget _getDirectionIcon(Direction direction) {
    switch (direction) {
      case Direction.up:
        return const Icon(Icons.arrow_upward, color: Colors.white, size: 20);
      case Direction.down:
        return const Icon(Icons.arrow_downward, color: Colors.white, size: 20);
      case Direction.left:
        return const Icon(Icons.arrow_back, color: Colors.white, size: 20);
      case Direction.right:
        return const Icon(Icons.arrow_forward, color: Colors.white, size: 20);
    }
  }

  Widget _buildPunchEffect(Direction? direction) {
    if (direction == null) return const SizedBox.shrink();

    Offset offset = const Offset(0, 0);

    switch (direction) {
      case Direction.up:
        offset = const Offset(0, -80);
        break;
      case Direction.down:
        offset = const Offset(0, 80);
        break;
      case Direction.left:
        offset = const Offset(-80, 0);
        break;
      case Direction.right:
        offset = const Offset(80, 0);
        break;
    }

    return Positioned(
      top: 150,
      left: widget.isPlayerOne ? 100 : 20,
      right: widget.isPlayerOne ? 20 : 100,
      child: Transform.translate(
        offset: offset,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _controller.value,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: widget.isPlayerOne
                  ? Colors.blue.withOpacity(0.5)
                  : Colors.red.withOpacity(0.5),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.isPlayerOne
                      ? Colors.blue.withOpacity(0.3)
                      : Colors.red.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: Text(
                "POW!",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum Direction {
  up,
  down,
  left,
  right,
}
