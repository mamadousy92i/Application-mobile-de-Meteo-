import 'package:dio/dio.dart';
import '../models/forecast_response.dart';
import '../models/daily_forecast.dart';
import '../api/weather_api.dart';

class ForecastService {
  static const String _apiKey = '4b593112a5b07b5fff0c7f2be4a320ff';

  // Instance de l'API
  final WeatherApi _api;

  ForecastService() : _api = WeatherApi(Dio());

  /// Récupérer les prévisions 5 jours par nom de ville
  Future<List<DailyForecast>> get5DayForecastByCity(String cityName) async {
    try {
      final response = await _api.getForecast(
        cityName,
        _apiKey,
        'metric',
        'fr',
      );

      return _processForecastResponse(response);
    } catch (e) {
      print('Erreur prévisions 5 jours pour $cityName: $e');
      throw Exception('Impossible de récupérer les prévisions pour $cityName');
    }
  }

  /// Récupérer les prévisions 5 jours par coordonnées
  Future<List<DailyForecast>> get5DayForecastByCoords(
      double lat,
      double lon,
      ) async {
    try {
      final response = await _api.getForecastByCoords(
        lat,
        lon,
        _apiKey,
        'metric',
        'fr',
      );

      return _processForecastResponse(response);
    } catch (e) {
      print('Erreur prévisions par coordonnées ($lat, $lon): $e');
      throw Exception('Impossible de récupérer les prévisions');
    }
  }

  /// Traiter la réponse de l'API et la convertir en DailyForecast
  List<DailyForecast> _processForecastResponse(ForecastResponse response) {
    // Grouper les prévisions par jour
    Map<String, List<ForecastItem>> dailyGroups = {};

    for (var item in response.list) {
      final date = DateTime.fromMillisecondsSinceEpoch(item.dt * 1000);
      final dayKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      if (!dailyGroups.containsKey(dayKey)) {
        dailyGroups[dayKey] = [];
      }
      dailyGroups[dayKey]!.add(item);
    }

    // Convertir en DailyForecast (prendre seulement les 5 premiers jours)
    List<DailyForecast> dailyForecasts = [];

    final sortedKeys = dailyGroups.keys.toList()..sort();

    for (String dayKey in sortedKeys.take(5)) {
      final items = dailyGroups[dayKey]!;
      if (items.isNotEmpty) {
        dailyForecasts.add(_createDailyForecastFromItems(items));
      }
    }

    return dailyForecasts;
  }

  /// Créer un DailyForecast à partir d'une liste d'items du même jour
  DailyForecast _createDailyForecastFromItems(List<ForecastItem> items) {
    final date = DateTime.fromMillisecondsSinceEpoch(items.first.dt * 1000);

    // Calculer min/max températures
    final temperatures = items.map((item) => item.main.temp).toList();
    final tempMax = temperatures.reduce((a, b) => a > b ? a : b);
    final tempMin = temperatures.reduce((a, b) => a < b ? a : b);

    // Prendre la météo la plus fréquente ou celle de midi
    final midDayItem = _findMidDayItem(items) ?? items.first;

    // Calculer moyennes
    final avgHumidity = items
        .map((item) => item.main.humidity)
        .reduce((a, b) => a + b) ~/ items.length;

    final avgWindSpeed = items
        .map((item) => item.wind.speed)
        .reduce((a, b) => a + b) / items.length;

    final avgPrecipitation = items
        .map((item) => item.probabilityOfPrecipitation)
        .reduce((a, b) => a + b) / items.length;

    return DailyForecast.fromApiData(
      date: date,
      tempMax: tempMax,
      tempMin: tempMin,
      description: _capitalizeFirst(midDayItem.weather.first.description),
      weatherMain: midDayItem.weather.first.main,
      weatherId: midDayItem.weather.first.id,
      humidity: avgHumidity,
      windSpeed: avgWindSpeed,
      precipitationProbability: avgPrecipitation,
    );
  }

  /// Trouver l'item le plus proche de midi (12h00)
  ForecastItem? _findMidDayItem(List<ForecastItem> items) {
    ForecastItem? closest;
    int minDifference = 24 * 60; // 24 heures en minutes

    for (var item in items) {
      final dateTime = DateTime.fromMillisecondsSinceEpoch(item.dt * 1000);
      final hourDifference = (dateTime.hour - 12).abs();

      if (hourDifference < minDifference) {
        minDifference = hourDifference;
        closest = item;
      }
    }

    return closest;
  }

  /// Capitaliser la première lettre
  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Méthode utilitaire pour obtenir des prévisions de fallback en cas d'erreur
  List<DailyForecast> getFallbackForecasts() {
    final now = DateTime.now();

    return List.generate(5, (index) {
      final date = now.add(Duration(days: index + 1));

      return DailyForecast(
        date: date,
        dayName: DailyForecast.getShortDayName(date),
        tempMax: 20.0 + (index * 2),
        tempMin: 15.0 + (index * 1.5),
        description: 'Données non disponibles',
        icon: 'clouds',
        humidity: 60,
        windSpeed: 10.0,
        weatherId: 801,
        weatherMain: 'Clouds',
      );
    });
  }
}