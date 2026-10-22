import 'package:flutter_test/flutter_test.dart';
import 'package:ritmia/features/badges/services/badge_service.dart';
import 'package:ritmia/features/habits/models/habit.dart';

void main() {
  group('BadgeService Tests', () {
    late BadgeService service;

    setUp(() {
      service = BadgeService();
    });

    test('7 gün seriye ulaşan alışkanlık İlk Kıvılcım rozetini kazanır', () {
      final habit = Habit(
        id: 'h_test_1',
        userId: 'u_test',
        name: 'Meditasyon',
        category: 'Zihin',
        startDate: DateTime.now().subtract(const Duration(days: 10)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final badges = service.evaluateBadges(
        userId: 'u_test',
        habits: [habit],
        habitStreaks: {'h_test_1': 7},
        existingBadges: const [],
      );

      expect(badges.length, 1);
      expect(badges.first.badgeId, 'badge_spark_7');
      expect(badges.first.habitName, 'Meditasyon');
    });

    test('30 gün seriye ulaşan alışkanlık hem 7 hem 30 gün rozetlerini kazanır', () {
      final habit = Habit(
        id: 'h_test_2',
        userId: 'u_test',
        name: 'Kitap Okuma',
        category: 'Öğrenme',
        startDate: DateTime.now().subtract(const Duration(days: 35)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final badges = service.evaluateBadges(
        userId: 'u_test',
        habits: [habit],
        habitStreaks: {'h_test_2': 30},
        existingBadges: const [],
      );

      expect(badges.length, 2);
      expect(badges.any((b) => b.badgeId == 'badge_spark_7'), true);
      expect(badges.any((b) => b.badgeId == 'badge_rhythm_30'), true);
    });

    test('Rozetler idempotent biçimde verilir ve mükerrer oluşturulmaz', () {
      final habit = Habit(
        id: 'h_test_1',
        userId: 'u_test',
        name: 'Meditasyon',
        category: 'Zihin',
        startDate: DateTime.now().subtract(const Duration(days: 10)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // İlk değerlendirme
      final initialBadges = service.evaluateBadges(
        userId: 'u_test',
        habits: [habit],
        habitStreaks: {'h_test_1': 7},
        existingBadges: const [],
      );
      expect(initialBadges.length, 1);

      // İkinci değerlendirme (aynı seri ile)
      final secondRun = service.evaluateBadges(
        userId: 'u_test',
        habits: [habit],
        habitStreaks: {'h_test_1': 8},
        existingBadges: initialBadges,
      );
      // Rozet sayısı artmamalı
      expect(secondRun.length, 1);
    });
  });
}
