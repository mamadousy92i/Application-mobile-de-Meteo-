import 'dart:ui';

class WeatherVideoService {
  // Mapping basé sur le champ "main" de l'API OpenWeather
  static String getVideoPath(String weatherMain) {
    switch (weatherMain.toLowerCase()) {
      case 'clear':
        return 'assets/animations/sunny.mp4';

      case 'clouds':
        return 'assets/animations/nuageux.mp4';

      case 'rain':
      case 'drizzle':
        return 'assets/animations/rain.mp4';

      case 'snow':
        return 'assets/animations/snow.mp4';

      case 'thunderstorm':
        return 'assets/animations/storm.mp4';

      case 'mist':
      case 'fog':
      case 'haze':
        return 'assets/animations/fog.mp4';

      default:
        return 'assets/animations/nuageux.mp4'; // Fallback
    }
  }

  // Mapping basé sur les codes ID (plus précis)
  static String getVideoPathByCode(int weatherId) {
    if (weatherId >= 200 && weatherId < 300) {
      // Thunderstorm (200-299)
      return 'assets/animations/storm.mp4';
    } else if (weatherId >= 300 && weatherId < 400) {
      // Drizzle (300-399)
      return 'assets/animations/light_rain.mp4';
    } else if (weatherId >= 500 && weatherId < 600) {
      // Rain (500-599)
      return 'assets/animations/rain.mp4';
    } else if (weatherId >= 600 && weatherId < 700) {
      // Snow (600-699)
      return 'assets/animations/snow.mp4';
    } else if (weatherId >= 700 && weatherId < 800) {
      // Atmosphere (fog, mist, etc) (700-799)
      return 'assets/animations/fog.mp4';
    } else if (weatherId == 800) {
      // Clear sky (800)
      return 'assets/animations/sunny.mp4';
    } else if (weatherId > 800 && weatherId < 900) {
      // Clouds (801-804)
      return 'assets/animations/nuageux.mp4';
    } else {
      // Fallback
      return 'assets/animations/nuageux.mp4';
    }
  }

  // Fonction pour obtenir la couleur de fond selon la météo
  static List<Color> getBackgroundColors(String weatherMain) {
    switch (weatherMain.toLowerCase()) {
      case 'clear':
        return [
          const Color(0xFF87CEEB), // Bleu ciel
          const Color(0xFFFFA500), // Orange soleil
        ];

      case 'clouds':
        return [
          const Color(0xFF9E9E9E), // Gris
          const Color(0xFFBDBDBD), // Gris clair
        ];

      case 'rain':
      case 'drizzle':
        return [
          const Color(0xFF455A64), // Bleu-gris foncé
          const Color(0xFF78909C), // Bleu-gris
        ];

      case 'snow':
        return [
          const Color(0xFFECEFF1), // Blanc-gris
          const Color(0xFFCFD8DC), // Gris très clair
        ];

      default:
        return [
          const Color(0xFF9E9E9E),
          const Color(0xFFBDBDBD),
        ];
    }
  }
}