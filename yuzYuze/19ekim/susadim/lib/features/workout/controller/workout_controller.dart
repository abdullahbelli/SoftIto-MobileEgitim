import 'package:flutter/foundation.dart';
import '../models/workout_entry.dart';

class WorkoutController extends ChangeNotifier {
  WorkoutController({this.dailyCalorieTarget = 500});

  final int dailyCalorieTarget;
  final List<WorkoutEntry> _workouts = <WorkoutEntry>[];

  List<WorkoutEntry> get workouts => List.unmodifiable(_workouts);

  int get totalBurnedCalories =>
      _workouts.fold<int>(0, (sum, item) => sum + item.burnedCalories);

  int get totalMinutes =>
      _workouts.fold<int>(0, (sum, item) => sum + item.durationMinutes);

  double get calorieProgressRatio {
    if (dailyCalorieTarget == 0) return 0.0;
    final ratio = totalBurnedCalories / dailyCalorieTarget;
    return ratio > 1.0 ? 1.0 : ratio;
  }

  void addWorkout({
    required String title,
    required int durationMinutes,
    required int burnedCalories,
  }) {
    final entry = WorkoutEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      durationMinutes: durationMinutes,
      burnedCalories: burnedCalories,
      timestamp: DateTime.now(),
    );
    _workouts.insert(0, entry);
    notifyListeners();
  }

  void removeWorkout(String id) {
    _workouts.removeWhere((entry) => entry.id == id);
    notifyListeners();
  }
}
