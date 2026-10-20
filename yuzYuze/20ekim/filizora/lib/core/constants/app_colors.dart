import 'package:flutter/material.dart';

/// Filizora Modern Girişimcilik & İnovasyon Marka Renk Paleti
///
/// Girişimcilik ekosistemine uygun, modern, prestijli ve uyumlu renk paleti:
/// - Indigo (Royal Indigo): #4F46E5 (Ana marka rengi, teknoloji ve güven)
/// - Emerald (Filiz Yeşili): #10B981 (Büyüme, tohum aşaması, onay ve başarı)
/// - Violet Glow:           #6366F1 (Dinamik etkileşimler ve vurgular)
/// - Amber (Altın Sarısı):   #F59E0B (Bekleyen onaylar, yıldız ve derecelendirme)
/// - Rose (Modern Gül/Kırmızı): #F43F5E (Uyarılar, ret ve hata durumları)
class AppColors {
  const AppColors._();

  // 1. Ana Modern Marka Renkleri
  static const Color primary = Color(0xFF4F46E5);
  static const Color emerald = Color(0xFF10B981);
  static const Color violet = Color(0xFF6366F1);
  static const Color cyan = Color(0xFF06B6D4);
  static const Color coral = Color(0xFFF97316);
  static const Color amber = Color(0xFFF59E0B);
  static const Color rose = Color(0xFFF43F5E);

  // 2. Geriye Dönük Uyumluluk için Marka Renk Eşleşmeleri
  static const Color oceanBlue = Color(0xFF4F46E5); // Royal Indigo
  static const Color teal = Color(0xFF10B981);      // Filiz Emerald
  static const Color orange = Color(0xFF4F46E5);    // Modern Primary Action
  static const Color red = Color(0xFFF43F5E);       // Modern Rose Red

  // 3. Koyu Tema Zemin ve Kart Renkleri (Sleek Obsidian & Midnight Slate)
  static const Color obsidianBackground = Color(0xFF090D16);
  static const Color obsidianSurface = Color(0xFF0F172A);
  static const Color obsidianCard = Color(0xFF1E293B);
  static const Color obsidianBorder = Color(0xFF334155);

  // 4. Aydınlık Tema Zemin ve Kart Renkleri (Clean Slate & Crisp White)
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // 5. Koyu Tema Metin Renkleri
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // 6. Aydınlık Tema Metin Renkleri
  static const Color textLightPrimary = Color(0xFF0F172A);
  static const Color textLightSecondary = Color(0xFF475569);
  static const Color textLightMuted = Color(0xFF94A3B8);

  // 7. Modern Degrade (Gradient) Tanımlamaları
  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sproutGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Geriye dönük uyumluluk takma adları
  static const Color neonCyan = cyan;
  static const Color neonTeal = teal;
  static const Color neonLime = emerald;
  static const Color neonAmber = amber;
  static const Color neonCrimson = red;
  static const Color neonPurple = violet;
}
