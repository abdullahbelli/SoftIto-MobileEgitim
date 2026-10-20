import 'package:flutter/foundation.dart';
import '../models/workout_entry.dart';

/// Egzersiz ve Kalori Durum Yöneticisi (ValueNotifier Tabanlı)
class WorkoutController {
  final ValueNotifier<List<WorkoutEntry>> workouts = ValueNotifier<List<WorkoutEntry>>([
    WorkoutEntry(
      id: '1',
      title: 'Kardiyo & Koşu',
      durationMinutes: 30,
      burnedCalories: 280,
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    WorkoutEntry(
      id: '2',
      title: 'Ağırlık Antrenmanı',
      durationMinutes: 45,
      burnedCalories: 350,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ]);

  final int dailyCalorieGoal = 800;

  int get totalCalories =>
      workouts.value.fold<int>(0, (sum, item) => sum + item.burnedCalories);

  int get totalDuration =>
      workouts.value.fold<int>(0, (sum, item) => sum + item.durationMinutes);

  void addWorkout(String title, int durationMinutes, int burnedCalories) {
    final entry = WorkoutEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      durationMinutes: durationMinutes,
      burnedCalories: burnedCalories,
      timestamp: DateTime.now(),
    );
    workouts.value = [entry, ...workouts.value];
  }

  void removeWorkout(String id) {
    workouts.value = workouts.value.where((item) => item.id != id).toList();
  }

  void dispose() {
    workouts.dispose();
  }
}
