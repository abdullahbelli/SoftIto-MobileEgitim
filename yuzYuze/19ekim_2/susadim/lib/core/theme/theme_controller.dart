import 'package:flutter/material.dart';

/// Dinamik Tema Durum Yöneticisi (ValueNotifier Tabanlı)
class ThemeController {
  final ValueNotifier<ThemeMode> themeMode;

  ThemeController({ThemeMode initialMode = ThemeMode.dark})
      : themeMode = ValueNotifier<ThemeMode>(initialMode);

  bool get isDarkMode => themeMode.value == ThemeMode.dark;

  void toggleTheme() {
    themeMode.value = isDarkMode ? ThemeMode.light : ThemeMode.dark;
  }

  void setTheme(ThemeMode mode) {
    themeMode.value = mode;
  }

  void dispose() {
    themeMode.dispose();
  }
}
