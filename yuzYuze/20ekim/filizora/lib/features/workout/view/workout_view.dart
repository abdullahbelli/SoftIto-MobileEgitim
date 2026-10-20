import 'package:flutter/material.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/app_theme_toggle_button.dart';
import '../controllers/workout_controller.dart';
import '../models/workout_entry.dart';
import '../widgets/workout_item_tile.dart';
import '../widgets/workout_quick_buttons.dart';
import '../widgets/workout_summary_card.dart';

/// Egzersiz ve Kalori Takip Ana Ekranı (StatelessWidget + ValueNotifier mimarisi)
class WorkoutView extends StatelessWidget {
  final WorkoutController controller;
  final ThemeController? themeController;

  const WorkoutView({
    super.key,
    required this.controller,
    this.themeController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppLogo(size: 26),
            SizedBox(width: 10),
            Text('Susadım v1 • Egzersiz'),
          ],
        ),
        actions: [
          if (themeController != null)
            AppThemeToggleButton(themeController: themeController!),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ValueListenableBuilder<List<WorkoutEntry>>(
              valueListenable: controller.workouts,
              builder: (context, workouts, _) {
                return WorkoutSummaryCard(
                  totalCalories: controller.totalCalories,
                  goalCalories: controller.dailyCalorieGoal,
                  totalMinutes: controller.totalDuration,
                );
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Hızlı Egzersiz Kaydı',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            WorkoutQuickButtons(
              onAdd: controller.addWorkout,
            ),
            const SizedBox(height: 24),
            Text(
              'Tamamlanan Antrenmanlar',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<List<WorkoutEntry>>(
              valueListenable: controller.workouts,
              builder: (context, workouts, _) {
                if (workouts.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text('Bugün henüz antrenman kaydedilmedi.'),
                    ),
                  );
                }
                return Column(
                  children: workouts.map((workout) {
                    return WorkoutItemTile(
                      item: workout,
                      onRemove: () => controller.removeWorkout(workout.id),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
