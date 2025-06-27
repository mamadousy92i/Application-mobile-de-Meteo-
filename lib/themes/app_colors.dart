// themes/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // ==================== COULEURS PRINCIPALES ====================

  // Couleurs de base de l'app (ex app_theme.dart)
  static const Color primaryBlue = Color(0xFF667EEA);
  static const Color primaryPurple = Color(0xFF764BA2);
  static const Color accentPink = Color(0xFFF093FB);

  // Couleurs secondaires (ex colors.dart)
  static const Color lightBlue = Color(0xFFAECDFF);
  static const Color brightBlue = Color(0xFF5896FD);
  static const Color softViolet = Color(0xFFB0A4FF);
  static const Color darkViolet = Color(0xFF806EF8);
  static const Color darkBackground = Color(0xFF1A1D26);

  // ==================== COULEURS SÉMANTIQUES ====================

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ==================== COULEURS MÉTÉO ====================

  static const Color sunny = Color(0xFFFFB75E);
  static const Color cloudy = Color(0xFF74B9FF);
  static const Color rainy = Color(0xFF636FA4);
  static const Color snowy = Color(0xFFE6F3FF);
  static const Color stormy = Color(0xFF485461);

  // ==================== COULEURS ADAPTATIVES ====================

  // Couleurs qui changent selon le thème
  static Color surface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF1E1E2E)
        : Colors.white;
  }

  static Color onSurface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black87;
  }

  static Color cardBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2D3748)
        : Colors.white;
  }

  static Color subtleText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white70
        : Colors.black54;
  }

  // ==================== GRADIENTS MÉTÉO ====================

  static List<Color> sunnyGradient = [
    const Color(0xFFFFB75E),
    const Color(0xFFED8F03),
  ];

  static List<Color> cloudyGradient = [
    const Color(0xFF74B9FF),
    const Color(0xFF0984E3),
  ];

  static List<Color> rainyGradient = [
    const Color(0xFF636FA4),
    const Color(0xFFE8CBC0),
  ];

  static List<Color> snowyGradient = [
    const Color(0xFFE6F3FF),
    const Color(0xFFB3D9FF),
  ];

  // ==================== MÉTHODES UTILITAIRES ====================

  /// Obtenir un gradient météo selon la condition
  static List<Color> getWeatherGradient(String weatherMain) {
    switch (weatherMain.toLowerCase()) {
      case 'clear':
        return sunnyGradient;
      case 'clouds':
        return cloudyGradient;
      case 'rain':
      case 'drizzle':
        return rainyGradient;
      case 'snow':
        return snowyGradient;
      default:
        return [primaryBlue, primaryPurple];
    }
  }

  /// Obtenir une couleur d'accent selon la température
  static Color getTemperatureColor(double temperature) {
    if (temperature < 0) return const Color(0xFF3B82F6); // Bleu froid
    if (temperature < 10) return const Color(0xFF06B6D4); // Cyan
    if (temperature < 20) return const Color(0xFF10B981); // Vert
    if (temperature < 30) return const Color(0xFFF59E0B); // Orange
    return const Color(0xFFEF4444); // Rouge chaud
  }
}