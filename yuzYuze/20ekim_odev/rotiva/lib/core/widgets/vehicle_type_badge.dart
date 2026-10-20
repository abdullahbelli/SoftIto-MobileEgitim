import 'package:flutter/material.dart'; // Material Design arayüz bileşenleri.

import '../constants/app_constants.dart'; // VehicleCategory enum tipi.
import '../constants/vehicle_badge_colors.dart'; // Araç kategorisi renk ve ikon eşleştirmeleri.

/// Araç tipine (kategorisine) özel renkli rozet (Badge) bileşeni.
/// Material Design 3 tasarım standartlarına uygun, tema duyarlı okunaklı çip.
/// - Sedan: Mavi (directions_car)
/// - SUV: Mor (directions_car_filled)
/// - Hatchback: Turkuaz (directions_car_outlined)
/// - Coupe / Spor: Kırmızı (speed)
/// - Ticari / Van: Kahverengi (airport_shuttle)
/// - Station Wagon: Bronz / Sıcak Kahve (airport_shuttle)
/// - Lüks: Altın / Amber (workspace_premium)
class VehicleTypeBadge extends StatelessWidget {
  final VehicleCategory category; // Rozeti çizilecek araç kasa tipi
  final bool isCompact; // Kart içinde ufak boyutlandırma bayrağı

  const VehicleTypeBadge({
    super.key,
    required this.category,
    this.isCompact = false, // Varsayılan olarak normal boyut
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Cihazın geçerli tema bilgisi
    final isDark = theme.brightness == Brightness.dark; // Koyu mod aktif mi?

    // Araç tipi rengi ve ikonunu alıyoruz
    final baseColor = VehicleBadgeColors.getCategoryColor(category);
    final icon = VehicleBadgeColors.getCategoryIcon(category);
    final bgColor = VehicleBadgeColors.getBadgeBackgroundColor(
      baseColor,
      isDark,
    );
    final textColor = VehicleBadgeColors.getBadgeTextColor(baseColor, isDark);

    return Container(
      // Kompakt moda göre iç boşluk (padding) ayarlaması
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 7 : 10,
        vertical: isCompact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bgColor, // Saydamlaştırılmış şık arka plan rengi
        borderRadius: BorderRadius.circular(8), // Yuvarlatılmış köşe yarıçapı
        border: Border.all(
          color: baseColor.withValues(alpha: isDark ? 0.35 : 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Rozet sadece içeriği kadar yer kaplar
        children: [
          Icon(
            icon,
            size: isCompact ? 13 : 15,
            color: textColor,
          ), // Araç kasa tipi simgesi
          const SizedBox(width: 4), // İkon ile metin arası mesafe
          Text(
            category.displayName, // Türkçe kategori ismi (Sedan, SUV vb.)
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
