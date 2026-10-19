import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../models/water_log.dart';

/// Su tüketim geçmişi öğesi (40 satır kuralına uygun)
class WaterHistoryTile extends StatelessWidget {
  final WaterLog log;

  const WaterHistoryTile({
    super.key,
    required this.log,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hour = log.timestamp.hour.toString().padLeft(2, '0');
    final minute = log.timestamp.minute.toString().padLeft(2, '0');
    final iconColor = isDark ? AppColors.neonCyan : AppColors.neonTeal;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.obsidianBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(30),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.water_drop_rounded, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              '+${log.amountMl} ml Su Tüketimi',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '$hour:$minute',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
