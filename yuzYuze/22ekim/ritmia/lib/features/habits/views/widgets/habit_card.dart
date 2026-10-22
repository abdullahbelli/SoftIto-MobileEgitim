import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../models/habit.dart';
import '../../models/habit_day_progress.dart';

/// Alışkanlık Kartı (HabitCard)
/// Kategori ikonu, alışkanlık adı, seri (streak), ilerleme durumu,
/// motivasyon metni ve tamamlama/artırma etkileşimlerini barındırır.
class HabitCard extends StatelessWidget {
  final Habit habit;
  final HabitDayProgress? progress;
  final int streak;
  final VoidCallback onToggle;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onEdit;

  const HabitCard({
    super.key,
    required this.habit,
    required this.progress,
    required this.streak,
    required this.onToggle,
    required this.onIncrement,
    required this.onDecrement,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isCompleted = progress?.isCompleted ?? false;
    final ratio = progress?.ratio ?? 0.0;

    final categoryColor = AppConstants.categoryColor(habit.category);
    final categoryIcon = AppConstants.categoryIcon(habit.category);
    final motivation = AppConstants.motivationMessage(streak);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: isCompleted
              ? categoryColor.withValues(alpha: 0.6)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: isCompleted ? 1.5 : 1.0,
        ),
      ),
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

            // İlerleme Çubuğu (Progress bar)
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 8,
                backgroundColor: isDark
                    ? AppColors.darkBorder.withValues(alpha: 0.5)
                    : AppColors.lightBorder,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isCompleted ? Colors.green : categoryColor,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Alt Satır: İlerleme Metni ve Tamamlama/Artırma Butonları
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Miktar / Hedef etiketi
                Text(
                  _buildProgressText(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isCompleted
                        ? Colors.green
                        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                  ),
                ),

                // Kontroller
                _buildActionButtons(theme, categoryColor, isCompleted),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _buildProgressText() {
    final current = progress?.amount ?? 0.0;
    final target = habit.targetValue;

    if (habit.targetType == AppConstants.targetTypeCheck) {
      return (progress?.isCompleted ?? false) ? 'Tamamlandı 🎉' : 'Henüz yapılmadı';
    } else if (habit.targetType == AppConstants.targetTypeDuration) {
      return '${current.toInt()} / ${target.toInt()} dk';
    } else {
      return '${current.toInt()} / ${target.toInt()} adet';
    }
  }

  Widget _buildActionButtons(ThemeData theme, Color categoryColor, bool isCompleted) {
    if (habit.targetType == AppConstants.targetTypeCheck) {
      return InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isCompleted
                ? Colors.green
                : categoryColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                size: 18,
                color: isCompleted ? Colors.white : categoryColor,
              ),
              const SizedBox(width: 6),
              Text(
                isCompleted ? 'Yapıldı' : 'Tamamla',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isCompleted ? Colors.white : categoryColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Adet veya Dakika için Sayaç Butonları
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(
          onPressed: (progress?.amount ?? 0) > 0 ? onDecrement : null,
          icon: const Icon(Icons.remove_rounded, size: 16),
          style: IconButton.styleFrom(
            minimumSize: const Size(36, 36),
            padding: EdgeInsets.zero,
          ),
        ),
        const SizedBox(width: 6),
        IconButton.filled(
          onPressed: onIncrement,
          icon: const Icon(Icons.add_rounded, size: 16),
          style: IconButton.styleFrom(
            backgroundColor: isCompleted ? Colors.green : categoryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(36, 36),
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}
