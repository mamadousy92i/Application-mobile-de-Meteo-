import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import '../models/weather.dart';
import '../services/real_weather_service.dart';
import '../themes/app_colors.dart';
import 'home_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _fadeController;
  late AnimationController _particleController;
  late AnimationController _waveController;

  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _waveAnimation;

  int _currentMessageIndex = 0;
  Timer? _messageTimer;
  Timer? _apiTimer;

  // Service météo
  final RealWeatherService _weatherService = RealWeatherService();

  //  5 VILLES FIXES avec leurs infos visuelles
  final List<CityInfo> _cityInfos = [
    CityInfo('Dakar', '🌍', AppColors.sunny, Icons.wb_sunny_rounded),
    CityInfo('Paris', '🗼', AppColors.info, Icons.wb_sunny_rounded),
    CityInfo('Londres', '🏰', AppColors.cloudy, Icons.wb_sunny_rounded),
    CityInfo('New York', '🗽', AppColors.success, Icons.wb_sunny_rounded),
    CityInfo('Tokyo', '🏯', AppColors.warning, Icons.wb_sunny_rounded),
  ];

  // Données météo récupérées
  final List<Weather> _weatherData = [];
  int _currentCityIndex = 0;

  // Particules flottantes
  List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeParticles();
    _startAnimations();
    _startApiCalls();
  }

  void _initializeAnimations() {
    _progressController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    _waveController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(parent: _waveController, curve: Curves.linear));
  }

  void _initializeParticles() {
    final random = math.Random();
    _particles = List.generate(20, (index) {
      return Particle(
        x: random.nextDouble() * 400,
        y: random.nextDouble() * 800,
        size: 2 + random.nextDouble() * 4,
        speed: 0.5 + random.nextDouble() * 1.5,
        color: Color.lerp(
          AppColors.brightBlue,
          AppColors.softViolet,
          random.nextDouble(),
        )!,
      );
    });
  }

  void _startAnimations() {
    _fadeController.forward();
    _progressController.forward();
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
    _particleController.repeat();
    _waveController.repeat();

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToWeatherTable();
      }
    });
  }

  void _startApiCalls() {
    _fetchNextCity();
    _apiTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentCityIndex < _cityInfos.length) {
        _fetchNextCity();
      } else {
        timer.cancel();
      }
    });
  }

  void _fetchNextCity() async {
    if (_currentCityIndex >= _cityInfos.length) return;

    final cityInfo = _cityInfos[_currentCityIndex];

    try {
      final weather = await _weatherService.getWeatherByCity(cityInfo.name);

      if (mounted) {
        setState(() {
          _weatherData.add(weather);
          _currentMessageIndex = _currentCityIndex;
          _currentCityIndex++;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentCityIndex++;
        });
      }
    }
  }

  void _navigateToWeatherTable() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
            HomeScreen(weatherData: _weatherData),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.3),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 1000),
      ),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    _fadeController.dispose();
    _particleController.dispose();
    _waveController.dispose();
    _messageTimer?.cancel();
    _apiTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          //  Arrière-plan avec gradient dynamique
          _buildDynamicBackground(),

          //  Particules flottantes
          _buildFloatingParticles(),

          //  Contenu principal
          _buildMainContent(),
        ],
      ),
    );
  }

  Widget _buildDynamicBackground() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(
                  AppColors.darkBackground,
                  const Color(0xFF2D3748),
                  0.5 + math.sin(_waveAnimation.value) * 0.2,
                )!,
                Color.lerp(
                  const Color(0xFF2D3748),
                  const Color(0xFF4A5568),
                  0.5 + math.cos(_waveAnimation.value * 1.5) * 0.2,
                )!,
                AppColors.darkBackground,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return Stack(
          children: _particles.map((particle) {
            final time = _particleController.value * 2 * math.pi;
            final x = particle.x + math.sin(time + particle.x) * 20;
            final y = particle.y + math.cos(time + particle.y) * 15;

            return Positioned(
              left: x,
              top: y,
              child: Opacity(
                opacity: 0.3 + math.sin(time + particle.speed) * 0.2,
                child: Container(
                  width: particle.size,
                  height: particle.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: particle.color,
                    boxShadow: [
                      BoxShadow(
                        color: particle.color.withAlpha(128),
                        blurRadius: 4,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildMainContent() {
    return SafeArea(
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  //  Header avec glassmorphism
                  _buildGlassHeader(),

                  const SizedBox(height: 40),

                  //  Animation centrale
                  _buildCentralAnimation(),

                  const SizedBox(height: 40),

                  //  Section de progression
                  _buildProgressSection(),

                  const SizedBox(height: 40),

                  //  Bouton recommencer
                  _buildPermanentRestartButton(),

                  const Spacer(flex: 2),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGlassHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withAlpha(38),
            Colors.white.withAlpha(13),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withAlpha(51),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [AppColors.brightBlue, AppColors.softViolet, Colors.white],
            ).createShader(bounds),
            child: const Text(
              'Météo Express',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Récupération données météo mondiales',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withAlpha(204),
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCentralAnimation() {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Cercles rotatifs
            Transform.rotate(
              angle: _rotationAnimation.value,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.brightBlue.withAlpha(77),
                    width: 2,
                  ),
                ),
              ),
            ),

            Transform.rotate(
              angle: -_rotationAnimation.value,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.softViolet.withAlpha(102),
                    width: 1,
                  ),
                ),
              ),
            ),

            // Particules orbitales
            ...List.generate(6, (index) {
              final angle =
                  (index * 60 + _rotationAnimation.value * 180 / math.pi) *
                      math.pi /
                      180;
              return Transform.translate(
                offset: Offset(50 * math.cos(angle), 50 * math.sin(angle)),
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.lerp(
                            AppColors.brightBlue,
                            AppColors.softViolet,
                            index / 6,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.brightBlue.withAlpha(128),
                              blurRadius: 4,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }),

            // Icône centrale avec ville actuelle
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.brightBlue.withAlpha(204),
                          AppColors.softViolet.withAlpha(153),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.brightBlue.withAlpha(102),
                          blurRadius: 15,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Soleil qui tourne
                        AnimatedBuilder(
                          animation: _rotationController,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _rotationAnimation.value,
                              child: const Icon(
                                Icons.wb_sunny_rounded,
                                size: 24,
                                color: Colors.orange,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildProgressSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withAlpha(26),
            Colors.white.withAlpha(13),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withAlpha(38),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Message dynamique
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Text(
              _currentMessageIndex < _cityInfos.length
                  ? '${_cityInfos[_currentMessageIndex].emoji} Exploration de ${_cityInfos[_currentMessageIndex].name}...'
                  : '✨ Finalisation en cours...',
              key: ValueKey(_currentMessageIndex),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 20),

          // Barre de progression stylée
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.white.withAlpha(26),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          width:
                          MediaQuery.of(context).size.width *
                              _progressAnimation.value *
                              0.8,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            gradient: LinearGradient(
                              colors: [AppColors.brightBlue, AppColors.softViolet],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.brightBlue.withAlpha(128),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(_progressAnimation.value * 100).round()}%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.brightBlue,
                        ),
                      ),
                      Text(
                        '${_weatherData.length}/5 villes',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPermanentRestartButton() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_pulseAnimation.value - 1.0) * 0.01,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brightBlue.withAlpha(77),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: AppColors.softViolet.withAlpha(51),
                  blurRadius: 25,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.brightBlue, AppColors.softViolet],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.white.withAlpha(51),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(25),
                  onTap: _restartLoading,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedBuilder(
                          animation: _rotationController,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _rotationAnimation.value,
                              child: const Icon(
                                Icons.refresh_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Recommencer',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _restartLoading() {
    setState(() {
      _currentMessageIndex = 0;
      _currentCityIndex = 0;
      _weatherData.clear();
    });
    _progressController.reset();
    _startAnimations();
    _startApiCalls();
  }
}

// Modèles de données
class CityInfo {
  final String name;
  final String emoji;
  final Color color;
  final IconData icon;

  CityInfo(this.name, this.emoji, this.color, this.icon);
}

class Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final Color color;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.color,
  });
}