import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../habits/models/habit.dart';
import '../../habits/models/habit_day_progress.dart';
import '../../habits/services/habit_streak_service.dart';

/// Takvim hesaplamaları ve ısı haritası renk belirleme servisi.
/// project.md Bölüm 5'teki renk ve oran kurallarını tam olarak uygular.
class CalendarService {
  final HabitStreakService _streakService;

  CalendarService(this._streakService);

  /// Belirtilen ay için takvim günlerini (haftanın günlerine göre hizalı matris) üretir
  List<DateTime?> generateMonthDays(DateTime monthDate) {
    final firstDayOfMonth = DateTime(monthDate.year, monthDate.month, 1);
    final daysInMonth = DateTime(monthDate.year, monthDate.month + 1, 0).day;

    // DateTime.weekday: 1 = Pazartesi ... 7 = Pazar
    final leadingEmptyCount = firstDayOfMonth.weekday - 1;

    final List<DateTime?> days = [];

    // Ayın ilk gününden önceki boş hücreler
    for (int i = 0; i < leadingEmptyCount; i++) {
      days.add(null);
    }

    // Ayın günleri
    for (int day = 1; day <= daysInMonth; day++) {
      days.add(DateTime(monthDate.year, monthDate.month, day));
    }

    return days;
  }

  /// Günün tamamlanma oranına göre ısı haritası rengini döner.
  /// Kırmızı-yeşil yerine yapılmayanlardan yapılanlara doğru tema rengi koyulaşarak gider.
  Color getHeatMapColor({
    required DayCompletionReport report,
    required bool isFuture,
    required bool isDark,
    Color? primaryColor,
  }) {
    if (isFuture || !report.isPlannedDay) {
      return isDark ? AppColors.heatMapNeutralDark : AppColors.heatMapNeutralLight;
    }

    final accent = primaryColor ?? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary);
    return AppColors.dynamicHeatMapColor(
      ratio: report.completionRatio,
      primaryColor: accent,
      isDark: isDark,
    );
  }

  /// Gün raporunu hesaplar
  DayCompletionReport getDayReport({
    required DateTime date,
    required List<Habit> habits,
    required Map<String, HabitDayProgress> progressMap,
    String? habitIdFilter,
  }) {
    return _streakService.getDayReport(
      date: date,
      habits: habits,
      progressMap: progressMap,
      habitIdFilter: habitIdFilter,
    );
  }
}
