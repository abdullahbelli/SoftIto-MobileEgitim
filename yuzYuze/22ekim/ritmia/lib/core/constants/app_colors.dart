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

  // Takvim Isı Haritası Renkleri (Geriye Dönük Uyumluluk Sabitleri)
  static const Color heatMap100 = Color(0xFF15803D); // %100 koyu yeşil
  static const Color heatMap75 = Color(0xFF22C55E);  // %67-99 orta yeşil
  static const Color heatMap50 = Color(0xFF86EFAC);  // %34-66 açık yeşil
  static const Color heatMap25 = Color(0xFFDCFCE7);  // %1-33 soluk yeşil
  static const Color heatMap0 = Color(0xFFEF4444);   // %0 kırmızı
  static const Color heatMapNeutralLight = Color(0xFFF1F3F5);
  static const Color heatMapNeutralDark = Color(0xFF2A2333);

  /// Takvim Isı Haritası için tema rengine bağlı dinamik renk üretici.
  /// Kırmızı-yeşil yerine yapılmayanlardan (%0) yapılanlara (%100) doğru
  /// kullanıcının seçtiği aktif tema rengi koyulaşarak ve doygunlaşarak gider.
  static Color dynamicHeatMapColor({
    required double ratio,
    required Color primaryColor,
    required bool isDark,
  }) {
    final hsl = HSLColor.fromColor(primaryColor);
    final hue = hsl.hue;

    if (!isDark) {
      // Aydınlık Mod: Yapılmayandan (%0) yapılana (%100) doğru koyulaşarak gider (Lightness azalır)
      if (ratio >= 1.0) {
        // %100 - Tam Yapılan: En koyu ve doygun tema rengi
        return HSLColor.fromAHSL(1.0, hue, (hsl.saturation * 1.1).clamp(0.65, 0.95), 0.38).toColor();
      } else if (ratio >= 0.67) {
        // %67-99: Koyu tema rengi
        return HSLColor.fromAHSL(1.0, hue, (hsl.saturation * 1.0).clamp(0.55, 0.90), 0.52).toColor();
      } else if (ratio >= 0.34) {
        // %34-66: Orta tema rengi
        return HSLColor.fromAHSL(1.0, hue, (hsl.saturation * 0.9).clamp(0.45, 0.85), 0.68).toColor();
      } else if (ratio > 0.0) {
        // %1-33: Açık tema rengi
        return HSLColor.fromAHSL(1.0, hue, (hsl.saturation * 0.7).clamp(0.35, 0.75), 0.82).toColor();
      } else {
        // %0 - Yapılmayan: Kırmızı yerine zarif, çok açık pudra/pastel tema tonu
        return HSLColor.fromAHSL(1.0, hue, (hsl.saturation * 0.45).clamp(0.20, 0.55), 0.93).toColor();
      }
    } else {
      // Karanlık Mod: Yapılmayandan (%0) yapılana (%100) doğru belirginleşerek ve doygunlaşarak gider
      if (ratio >= 1.0) {
        // %100 - Tam Yapılan: Canlı ve tam tema rengi
        return primaryColor;
      } else if (ratio >= 0.67) {
        // %67-99: Güçlü tema tonu
        return HSLColor.fromAHSL(1.0, hue, hsl.saturation * 0.85, 0.50).toColor();
      } else if (ratio >= 0.34) {
        // %34-66: Orta tema tonu
        return HSLColor.fromAHSL(1.0, hue, hsl.saturation * 0.70, 0.38).toColor();
      } else if (ratio > 0.0) {
        // %1-33: Düşük tema tonu
        return HSLColor.fromAHSL(1.0, hue, hsl.saturation * 0.55, 0.27).toColor();
      } else {
        // %0 - Yapılmayan: Çok hafif, karanlık mod yüzeyine uyumlu tema tonu
        return HSLColor.fromAHSL(1.0, hue, hsl.saturation * 0.40, 0.18).toColor();
      }
    }
  }

  // Lig Madalya Renkleri
  static const Color goldMedal = Color(0xFFEAB308);
  static const Color silverMedal = Color(0xFF94A3B8);
  static const Color bronzeMedal = Color(0xFFD97706);

  // Vurgu Rengi Seçenekleri (Kullanıcı Tercihi)
  static const Map<String, Color> accentColors = {
    'pink': Color(0xFFDB2777),
    'orange': Color(0xFFF97316),
    'purple': Color(0xFF8B5CF6),
    'blue': Color(0xFF0EA5E9),
    'green': Color(0xFF10B981),
  };

  // Dinamik Aydınlık Tema Token Oluşturucu
  static Color dynamicLightPrimaryContainer(Color accent) {
    final hsl = HSLColor.fromColor(accent);
    return HSLColor.fromAHSL(1.0, hsl.hue, (hsl.saturation * 0.45).clamp(0.20, 0.55), 0.94).toColor();
  }

  static Color dynamicLightOnPrimaryContainer(Color accent) {
    final hsl = HSLColor.fromColor(accent);
    return HSLColor.fromAHSL(1.0, hsl.hue, (hsl.saturation * 0.9).clamp(0.5, 0.95), 0.28).toColor();
  }

  static Color dynamicLightSurfaceVariant(Color accent) {
    final hsl = HSLColor.fromColor(accent);
    return HSLColor.fromAHSL(1.0, hsl.hue, 0.18, 0.96).toColor();
  }

  static Color dynamicLightBorder(Color accent) {
    final hsl = HSLColor.fromColor(accent);
    return HSLColor.fromAHSL(1.0, hsl.hue, 0.30, 0.88).toColor();
  }

  static Color dynamicLightBackground(Color accent) {
    final hsl = HSLColor.fromColor(accent);
    return HSLColor.fromAHSL(1.0, hsl.hue, 0.12, 0.98).toColor();
  }

  // Dinamik Karanlık Tema Token Oluşturucu
  // Kullanıcının seçtiği vurgu rengine (pembe, turuncu, mor, mavi, yeşil vb.) göre
  // karanlık tema arka planı, kart yüzeyi, input alanları ve kenarlıkları
  // derin, şık ve uyumlu tonlarda dinamik olarak üretir.
  static Color dynamicDarkBackground(Color accent) {
    final hsl = HSLColor.fromColor(accent);
    // Vurgu tonunu koruyarak derin gece zemin rengi
    return HSLColor.fromAHSL(1.0, hsl.hue, 0.22, 0.07).toColor();
  }

  static Color dynamicDarkSurface(Color accent) {
    final hsl = HSLColor.fromColor(accent);
    // Kart ve modallar için hafifçe açılmış yüzey rengi
    return HSLColor.fromAHSL(1.0, hsl.hue, 0.24, 0.12).toColor();
  }

  static Color dynamicDarkSurfaceVariant(Color accent) {
    final hsl = HSLColor.fromColor(accent);
    // Arama, input ve alt bölümler için yüzey varyantı
    return HSLColor.fromAHSL(1.0, hsl.hue, 0.26, 0.17).toColor();
  }

  static Color dynamicDarkBorder(Color accent) {
    final hsl = HSLColor.fromColor(accent);
    // Belirgin ve estetik vurgulu kenarlık rengi
    return HSLColor.fromAHSL(1.0, hsl.hue, 0.38, 0.26).toColor();
  }

  static Color dynamicDarkPrimaryContainer(Color accent) {
    final hsl = HSLColor.fromColor(accent);
    // Vurgu renginin koyu moddaki zemin kapsayıcısı
    return HSLColor.fromAHSL(1.0, hsl.hue, 0.48, 0.19).toColor();
  }

  static Color dynamicDarkOnPrimaryContainer(Color accent) {
    final hsl = HSLColor.fromColor(accent);
    return HSLColor.fromAHSL(1.0, hsl.hue, 0.70, 0.88).toColor();
  }
}
