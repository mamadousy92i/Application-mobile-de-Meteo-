import 'package:flutter/material.dart';
import 'package:weather_app/models/weather.dart';
import 'dart:async';
import '../services/real_weather_service.dart';
import '../services/nominatim_search_service.dart';
import '../widgets/city_search_widget.dart';
import '../widgets/weather/weather_card_widget.dart';
import '../widgets/header/header_widget.dart';
import '../themes/app_colors.dart';
import 'loading_screen.dart';
import 'welcome_screen.dart';

class HomeScreen extends StatefulWidget {
  final List<Weather> weatherData;

  const HomeScreen({super.key, required this.weatherData});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final RealWeatherService _weatherService = RealWeatherService();
  late List<Weather> _weatherList;
  bool _isLoading = false;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _staggerController;

  //  Variables pour mises à jour automatiques
  Timer? _autoRefreshTimer;
  bool _isAutoRefreshEnabled = true;
  int _currentUpdateIndex = 0;
  DateTime _lastUpdateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _weatherList = List.from(widget.weatherData);

    // Animations ultra fluides
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _startAnimations();
    _startAutoRefresh();
  }

  // Permet de démarrer les mises à jour automatiques
  void _startAutoRefresh() {
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (mounted && _isAutoRefreshEnabled && _weatherList.isNotEmpty) {
        _updateSingleCity();
      }
    });
  }

  //  Mettre à jour une ville à la fois
  void _updateSingleCity() async {
    if (_weatherList.isEmpty || _isLoading) return;

    final weather = _weatherList[_currentUpdateIndex];

    try {
      print(' Mise à jour automatique: ${weather.name}');

      final updatedWeather = await _weatherService.getWeatherByCity(
        weather.name,
      );

      if (mounted) {
        setState(() {
          _weatherList[_currentUpdateIndex] = updatedWeather;
          _lastUpdateTime = DateTime.now();

          // Passer à la ville suivante
          _currentUpdateIndex = (_currentUpdateIndex + 1) % _weatherList.length;
        });

        // Afficher subtilement la mise à jour
        _showUpdateIndicator(weather.name);
      }
    } catch (e) {
      print('Erreur mise à jour automatique ${weather.name}: $e');
      // Passer à la ville suivante même en cas d'erreur
      _currentUpdateIndex = (_currentUpdateIndex + 1) % _weatherList.length;
    }
  }

  //  Indicateur  de mise à jour
  void _showUpdateIndicator(String cityName) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Text('$cityName mise à jour'),
          ],
        ),
        backgroundColor: AppColors.success.withAlpha((0.8 * 255).round()),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  //  Basculer la mise à jour automatique
  void _toggleAutoRefresh() {
    setState(() {
      _isAutoRefreshEnabled = !_isAutoRefreshEnabled;
    });

    _showCustomSnackBar(
      _isAutoRefreshEnabled
          ? 'Mise à jour automatique activée'
          : 'Mise à jour automatique désactivée',
      _isAutoRefreshEnabled ? AppColors.success : AppColors.warning,
      _isAutoRefreshEnabled ? Icons.sync_rounded : Icons.sync_disabled_rounded,
    );
  }

  //  Formater la dernière mise à jour
  String _formatLastUpdate() {
    final now = DateTime.now();
    final difference = now.difference(_lastUpdateTime);

    if (difference.inMinutes < 1) {
      return 'Maintenant';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else {
      return '${difference.inHours}h';
    }
  }

  void _startAnimations() async {
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _slideController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _staggerController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _staggerController.dispose();
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  void _addCityFromSearch(CitySearchResult cityResult) async {
    final alreadyExists = _weatherList.any(
          (weather) => weather.name.toLowerCase() == cityResult.name.toLowerCase(),
    );

    if (alreadyExists) {
      _showCustomSnackBar(
        '${cityResult.name} est déjà dans votre liste !',
        AppColors.warning,
        Icons.warning_rounded,
      );
      return;
    }

    if (_weatherList.length >= 8) {
      _showCustomSnackBar(
        'Maximum 8 villes autorisées !',
        AppColors.error,
        Icons.block_rounded,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final weather = await _weatherService.getWeatherByCoordinates(
        cityResult.lat,
        cityResult.lon,
        customName: cityResult.name,
      );

      if (mounted) {
        setState(() {
          _weatherList.add(weather);
          _isLoading = false;
        });

        _showCustomSnackBar(
          '${cityResult.name} ajoutée avec succès !',
          AppColors.success,
          Icons.check_circle_rounded,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showCustomSnackBar(
          'Erreur lors de l\'ajout de ${cityResult.name}',
          AppColors.error,
          Icons.error_rounded,
        );
      }
    }
  }

  void _removeCity(int index) {
    final cityName = _weatherList[index].name;

    showDialog(
      context: context,
      builder: (context) => _buildModernDialog(cityName, index),
    );
  }

  Widget _buildModernDialog(String cityName, int index) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground(context),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.2 * 255).round()),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha((0.1 * 255).round()),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Supprimer la ville',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Voulez-vous supprimer $cityName de votre liste ?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.subtleText(context),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Annuler',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.subtleText(context),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _weatherList.removeAt(index);
                      });
                      Navigator.pop(context);
                      _showCustomSnackBar(
                        '$cityName supprimée',
                        AppColors.success,
                        Icons.check_circle_rounded,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Supprimer',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomSnackBar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _refreshAllWeather() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Weather> updatedWeather = [];

      for (int i = 0; i < _weatherList.length; i++) {
        final weather = _weatherList[i];
        try {
          final updated = await _weatherService.getWeatherByCity(weather.name);
          updatedWeather.add(updated);

          if (i < _weatherList.length - 1) {
            await Future.delayed(const Duration(milliseconds: 300));
          }
        } catch (e) {
          print('Erreur refresh ${weather.name}: $e');
          updatedWeather.add(weather);
        }
      }

      if (mounted) {
        setState(() {
          _weatherList = updatedWeather;
          _isLoading = false;
          _lastUpdateTime = DateTime.now();
        });

        _showCustomSnackBar(
          'Toutes les villes actualisées !',
          AppColors.success,
          Icons.refresh_rounded,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showCustomSnackBar(
          'Erreur lors de l\'actualisation',
          AppColors.error,
          Icons.error_rounded,
        );
      }
    }
  }

  void _restartExperience() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => const LoadingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.3),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  void _goToWelcome() {
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => const WelcomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-0.3, 0.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.surface(context),
      body: AnimatedBuilder(
        animation: _fadeController,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeController.value,
            child: Column(
              children: [
                // ✅ HEADER REFACTORISÉ - Une seule ligne remplace 70 lignes !
                HeaderWidget(
                  weatherCount: _weatherList.length,
                  isAutoRefreshEnabled: _isAutoRefreshEnabled,
                  isLoading: _isLoading,
                  lastUpdateTime: _formatLastUpdate(),
                  onGoToWelcome: _goToWelcome,
                  onToggleAutoRefresh: _toggleAutoRefresh,
                  onRefreshAllWeather: _refreshAllWeather,
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        _buildPremiumSearchSection(isDarkMode),
                        _buildUniformWeatherList(isDarkMode),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPremiumSearchSection(bool isDarkMode) {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _slideController.value) * 30),
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardBackground(context),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(
                    isDarkMode ? (0.3 * 255).round() : (0.08 * 255).round(),
                  ),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primaryBlue, AppColors.primaryPurple],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.explore_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Explorer le monde',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface(context),
                            ),
                          ),
                          Text(
                            'Ajoutez n\'importe quelle ville',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.subtleText(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                CitySearchWidget(onCitySelected: _addCityFromSearch),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUniformWeatherList(bool isDarkMode) {
    if (_weatherList.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppColors.cardBackground(context),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(
                isDarkMode ? (0.3 * 255).round() : (0.08 * 255).round(),
              ),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 64,
              color: AppColors.subtleText(context),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune ville ajoutée',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.subtleText(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Utilisez la recherche ci-dessus pour ajouter des villes',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.subtleText(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vos villes (${_weatherList.length})',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface(context),
            ),
          ),
          const SizedBox(height: 16),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _weatherList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final weather = _weatherList[index];

              return AnimatedBuilder(
                animation: _staggerController,
                builder: (context, child) {
                  final delay = index * 0.1;
                  final animation = Tween<double>(begin: 0, end: 1).animate(
                    CurvedAnimation(
                      parent: _staggerController,
                      curve: Interval(
                        delay,
                        delay + 0.3,
                        curve: Curves.easeOut,
                      ),
                    ),
                  );

                  return Transform.translate(
                    offset: Offset(0, (1 - animation.value) * 30),
                    child: Opacity(
                      opacity: animation.value,
                      child: WeatherCardWidget(
                        weather: weather,
                        index: index,
                        isDarkMode: isDarkMode,
                        onLongPress: () => _removeCity(index),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}