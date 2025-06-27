import 'package:flutter/material.dart';
import 'dart:math';

class NightWeatherAnimation extends StatefulWidget {
  final Widget child;
  final String weatherCondition;

  const NightWeatherAnimation({
    super.key,
    required this.child,
    this.weatherCondition = 'clear',
  });

  @override
  State<NightWeatherAnimation> createState() => _NightWeatherAnimationState();
}

class _NightWeatherAnimationState extends State<NightWeatherAnimation>
    with TickerProviderStateMixin {
  late AnimationController _starsController;
  late AnimationController _mistController;
  late AnimationController _moonController;
  late AnimationController _cloudController;

  late Animation<double> _starsAnimation;
  late Animation<double> _mistAnimation;
  late Animation<double> _moonAnimation;
  late Animation<double> _cloudAnimation;

  List<Star> _stars = [];
  List<MistParticle> _mistParticles = [];

  @override
  void initState() {
    super.initState();

    // Animation des étoiles scintillantes
    _starsController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Animation de la brume/nuages
    _mistController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    // Animation de la lune
    _moonController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    );

    // Animation des nuages lents
    _cloudController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _starsAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _starsController, curve: Curves.easeInOut),
    );

    _mistAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _mistController, curve: Curves.linear),
    );

    _moonAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _moonController, curve: Curves.linear),
    );

    _cloudAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _cloudController, curve: Curves.linear),
    );

    _generateStars();
    _generateMistParticles();
    _startAnimations();
  }

  void _generateStars() {
    final random = Random();
    _stars = List.generate(25, (index) {
      return Star(
        x: random.nextDouble(),
        y: random.nextDouble() * 0.7, // Étoiles dans le haut de l'écran
        size: 1.0 + random.nextDouble() * 2.0,
        opacity: 0.3 + random.nextDouble() * 0.7,
        twinkleSpeed: 0.5 + random.nextDouble() * 1.5,
        twinkleOffset: random.nextDouble() * 2 * pi,
      );
    });
  }

  void _generateMistParticles() {
    final random = Random();
    _mistParticles = List.generate(15, (index) {
      return MistParticle(
        x: random.nextDouble(),
        y: 0.3 + random.nextDouble() * 0.7,
        size: 30.0 + random.nextDouble() * 80.0,
        opacity: 0.1 + random.nextDouble() * 0.3,
        speed: 0.2 + random.nextDouble() * 0.6,
        drift: random.nextDouble() * 0.1 - 0.05,
      );
    });
  }

  void _startAnimations() {
    _starsController.repeat(reverse: true);
    _mistController.repeat();
    _moonController.repeat();
    _cloudController.repeat();
  }

  @override
  void dispose() {
    _starsController.dispose();
    _mistController.dispose();
    _moonController.dispose();
    _cloudController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fond dégradé nocturne
        _buildNightGradient(),

        // Animation de la lune
        _buildMoonAnimation(),

        // Animation des étoiles
        _buildStarsAnimation(),

        // Animation de brume/nuages selon la météo
        _buildMistAnimation(),

        // Nuages légers pour certaines conditions
        if (widget.weatherCondition.contains('cloud')) _buildCloudAnimation(),

        // Contenu par-dessus
        widget.child,
      ],
    );
  }

  Widget _buildNightGradient() {
    Color topColor;
    Color bottomColor;

    switch (widget.weatherCondition.toLowerCase()) {
      case 'clear':
        topColor = const Color(0xFF0B1426);
        bottomColor = const Color(0xFF1A2332);
        break;
      case 'clouds':
        topColor = const Color(0xFF0D1421);
        bottomColor = const Color(0xFF1F2937);
        break;
      case 'rain':
        topColor = const Color(0xFF0F1419);
        bottomColor = const Color(0xFF1F2028);
        break;
      default:
        topColor = const Color(0xFF0B1426);
        bottomColor = const Color(0xFF1A2332);
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [topColor, bottomColor],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }

  Widget _buildMoonAnimation() {
    return AnimatedBuilder(
      animation: _moonAnimation,
      builder: (context, child) {
        final moonPosition = _moonAnimation.value;

        return Positioned(
          top: 30 + (moonPosition * 20), // Mouvement vertical
          right: 40 + (sin(moonPosition * 2 * pi) * 15), // Mouvement horizontal
          child: Opacity(
            opacity: 0.8,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withAlpha(230),
                    Colors.white.withAlpha(153),
                    Colors.white.withAlpha(51),
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withAlpha(77),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(217),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStarsAnimation() {
    return AnimatedBuilder(
      animation: _starsAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: StarsPainter(_stars, _starsAnimation.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildMistAnimation() {
    return AnimatedBuilder(
      animation: _mistAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: MistPainter(_mistParticles, _mistAnimation.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildCloudAnimation() {
    return AnimatedBuilder(
      animation: _cloudAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: NightCloudsPainter(_cloudAnimation.value),
          size: Size.infinite,
        );
      },
    );
  }
}

// Modèle pour les étoiles
class Star {
  final double x;
  final double y;
  final double size;
  final double opacity;
  final double twinkleSpeed;
  final double twinkleOffset;

  Star({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.twinkleSpeed,
    required this.twinkleOffset,
  });
}

// Modèle pour les particules de brume
class MistParticle {
  final double x;
  final double y;
  final double size;
  final double opacity;
  final double speed;
  final double drift;

  MistParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.speed,
    required this.drift,
  });
}

// Painter pour les étoiles scintillantes
class StarsPainter extends CustomPainter {
  final List<Star> stars;
  final double animationValue;

  StarsPainter(this.stars, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (Star star in stars) {
      final opacity = star.opacity * (0.3 + 0.7 * sin(animationValue * 2 * pi * star.twinkleSpeed + star.twinkleOffset).abs());
      final paint = Paint()
        ..color = Colors.white.withAlpha((opacity * 255).round())
        ..style = PaintingStyle.fill;

      final center = Offset(star.x * size.width, star.y * size.height);

      // Étoile principale
      canvas.drawCircle(center, star.size, paint);

      // Effet de scintillement (croix)
      final glowOpacity = star.opacity * 0.6 * sin(animationValue * 2 * pi * star.twinkleSpeed + star.twinkleOffset).abs();
      final glowPaint = Paint()
        ..color = Colors.white.withAlpha((glowOpacity * 255).round())
        ..strokeWidth = 0.5
        ..style = PaintingStyle.stroke;

      final glowSize = star.size * 3;
      canvas.drawLine(
        Offset(center.dx - glowSize, center.dy),
        Offset(center.dx + glowSize, center.dy),
        glowPaint,
      );
      canvas.drawLine(
        Offset(center.dx, center.dy - glowSize),
        Offset(center.dx, center.dy + glowSize),
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Painter pour la brume nocturne
class MistPainter extends CustomPainter {
  final List<MistParticle> particles;
  final double animationValue;

  MistPainter(this.particles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (MistParticle particle in particles) {
      final progress = (animationValue * particle.speed) % 1.0;
      final drift = sin(animationValue * 2 * pi * 0.5) * particle.drift;

      final opacity = particle.opacity * (1.0 - progress * 0.3);
      final paint = Paint()
        ..color = Colors.white.withAlpha((opacity * 255).round())
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      final center = Offset(
        (particle.x + drift) * size.width,
        particle.y * size.height + (progress * size.height * 0.1),
      );

      canvas.drawCircle(center, particle.size * (0.8 + progress * 0.4), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Painter pour les nuages nocturnes
class NightCloudsPainter extends CustomPainter {
  final double animationValue;

  NightCloudsPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(26)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    // Nuage 1
    final cloud1X = (animationValue * 1.2 - 0.2) * size.width;
    final cloud1Path = Path()
      ..addOval(Rect.fromCenter(
        center: Offset(cloud1X, size.height * 0.25),
        width: 120,
        height: 40,
      ))
      ..addOval(Rect.fromCenter(
        center: Offset(cloud1X + 30, size.height * 0.22),
        width: 80,
        height: 35,
      ))
      ..addOval(Rect.fromCenter(
        center: Offset(cloud1X - 20, size.height * 0.27),
        width: 70,
        height: 30,
      ));

    canvas.drawPath(cloud1Path, paint);

    // Nuage 2
    final cloud2X = ((animationValue * 0.8 + 0.3) % 1.2 - 0.2) * size.width;
    final cloud2Path = Path()
      ..addOval(Rect.fromCenter(
        center: Offset(cloud2X, size.height * 0.45),
        width: 100,
        height: 35,
      ))
      ..addOval(Rect.fromCenter(
        center: Offset(cloud2X + 25, size.height * 0.42),
        width: 70,
        height: 30,
      ));

    canvas.drawPath(cloud2Path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}