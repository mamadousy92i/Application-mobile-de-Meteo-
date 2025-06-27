import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isActive;
  final double size;
  final Color? activeColor;
  final String? tooltip;

  const CustomButton({
    super.key,
    required this.icon,
    this.onTap,
    this.isLoading = false,
    this.isActive = false,
    this.size = 40,
    this.activeColor,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveActiveColor = activeColor ?? Colors.green;

    return Tooltip(
      message: tooltip ?? '',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: isActive
                ? effectiveActiveColor.withAlpha((0.3 * 255).round())
                : Colors.white.withAlpha((0.2 * 255).round()),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive
                  ? effectiveActiveColor.withAlpha((0.5 * 255).round())
                  : Colors.white.withAlpha((0.3 * 255).round()),
              width: 1,
            ),
            boxShadow: isActive ? [
              BoxShadow(
                color: effectiveActiveColor.withAlpha((0.2 * 255).round()),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
              width: size * 0.45,
              height: size * 0.45,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : Icon(
              icon,
              color: isActive
                  ? _getActiveIconColor(effectiveActiveColor)
                  : Colors.white,
              size: size * 0.5,
            ),
          ),
        ),
      ),
    );
  }

  // ✅ Calcule la couleur d'icône optimale selon l'arrière-plan
  Color _getActiveIconColor(Color activeColor) {
    // Si c'est vert, utiliser une nuance plus claire
    if (activeColor == Colors.green) {
      return Colors.green[300] ?? Colors.green;
    }
    // Sinon, blanc par défaut
    return Colors.white;
  }
}

// ✅ CORRIGÉ : Classe séparée pour les factory methods
class CustomButtonFactory {
  // Bouton de thème (jour/nuit)
  static Widget theme({
    required bool isDarkMode,
    required VoidCallback onTap,
    double size = 40,
  }) {
    return CustomButton(
      icon: isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
      onTap: onTap,
      size: size,
      tooltip: isDarkMode ? 'Mode clair' : 'Mode sombre',
    );
  }

  // Bouton refresh avec loading
  static Widget refresh({
    required VoidCallback? onTap,
    bool isLoading = false,
    double size = 40,
  }) {
    return CustomButton(
      icon: Icons.refresh_rounded,
      onTap: onTap,
      isLoading: isLoading,
      size: size,
      tooltip: 'Actualiser',
    );
  }

  // Bouton sync auto
  static Widget autoSync({
    required bool isEnabled,
    required VoidCallback onTap,
    double size = 40,
  }) {
    return CustomButton(
      icon: isEnabled ? Icons.sync_rounded : Icons.sync_disabled_rounded,
      onTap: onTap,
      isActive: isEnabled,
      size: size,
      activeColor: Colors.green,
      tooltip: isEnabled ? 'Auto-sync activé' : 'Auto-sync désactivé',
    );
  }

  // Bouton retour
  static Widget back({
    required VoidCallback onTap,
    double size = 40,
  }) {
    return CustomButton(
      icon: Icons.arrow_back_ios_rounded,
      onTap: onTap,
      size: size,
      tooltip: 'Retour',
    );
  }
}