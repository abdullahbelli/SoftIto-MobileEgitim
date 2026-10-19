import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../controller/workout_controller.dart';
import '../widget/workout_item_tile.dart';
import '../widget/workout_summary_card.dart';

class WorkoutView extends StatelessWidget {
  const WorkoutView({
    required this.controller,
    super.key,
  });

  final WorkoutController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            WorkoutSummaryCard(controller: controller),
            const SizedBox(height: 16),
            _buildWorkoutQuickButtons(context),
            const SizedBox(height: 24),
            const Text(
              'Bugünkü Egzersizler',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (controller.workouts.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32.0),
                child: Center(
                  child: Text(
                    'Henüz egzersiz kaydedilmedi.',
                    style: TextStyle(color: AppColors.textTertiary),
                  ),
                ),
              )
            else
              ...controller.workouts.map(
                (entry) => WorkoutItemTile(
                  entry: entry,
                  onDelete: () => controller.removeWorkout(entry.id),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildWorkoutQuickButtons(BuildContext context) {
    return Row(
      children: [
        _buildAction(
          title: 'Koşu (30 dk)',
          calories: 250,
          duration: 30,
          icon: Icons.directions_run,
        ),
        const SizedBox(width: 12),
        _buildAction(
          title: 'Ağırlık (45 dk)',
          calories: 320,
          duration: 45,
          icon: Icons.fitness_center,
        ),
      ],
    );
  }

  Widget _buildAction({
    required String title,
    required int calories,
    required int duration,
    required IconData icon,
  }) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: () => controller.addWorkout(
          title: title,
          durationMinutes: duration,
          burnedCalories: calories,
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          foregroundColor: AppColors.neonLime,
          side: const BorderSide(color: AppColors.obsidianBorder),
          backgroundColor: AppColors.obsidianCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Icon(icon, size: 20, color: AppColors.neonLime),
        label: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
