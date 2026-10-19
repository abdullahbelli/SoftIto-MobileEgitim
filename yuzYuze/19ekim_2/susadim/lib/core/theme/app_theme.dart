import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Susadım v1 Tema Yapılandırması (Karanlık ve Aydınlık Material 3)
class AppTheme {
  const AppTheme._();

  /// Koyu Tema (Dark Obsidian & Neon)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.obsidianBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.neonCyan,
        onPrimary: AppColors.obsidianBackground,
        secondary: AppColors.neonLime,
        onSecondary: AppColors.obsidianBackground,
        surface: AppColors.obsidianSurface,
        onSurface: AppColors.textPrimary,
        error: AppColors.neonCrimson,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.obsidianBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: AppColors.neonCyan),
      ),
      cardTheme: CardThemeData(
        color: AppColors.obsidianCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.obsidianBorder, width: 1),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.obsidianSurface,
        indicatorColor: AppColors.neonCyan.withAlpha(50),
        elevation: 8,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: AppColors.neonCyan,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            );
          }
          return const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.neonCyan);
          }
          return const IconThemeData(color: AppColors.textSecondary);
        }),
      ),
    );
  }

  /// Aydınlık Tema (Sportif Fresh Beyaz & Neon)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.neonTeal,
        onPrimary: Colors.white,
        secondary: AppColors.neonAmber,
        onSecondary: Colors.white,
        surface: AppColors.lightSurface,
        onSurface: AppColors.textLightPrimary,
        error: AppColors.neonCrimson,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textLightPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: AppColors.neonTeal),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        indicatorColor: AppColors.neonTeal.withAlpha(40),
        elevation: 4,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: AppColors.neonTeal,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            );
          }
          return const TextStyle(
            color: AppColors.textLightSecondary,
            fontSize: 12,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.neonTeal);
          }
          return const IconThemeData(color: AppColors.textLightSecondary);
        }),
      ),
    );
  }
}
