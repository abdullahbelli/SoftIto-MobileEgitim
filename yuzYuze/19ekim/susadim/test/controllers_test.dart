import 'package:flutter_test/flutter_test.dart';
import 'package:susadim/features/competition/controller/competition_controller.dart';
import 'package:susadim/features/water_tracker/controller/water_tracker_controller.dart';
import 'package:susadim/features/workout/controller/workout_controller.dart';

void main() {
  group('WaterTrackerController Tests', () {
    test('Initial values are empty and progress is zero', () {
      final controller = WaterTrackerController(dailyTargetMl: 2000);
      expect(controller.totalConsumedMl, 0);
      expect(controller.progressRatio, 0.0);
      expect(controller.remainingMl, 2000);
    });

    test('addWater increases consumed ml and calculates progress', () {
      final controller = WaterTrackerController(dailyTargetMl: 2000);
      controller.addWater(500);

      expect(controller.totalConsumedMl, 500);
      expect(controller.progressRatio, 0.25);
      expect(controller.remainingMl, 1500);
      expect(controller.logs.length, 1);
    });

    test('resetToday clears logs', () {
      final controller = WaterTrackerController(dailyTargetMl: 2000);
      controller.addWater(500);
      controller.resetToday();

      expect(controller.totalConsumedMl, 0);
      expect(controller.logs, isEmpty);
    });
  });

  group('WorkoutController Tests', () {
    test('addWorkout adds entry and updates totals', () {
      final controller = WorkoutController(dailyCalorieTarget: 500);
      controller.addWorkout(
        title: 'Koşu',
        durationMinutes: 30,
        burnedCalories: 250,
      );

      expect(controller.totalBurnedCalories, 250);
      expect(controller.totalMinutes, 30);
      expect(controller.calorieProgressRatio, 0.5);
      expect(controller.workouts.length, 1);
    });
  });

  group('CompetitionController Tests', () {
    test('Initializes with default users and podium', () {
      final controller = CompetitionController();
      expect(controller.users.length, greaterThanOrEqualTo(3));
      expect(controller.topThree.length, 3);
      expect(controller.currentUser.name, 'Sen');
    });

    test('challengeUser toggles challenged state', () {
      final controller = CompetitionController();
      final targetId = controller.users.first.id;
      expect(controller.users.first.isChallenged, isFalse);

      controller.challengeUser(targetId);
      expect(controller.users.first.isChallenged, isTrue);
    });

    test('boostCurrentUserStreak increments days and updates score', () {
      final controller = CompetitionController();
      final initialStreak = controller.currentUser.streakDays;

      controller.boostCurrentUserStreak();
      expect(controller.currentUser.streakDays, initialStreak + 1);
    });
  });
}
