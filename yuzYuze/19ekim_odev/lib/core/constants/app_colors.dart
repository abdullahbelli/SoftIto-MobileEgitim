import 'package:flutter/material.dart';

/// Dijital Günlüğüm uygulaması için Material 3 uyumlu merkezi renk paleti.
/// Mor ve lila vurguları ile zenginleştirilmiş aydınlık ve karanlık mod tonları.
abstract final class AppColors {
  // --- Aydınlık Tema Renkleri (Light Mode) ---
  static const Color lightPrimary = Color(0xFF6750A4);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightPrimaryContainer = Color(0xFFEADDFF);
  static const Color lightOnPrimaryContainer = Color(0xFF21005D);

  static const Color lightSecondary = Color(0xFF625B71);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightSecondaryContainer = Color(0xFFE8DEF8);
  static const Color lightOnSecondaryContainer = Color(0xFF1D192B);

  static const Color lightBackground = Color(0xFFFDF7FF);
  static const Color lightOnBackground = Color(0xFF1D1B20);
  static const Color lightSurface = Color(0xFFFDF7FF);
  static const Color lightOnSurface = Color(0xFF1D1B20);
  static const Color lightSurfaceVariant = Color(0xFFE7E0EC);
  static const Color lightOnSurfaceVariant = Color(0xFF49454F);

  static const Color lightCardBackground = Color(0xFFFFFFFF);
  static const Color lightCalendarBadge = Color(0xFF9C27B0);
  static const Color lightTodayBorder = Color(0xFF6750A4);

  // --- Karanlık Tema Renkleri (Dark Mode) ---
  static const Color darkPrimary = Color(0xFFD0BCFF);
  static const Color darkOnPrimary = Color(0xFF381E72);
  static const Color darkPrimaryContainer = Color(0xFF4F378B);
  static const Color darkOnPrimaryContainer = Color(0xFFEADDFF);

  static const Color darkSecondary = Color(0xFFCCC2DC);
  static const Color darkOnSecondary = Color(0xFF332D41);
  static const Color darkSecondaryContainer = Color(0xFF4A4458);
  static const Color darkOnSecondaryContainer = Color(0xFFE8DEF8);

  static const Color darkBackground = Color(0xFF141218);
  static const Color darkOnBackground = Color(0xFFE6E1E5);
  static const Color darkSurface = Color(0xFF141218);
  static const Color darkOnSurface = Color(0xFFE6E1E5);
  static const Color darkSurfaceVariant = Color(0xFF49454F);
  static const Color darkOnSurfaceVariant = Color(0xFFCAC4D0);

  static const Color darkCardBackground = Color(0xFF211F26);
  static const Color darkCalendarBadge = Color(0xFFCE93D8);
  static const Color darkTodayBorder = Color(0xFFD0BCFF);

  // --- Ortak Durum Renkleri ---
  static const Color error = Color(0xFFBA1A1A);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFED6C02);
}
