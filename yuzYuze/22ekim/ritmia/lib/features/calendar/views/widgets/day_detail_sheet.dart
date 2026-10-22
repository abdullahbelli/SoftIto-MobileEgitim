import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../habits/models/habit.dart';
import '../../../habits/models/habit_day_progress.dart';
import '../../../habits/services/habit_streak_service.dart';

/// Takvimde bir güne dokunulduğunda açılan detay raporu sayfası/bottom sheet'i.
/// project.md Bölüm 5 kurallarına uygun olarak günlük başarıyı ve detayları listeler.
class DayDetailSheet extends StatelessWidget {
  final DateTime date;
  final DayCompletionReport report;
  final List<Habit> plannedHabits;
  final Map<String, HabitDayProgress> progressMap;

  const DayDetailSheet({
    super.key,
    required this.date,
    required this.report,
    required this.plannedHabits,
    required this.progressMap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dateStr = AppDateUtils.toDateString(date);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sürükleme Çizgisi
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tarih Başlığı
              Text(
                AppDateUtils.formatFullTurkish(date),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Tamamlama Durum Özeti
              if (!report.isPlannedDay) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Bu gün için planlanmış herhangi bir alışkanlık yoktu.',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Başarı İlerleme Rozeti
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: report.completionRatio >= 1.0
                        ? Colors.green.withValues(alpha: 0.15)
                        : (report.completionRatio > 0.0
                            ? theme.colorScheme.primary.withValues(alpha: 0.12)
                            : Colors.red.withValues(alpha: 0.12)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        report.completionRatio >= 1.0
                            ? Icons.stars_rounded
                            : (report.completionRatio > 0.0 ? Icons.trending_up_rounded : Icons.cancel_outlined),
                        color: report.completionRatio >= 1.0
                            ? Colors.green
                            : (report.completionRatio > 0.0 ? theme.colorScheme.primary : Colors.red),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${report.completedCount} / ${report.totalPlanned} Alışkanlık Tamamlandı',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              _getMotivationText(report.completionRatio),
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  'Günün Planlanan Alışkanlıkları',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // Alışkanlık Listesi
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: plannedHabits.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final habit = plannedHabits[index];
                      final progress = progressMap['${habit.id}_$dateStr'];
                      final isCompleted = progress?.isCompleted ?? false;
                      final catIcon = AppConstants.categoryIcon(habit.category);
                      final catColor = AppConstants.categoryColor(habit.category);

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isCompleted
                                ? Colors.green.withValues(alpha: 0.5)
                                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: catColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(catIcon, color: catColor, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    habit.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                  Text(
                                    habit.targetType == AppConstants.targetTypeCheck
                                        ? (isCompleted ? 'Tamamlandı' : 'Yapılmadı')
                                        : '${(progress?.amount ?? 0).toInt()} / ${habit.targetValue.toInt()} ${habit.targetType == AppConstants.targetTypeDuration ? 'dk' : 'adet'}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                              color: isCompleted ? Colors.green : Colors.grey,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _getMotivationText(double ratio) {
    if (ratio >= 1.0) {
      return 'Mükemmel bir gün! Tüm hedeflerine ulaştın.';
    } else if (ratio >= 0.5) {
      return 'Güzel bir gayret! Ritmini sürdürmeye devam et.';
    } else if (ratio > 0.0) {
      return 'Bir adım atıldı, yarın daha da güçlü olabilirsin.';
    } else {
      return 'Bugün hedeflere ulaşılamadı. Hiç sorun değil, yeni gün yeni bir başlangıç!';
    }
  }
}
