import 'package:flutter/material.dart';

import 'app_constants.dart';

/// Rotiva araç tipi ve yakıt türü için merkezi renk, ikon ve stil tanımları.
/// Renkler, kullanıcının özellikleri sadece yazıyı okumadan renklerden de kolayca ayırt etmesini sağlar.
class VehicleBadgeColors {
  // ==================== YAKIT TÜRÜ RENKLERİ ====================
  // Benzin: Turuncu
  static const Color gasolineColor = Color(0xFFF57C00);
  // Dizel: Mavi
  static const Color dieselColor = Color(0xFF1976D2);
  // Hibrit: Mor
  static const Color hybridColor = Color(0xFF7B1FA2);
  // Elektrik: Yeşil
  static const Color electricColor = Color(0xFF2E7D32);

  // ==================== ARAÇ TİPİ RENKLERİ ====================
  // Sedan: Mavi
  static const Color sedanColor = Color(0xFF1E88E5);
  // SUV: Mor
  static const Color suvColor = Color(0xFF8E24AA);
  // Hatchback: Turkuaz / Camgöbeği
  static const Color hatchbackColor = Color(0xFF00ACC1);
  // Coupe / Spor: Kırmızı
  static const Color coupeColor = Color(0xFFE53935);
  // Ticari / Van: Kahverengi
  static const Color commercialColor = Color(0xFF6D4C41);
  // Station Wagon: Sıcak Kahverengi / Bronz
  static const Color stationWagonColor = Color(0xFF5D4037);
  // Lüks: Altın / Amber
  static const Color luxuryColor = Color(0xFFFFA000);

  // ==================== YARDIMCI METOTLAR ====================

  /// Yakıt türüne karşılık gelen ana renk
  static Color getFuelColor(FuelType fuelType) {
    switch (fuelType) {
      case FuelType.gasoline:
        return gasolineColor;
      case FuelType.diesel:
        return dieselColor;
      case FuelType.hybrid:
        return hybridColor;
      case FuelType.electric:
        return electricColor;
    }
  }

  /// Yakıt türü ikonu
  static IconData getFuelIcon(FuelType fuelType) {
    switch (fuelType) {
      case FuelType.gasoline:
      case FuelType.diesel:
        return Icons.local_gas_station;
      case FuelType.hybrid:
        return Icons.eco;
      case FuelType.electric:
        return Icons.bolt;
    }
  }

  /// Araç kategorisine karşılık gelen ana renk
  static Color getCategoryColor(VehicleCategory category) {
    switch (category) {
      case VehicleCategory.sedan:
        return sedanColor;
      case VehicleCategory.suv:
        return suvColor;
      case VehicleCategory.hatchback:
        return hatchbackColor;
      case VehicleCategory.coupe:
        return coupeColor;
      case VehicleCategory.commercial:
        return commercialColor;
      case VehicleCategory.stationWagon:
        return stationWagonColor;
      case VehicleCategory.luxury:
        return luxuryColor;
    }
  }

  /// Araç kategorisi ikonu
  static IconData getCategoryIcon(VehicleCategory category) {
    switch (category) {
      case VehicleCategory.sedan:
        return Icons.directions_car;
      case VehicleCategory.suv:
        return Icons.directions_car_filled;
      case VehicleCategory.hatchback:
        return Icons.directions_car_outlined;
      case VehicleCategory.coupe:
        return Icons.speed;
      case VehicleCategory.commercial:
      case VehicleCategory.stationWagon:
        return Icons.airport_shuttle;
      case VehicleCategory.luxury:
        return Icons.workspace_premium;
    }
  }

  /// Temaya uygun rozet arka plan rengi (hafif şeffaf ve ferah)
  static Color getBadgeBackgroundColor(Color baseColor, bool isDark) {
    return isDark
        ? baseColor.withValues(alpha: 0.22)
        : baseColor.withValues(alpha: 0.12);
  }

  /// Temaya uygun rozet metin/ikon rengi (okunabilir yüksek kontrast)
  static Color getBadgeTextColor(Color baseColor, bool isDark) {
    if (isDark) {
      // Koyu temada biraz daha aydınlık ton
      return Color.alphaBlend(Colors.white.withValues(alpha: 0.35), baseColor);
    }
    // Açık temada doygun renk
    return baseColor;
  }
}
