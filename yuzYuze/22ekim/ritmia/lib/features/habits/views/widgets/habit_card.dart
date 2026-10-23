import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../models/habit.dart';
import '../../models/habit_day_progress.dart';
import '../../services/motivation_service.dart';

/// Alışkanlık Kartı (HabitCard)
/// Kategori ikonu, alışkanlık adı, seri (streak), ilerleme durumu,
/// motivasyon metni ve tamamlama/artırma etkileşimlerini barındırır.
class HabitCard extends StatelessWidget {
  final Habit habit;
  final HabitDayProgress? progress;
  final int streak;
  final VoidCallback onToggle;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback onEdit;
  final VoidCallback? onTap;
  final String? customMotivation;

  const HabitCard({
    super.key,
    required this.habit,
    required this.progress,
    required this.streak,
    required this.onToggle,
    this.onIncrement,
    this.onDecrement,
    required this.onEdit,
    this.onTap,
    this.customMotivation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isCompleted = progress?.isCompleted ?? false;

    final categoryColor = AppConstants.categoryColor(habit.category);
    final categoryIcon = AppConstants.categoryIcon(habit.category);

    final motivationService = context.watch<MotivationService>();
    final motivation = customMotivation ??
        motivationService.getStreakMotivation(
          streak: streak,
          category: habit.category,
          habitTitle: habit.name,
        );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: isCompleted
              ? Colors.green.withValues(alpha: 0.7)
              : theme.colorScheme.outline,
          width: isCompleted ? 1.5 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst Satır: Kategori İkonu + İsim/Açıklama + Düzenle (Kalem)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kategori İkon Kutusu
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: isDark ? 0.25 : 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(categoryIcon, color: categoryColor, size: 24),
                ),
                const SizedBox(width: 14),

                // Alışkanlık Adı ve Kategori
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (habit.description != null && habit.description!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          habit.description!,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // Sağ Üst: Düzenle (Kalem) Butonu
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  tooltip: 'Düzenle',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  onPressed: onEdit,
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Orta Satır: Streak Rozeti ve Motivasyon Metni
            Row(
              children: [
                // Alev ve Seri Sayısı
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.flameOrange.withValues(alpha: isDark ? 0.2 : 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        color: AppColors.flameOrange,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$streak gün',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.flameOrange,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Motivasyon Mesajı
                Expanded(
                  child: Text(
                    motivation,
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // İlerleme Çubuğu (Yaptım ise %100, değilse %0)
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: isCompleted ? 1.0 : 0.0,
                minHeight: 6,
                backgroundColor: theme.colorScheme.outline.withValues(alpha: isDark ? 0.35 : 0.25),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isCompleted ? Colors.green : theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Alt Satır: Durum Etiketi ve Yaptım / Yapmadım Butonu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Durum etiketi
                Row(
                  children: [
                    Icon(
                      isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      size: 16,
                      color: isCompleted
                          ? Colors.green
                          : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isCompleted ? 'Bugün yapıldı' : 'Bugün yapılmadı',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isCompleted
                            ? Colors.green
                            : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                      ),
                    ),
                  ],
                ),

                // Yaptım / Yapmadım Aksiyon Butonu
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onToggle,
                    borderRadius: BorderRadius.circular(14),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? Colors.green
                            : theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isCompleted
                              ? Colors.green
                              : theme.colorScheme.primary.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isCompleted ? Icons.check_rounded : Icons.add_task_rounded,
                            size: 18,
                            color: isCompleted ? Colors.white : theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isCompleted ? 'Yaptım ✓' : 'Yaptım',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isCompleted ? Colors.white : theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
}
