// widgets/header/header_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../themes/app_theme.dart';
import '../common/custom_button.dart';
import '../common/custom_chip.dart';

class HeaderWidget extends StatelessWidget {
  final int weatherCount;
  final bool isAutoRefreshEnabled;
  final bool isLoading;
  final String lastUpdateTime;
  final VoidCallback onGoToWelcome;
  final VoidCallback onToggleAutoRefresh;
  final VoidCallback? onRefreshAllWeather;

  const HeaderWidget({
    super.key,
    required this.weatherCount,
    required this.isAutoRefreshEnabled,
    required this.isLoading,
    required this.lastUpdateTime,
    required this.onGoToWelcome,
    required this.onToggleAutoRefresh,
    this.onRefreshAllWeather,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 160,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
            const Color(0xFF1A1D29),
            const Color(0xFF2D3748),
            const Color(0xFF4A5568),
          ]
              : [
            const Color(0xFF0EA5E9),
            const Color(0xFF3B82F6),
            const Color(0xFF1E40AF),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              _buildTopRow(),
              const SizedBox(height: 16),
              _buildChipsRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopRow() {
    return Row(
      children: [
        // Bouton retour
        CustomButtonFactory.back(onTap: onGoToWelcome),
        const SizedBox(width: 8),

        // Titre de l'app
        Expanded(
          child: Row(
            children: [
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Météo Express',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.8,
                      ),
                    ),
                    Text(
                      'Données en temps réel',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withAlpha((0.8 * 255).round()),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Boutons d'action
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return CustomButtonFactory.theme(
              isDarkMode: themeProvider.isDarkMode,
              onTap: themeProvider.toggleTheme,
            );
          },
        ),
        const SizedBox(width: 8),
        CustomButtonFactory.autoSync(
          isEnabled: isAutoRefreshEnabled,
          onTap: onToggleAutoRefresh,
        ),
        const SizedBox(width: 8),
        CustomButtonFactory.refresh(
          onTap: isLoading ? null : onRefreshAllWeather,
          isLoading: isLoading,
        ),
      ],
    );
  }

  Widget _buildChipsRow() {
    return Row(
      children: [
        CustomChipFactory.counter(
          count: weatherCount,
          singular: 'ville',
          plural: 'villes',
        ),
        const SizedBox(width: 12),
        CustomChipFactory.status(
          isEnabled: isAutoRefreshEnabled,
          enabledText: 'Auto 8s',
          disabledText: 'Manuel',
          enabledIcon: Icons.access_time_rounded,
          disabledIcon: Icons.pause_circle_outline_rounded,
        ),
        const SizedBox(width: 12),
        CustomChipFactory.time(
          timeText: lastUpdateTime,
          isRecent: lastUpdateTime == 'Maintenant',
        ),
      ],
    );
  }
}