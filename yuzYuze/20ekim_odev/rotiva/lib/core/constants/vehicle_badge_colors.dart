import 'package:flutter/material.dart'; // Renkler (Color) ve İkonlar (IconData) için Flutter Material paketini içe aktarıyoruz.

import 'app_constants.dart'; // Yakıt ve Kategori enum tiplerini kullanabilmek için sabitleri içe aktarıyoruz.

/// Rotiva araç tipi ve yakıt türü için merkezi renk, ikon ve stil tanımları.
/// Renkler, kullanıcının özellikleri sadece yazıyı okumadan renklerden de kolayca ayırt etmesini sağlar.
class VehicleBadgeColors {
  // ==================== YAKIT TÜRÜ RENKLERİ ====================
  // Benzin: Turuncu (Geleneksel pompa hissi)
  static const Color gasolineColor = Color(0xFFF57C00);
  // Dizel: Mavi (Güçlü ve kurumsal ton)
  static const Color dieselColor = Color(0xFF1976D2);
  // Hibrit: Mor (Çevre dostu teknoloji kombinasyonu)
  static const Color hybridColor = Color(0xFF7B1FA2);
  // Elektrik: Yeşil (Sıfır emisyon ve doğa vurgusu)
  static const Color electricColor = Color(0xFF2E7D32);

  // ==================== ARAÇ TİPİ RENKLERİ ====================
  // Sedan: Mavi (Klasik ve güvenilir aile/iş aracı)
  static const Color sedanColor = Color(0xFF1E88E5);
  // SUV: Mor (Geniş hacim ve prestij hissi)
  static const Color suvColor = Color(0xFF8E24AA);
  // Hatchback: Turkuaz / Camgöbeği (Şehir içi pratik ve genç kullanım)
  static const Color hatchbackColor = Color(0xFF00ACC1);
  // Coupe / Spor: Kırmızı (Hız, performans ve dinamizm)
  static const Color coupeColor = Color(0xFFE53935);
  // Ticari / Van: Kahverengi (Yük taşıma ve dayanıklılık)
  static const Color commercialColor = Color(0xFF6D4C41);
  // Station Wagon: Sıcak Kahverengi / Bronz (Uzun yol ve geniş bagaj)
  static const Color stationWagonColor = Color(0xFF5D4037);
  // Lüks: Altın / Amber (Vip ve üst segment)
  static const Color luxuryColor = Color(0xFFFFA000);

  // ==================== YARDIMCI METOTLAR ====================

  /// Verilen yakıt türüne (FuelType) karşılık gelen Color nesnesini döner.
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

  /// Verilen yakıt türüne uygun IconData simgesini döner.
  static IconData getFuelIcon(FuelType fuelType) {
    switch (fuelType) {
      case FuelType.gasoline:
      case FuelType.diesel:
        return Icons.local_gas_station; // Akaryakıt pompası simgesi
      case FuelType.hybrid:
        return Icons.eco; // Çevre dostu yaprak simgesi
      case FuelType.electric:
        return Icons.bolt; // Elektrik / şimşek simgesi
    }
  }

  /// Verilen araç gövde kategorisine (VehicleCategory) karşılık gelen Color nesnesini döner.
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

  /// Verilen araç kategorisine en uygun araç silueti ikonunu döner.
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

  /// Temanın açık veya koyu oluşuna göre rozet arka plan şeffaflığını hesaplar.
  static Color getBadgeBackgroundColor(Color baseColor, bool isDark) {
    // Koyu temada arka plan biraz daha opak (%22), açık temada daha şeffaf (%12) yapılır.
    return isDark
        ? baseColor.withValues(alpha: 0.22)
        : baseColor.withValues(alpha: 0.12);
  }

  /// Koyu veya açık temada rozet üzerindeki metin ve ikonun yüksek kontrastta okunabilir olmasını sağlar.
  static Color getBadgeTextColor(Color baseColor, bool isDark) {
    if (isDark) {
      // Koyu temada koyu zemin üzerinde okunması için rengi beyazla harmanlayıp aydınlatıyoruz.
      return Color.alphaBlend(Colors.white.withValues(alpha: 0.35), baseColor);
    }
    // Açık temada orijinal rengin kendisi zaten açık zemin üzerinde yeterince kontrastlıdır.
    return baseColor;
  }
}
