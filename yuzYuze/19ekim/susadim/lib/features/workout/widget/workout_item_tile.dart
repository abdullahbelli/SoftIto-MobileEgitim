import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/workout_entry.dart';

class WorkoutItemTile extends StatelessWidget {
  const WorkoutItemTile({
    required this.entry,
    required this.onDelete,
    super.key,
  });

  final WorkoutEntry entry;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.obsidianCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.obsidianBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.neonLime.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.fitness_center, color: AppColors.neonLime, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  '${entry.durationMinutes} dakika • ${entry.burnedCalories} kcal',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.textTertiary, size: 20),
            onPressed: onDelete,
            tooltip: 'Egzersizi Sil',
          ),
        ],
      ),
    );
  }
}
