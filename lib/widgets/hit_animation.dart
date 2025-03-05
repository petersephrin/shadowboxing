import 'package:flutter/material.dart';

class HitAnimation extends StatefulWidget {
  final bool isAnimating;
  final bool isGameOver;
  final String winnerName;

  const HitAnimation({
    Key? key,
    required this.isAnimating,
    required this.isGameOver,
    required this.winnerName,
  }) : super(key: key);

  @override
  _HitAnimationState createState() => _HitAnimationState();
}

class _HitAnimationState extends State<HitAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.3, curve: Curves.easeIn),
        reverseCurve: Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.5, curve: Curves.elasticOut),
        reverseCurve: Interval(0.5, 1.0, curve: Curves.easeInBack),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(HitAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isAnimating && !oldWidget.isAnimating) {
      _controller.reset();
      _controller.forward().then((_) {
        _controller.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      child: Center(
        child:
            widget.isGameOver
                ? _buildWinnerAnimation()
                : AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _opacityAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: widget.isAnimating ? _buildHitEffect() : SizedBox(),
                ),
      ),
    );
  }

  Widget _buildHitEffect() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Circular flash
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
        ),

        // Inner flare
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.yellow.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
        ),

        // Hit text
        Text(
          "HIT!",
          style: TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.red.shade900,
                blurRadius: 10,
                offset: Offset(2, 2),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWinnerAnimation() {
    return AnimatedOpacity(
      opacity: widget.isGameOver ? 1.0 : 0.0,
      duration: Duration(milliseconds: 800),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.winnerName.toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "WINS!",
            style: TextStyle(
              color: Colors.yellow,
              fontSize: 40,
              fontWeight: FontWeight.bold,
              letterSpacing: 3.0,
              shadows: [
                Shadow(
                  color: Colors.red.shade900,
                  blurRadius: 15,
                  offset: Offset(3, 3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
