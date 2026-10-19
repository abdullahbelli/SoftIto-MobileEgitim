import 'package:flutter/material.dart';

/// Gece spor salonu paleti: Dark Obsidian & Neon
abstract final class AppColors {
  // Arka plan ve yüzey renkleri (Obsidian tonları)
  static const Color obsidianBackground = Color(0xFF0C0E14);
  static const Color obsidianSurface = Color(0xFF141722);
  static const Color obsidianCard = Color(0xFF1C2030);
  static const Color obsidianBorder = Color(0xFF282F44);

  // Neon vurgular
  static const Color neonCyan = Color(0xFF00F0FF); // Su ve hidrasyon vurgusu
  static const Color neonTeal = Color(0xFF00E5BC); // İkincil su gradyanı
  static const Color neonLime = Color(0xFFB8FF00); // Egzersiz & enerji vurgusu
  static const Color neonAmber = Color(0xFFFFB800); // Hedef & kalori vurgusu
  static const Color neonCrimson = Color(0xFFFF3366); // Nabız / uyarı

  // Podyum ve Liderlik Renkleri
  static const Color podiumGold = Color(0xFFFFD700);
  static const Color podiumSilver = Color(0xFFC0C7D6);
  static const Color podiumBronze = Color(0xFFCD7F32);

  // Metin renkleri
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9098AA);
  static const Color textTertiary = Color(0xFF5E6578);

  // Gradyanlar
  static const LinearGradient waterGradient = LinearGradient(
    colors: [neonCyan, neonTeal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient workoutGradient = LinearGradient(
    colors: [neonLime, Color(0xFF70FF00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
