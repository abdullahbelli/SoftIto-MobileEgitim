import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Egzersiz özet kartı (40 satır kuralına uygun)
class WorkoutSummaryCard extends StatelessWidget {
  final int totalCalories;
  final int goalCalories;
  final int totalMinutes;

  const WorkoutSummaryCard({
    super.key,
    required this.totalCalories,
    required this.goalCalories,
    required this.totalMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ratio = (totalCalories / goalCalories).clamp(0.0, 1.0);
    final limeColor = isDark ? AppColors.neonLime : const Color(0xFF16A34A);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMetric(
                  context: context,
                  label: 'Yakılan Kalori',
                  value: '$totalCalories kcal',
                  color: limeColor,
                ),
                _buildMetric(
                  context: context,
                  label: 'Toplam Süre',
                  value: '$totalMinutes dk',
                  color: AppColors.neonAmber,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 10,
                backgroundColor: isDark ? AppColors.obsidianBorder : AppColors.lightBorder,
                valueColor: AlwaysStoppedAnimation<Color>(limeColor),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Hedef: $goalCalories kcal',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric({
    required BuildContext context,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
