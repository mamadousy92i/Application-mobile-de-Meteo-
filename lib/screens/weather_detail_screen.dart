import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/weather.dart';
import '../models/daily_forecast.dart';
import '../services/dynamic_weather_background_service.dart';
import '../services/real_weather_service.dart';
import '../services/forecast_service.dart';
import '../themes/app_colors.dart';
import 'full_screen_weather_map_screen.dart';

class WeatherDetailScreen extends StatefulWidget {
  final Weather weather;

  const WeatherDetailScreen({super.key, required this.weather});

  @override
  State<WeatherDetailScreen> createState() => _WeatherDetailScreenState();
}

class _WeatherDetailScreenState extends State<WeatherDetailScreen> {
  late final MapController _mapController;
  final RealWeatherService _weatherService = RealWeatherService();
  final ForecastService _forecastService = ForecastService();
  List<DailyForecast> _forecasts = [];
  bool _isLoadingForecast = true;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _loadRealForecast();
  }

  void _loadRealForecast() async {
    setState(() {
      _isLoadingForecast = true;
    });

    try {
      // Essayer d'abord par coordonnées
      final forecasts = await _forecastService.get5DayForecastByCoords(
        widget.weather.coord.lat,
        widget.weather.coord.lon,
      );

      if (mounted) {
        setState(() {
          _forecasts = forecasts;
          _isLoadingForecast = false;
        });
      }
    } catch (e) {
      print('Erreur chargement prévisions: $e');

      // Fallback : essayer par nom de ville
      try {
        final forecasts = await _forecastService.get5DayForecastByCity(
          widget.weather.name,
        );

        if (mounted) {
          setState(() {
            _forecasts = forecasts;
            _isLoadingForecast = false;
          });
        }
      } catch (e2) {
        print('Erreur fallback prévisions: $e2');

        // Dernier fallback : données par défaut
        if (mounted) {
          setState(() {
            _forecasts = _forecastService.getFallbackForecasts();
            _isLoadingForecast = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () => _shareWeather(context),
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new, color: Colors.white),
            onPressed: () => _openInExternalMaps(),
          ),
        ],
      ),
      body: DynamicWeatherBackground(
        weather: widget.weather,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildWeatherGrid(),
                  const SizedBox(height: 24),
                  _build5DayForecast(),
                  const SizedBox(height: 24),
                  _buildOpenStreetMapSection(),
                  const SizedBox(height: 24),
                  _buildSystemInfo(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.weather.displayNameOrName,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 3,
                color: Colors.black54,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.weather.weather[0].description.toUpperCase(),
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withAlpha((0.9 * 255).round()),
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
            shadows: const [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 2,
                color: Colors.black38,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${widget.weather.main.temp.round()}°",
              style: const TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.w300,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: Offset(2, 2),
                    blurRadius: 4,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Ressenti ${widget.weather.main.feelsLike.round()}°",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withAlpha((0.9 * 255).round()),
                      shadows: const [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 2,
                          color: Colors.black38,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "H:${widget.weather.main.tempMax.round()}° L:${widget.weather.main.tempMin.round()}°",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withAlpha((0.9 * 255).round()),
                      shadows: const [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 2,
                          color: Colors.black38,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeatherGrid() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.2 * 255).round()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withAlpha((0.3 * 255).round()),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildWeatherItem(
                    icon: Icons.water_drop,
                    label: "HUMIDITÉ",
                    value: "${widget.weather.main.humidity}%",
                  ),
                ),
                Container(
                  width: 1,
                  height: 60,
                  color: Colors.white.withAlpha((0.3 * 255).round()),
                ),
                Expanded(
                  child: _buildWeatherItem(
                    icon: Icons.air,
                    label: "VENT",
                    value:
                    "${widget.weather.wind.speed.toStringAsFixed(1)} km/h",
                  ),
                ),
              ],
            ),
            Divider(color: Colors.white.withAlpha((0.3 * 255).round())),
            Row(
              children: [
                Expanded(
                  child: _buildWeatherItem(
                    icon: Icons.speed,
                    label: "PRESSION",
                    value: "${widget.weather.main.pressure} hPa",
                  ),
                ),
                Container(
                  width: 1,
                  height: 60,
                  color: Colors.white.withAlpha((0.3 * 255).round()),
                ),
                Expanded(
                  child: _buildWeatherItem(
                    icon: Icons.visibility,
                    label: "VISIBILITÉ",
                    value:
                    "${(widget.weather.visibility / 1000).toStringAsFixed(1)} km",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  //  SECTION : Prévisions 5 jours avec vraies données API
  Widget _build5DayForecast() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.2 * 255).round()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withAlpha((0.3 * 255).round()),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_month_rounded,
                  color: Colors.white.withAlpha((0.8 * 255).round()),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  "PRÉVISIONS 5 JOURS",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withAlpha((0.7 * 255).round()),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_isLoadingForecast)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              )
            else
              Column(
                children: _forecasts.asMap().entries.map((entry) {
                  final index = entry.key;
                  final forecast = entry.value;
                  final isLast = index == _forecasts.length - 1;

                  return Column(
                    children: [
                      _buildForecastRow(forecast),
                      if (!isLast)
                        Divider(
                          color: Colors.white.withAlpha(
                            (0.2 * 255).round(),
                          ),
                          height: 1,
                        ),
                    ],
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastRow(DailyForecast forecast) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Jour de la semaine
          SizedBox(
            width: 45,
            child: Text(
              forecast.appropriateDayName,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Icône météo
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.getWeatherGradient(forecast.icon)[0]
                  .withAlpha((0.3 * 255).round()),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getWeatherIconFromString(forecast.icon),
              color: Colors.white,
              size: 24,
            ),
          ),

          const SizedBox(width: 16),

          // Description
          Expanded(
            flex: 2,
            child: Text(
              forecast.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withAlpha((0.8 * 255).round()),
                fontWeight: FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(width: 16),

          // Température minimale
          SizedBox(
            width: 35,
            child: Text(
              "${forecast.tempMin.round()}°",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withAlpha((0.6 * 255).round()),
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Barre de température (style Apple)
          Container(
            width: 60,
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: LinearGradient(
                colors: [
                  Colors.blue.withAlpha((0.6 * 255).round()),
                  AppColors.getTemperatureColor(forecast.tempMax),
                ],
              ),
            ),
          ),

          // Température maximale
          SizedBox(
            width: 35,
            child: Text(
              "${forecast.tempMax.round()}°",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIconFromString(String weatherType) {
    switch (weatherType.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny_rounded;
      case 'clouds':
        return Icons.cloud_rounded;
      case 'rain':
        return Icons.grain_rounded;
      case 'snow':
        return Icons.ac_unit_rounded;
      case 'thunderstorm':
        return Icons.flash_on_rounded;
      default:
        return Icons.wb_cloudy_rounded;
    }
  }

  Widget _buildWeatherItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white.withAlpha((0.8 * 255).round()),
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withAlpha((0.7 * 255).round()),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpenStreetMapSection() {
    final cityLatLng = LatLng(
      widget.weather.coord.lat,
      widget.weather.coord.lon,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.2 * 255).round()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withAlpha((0.3 * 255).round()),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.map,
                  color: Colors.white.withAlpha((0.8 * 255).round()),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "LOCALISATION",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withAlpha((0.7 * 255).round()),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${widget.weather.coord.lat.toStringAsFixed(4)}, ${widget.weather.coord.lon.toStringAsFixed(4)}",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _centerMap(),
                      icon: Icon(
                        Icons.my_location,
                        color: Colors.white.withAlpha((0.8 * 255).round()),
                      ),
                      tooltip: "Centrer",
                    ),
                    IconButton(
                      onPressed: _openInExternalMaps,
                      icon: Icon(
                        Icons.open_in_new,
                        color: Colors.white.withAlpha((0.8 * 255).round()),
                      ),
                      tooltip: "Ouvrir dans Maps",
                    ),
                  ],
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            child: SizedBox(
              height: 200,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: cityLatLng,
                  initialZoom: 11.0,
                  minZoom: 2.0,
                  maxZoom: 18.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.weather_app',
                    maxZoom: 18,
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: cityLatLng,
                        width: 60,
                        height: 60,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.getTemperatureColor(widget.weather.main.temp)
                                .withAlpha((0.9 * 255).round()),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(
                                  (0.4 * 255).round(),
                                ),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _getWeatherIconFromString(widget.weather.weather[0].main),
                                color: Colors.white,
                                size: 20,
                              ),
                              Text(
                                "${widget.weather.main.temp.round()}°",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _centerMap() {
    _mapController.move(
      LatLng(widget.weather.coord.lat, widget.weather.coord.lon),
      11.0,
    );
  }

  Widget _buildSystemInfo() {
    final sunrise = DateTime.fromMillisecondsSinceEpoch(
      widget.weather.sys.sunrise * 1000,
    );
    final sunset = DateTime.fromMillisecondsSinceEpoch(
      widget.weather.sys.sunset * 1000,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.2 * 255).round()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withAlpha((0.3 * 255).round()),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _buildWeatherItem(
                icon: Icons.wb_sunny,
                label: "LEVER DU SOLEIL",
                value:
                "${sunrise.hour.toString().padLeft(2, '0')}:${sunrise.minute.toString().padLeft(2, '0')}",
              ),
            ),
            Container(
              width: 1,
              height: 60,
              color: Colors.white.withAlpha((0.3 * 255).round()),
            ),
            Expanded(
              child: _buildWeatherItem(
                icon: Icons.wb_twilight,
                label: "COUCHER DU SOLEIL",
                value:
                "${sunset.hour.toString().padLeft(2, '0')}:${sunset.minute.toString().padLeft(2, '0')}",
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openInExternalMaps() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => FullscreenWeatherMapScreen(weather: widget.weather),
      ),
    );
  }

  void _shareWeather(BuildContext context) {
    final shareText =
        "🌤️ Météo à ${widget.weather.displayNameOrName}\n"
        "🌡️ ${widget.weather.main.temp.round()}°C (${widget.weather.weather[0].description})\n"
        "💨 Vent: ${widget.weather.wind.speed.toStringAsFixed(1)} km/h\n"
        "💧 Humidité: ${widget.weather.main.humidity}%\n"
        "📍 ${widget.weather.coord.lat.toStringAsFixed(4)}, ${widget.weather.coord.lon.toStringAsFixed(4)}";

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Données prêtes à partager !\n$shareText"),
        duration: const Duration(seconds: 4),
        backgroundColor:
        Theme.of(context).snackBarTheme.backgroundColor ?? Colors.grey[800],
        action: SnackBarAction(
          label: "OK",
          onPressed: () {},
          textColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}