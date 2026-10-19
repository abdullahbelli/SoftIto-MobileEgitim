import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../controller/water_tracker_controller.dart';

class WaterProgressCard extends StatelessWidget {
  const WaterProgressCard({
    required this.controller,
    super.key,
  });

  final WaterTrackerController controller;

  @override
  Widget build(BuildContext context) {
    final progressPercentage = (controller.progressRatio * 100).toInt();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMetricColumn(
                  title: 'İçilen',
                  value: '${controller.totalConsumedMl} ml',
                  color: AppColors.neonCyan,
                ),
                _buildProgressIndicator(progressPercentage),
                _buildMetricColumn(
                  title: 'Kalan Hedef',
                  value: '${controller.remainingMl} ml',
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: controller.progressRatio,
                minHeight: 10,
                backgroundColor: AppColors.obsidianBorder,
                valueColor: const AlwaysStoppedAnimation(AppColors.neonCyan),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricColumn({
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

  Widget _buildProgressIndicator(int percentage) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.neonCyan.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.3)),
      ),
      child: Text(
        '%$percentage',
        style: const TextStyle(
          color: AppColors.neonCyan,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}
