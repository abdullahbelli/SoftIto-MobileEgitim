import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Su tüketim ilerleme kartı (40 satır kuralına uygun)
class WaterProgressCard extends StatelessWidget {
  final int current;
  final int goal;

  const WaterProgressCard({
    super.key,
    required this.current,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final double ratio = (current / goal).clamp(0.0, 1.0);
    final int percent = (ratio * 100).toInt();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bugünkü Su İlerlemesi',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '%$percent',
                  style: TextStyle(
                    color: isDark ? AppColors.neonCyan : AppColors.neonTeal,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 12,
                backgroundColor: isDark
                    ? AppColors.obsidianBorder
                    : AppColors.lightBorder,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? AppColors.neonCyan : AppColors.neonTeal,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'İçilen: $current ml',
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  'Hedef: $goal ml',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
