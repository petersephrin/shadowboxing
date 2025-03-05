import 'package:flutter/material.dart';
import 'dart:math' as math;

// This file contains helper classes for animations and effects

class HitFlashAnimation extends StatefulWidget {
  final Widget child;
  final bool triggerAnimation;
  final Color flashColor;

  const HitFlashAnimation({
    Key? key,
    required this.child,
    required this.triggerAnimation,
    this.flashColor = Colors.white,
  }) : super(key: key);

  @override
  State<HitFlashAnimation> createState() => _HitFlashAnimationState();
}

class _HitFlashAnimationState extends State<HitFlashAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 0.8,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.triggerAnimation) {
      _playAnimation();
    }
  }

  @override
  void didUpdateWidget(HitFlashAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.triggerAnimation && !oldWidget.triggerAnimation) {
      _playAnimation();
    }
  }

  void _playAnimation() {
    _controller.forward().then((_) {
      _controller.reverse();
    });
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
        widget.child,
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Container(
                color: widget.flashColor,
              ),
            );
          },
        ),
      ],
    );
  }
}

class ScreenShakeAnimation extends StatefulWidget {
  final Widget child;
  final bool triggerAnimation;
  final double intensity;

  const ScreenShakeAnimation({
    Key? key,
    required this.child,
    required this.triggerAnimation,
    this.intensity = 10.0,
  }) : super(key: key);

  @override
  State<ScreenShakeAnimation> createState() => _ScreenShakeAnimationState();
}

class _ScreenShakeAnimationState extends State<ScreenShakeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final math.Random _random = math.Random();
  Offset _offset = Offset.zero;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _controller.addListener(() {
      if (_controller.isAnimating) {
        setState(() {
          _offset = Offset(
            _random.nextDouble() * widget.intensity * 2 - widget.intensity,
            _random.nextDouble() * widget.intensity * 2 - widget.intensity,
          );
        });
      } else {
        setState(() {
          _offset = Offset.zero;
        });
      }
    });

    if (widget.triggerAnimation) {
      _playAnimation();
    }
  }

  @override
  void didUpdateWidget(ScreenShakeAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.triggerAnimation && !oldWidget.triggerAnimation) {
      _playAnimation();
    }
  }

  void _playAnimation() {
    _controller.forward().then((_) {
      _controller.reverse();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: _offset,
      child: widget.child,
    );
  }
}

class PulsingBackground extends StatefulWidget {
  final Color baseColor;
  final Color pulseColor;
  final double intensity;

  const PulsingBackground({
    Key? key,
    required this.baseColor,
    required this.pulseColor,
    this.intensity = 1.0,
  }) : super(key: key);

  @override
  State<PulsingBackground> createState() => _PulsingBackgroundState();
}

class _PulsingBackgroundState extends State<PulsingBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.repeat(reverse: true);
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
        final effectiveIntensity = _pulseAnimation.value * widget.intensity;

        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.0 + effectiveIntensity * 0.3,
              colors: [
                Color.lerp(widget.baseColor, widget.pulseColor,
                    effectiveIntensity * 0.7)!,
                widget.baseColor,
              ],
              stops: const [0.4, 1.0],
            ),
          ),
        );
      },
    );
  }
}

class ImpactParticles extends StatefulWidget {
  final bool triggerAnimation;
  final Color particleColor;
  final double size;

  const ImpactParticles({
    Key? key,
    required this.triggerAnimation,
    this.particleColor = Colors.yellow,
    this.size = 200,
  }) : super(key: key);

  @override
  State<ImpactParticles> createState() => _ImpactParticlesState();
}

class _ImpactParticlesState extends State<ImpactParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _controller.addListener(() {
      setState(() {
        // Update existing particles
        for (var particle in _particles) {
          particle.update();
        }
      });
    });

    if (widget.triggerAnimation) {
      _generateParticles();
      _playAnimation();
    }
  }

  @override
  void didUpdateWidget(ImpactParticles oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.triggerAnimation && !oldWidget.triggerAnimation) {
      _generateParticles();
      _playAnimation();
    }
  }

  void _generateParticles() {
    _particles.clear();

    for (int i = 0; i < 20; i++) {
      final angle = _random.nextDouble() * 2 * math.pi;
      final speed = _random.nextDouble() * 5 + 3;
      final size = _random.nextDouble() * 8 + 3;

      _particles.add(
        _Particle(
          x: 0,
          y: 0,
          vx: math.cos(angle) * speed,
          vy: math.sin(angle) * speed,
          size: size,
          color: widget.particleColor.withOpacity(0.7),
        ),
      );
    }
  }

  void _playAnimation() {
    _controller.forward().then((_) {
      _controller.reset();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(widget.size, widget.size),
      painter: _ParticlePainter(
        particles: _particles,
        progress: _controller.value,
      ),
    );
  }
}

class _Particle {
  double x;
  double y;
  final double vx;
  final double vy;
  final double size;
  final Color color;

  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
  });

  void update() {
    x += vx;
    y += vy;
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ParticlePainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (var particle in particles) {
      final opacity = 1.0 - progress;
      final paint = Paint()..color = particle.color.withOpacity(opacity);

      canvas.drawCircle(
        center + Offset(particle.x, particle.y),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) => true;
}
