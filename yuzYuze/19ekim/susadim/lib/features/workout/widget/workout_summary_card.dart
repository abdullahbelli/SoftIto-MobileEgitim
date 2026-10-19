import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../controller/workout_controller.dart';

class WorkoutSummaryCard extends StatelessWidget {
  const WorkoutSummaryCard({
    required this.controller,
    super.key,
  });

  final WorkoutController controller;

  @override
  Widget build(BuildContext context) {
    final calorieRatio = (controller.calorieProgressRatio * 100).toInt();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoColumn(
                  title: 'Yakılan Kalori',
                  value: '${controller.totalBurnedCalories} kcal',
                  color: AppColors.neonLime,
                ),
                _buildBadge('%$calorieRatio Hedef'),
                _buildInfoColumn(
                  title: 'Toplam Süre',
                  value: '${controller.totalMinutes} dk',
                  color: AppColors.textPrimary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: controller.calorieProgressRatio,
                minHeight: 10,
                backgroundColor: AppColors.obsidianBorder,
                valueColor: const AlwaysStoppedAnimation(AppColors.neonLime),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn({
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.neonLime.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neonLime.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.neonLime,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
