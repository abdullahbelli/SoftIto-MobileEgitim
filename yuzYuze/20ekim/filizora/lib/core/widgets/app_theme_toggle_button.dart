import 'package:flutter/material.dart';
import '../theme/theme_controller.dart';

/// Tema Değiştirme Butonu (Karanlık / Aydınlık Mod)
class AppThemeToggleButton extends StatelessWidget {
  final ThemeController themeController;

  const AppThemeToggleButton({
    super.key,
    required this.themeController,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeController.themeMode,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;
        return IconButton(
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          ),
          tooltip: isDark ? 'Aydınlık Moda Geç' : 'Karanlık Moda Geç',
          onPressed: themeController.toggleTheme,
        );
      },
    );
  }
}
