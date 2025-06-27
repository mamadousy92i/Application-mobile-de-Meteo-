import 'package:flutter/material.dart';

class CustomChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final Color? borderColor;
  final double? fontSize;
  final double? iconSize;
  final EdgeInsetsGeometry? padding;
  final bool isActive;

  const CustomChip({
    super.key,
    required this.icon,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.borderColor,
    this.fontSize = 12,
    this.iconSize = 16,
    this.padding,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
    final effectiveBackgroundColor = backgroundColor ?? Colors.white.withAlpha((0.15 * 255).round());
    final effectiveBorderColor = borderColor ?? Colors.white.withAlpha((0.2 * 255).round());
    final effectiveTextColor = textColor ?? Colors.white;
    final effectiveIconColor = iconColor ?? Colors.white.withAlpha((0.8 * 255).round());

    return Container(
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withAlpha((0.2 * 255).round())
            : effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? Colors.green.withAlpha((0.4 * 255).round())
              : effectiveBorderColor,
          width: 1,
        ),
        boxShadow: isActive ? [
          BoxShadow(
            color: Colors.green.withAlpha((0.3 * 255).round()),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? Colors.green[300] : effectiveIconColor,
            size: iconSize,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isActive ? Colors.green[200] : effectiveTextColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ Factory methods pour usage courant dans l'app météo
class CustomChipFactory {
  // Chip d'information standard (header)
  static Widget info({
    required IconData icon,
    required String text,
    bool isActive = false,
  }) {
    return CustomChip(
      icon: icon,
      text: text,
      isActive: isActive,
    );
  }

  // Chip de statut (auto/manuel)
  static Widget status({
    required bool isEnabled,
    required String enabledText,
    required String disabledText,
    IconData? enabledIcon,
    IconData? disabledIcon,
  }) {
    return CustomChip(
      icon: isEnabled
          ? (enabledIcon ?? Icons.check_circle_rounded)
          : (disabledIcon ?? Icons.pause_circle_outline_rounded),
      text: isEnabled ? enabledText : disabledText,
      isActive: isEnabled,
    );
  }

  // Chip compteur (nombre de villes)
  static Widget counter({
    required int count,
    required String singular,
    required String plural,
    IconData icon = Icons.location_city_rounded,
  }) {
    return CustomChip(
      icon: icon,
      text: '$count ${count <= 1 ? singular : plural}',
    );
  }

  // Chip temporel (dernière mise à jour)
  static Widget time({
    required String timeText,
    IconData icon = Icons.update_rounded,
    bool isRecent = false,
  }) {
    return CustomChip(
      icon: icon,
      text: timeText,
      isActive: isRecent && timeText == 'Maintenant',
    );
  }

  // Chip de statut avec couleur personnalisée
  static Widget coloredStatus({
    required IconData icon,
    required String text,
    required Color color,
    bool isGlowing = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha((0.2 * 255).round()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withAlpha((0.4 * 255).round()),
          width: 1,
        ),
        boxShadow: isGlowing ? [
          BoxShadow(
            color: color.withAlpha((0.4 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color.withAlpha((0.9 * 255).round()),
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: color.withAlpha((0.95 * 255).round()),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}