import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import '../themes/app_theme.dart';
import '../themes/app_colors.dart';
import 'loading_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {

  late PageController _pageController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _floatingController;
  late AnimationController _particleController;

  Timer? _autoScrollTimer;
  int _currentVideoIndex = 0;

  // Liste des vidéos météo avec descriptions et couleurs enhanced
  final List<WeatherVideo> _weatherVideos = [
    WeatherVideo(
      path: 'assets/animations/sunny.mp4',
      title: 'Journées Ensoleillées',
      subtitle: 'Découvrez la météo en temps réel',
      gradient: AppColors.sunnyGradient,
      accentColor: AppColors.sunny,
      icon: Icons.wb_sunny_rounded,
    ),
    WeatherVideo(
      path: 'assets/animations/rain.mp4',
      title: 'Pluies Rafraîchissantes',
      subtitle: 'Données précises et fiables',
      gradient: AppColors.rainyGradient,
      accentColor: AppColors.rainy,
      icon: Icons.water_drop_rounded,
    ),
    WeatherVideo(
      path: 'assets/animations/nuageux.mp4',
      title: 'Nuages Changeants',
      subtitle: 'Prévisions pour 5 villes',
      gradient: AppColors.cloudyGradient,
      accentColor: AppColors.cloudy,
      icon: Icons.cloud_rounded,
    ),
    WeatherVideo(
      path: 'assets/animations/snow.mp4',
      title: 'Neige Cristalline',
      subtitle: 'Interface moderne et intuitive',
      gradient: AppColors.snowyGradient,
      accentColor: AppColors.snowy,
      icon: Icons.ac_unit_rounded,
    ),
  ];

  final List<VideoPlayerController> _videoControllers = [];
  List<Offset> _particlePositions = [];

  @override
  void initState() {
    super.initState();

    _pageController = PageController();

    // Animations
    _fadeController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    _initializeParticles();
    _initializeVideos();
    _startAnimations();
    _startAutoScroll();
  }

  void _initializeParticles() {
    final random = math.Random();
    _particlePositions = List.generate(15, (index) {
      return Offset(
        random.nextDouble() * 400,
        random.nextDouble() * 800,
      );
    });
  }

  void _initializeVideos() async {
    for (String videoPath in _weatherVideos.map((v) => v.path)) {
      final controller = VideoPlayerController.asset(videoPath);
      _videoControllers.add(controller);

      try {
        await controller.initialize();
        controller.setLooping(true);
        controller.setVolume(0.0);
        if (mounted) setState(() {});
      } catch (e) {
        if (kDebugMode) {
          print('Erreur chargement vidéo $videoPath: $e');
        }
      }
    }

    if (_videoControllers.isNotEmpty) {
      _videoControllers[0].play();
    }
  }

  void _startAnimations() {
    _fadeController.forward();
    _slideController.forward();
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
    _floatingController.repeat(reverse: true);
    _particleController.repeat();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted && _pageController.hasClients) {
        final nextIndex = (_currentVideoIndex + 1) % _weatherVideos.length;
        _changePage(nextIndex);
      }
    });
  }

  void _changePage(int index) {
    if (!mounted) return;

    if (_currentVideoIndex < _videoControllers.length) {
      _videoControllers[_currentVideoIndex].pause();
    }

    setState(() {
      _currentVideoIndex = index;
    });

    if (index < _videoControllers.length && _videoControllers[index].value.isInitialized) {
      _videoControllers[index].play();
    }

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    _floatingController.dispose();
    _particleController.dispose();
    _autoScrollTimer?.cancel();

    for (var controller in _videoControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          //  Arrière-plan vidéo
          _buildVideoBackground(),

          //  Particules flottantes
          _buildFloatingParticles(),

          //  Overlay de gradient dynamique
          _buildDynamicGradientOverlay(),

          //  Contenu principal avec glassmorphism
          _buildGlassmorphismContent(),

          //  Indicateurs de page stylés
          _buildStylizedPageIndicators(),

          //  Éléments décoratifs flottants
          _buildFloatingElements(),

          //  Bouton switch thème premium
          _buildPremiumThemeToggle(),
        ],
      ),
    );
  }

  Widget _buildVideoBackground() {
    if (_videoControllers.isEmpty || _currentVideoIndex >= _videoControllers.length) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _weatherVideos[_currentVideoIndex].gradient,
          ),
        ),
      );
    }

    final controller = _videoControllers[_currentVideoIndex];

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      child: controller.value.isInitialized
          ? SizedBox.expand(
        key: ValueKey(_currentVideoIndex),
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: controller.value.size.width,
            height: controller.value.size.height,
            child: VideoPlayer(controller),
          ),
        ),
      )
          : Container(
        key: ValueKey('fallback_$_currentVideoIndex'),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _weatherVideos[_currentVideoIndex].gradient,
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return Stack(
          children: _particlePositions.asMap().entries.map((entry) {
            final index = entry.key;
            final position = entry.value;
            final animationOffset = _particleController.value * 2 * math.pi;

            return Positioned(
              left: position.dx + math.sin(animationOffset + index) * 30,
              top: position.dy + math.cos(animationOffset + index * 0.5) * 20,
              child: Opacity(
                opacity: 0.1 + (math.sin(animationOffset + index) * 0.1),
                child: Icon(
                  _weatherVideos[_currentVideoIndex].icon,
                  size: 20 + (index % 3) * 5,
                  color: _weatherVideos[_currentVideoIndex].accentColor,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildDynamicGradientOverlay() {
    // Overlay adaptatif selon le type de météo
    List<Color> overlayColors;

    switch (_currentVideoIndex) {
      case 0: // Sunny - overlay plus clair
        overlayColors = [
          Colors.black.withAlpha((0.1 * 255).round()),
          Colors.transparent,
          Colors.black.withAlpha((0.2 * 255).round()),
          Colors.black.withAlpha((0.4 * 255).round()),
        ];
        break;
      case 1: // Rain - overlay plus foncé
        overlayColors = [
          Colors.black.withAlpha((0.3 * 255).round()),
          Colors.transparent,
          Colors.black.withAlpha((0.4 * 255).round()),
          Colors.black.withAlpha((0.7 * 255).round()),
        ];
        break;
      default: // Autres - overlay standard
        overlayColors = [
          Colors.black.withAlpha((0.2 * 255).round()),
          Colors.transparent,
          Colors.black.withAlpha((0.3 * 255).round()),
          Colors.black.withAlpha((0.6 * 255).round()),
        ];
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: overlayColors,
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
    );
  }

  Widget _buildPremiumThemeToggle() {
    return Positioned(
      top: 50,
      right: 20,
      child: SafeArea(
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return AnimatedBuilder(
              animation: _floatingController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, math.sin(_floatingController.value * 2 * math.pi) * 3),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withAlpha((0.25 * 255).round()),
                          Colors.white.withAlpha((0.15 * 255).round()),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withAlpha((0.4 * 255).round()),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _weatherVideos[_currentVideoIndex].accentColor.withAlpha((0.4 * 255).round()),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          themeProvider.toggleTheme();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            transitionBuilder: (child, animation) {
                              return RotationTransition(
                                turns: animation,
                                child: FadeTransition(opacity: animation, child: child),
                              );
                            },
                            child: Icon(
                              themeProvider.isDarkMode
                                  ? Icons.light_mode_rounded
                                  : Icons.dark_mode_rounded,
                              key: ValueKey(themeProvider.isDarkMode),
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildGlassmorphismContent() {
    return SafeArea(
      child: AnimatedBuilder(
        animation: _fadeController,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeController.value,
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const Spacer(flex: 1),

                      //  Logo et titre avec glassmorphism
                      _buildGlassmorphismHeader(),

                      const SizedBox(height: 20),

                      //  Contenu dynamique avec cartes glass
                      _buildGlassContentCards(),

                      const SizedBox(height: 30),

                      //  Bouton
                      _buildNeonStartButton(),

                      const Spacer(flex: 1),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGlassmorphismHeader() {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _slideController.value) * 100),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withAlpha((0.25 * 255).round()),
                  Colors.white.withAlpha((0.15 * 255).round()),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withAlpha((0.4 * 255).round()),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withAlpha((0.1 * 255).round()),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withAlpha((0.1 * 255).round()),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Column(
                children: [
                  // Logo météo animé avec rotation
                  AnimatedBuilder(
                    animation: _rotationController,
                    builder: (context, child) {
                      return Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              _weatherVideos[_currentVideoIndex].accentColor.withAlpha((0.4 * 255).round()),
                              _weatherVideos[_currentVideoIndex].accentColor.withAlpha((0.1 * 255).round()),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.7, 1.0],
                          ),
                          border: Border.all(
                            color: _weatherVideos[_currentVideoIndex].accentColor.withAlpha((0.6 * 255).round()),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _weatherVideos[_currentVideoIndex].accentColor.withAlpha((0.3 * 255).round()),
                              blurRadius: 20,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                        child: Transform.rotate(
                          angle: _rotationController.value * 2 * math.pi,
                          child: Icon(
                            _weatherVideos[_currentVideoIndex].icon,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Titre principal avec effet shimmer amélioré
                  AnimatedBuilder(
                    animation: _rotationController,
                    builder: (context, child) {
                      return ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            Colors.white,
                            _weatherVideos[_currentVideoIndex].accentColor,
                            Colors.white,
                            _weatherVideos[_currentVideoIndex].accentColor,
                            Colors.white,
                          ],
                          stops: [
                            0.0,
                            0.2 + _rotationController.value * 0.3,
                            0.5 + _rotationController.value * 0.3,
                            0.8 + _rotationController.value * 0.3,
                            1.0,
                          ],
                        ).createShader(bounds),
                        child: const Text(
                          'Météo Express',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 8),

                  // Sous-titre
                  Text(
                    'Votre compagnon météo intelligent',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withAlpha((0.95 * 255).round()),
                      fontWeight: FontWeight.w300,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlassContentCards() {
    return SizedBox(
      height: 140,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          // Auto-scroll géré par le timer
        },
        itemCount: _weatherVideos.length,
        itemBuilder: (context, index) {
          final video = _weatherVideos[index];
          return AnimatedBuilder(
            animation: _slideController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, (1 - _slideController.value) * 50),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withAlpha((0.3 * 255).round()),
                        Colors.white.withAlpha((0.15 * 255).round()),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: video.accentColor.withAlpha((0.5 * 255).round()),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: video.accentColor.withAlpha((0.25 * 255).round()),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.white.withAlpha((0.1 * 255).round()),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          video.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(1, 1),
                                blurRadius: 3,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 8),

                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                video.accentColor.withAlpha((0.3 * 255).round()),
                                video.accentColor.withAlpha((0.1 * 255).round()),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: video.accentColor.withAlpha((0.4 * 255).round()),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            video.subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withAlpha((0.95 * 255).round()),
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildNeonStartButton() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_pulseController.value * 0.03),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(35),
              boxShadow: [
                BoxShadow(
                  color: _weatherVideos[_currentVideoIndex].accentColor.withAlpha((0.5 * 255).round()),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: _weatherVideos[_currentVideoIndex].accentColor.withAlpha((0.3 * 255).round()),
                  blurRadius: 40,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withAlpha((0.9 * 255).round()),
                    Colors.white.withAlpha((0.7 * 255).round()),
                  ],
                ),
                borderRadius: BorderRadius.circular(35),
                border: Border.all(
                  color: _weatherVideos[_currentVideoIndex].accentColor.withAlpha((0.5 * 255).round()),
                  width: 2,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(35),
                  onTap: _startWeatherExperience,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.play_arrow_rounded,
                          size: 28,
                          color: Colors.black87,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Commencer l\'expérience',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: Colors.black87,
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

  // INDICATEURS DE PAGE
  Widget _buildStylizedPageIndicators() {
    return Positioned(
      bottom: 80,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          _weatherVideos.length,
              (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            margin: const EdgeInsets.symmetric(horizontal: 6),
            width: _currentVideoIndex == index ? 30 : 10,
            height: 6,
            decoration: BoxDecoration(
              gradient: _currentVideoIndex == index
                  ? LinearGradient(
                colors: [
                  _weatherVideos[_currentVideoIndex].accentColor,
                  Colors.white,
                ],
              )
                  : null,
              color: _currentVideoIndex != index
                  ? Colors.white.withAlpha((0.4 * 255).round())
                  : null,
              borderRadius: BorderRadius.circular(3),
              boxShadow: _currentVideoIndex == index
                  ? [
                BoxShadow(
                  color: _weatherVideos[_currentVideoIndex].accentColor.withAlpha((0.5 * 255).round()),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingElements() {
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        return Stack(
          children: [
            // Élément flottant 1
            Positioned(
              top: 150 + math.sin(_floatingController.value * 2 * math.pi) * 10,
              left: 30,
              child: Opacity(
                opacity: 0.3,
                child: Icon(
                  Icons.wb_cloudy_outlined,
                  size: 40,
                  color: _weatherVideos[_currentVideoIndex].accentColor,
                ),
              ),
            ),
            // Élément flottant 2
            Positioned(
              top: 300 + math.cos(_floatingController.value * 2 * math.pi) * 15,
              right: 40,
              child: Opacity(
                opacity: 0.2,
                child: Icon(
                  Icons.air_rounded,
                  size: 35,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _startWeatherExperience() {
    for (var controller in _videoControllers) {
      controller.pause();
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoadingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.3),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 1000),
      ),
    );
  }
}

// Modèle  pour les vidéos météo
class WeatherVideo {
  final String path;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final Color accentColor;
  final IconData icon;

  WeatherVideo({
    required this.path,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.accentColor,
    required this.icon,
  });
}