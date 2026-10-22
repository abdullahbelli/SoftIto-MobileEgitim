import 'package:flutter_test/flutter_test.dart';
import 'package:ritmia/core/utils/date_utils.dart';
import 'package:ritmia/features/habits/models/habit.dart';
import 'package:ritmia/features/habits/models/habit_day_progress.dart';
import 'package:ritmia/features/habits/services/habit_streak_service.dart';

void main() {
  group('HabitStreakService Tests', () {
    late HabitStreakService service;
    late DateTime referenceDate;

    setUp(() {
      service = HabitStreakService();
      // Sabit bir Perşembe günü (Örn: 2026-10-22)
      referenceDate = DateTime(2026, 10, 22);
    });

    test('Her gün planlı bir alışkanlıkta ardışık tamamlanan günler seriyi doğru artırır', () {
      final habit = Habit(
        id: 'h1',
        userId: 'u1',
        name: 'Su İç',
        category: 'Sağlık',
        targetType: 'check',
        targetValue: 1.0,
        scheduledWeekdays: const [1, 2, 3, 4, 5, 6, 7],
        startDate: referenceDate.subtract(const Duration(days: 10)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final progressMap = <String, HabitDayProgress>{};

      // Bugün (2026-10-22) ve önceki 3 gün tamamlandı (toplam 4 gün streak)
      for (int i = 0; i <= 3; i++) {
        final d = referenceDate.subtract(Duration(days: i));
        final dStr = AppDateUtils.toDateString(d);
        progressMap['h1_$dStr'] = HabitDayProgress(
          habitId: 'h1',
          localDate: dStr,
          amount: 1.0,
          targetSnapshot: 1.0,
          completedAt: d,
          updatedAt: d,
        );
      }

      final streak = service.calculateHabitStreak(
        habit: habit,
        progressMap: progressMap,
        referenceDate: referenceDate,
      );

      expect(streak, 4);
    });

    test('Bugün henüz tamamlanmamışken seriyi kırmaz, dünkü seriyi korur', () {
      final habit = Habit(
        id: 'h2',
        userId: 'u1',
        name: 'Kitap Oku',
        category: 'Öğrenme',
        targetType: 'count',
        targetValue: 20.0,
        scheduledWeekdays: const [1, 2, 3, 4, 5, 6, 7],
        startDate: referenceDate.subtract(const Duration(days: 10)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final progressMap = <String, HabitDayProgress>{};

      // Bugün (0. gün) yapılmadı, ama dünden geriye 3 gün yapıldı
      for (int i = 1; i <= 3; i++) {
        final d = referenceDate.subtract(Duration(days: i));
        final dStr = AppDateUtils.toDateString(d);
        progressMap['h2_$dStr'] = HabitDayProgress(
          habitId: 'h2',
          localDate: dStr,
          amount: 20.0,
          targetSnapshot: 20.0,
          completedAt: d,
          updatedAt: d,
        );
      }

      final streak = service.calculateHabitStreak(
        habit: habit,
        progressMap: progressMap,
        referenceDate: referenceDate,
      );

      // Bugün henüz bitmediği için dünkü seri (3) korunmalıdır
      expect(streak, 3);
    });

    test('Planlı olmayan günler seriyi bozmaz veya kırmaz', () {
      // Sadece hafta içi (1..5) planlı bir alışkanlık
      // referenceDate (2026-10-22) = Perşembe (4)
      // Önceki günler: Çarşamba (3), Salı (2), Pazartesi (1), Pazar (7 - plan dışı), Cumartesi (6 - plan dışı), Cuma (5)
      final habit = Habit(
        id: 'h3',
        userId: 'u1',
        name: 'Koşu',
        category: 'Spor',
        targetType: 'check',
        targetValue: 1.0,
        scheduledWeekdays: const [1, 2, 3, 4, 5], // Sadece hafta içi
        startDate: referenceDate.subtract(const Duration(days: 20)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final progressMap = <String, HabitDayProgress>{};

      // Bu haftanın Pzt, Sal, Çar, Per günleri ve geçen Cuma tamamlandı
      final completedDates = [
        referenceDate, // Perşembe
        referenceDate.subtract(const Duration(days: 1)), // Çarşamba
        referenceDate.subtract(const Duration(days: 2)), // Salı
        referenceDate.subtract(const Duration(days: 3)), // Pazartesi
        referenceDate.subtract(const Duration(days: 6)), // Geçen Cuma
      ];

      for (final d in completedDates) {
        final dStr = AppDateUtils.toDateString(d);
        progressMap['h3_$dStr'] = HabitDayProgress(
          habitId: 'h3',
          localDate: dStr,
          amount: 1.0,
          targetSnapshot: 1.0,
          completedAt: d,
          updatedAt: d,
        );
      }

      final streak = service.calculateHabitStreak(
        habit: habit,
        progressMap: progressMap,
        referenceDate: referenceDate,
      );

      // Hafta sonu plan dışı olduğu için seriyi kırmamalı ve geçen Cuma ile birlikte 5 olmalıdır
      expect(streak, 5);
    });

    test('Günlük tamamlama raporu (DayCompletionReport) oranları doğru hesaplar', () {
      final habit1 = Habit(
        id: 'h1',
        userId: 'u1',
        name: 'H1',
        category: 'Sağlık',
        startDate: referenceDate.subtract(const Duration(days: 1)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final habit2 = Habit(
        id: 'h2',
        userId: 'u1',
        name: 'H2',
        category: 'Spor',
        startDate: referenceDate.subtract(const Duration(days: 1)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final dateStr = AppDateUtils.toDateString(referenceDate);
      final progressMap = <String, HabitDayProgress>{
        'h1_$dateStr': HabitDayProgress(
          habitId: 'h1',
          localDate: dateStr,
          amount: 1.0,
          targetSnapshot: 1.0,
          updatedAt: referenceDate,
        ),
      };

      final report = service.getDayReport(
        date: referenceDate,
        habits: [habit1, habit2],
        progressMap: progressMap,
      );

      expect(report.isPlannedDay, true);
      expect(report.totalPlanned, 2);
      expect(report.completedCount, 1);
      expect(report.completionRatio, 0.5);
    });
  });
}
