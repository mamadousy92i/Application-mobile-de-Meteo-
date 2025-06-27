import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/weather.dart';

class FullscreenWeatherMapScreen extends StatefulWidget {
  final Weather weather;

  const FullscreenWeatherMapScreen({super.key, required this.weather});

  @override
  State<FullscreenWeatherMapScreen> createState() =>
      _FullscreenWeatherMapScreenState();
}

class _FullscreenWeatherMapScreenState
    extends State<FullscreenWeatherMapScreen> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    final cityLatLng = LatLng(
      widget.weather.coord.lat,
      widget.weather.coord.lon,
    );

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: cityLatLng,
              initialZoom: 8.0,
              minZoom: 3.0,
              maxZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.weather_app',
                maxZoom: 18,
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: cityLatLng,
                    width: 80,
                    height: 80,
                    child: _buildWeatherMarker(),
                  ),
                ],
              ),
            ],
          ),
          _buildWeatherUI(),
        ],
      ),
    );
  }

  Widget _buildWeatherUI() {
    return SafeArea(
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(230),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(26),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Carte Météo',
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _centerOnCity,
                  icon: const Icon(Icons.my_location, color: Colors.black87),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildWeatherMarker() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _getMarkerColor().withAlpha(230),
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(77),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_getWeatherIcon(), color: Colors.white, size: 24),
              Text(
                "${widget.weather.main.temp.round()}°",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: -25,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(242),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(51),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              widget.weather.displayNameOrName,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getMarkerColor() {
    final temp = widget.weather.main.temp;
    if (temp < 0) return Colors.blue;
    if (temp < 10) return Colors.lightBlue;
    if (temp < 20) return Colors.green;
    if (temp < 30) return Colors.orange;
    return Colors.red;
  }

  IconData _getWeatherIcon() {
    final main = widget.weather.weather[0].main.toLowerCase();
    switch (main) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.cloud;
      case 'rain':
        return Icons.grain;
      case 'snow':
        return Icons.ac_unit;
      case 'thunderstorm':
        return Icons.flash_on;
      default:
        return Icons.wb_cloudy;
    }
  }

  void _centerOnCity() {
    _mapController.move(
      LatLng(widget.weather.coord.lat, widget.weather.coord.lon),
      8.0,
    );
  }
}
