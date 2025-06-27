import 'package:dio/dio.dart';

class NominatimSearchService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://nominatim.openstreetmap.org',
    connectTimeout: 10000,
    receiveTimeout: 10000,
    headers: {
      'User-Agent': 'WeatherApp/1.0 (Flutter)',
    },
  ));

  /// Recherche de villes avec OSM Nominatim
  Future<List<NominatimResult>> searchCities(String query) async {
    if (query.isEmpty || query.length < 2) return [];

    try {
      final response = await _dio.get(
        '/search',
        queryParameters: {
          'q': query,
          'format': 'json',
          'limit': 8,
          'addressdetails': 1,
          'featuretype': 'city', // Privilégier les villes
          'class': 'place',
          'type': 'city,town,village,municipality', // Types de lieux
          'countrycodes': '', // Tous les pays
          'accept-language': 'fr,en', // Français puis anglais
        },
      );

      final List<dynamic> data = response.data;
      print('Résultats Nominatim bruts pour $query: $data'); // Log pour débogage
      final results = data.map((json) => NominatimResult.fromJson(json)).toList();

      // Filtrer et améliorer les résultats
      return _filterAndImproveResults(results, query);
    } catch (e) {
      print('Erreur recherche Nominatim: $e');
      throw Exception('Erreur lors de la recherche de villes');
    }
  }

  /// Filtrer et améliorer les résultats
  List<NominatimResult> _filterAndImproveResults(List<NominatimResult> results, String query) {
    if (results.isEmpty) return results;

    // Filtrer les résultats pertinents
    final filtered = results.where((result) {
      // Garder seulement les lieux habités
      return result.type == 'city' ||
          result.type == 'town' ||
          result.type == 'village' ||
          result.type == 'municipality' ||
          result.type == 'administrative' ||
          result.placeClass == 'place';
    }).toList();

    final Map<String, NominatimResult> cityMap = {};
    for (NominatimResult result in filtered) {
      final cityKey = result.name.toLowerCase();

      if (!cityMap.containsKey(cityKey)) {
        cityMap[cityKey] = result;
      } else {
        // Préférer les résultats avec plus d'informations
        if (_isBetterResult(result, cityMap[cityKey]!)) {
          cityMap[cityKey] = result;
        }
      }
    }

    List<NominatimResult> finalResults = cityMap.values.toList();

    // Trier par pertinence
    finalResults.sort((a, b) {
      final queryLower = query.toLowerCase();
      final aName = a.name.toLowerCase();
      final bName = b.name.toLowerCase();

      // Correspondance exacte en premier
      if (aName == queryLower && bName != queryLower) return -1;
      if (bName == queryLower && aName != queryLower) return 1;

      // Commence par la requête
      if (aName.startsWith(queryLower) && !bName.startsWith(queryLower)) return -1;
      if (bName.startsWith(queryLower) && !aName.startsWith(queryLower)) return 1;

      // Priorité aux grandes villes (importance élevée)
      if (a.importance > 0.7 && b.importance <= 0.7) return -1;
      if (b.importance > 0.7 && a.importance <= 0.7) return 1;

      // Priorité par type (city > town > village)
      final aPriority = _getTypePriority(a.type);
      final bPriority = _getTypePriority(b.type);
      if (aPriority != bPriority) return aPriority.compareTo(bPriority);

      // Par importance (plus l'importance est élevée, mieux c'est)
      return b.importance.compareTo(a.importance);
    });

    return finalResults.take(5).toList();
  }

  /// Déterminer si un résultat est meilleur qu'un autre
  bool _isBetterResult(NominatimResult a, NominatimResult b) {
    // Préférer les types plus importants
    final aPriority = _getTypePriority(a.type);
    final bPriority = _getTypePriority(b.type);

    if (aPriority != bPriority) return aPriority < bPriority;

    // Préférer les résultats avec plus d'importance
    return a.importance > b.importance;
  }

  /// Priorité des types (plus bas = meilleur)
  int _getTypePriority(String type) {
    switch (type.toLowerCase()) {
      case 'city':
        return 1;
      case 'town':
        return 2;
      case 'municipality':
        return 3;
      case 'village':
        return 4;
      case 'administrative':
        return 5;
      default:
        return 6;
    }
  }
}

/// Modèle pour les résultats Nominatim
class NominatimResult {
  final String name;
  final String displayName;
  final double lat;
  final double lon;
  final String type;
  final String placeClass;
  final double importance;
  final Map<String, dynamic>? address;

  NominatimResult({
    required this.name,
    required this.displayName,
    required this.lat,
    required this.lon,
    required this.type,
    required this.placeClass,
    required this.importance,
    this.address,
  });

  factory NominatimResult.fromJson(Map<String, dynamic> json) {
    return NominatimResult(
      name: json['name'] ?? json['display_name']?.split(',')[0] ?? '',
      displayName: json['display_name'] ?? '',
      lat: double.tryParse(json['lat']?.toString() ?? '0') ?? 0.0,
      lon: double.tryParse(json['lon']?.toString() ?? '0') ?? 0.0,
      type: json['type'] ?? '',
      placeClass: json['class'] ?? '',
      importance: double.tryParse(json['importance']?.toString() ?? '0') ?? 0.0,
      address: json['address'],
    );
  }

  /// Nom formaté avec pays
  String get formattedName {
    if (address != null) {
      final country = address!['country'];
      final state = address!['state'];

      List<String> parts = [name];
      if (state != null && state.toString().isNotEmpty && state != name) {
        parts.add(state.toString());
      }
      if (country != null && country.toString().isNotEmpty) {
        parts.add(country.toString());
      }

      return parts.join(', ');
    }

    // Fallback : utiliser display_name mais plus court
    final parts = displayName.split(', ');
    if (parts.length > 3) {
      return [parts[0], parts[1], parts.last].join(', ');
    }
    return displayName;
  }

  /// Conversion vers CitySearchResult pour compatibilité
  CitySearchResult toCitySearchResult() {
    return CitySearchResult(
      name: name,
      lat: lat,
      lon: lon,
      country: address?['country'],
      state: address?['state'],
    );
  }

  @override
  String toString() => formattedName;
}

/// Garder le modèle CitySearchResult pour compatibilité
class CitySearchResult {
  final String name;
  final double lat;
  final double lon;
  final String? country;
  final String? state;

  CitySearchResult({
    required this.name,
    required this.lat,
    required this.lon,
    this.country,
    this.state,
  });

  String get fullName {
    List<String> parts = [name];
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (country != null && country!.isNotEmpty) parts.add(country!);
    return parts.join(', ');
  }
}