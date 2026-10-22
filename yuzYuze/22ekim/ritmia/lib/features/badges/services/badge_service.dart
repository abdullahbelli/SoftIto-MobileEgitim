import '../../habits/models/habit.dart';
import '../models/badge_definition.dart';
import '../models/earned_badge.dart';

/// Alışkanlık başarı rozetlerini hesaplayan servis.
/// project.md Kuralı: 7/30/365 planlı gün eşiklerinde idempotent biçimde rozet üretir.
class BadgeService {
  /// Alışkanlıklar ve serilere göre yeni kazanılan rozetleri hesaplar
  List<EarnedBadge> evaluateBadges({
    required String userId,
    required List<Habit> habits,
    required Map<String, int> habitStreaks,
    required List<EarnedBadge> existingBadges,
  }) {
    final updatedList = List<EarnedBadge>.from(existingBadges);

    for (final habit in habits) {
      if (habit.isArchived) continue;
      final streak = habitStreaks[habit.id] ?? 0;

      for (final def in BadgeDefinition.allBadges) {
        if (streak >= def.thresholdDays) {
          // Idempotency: Bu alışkanlık ve bu rozet daha önce verilmiş mi?
          final alreadyEarned = updatedList.any(
            (b) => b.badgeId == def.id && b.habitId == habit.id,
          );

          if (!alreadyEarned) {
            final newBadge = EarnedBadge(
              id: 'badge_${habit.id}_${def.id}',
              badgeId: def.id,
              userId: userId,
              habitId: habit.id,
              habitName: habit.name,
              earnedAt: DateTime.now(),
            );
            updatedList.add(newBadge);
          }
        }
      }
    }

    return updatedList;
  }
}
