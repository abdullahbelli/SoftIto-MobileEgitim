import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../constants/vehicle_badge_colors.dart';

/// Yakıt türüne özel renkli rozet (Badge) bileşeni.
/// - Benzin: Turuncu (local_gas_station)
/// - Dizel: Mavi (local_gas_station)
/// - Hibrit: Mor (eco)
/// - Elektrik: Yeşil (bolt)
class FuelTypeBadge extends StatelessWidget {
  final FuelType fuelType;
  final bool isCompact;

  const FuelTypeBadge({
    super.key,
    required this.fuelType,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final baseColor = VehicleBadgeColors.getFuelColor(fuelType);
    final icon = VehicleBadgeColors.getFuelIcon(fuelType);
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
            fuelType.displayName,
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
