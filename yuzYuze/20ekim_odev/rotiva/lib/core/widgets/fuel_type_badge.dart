import 'package:flutter/material.dart'; // Material Design bileşenleri.

import '../constants/app_constants.dart'; // FuelType enum tanımı.
import '../constants/vehicle_badge_colors.dart'; // Yakıt türü renk ve ikon eşleştirmeleri.

/// Yakıt türüne özel renkli rozet (Badge) bileşeni.
/// Material Design 3 tasarım sistemine uygun, tema duyarlı okunaklı çip.
/// - Benzin: Turuncu (local_gas_station)
/// - Dizel: Mavi (local_gas_station)
/// - Hibrit: Mor (eco)
/// - Elektrik: Yeşil (bolt)
class FuelTypeBadge extends StatelessWidget {
  final FuelType fuelType; // Rozeti çizilecek yakıt türü
  final bool isCompact; // Kart içi kullanımda daha ufak boyutlandırma bayrağı

  const FuelTypeBadge({
    super.key,
    required this.fuelType,
    this.isCompact = false, // Varsayılan standart boyut
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Geçerli tema verisini alıyoruz.
    final isDark = theme.brightness == Brightness.dark; // Koyu mod kontrolü

    // Merkezi yardımcı sınıftan renk ve ikonları alıyoruz
    final baseColor = VehicleBadgeColors.getFuelColor(fuelType);
    final icon = VehicleBadgeColors.getFuelIcon(fuelType);
    final bgColor = VehicleBadgeColors.getBadgeBackgroundColor(
      baseColor,
      isDark,
    );
    final textColor = VehicleBadgeColors.getBadgeTextColor(baseColor, isDark);

    return Container(
      // Kompakt modda iç boşluğu (padding) biraz daha küçük tutuyoruz
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 7 : 10,
        vertical: isCompact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bgColor, // Saydam tema arka planı
        borderRadius: BorderRadius.circular(8), // Yuvarlatılmış köşeler
        border: Border.all(
          color: baseColor.withValues(alpha: isDark ? 0.35 : 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Sadece içeriği kadar genişler
        children: [
          Icon(
            icon,
            size: isCompact ? 13 : 15,
            color: textColor,
          ), // Yakıt simgesi
          const SizedBox(width: 4), // İkon ile metin arası boşluk
          Text(
            fuelType.displayName, // Türkçe yakıt adı (Benzin, Dizel vb.)
            style: TextStyle(
              fontSize: isCompact ? 11 : 12,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
