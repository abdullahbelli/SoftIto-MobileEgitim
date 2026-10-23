import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../models/habit.dart';
import '../../models/habit_day_progress.dart';
import '../../services/motivation_service.dart';

/// Alışkanlık Detay Modalı (HabitDetailSheet)
/// Sayfanın %70'ini kaplayan, sürüklenebilen ve kaydırılabilen alt modal.
/// Alışkanlığa ait tam motivasyon cümlesini (Hugging Face), hedef bilgilerini,
/// seriyi ve hızlı işlem kontrollerini eksiksiz sunar.
class HabitDetailSheet extends StatelessWidget {
  final Habit habit;
  final HabitDayProgress? progress;
  final int streak;
  final VoidCallback onToggle;
  final VoidCallback onEdit;

  const HabitDetailSheet({
    super.key,
    required this.habit,
    required this.progress,
    required this.streak,
    required this.onToggle,
    required this.onEdit,
  });

  static Future<void> show(
    BuildContext context, {
    required Habit habit,
    required HabitDayProgress? progress,
    required int streak,
    required VoidCallback onToggle,
    required VoidCallback onEdit,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => HabitDetailSheet(
        habit: habit,
        progress: progress,
        streak: streak,
        onToggle: onToggle,
        onEdit: onEdit,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isCompleted = progress?.isCompleted ?? false;

    final categoryColor = AppConstants.categoryColor(habit.category);
    final categoryIcon = AppConstants.categoryIcon(habit.category);

    final motivationService = context.watch<MotivationService>();
    final fullMotivation = motivationService.getStreakMotivation(
      streak: streak,
      category: habit.category,
      habitTitle: habit.name,
    );

    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      // Kural: Ekranın %70'lik kısmını kaplar
      height: screenHeight * 0.70,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        children: [
          // 1. Sabit Üst Kısım: Sürükleme Çubuğu ve Başlık
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8, left: 20, right: 16),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.visibility_rounded,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Alışkanlık Detayı',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 22),
                      tooltip: 'Kapat',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // 2. Kaydırılabilir İçerik Alanı
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Alışkanlık Başlık Kartı
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: categoryColor.withValues(alpha: isDark ? 0.25 : 0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(categoryIcon, color: categoryColor, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                habit.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                ),
                              ),
                              if (habit.description != null && habit.description!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  habit.description!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  _buildTag(
                                    text: habit.category,
                                    color: categoryColor,
                                    icon: categoryIcon,
                                  ),
                                  _buildTag(
                                    text: habit.scheduledWeekdays.length == 7 ? 'Her Gün' : '${habit.scheduledWeekdays.length} Gün/Hafta',
                                    color: theme.colorScheme.primary,
                                    icon: Icons.calendar_today_rounded,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // HUGGING FACE MOTİVASYON BÖLÜMÜ (TAM VE KESİNTİSİZ METİN)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary.withValues(alpha: isDark ? 0.22 : 0.10),
                          theme.colorScheme.primaryContainer.withValues(alpha: isDark ? 0.15 : 0.20),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('🤗', style: TextStyle(fontSize: 13)),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Hugging Face Motivasyonu',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.flameOrange.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.local_fire_department_rounded,
                                    size: 13,
                                    color: AppColors.flameOrange,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$streak gün seri',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.flameOrange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Tam Metin - Asla Kırpılmaz
                        Text(
                          '“$fullMotivation”',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.italic,
                            height: 1.5,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),

                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Alışkanlığınızın $streak günlük ritmine özel',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                            Text(
                              '#${habit.category.toLowerCase()}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Bugünün Durumu ve İlerleme
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.green.withValues(alpha: isDark ? 0.15 : 0.08)
                          : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isCompleted
                            ? Colors.green.withValues(alpha: 0.5)
                            : theme.colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                          size: 28,
                          color: isCompleted ? Colors.green : (isDark ? Colors.white38 : Colors.black26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isCompleted ? 'Bugün Tamamlandı!' : 'Bugün Henüz Yapılmadı',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isCompleted
                                      ? Colors.green
                                      : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isCompleted
                                    ? 'Harika bir adım attın! Ritim puanın hanene yazıldı.'
                                    : 'Aşağıdaki butona dokunarak bugünü tamamlayabilirsin.',
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

                  const SizedBox(height: 24),

                  // Aksiyon Butonları
                  Row(
                    children: [
                      // Tamamla / Geri Al Butonu
                      Expanded(
                        flex: 3,
                        child: FilledButton.icon(
                          onPressed: () {
                            onToggle();
                            Navigator.of(context).pop();
                          },
                          icon: Icon(
                            isCompleted ? Icons.undo_rounded : Icons.check_rounded,
                            size: 18,
                          ),
                          label: Text(
                            isCompleted ? 'Geri Al' : 'Tamamlandı Olarak İşaretle',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: isCompleted ? Colors.grey.shade700 : theme.colorScheme.primary,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Düzenle Butonu
                      OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onEdit();
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(48, 48),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 18, color: theme.colorScheme.primary),
                            const SizedBox(width: 6),
                            const Text('Düzenle'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag({
    required String text,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
