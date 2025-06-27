import 'dart:math';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../models/weather.dart';
import 'weather_video_service.dart';


class DynamicWeatherBackground extends StatefulWidget {
  final Widget child;
  final Weather weather;

  const DynamicWeatherBackground({
    super.key,
    required this.child,
    required this.weather,
  });

  @override
  State<DynamicWeatherBackground> createState() => _DynamicWeatherBackgroundState();
}

class _DynamicWeatherBackgroundState extends State<DynamicWeatherBackground> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isVideoInitialized = false;
  String? _currentVideoPath;

  @override
  void initState() {
    super.initState();
    // L'initialisation est gérée dans VisibilityDetector
  }

  @override
  void didUpdateWidget(DynamicWeatherBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.weather.weather[0].main != widget.weather.weather[0].main) {
      _disposeVideo();
      // L'initialisation sera déclenchée par VisibilityDetector si la carte est visible
    }
  }

  void _initializeVideo() async {
    if (_isVideoInitialized || _videoPlayerController != null) return;

    try {
      final weatherMain = widget.weather.weather[0].main;
      _currentVideoPath = WeatherVideoService.getVideoPath(weatherMain);

      _videoPlayerController = VideoPlayerController.asset(
        _currentVideoPath!,
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
      );

      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: true,
        showControls: false,
        allowMuting: false,
        allowPlaybackSpeedChanging: false,
        allowFullScreen: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
      );

      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
      }
    } catch (e) {
      print('Erreur lors du chargement de la vidéo: $e');
      if (mounted) {
        setState(() {
          _isVideoInitialized = false;
        });
      }
    }
  }

  void _disposeVideo() {
    if (_videoPlayerController != null) {
      _videoPlayerController!.pause();
      _videoPlayerController!.dispose();
    }
    _chewieController?.dispose();
    _videoPlayerController = null;
    _chewieController = null;
    _isVideoInitialized = false;
  }

  //  Détection si c'est la nuit
  bool _isNightTime() {
    final now = DateTime.now();
    final sunrise = DateTime.fromMillisecondsSinceEpoch(widget.weather.sys.sunrise * 1000);
    final sunset = DateTime.fromMillisecondsSinceEpoch(widget.weather.sys.sunset * 1000);

    // Vérifier si l'heure actuelle est avant le lever ou après le coucher du soleil
    return now.isBefore(sunrise) || now.isAfter(sunset);
  }

  bool _shouldUseNightAnimation() {
    if (!_isNightTime()) return false;

    final weatherMain = widget.weather.weather[0].main.toLowerCase();
    // Utiliser l'animation de nuit pour clear et clouds pendant la nuit
    return weatherMain == 'clear' || weatherMain == 'clouds';
  }

  @override
  void dispose() {
    _disposeVideo();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weatherMain = widget.weather.weather[0].main;
    final fallbackColors = WeatherVideoService.getBackgroundColors(weatherMain);

    return VisibilityDetector(
      key: Key('weather-card-${widget.weather.name}-${widget.weather.weather[0].main}'),
      onVisibilityChanged: (visibilityInfo) {
        if (!mounted) return;

        final visibleFraction = visibilityInfo.visibleFraction;
        if (visibleFraction > 0.5) {
          if (!_isVideoInitialized && !_shouldUseNightAnimation()) {
            _initializeVideo();
          } else if (_isVideoInitialized && !(_videoPlayerController!.value.isPlaying)) {
            _videoPlayerController?.play();
          }
        } else if (visibleFraction <= 0.5 && _isVideoInitialized) {
          _videoPlayerController?.pause();
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            // ANIMATION DE NUIT ou Background vidéo/fallback
            if (_shouldUseNightAnimation())
              _buildNightAnimation()
            else
              _buildDayBackground(fallbackColors),

            // Overlay adaptatif selon jour/nuit
            _buildAdaptiveOverlay(),

            Positioned.fill(
              child: widget.child,
            ),
          ],
        ),
      ),
    );
  }

  //  Animation de nuit
  Widget _buildNightAnimation() {
    return Positioned.fill(
      child: NightWeatherAnimation(
        weatherCondition: widget.weather.weather[0].main,
        child: Container(),
      ),
    );
  }

  //  Background de jour (vidéo ou fallback)
  Widget _buildDayBackground(List<Color> fallbackColors) {
    if (_isVideoInitialized && _chewieController != null) {
      return Positioned.fill(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _videoPlayerController!.value.size.width,
            height: _videoPlayerController!.value.size.height,
            child: Chewie(controller: _chewieController!),
          ),
        ),
      );
    } else {
      return Positioned.fill(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: fallbackColors,
            ),
          ),
        ),
      );
    }
  }

  // Overlay adaptatif jour/nuit
  Widget _buildAdaptiveOverlay() {
    final weatherMain = widget.weather.weather[0].main;

    if (_shouldUseNightAnimation()) {
      // Overlay plus léger pour la nuit car l'animation gère déjà
      return Positioned.fill(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withAlpha(26),
                Colors.black.withAlpha(51),
              ],
            ),
          ),
        ),
      );
    } else {
      // Overlay normal pour le jour
      return Positioned.fill(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withAlpha((_getOverlayOpacity(weatherMain) * 255).round()),
                Colors.black.withAlpha(((_getOverlayOpacity(weatherMain) + 0.1) * 255).round()),
              ],
            ),
          ),
        ),
      );
    }
  }

  double _getOverlayOpacity(String weatherMain) {
    switch (weatherMain.toLowerCase()) {
      case 'clear':
        return 0.2;
      case 'rain':
      case 'snow':
        return 0.1;
      default:
        return 0.15;
    }
  }
}

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

  late Animation<double> _starsAnimation;
  late Animation<double> _mistAnimation;
  late Animation<double> _moonAnimation;

  List<Star> _stars = [];
  List<MistParticle> _mistParticles = [];

  @override
  void initState() {
    super.initState();

    _starsController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _mistController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _moonController = AnimationController(
      duration: const Duration(seconds: 15),
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

    _generateStars();
    _generateMistParticles();
    _startAnimations();
  }

  void _generateStars() {
    final random = Random();
    _stars = List.generate(20, (index) {
      return Star(
        x: random.nextDouble(),
        y: random.nextDouble() * 0.6,
        size: 0.8 + random.nextDouble() * 1.5,
        opacity: 0.4 + random.nextDouble() * 0.6,
        twinkleSpeed: 0.5 + random.nextDouble() * 1.0,
        twinkleOffset: random.nextDouble() * 2 * pi,
      );
    });
  }

  void _generateMistParticles() {
    final random = Random();
    _mistParticles = List.generate(8, (index) {
      return MistParticle(
        x: random.nextDouble(),
        y: 0.4 + random.nextDouble() * 0.6,
        size: 25.0 + random.nextDouble() * 60.0,
        opacity: 0.05 + random.nextDouble() * 0.15,
        speed: 0.15 + random.nextDouble() * 0.4,
        drift: random.nextDouble() * 0.08 - 0.04,
      );
    });
  }

  void _startAnimations() {
    _starsController.repeat(reverse: true);
    _mistController.repeat();
    _moonController.repeat();
  }

  @override
  void dispose() {
    _starsController.dispose();
    _mistController.dispose();
    _moonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildNightGradient(),
        _buildMoonAnimation(),
        _buildStarsAnimation(),
        _buildMistAnimation(),
        widget.child,
      ],
    );
  }

  Widget _buildNightGradient() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF0B1426),
            const Color(0xFF1A2332),
          ],
        ),
      ),
    );
  }

  Widget _buildMoonAnimation() {
    return AnimatedBuilder(
      animation: _moonAnimation,
      builder: (context, child) {
        return Positioned(
          top: 20 + (_moonAnimation.value * 10),
          right: 30 + (sin(_moonAnimation.value * 2 * pi) * 8),
          child: Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withAlpha(230),
                  Colors.white.withAlpha(102),
                  Colors.white.withAlpha(26),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withAlpha(51),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ],
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
}

class Star {
  final double x, y, size, opacity, twinkleSpeed, twinkleOffset;
  Star({required this.x, required this.y, required this.size, required this.opacity, required this.twinkleSpeed, required this.twinkleOffset});
}

class MistParticle {
  final double x, y, size, opacity, speed, drift;
  MistParticle({required this.x, required this.y, required this.size, required this.opacity, required this.speed, required this.drift});
}

class StarsPainter extends CustomPainter {
  final List<Star> stars;
  final double animationValue;

  StarsPainter(this.stars, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (Star star in stars) {
      final opacity = star.opacity * (0.4 + 0.6 * sin(animationValue * 2 * pi * star.twinkleSpeed + star.twinkleOffset).abs());
      final paint = Paint()
        ..color = Colors.white.withAlpha(opacity as int)
        ..style = PaintingStyle.fill;

      final center = Offset(star.x * size.width, star.y * size.height);

      // Étoile principale
      canvas.drawCircle(center, star.size, paint);

      // Effet de scintillement (croix)
      final glowPaint = Paint()
        ..color = Colors.white.withAlpha((opacity * 0.5) as int)
        ..strokeWidth = 0.3
        ..style = PaintingStyle.stroke;

      final glowSize = star.size * 2.5;
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

class MistPainter extends CustomPainter {
  final List<MistParticle> particles;
  final double animationValue;

  MistPainter(this.particles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (MistParticle particle in particles) {
      final progress = (animationValue * particle.speed) % 1.0;
      final drift = sin(animationValue * 2 * pi * 0.3) * particle.drift;

      final paint = Paint()
        ..color = Colors.white.withAlpha((particle.opacity * (1.0 - progress * 0.2)) as int)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      final center = Offset(
        (particle.x + drift) * size.width,
        particle.y * size.height + (progress * size.height * 0.08),
      );

      canvas.drawCircle(center, particle.size * (0.8 + progress * 0.3), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}