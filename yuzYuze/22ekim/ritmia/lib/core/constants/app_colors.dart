import 'package:flutter/material.dart';

/// Ritmia uygulamasının renk paleti ve tema token'ları.
/// Tasarım yönergesine göre pudra pembe (#FCE7F3), ana pembe (#DB2777),
/// gece eriği (#1B1421) ve koral vurgular (#FB7185) içerir.
abstract final class AppColors {
  // Aydınlık Tema Renkleri
  static const Color lightBackground = Color(0xFFFFF8FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFFDF2F8);
  static const Color lightPrimary = Color(0xFFDB2777); // Ana pembe
  static const Color lightPrimaryContainer = Color(0xFFFCE7F3); // Pudra pembe
  static const Color lightOnPrimaryContainer = Color(0xFF831843);
  static const Color lightTextPrimary = Color(0xFF301526); // Koyu metin
  static const Color lightTextSecondary = Color(0xFF705869);
  static const Color lightBorder = Color(0xFFF3D2E2);

  // Karanlık Tema Renkleri
  static const Color darkBackground = Color(0xFF1B1421); // Gece eriği
  static const Color darkSurface = Color(0xFF292033);
  static const Color darkSurfaceVariant = Color(0xFF382C47);
  static const Color darkPrimary = Color(0xFFFB7185); // Gül-koral vurgusu
  static const Color darkPrimaryContainer = Color(0xFF4A152E);
  static const Color darkOnPrimaryContainer = Color(0xFFFCE7F3);
  static const Color darkTextPrimary = Color(0xFFF9F1F7);
  static const Color darkTextSecondary = Color(0xFFB8A9B5);
  static const Color darkBorder = Color(0xFF4D3A58);

  // Ortak Renkler
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color flameOrange = Color(0xFFF97316); // Streak alevi

  // Takvim Isı Haritası Renkleri
  static const Color heatMap100 = Color(0xFF15803D); // %100 koyu yeşil
  static const Color heatMap75 = Color(0xFF22C55E);  // %67-99 orta yeşil
  static const Color heatMap50 = Color(0xFF86EFAC);  // %34-66 açık yeşil
  static const Color heatMap25 = Color(0xFFDCFCE7);  // %1-33 soluk yeşil
  static const Color heatMap0 = Color(0xFFEF4444);   // %0 kırmızı
  static const Color heatMapNeutralLight = Color(0xFFE5E7EB);
  static const Color heatMapNeutralDark = Color(0xFF374151);

  // Lig Madalya Renkleri
  static const Color goldMedal = Color(0xFFEAB308);
  static const Color silverMedal = Color(0xFF94A3B8);
  static const Color bronzeMedal = Color(0xFFD97706);

  // Vurgu Rengi Seçenekleri (Kullanıcı Tercihi)
  static const Map<String, Color> accentColors = {
    'pink': Color(0xFFDB2777),
    'purple': Color(0xFF8B5CF6),
    'blue': Color(0xFF0EA5E9),
    'green': Color(0xFF10B981),
    'orange': Color(0xFFF97316),
  };
}
