import '../../../core/utils/date_utils.dart';
import '../models/habit.dart';
import '../models/habit_day_progress.dart';

/// Alışkanlık ve genel seri (streak) hesaplamalarını yapan saf servis.
/// Planlı olmayan günlerin seriyi kırmaması ve gün bitmeden bugünün seriyi
/// sıfırlamaması kurallarını uygular.
class HabitStreakService {
  /// Tek bir alışkanlık için ardışık planlı gün serisini hesaplar.
  /// [habit]: İlgili alışkanlık
  /// [progressMap]: "habitId_YYYY-MM-DD" anahtarlı ilerleme haritası
  /// [referenceDate]: Test edilebilirlik için referans tarih (varsayılan: DateTime.now())
  int calculateHabitStreak({
    required Habit habit,
    required Map<String, HabitDayProgress> progressMap,
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayStr = AppDateUtils.toDateString(today);

    int streak = 0;

    // Bugünün durumu
    final todayProgressKey = '${habit.id}_$todayStr';
    final todayProgress = progressMap[todayProgressKey];
    final isTodayScheduled = habit.isScheduledOn(today);
    final isTodayCompleted = todayProgress != null && todayProgress.isCompleted;

    if (isTodayScheduled && isTodayCompleted) {
      streak += 1;
    }

    // Dünden geriye doğru planlı günleri tara
    DateTime checkDate = today.subtract(const Duration(days: 1));
    final startDateOnly = DateTime(habit.startDate.year, habit.startDate.month, habit.startDate.day);

    while (!checkDate.isBefore(startDateOnly)) {
      if (habit.isScheduledOn(checkDate)) {
        final dateStr = AppDateUtils.toDateString(checkDate);
        final key = '${habit.id}_$dateStr';
        final progress = progressMap[key];

        if (progress != null && progress.isCompleted) {
          streak += 1;
        } else {
          // Planlı bir geçmiş gün tamamlanmamışsa seri kırılır
          break;
        }
      }
      // Planlı olmayan günler seriyi bozmaz veya artırmaz, geriye taranmaya devam edilir
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  /// Tüm alışkanlıklar üzerinden genel streak (alev serisi) sayısını hesaplar.
  /// Bir günün başarılı sayılması için o gün planlanmış tüm aktif alışkanlıkların
  /// tamamlanmış olması gerekir. Planlı alışkanlık olmayan günler seriyi bozmaz.
  int calculateOverallStreak({
    required List<Habit> habits,
    required Map<String, HabitDayProgress> progressMap,
    DateTime? referenceDate,
  }) {
    final activeHabits = habits.where((h) => !h.isArchived).toList();
    if (activeHabits.isEmpty) return 0;

    final now = referenceDate ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int streak = 0;

    // Bugünün durumunu kontrol et
    final todayPlanned = activeHabits.where((h) => h.isScheduledOn(today)).toList();

    if (todayPlanned.isNotEmpty) {
      final todayStr = AppDateUtils.toDateString(today);
      final allCompleted = todayPlanned.every((h) {
        final p = progressMap['${h.id}_$todayStr'];
        return p != null && p.isCompleted;
      });
      if (allCompleted) {
        streak += 1;
      }
    }

    // Dünden geriye doğru tara
    DateTime checkDate = today.subtract(const Duration(days: 1));
    // En fazla 365 gün geriye git
    final limitDate = today.subtract(const Duration(days: 400));

    while (checkDate.isAfter(limitDate)) {
      final plannedOnDay = activeHabits.where((h) => h.isScheduledOn(checkDate)).toList();

      if (plannedOnDay.isNotEmpty) {
        final dateStr = AppDateUtils.toDateString(checkDate);
        final allCompleted = plannedOnDay.every((h) {
          final p = progressMap['${h.id}_$dateStr'];
          return p != null && p.isCompleted;
        });

        if (allCompleted) {
          streak += 1;
        } else {
          // Geçmiş bir planlı gün tamamlanamamışsa seri kırılır
          break;
        }
      }
      // Eğer o gün hiç planlı alışkanlık yoksa seriyi kırmadan devam eder
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  /// Belirli bir gün için tamamlanma istatistiklerini hesaplar.
  /// Takvim renklendirmesinde kullanılır.
  DayCompletionReport getDayReport({
    required DateTime date,
    required List<Habit> habits,
    required Map<String, HabitDayProgress> progressMap,
    String? habitIdFilter,
  }) {
    final activeHabits = habits.where((h) => !h.isArchived).toList();
    final targetHabits = habitIdFilter != null
        ? activeHabits.where((h) => h.id == habitIdFilter).toList()
        : activeHabits;

    final plannedHabits = targetHabits.where((h) => h.isScheduledOn(date)).toList();
    if (plannedHabits.isEmpty) {
      return const DayCompletionReport(
        isPlannedDay: false,
        totalPlanned: 0,
        completedCount: 0,
        completionRatio: 0.0,
      );
    }

    final dateStr = AppDateUtils.toDateString(date);
    int completed = 0;

    for (final habit in plannedHabits) {
      final progress = progressMap['${habit.id}_$dateStr'];
      if (progress != null && progress.isCompleted) {
        completed += 1;
      }
    }

    final ratio = completed / plannedHabits.length;
    return DayCompletionReport(
      isPlannedDay: true,
      totalPlanned: plannedHabits.length,
      completedCount: completed,
      completionRatio: ratio,
    );
  }
}

/// Günlük tamamlama istatistik raporu
class DayCompletionReport {
  final bool isPlannedDay;
  final int totalPlanned;
  final int completedCount;
  final double completionRatio;

  const DayCompletionReport({
    required this.isPlannedDay,
    required this.totalPlanned,
    required this.completedCount,
    required this.completionRatio,
  });
}
