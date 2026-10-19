import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:susadim/core/theme/theme_controller.dart';
import 'package:susadim/features/competition/controllers/competition_controller.dart';
import 'package:susadim/features/competition/models/leaderboard_user.dart';
import 'package:susadim/features/water_tracker/controllers/water_tracker_controller.dart';
import 'package:susadim/features/water_tracker/models/water_log.dart';
import 'package:susadim/features/workout/controllers/workout_controller.dart';
import 'package:susadim/features/workout/models/workout_entry.dart';
import 'package:susadim/main.dart';

void main() {
  group('Model Serialization Tests', () {
    test('WaterLog fromJson and toJson test', () {
      final log = WaterLog(
        id: 'w1',
        amountMl: 350,
        timestamp: DateTime(2026, 10, 19, 10, 0),
      );
      final json = log.toJson();
      final fromJson = WaterLog.fromJson(json);

      expect(fromJson.id, 'w1');
      expect(fromJson.amountMl, 350);
    });

    test('WorkoutEntry copyWith test', () {
      final entry = WorkoutEntry(
        id: 'e1',
        title: 'Koşu',
        durationMinutes: 25,
        burnedCalories: 200,
        timestamp: DateTime.now(),
      );
      final updated = entry.copyWith(burnedCalories: 250);

      expect(updated.burnedCalories, 250);
      expect(updated.title, 'Koşu');
    });

    test('LeaderboardUser serialization test', () {
      const user = LeaderboardUser(
        id: 'u1',
        name: 'Deniz',
        rank: 1,
        streakDays: 30,
        badgesCount: 7,
      );
      final json = user.toJson();
      final fromJson = LeaderboardUser.fromJson(json);

      expect(fromJson.name, 'Deniz');
      expect(fromJson.streakDays, 30);
    });
  });

  group('Controller State Management Tests', () {
    test('WaterTrackerController addWater and resetWater test', () {
      final controller = WaterTrackerController();
      final initial = controller.currentWater.value;

      controller.addWater(250);
      expect(controller.currentWater.value, initial + 250);
      expect(controller.logs.value.first.amountMl, 250);

      controller.resetWater();
      expect(controller.currentWater.value, 0);
      expect(controller.logs.value.isEmpty, true);

      controller.dispose();
    });

    test('WorkoutController addWorkout and removeWorkout test', () {
      final controller = WorkoutController();
      final initialCount = controller.workouts.value.length;

      controller.addWorkout('Yüzme', 40, 300);
      expect(controller.workouts.value.length, initialCount + 1);

      final addedId = controller.workouts.value.first.id;
      controller.removeWorkout(addedId);
      expect(controller.workouts.value.length, initialCount);

      controller.dispose();
    });

    test('CompetitionController boostStreak test', () {
      final controller = CompetitionController();
      final initialStreak = controller.userStreak.value;

      controller.boostStreak();
      expect(controller.userStreak.value, initialStreak + 1);

      controller.dispose();
    });

    test('ThemeController toggleTheme and setTheme test', () {
      final controller = ThemeController();
      expect(controller.themeMode.value, ThemeMode.dark);
      expect(controller.isDarkMode, true);

      controller.toggleTheme();
      expect(controller.themeMode.value, ThemeMode.light);
      expect(controller.isDarkMode, false);

      controller.setTheme(ThemeMode.dark);
      expect(controller.themeMode.value, ThemeMode.dark);

      controller.dispose();
    });
  });

  group('Widget Smoke Test', () {
    testWidgets('SusadimApp launches and renders tabs and theme toggle', (WidgetTester tester) async {
      final themeController = ThemeController();
      await tester.pumpWidget(SusadimApp(themeController: themeController));
      await tester.pumpAndSettle();

      expect(find.text('Susadım v1 • Su Takibi'), findsOneWidget);
      expect(find.text('Su Takibi'), findsWidgets);
      expect(find.text('Egzersiz'), findsWidgets);
      expect(find.text('Yarışma'), findsWidgets);

      // Tema butonunu bul ve tıkla
      final toggleButton = find.byTooltip('Aydınlık Moda Geç');
      expect(toggleButton, findsOneWidget);

      await tester.tap(toggleButton);
      await tester.pumpAndSettle();

      expect(themeController.themeMode.value, ThemeMode.light);
      expect(find.byTooltip('Karanlık Moda Geç'), findsOneWidget);

      themeController.dispose();
    });
  });
}
