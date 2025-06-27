import 'package:dio/dio.dart';
import '../models/weather.dart';
import '../api/api_client.dart';
import 'nominatim_search_service.dart';

class RealWeatherService {
  static const String _apiKey = '4b593112a5b07b5fff0c7f2be4a320ff';

  // Réutiliser votre ApiClient existant pour la météo
  final _weatherApi = ApiClient.weatherApi;

  // Utiliser Nominatim pour la recherche de villes
  final _searchService = NominatimSearchService();

  /// Recherche de villes avec Nominatim (meilleure qualité)
  Future<List<CitySearchResult>> searchCities(String query) async {
    try {
      final nominatimResults = await _searchService.searchCities(query);

      // Convertir vers le format attendu
      return nominatimResults
          .map((result) => result.toCitySearchResult())
          .toList();
    } catch (e) {
      print('Erreur recherche villes: $e');
      throw Exception('Erreur lors de la recherche de villes');
    }
  }

  /// Récupérer la météo par nom de ville (utilise votre WeatherApi)
  Future<Weather> getWeatherByCity(String cityName) async {
    try {
      return await _weatherApi.getWeather(
        cityName,
        _apiKey,
        'metric', // Températures en Celsius
      );
    } catch (e) {
      print('Erreur météo par ville: $e');
      throw Exception('Erreur lors de la récupération des données météo pour $cityName');
    }
  }

  /// Récupérer la météo par coordonnées avec nom personnalisé optionnel
  Future<Weather> getWeatherByCoordinates(double lat, double lon, {String? customName}) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://api.openweathermap.org/data/2.5/weather',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'appid': _apiKey,
          'units': 'metric',
          'lang': 'fr',
        },
      );

      final weather = Weather.fromJson(response.data);

      // Si un nom personnalisé est fourni, remplacer le nom de l'API
      if (customName != null && customName.isNotEmpty) {
        // Créer une nouvelle instance avec le nom personnalisé
        final customWeather = Weather(
          coord: weather.coord,
          weather: weather.weather,
          base: weather.base,
          main: weather.main,
          visibility: weather.visibility,
          wind: weather.wind,
          clouds: weather.clouds,
          dt: weather.dt,
          sys: weather.sys,
          timezone: weather.timezone,
          id: weather.id,
          name: customName, // ← Utiliser le nom recherché
          cod: weather.cod,
        );
        return customWeather;
      }

      return weather;
    } catch (e) {
      print('Erreur météo par coordonnées: $e');
      throw Exception('Erreur lors de la récupération des données météo');
    }
  }

  /// Récupérer la météo pour plusieurs villes (utilise votre WeatherApi)
  Future<List<Weather>> getWeatherForCities(List<String> cityNames) async {
    List<Weather> weatherList = [];

    for (String city in cityNames) {
      try {
        final weather = await getWeatherByCity(city);
        weatherList.add(weather);

        // Petite pause pour éviter de surcharger l'API
        await Future.delayed(const Duration(milliseconds: 300));
      } catch (e) {
        print('Erreur pour $city: $e');
        // Continuer avec les autres villes même si une échoue
      }
    }

    return weatherList;
  }

  /// Obtenir météo par coordonnées multiples avec noms personnalisés
  Future<List<Weather>> getWeatherForCoordinates(List<CitySearchResult> cities) async {
    List<Weather> weatherList = [];

    for (CitySearchResult city in cities) {
      try {
        final weather = await getWeatherByCoordinates(
          city.lat,
          city.lon,
          customName: city.name, // ← Passer le nom de la ville recherchée
        );
        weatherList.add(weather);

        await Future.delayed(const Duration(milliseconds: 300));
      } catch (e) {
        print('Erreur pour ${city.name}: $e');
      }
    }

    return weatherList;
  }
}