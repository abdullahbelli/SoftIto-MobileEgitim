import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../constants/vehicle_badge_colors.dart';

/// Araç tipine (kategorisine) özel renkli rozet (Badge) bileşeni.
/// - Sedan: Mavi (directions_car)
/// - SUV: Mor (directions_car_filled)
/// - Hatchback: Turkuaz (directions_car)
/// - Coupe / Spor: Kırmızı (speed)
/// - Ticari / Van: Kahverengi (airport_shuttle)
/// - Station Wagon: Kahverengi (airport_shuttle)
/// - Lüks: Altın / Amber (workspace_premium)
class VehicleTypeBadge extends StatelessWidget {
  final VehicleCategory category;
  final bool isCompact;

  const VehicleTypeBadge({
    super.key,
    required this.category,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final baseColor = VehicleBadgeColors.getCategoryColor(category);
    final icon = VehicleBadgeColors.getCategoryIcon(category);
    final bgColor = VehicleBadgeColors.getBadgeBackgroundColor(
      baseColor,
      isDark,
    );
    final textColor = VehicleBadgeColors.getBadgeTextColor(baseColor, isDark);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 7 : 10,
        vertical: isCompact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: baseColor.withValues(alpha: isDark ? 0.35 : 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isCompact ? 13 : 15, color: textColor),
          const SizedBox(width: 4),
          Text(
            category.displayName,
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
