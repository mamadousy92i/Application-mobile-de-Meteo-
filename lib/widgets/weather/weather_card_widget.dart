import 'package:flutter/material.dart';
import '../../models/weather.dart';
import '../../services/dynamic_weather_background_service.dart';
import '../../screens/weather_detail_screen.dart';
import '../../themes/app_colors.dart';

class WeatherCardWidget extends StatelessWidget {
  final Weather weather;
  final int index;
  final VoidCallback? onLongPress;
  final bool isDarkMode;

  const WeatherCardWidget({
    super.key,
    required this.weather,
    required this.index,
    required this.isDarkMode,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WeatherDetailScreen(weather: weather),
          ),
        );
      },
      onLongPress: onLongPress,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppColors.getWeatherGradient(weather.weather[0].main)[0]
                  .withAlpha((0.3 * 255).round()),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: DynamicWeatherBackground(
            weather: weather,
            child: Stack(
              children: [
                // Contenu principal
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header avec nom et description seulement
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            weather.name,
                            style: const TextStyle(
                              fontSize: 24,
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
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            weather.weather[0].description.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withAlpha((0.9 * 255).round()),
                              letterSpacing: 1,
                              shadows: const [
                                Shadow(
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                  color: Colors.black45,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Température et détails alignés à droite
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Détails à gauche (ressenti)
                          Text(
                            "Ressenti ${weather.main.feelsLike.round()}°",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withAlpha((0.9 * 255).round()),
                              shadows: const [
                                Shadow(
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                  color: Colors.black45,
                                ),
                              ],
                            ),
                          ),

                          // Températures à droite
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "${weather.main.temp.round()}°",
                                style: const TextStyle(
                                  fontSize: 54,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white,
                                  height: 1,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(2, 2),
                                      blurRadius: 4,
                                      color: Colors.black54,
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                "H:${weather.main.tempMax.round()}° L:${weather.main.tempMin.round()}°",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withAlpha((0.9 * 255).round()),
                                  shadows: const [
                                    Shadow(
                                      offset: Offset(1, 1),
                                      blurRadius: 2,
                                      color: Colors.black45,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}