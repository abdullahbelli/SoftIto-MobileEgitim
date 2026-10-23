import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_utils.dart';
import '../../models/badge_definition.dart';
import '../../models/earned_badge.dart';

/// Rozet Görsel Bileşeni (BadgeItem).
/// Kazanılmış rozetlerde ışıltılı gradient ve kazanım tarihi sunar;
/// henüz kazanılmamış rozetlerde ise ikon ve kriterleri gizlemek yerine
/// şık bir "Önizleme Modu", puan değeri ve anlık seri ilerleme çubuğu gösterir.
class BadgeItem extends StatelessWidget {
  final BadgeDefinition definition;
  final EarnedBadge? earnedBadge;
  final int currentStreak;

  const BadgeItem({
    super.key,
    required this.definition,
    this.earnedBadge,
    this.currentStreak = 0,
  });

  bool get isEarned => earnedBadge != null;

  int get badgePoints {
    return switch (definition.thresholdDays) {
      7 => 20,
      30 => 60,
      365 => 200,
      _ => 50,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final progressRatio = (currentStreak / definition.thresholdDays).clamp(0.0, 1.0);
    final daysLeft = definition.thresholdDays - currentStreak;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showBadgePreviewSheet(context),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isEarned
                ? definition.color.withValues(alpha: isDark ? 0.20 : 0.10)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isEarned
                  ? definition.color.withValues(alpha: 0.7)
                  : theme.colorScheme.outline,
              width: isEarned ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rozet Madalyon / Önizleme İkon Alanı
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: isEarned
                          ? LinearGradient(
                              colors: [
                                definition.color,
                                definition.color.withValues(alpha: 0.75),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isEarned
                          ? null
                          : definition.color.withValues(alpha: isDark ? 0.22 : 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isEarned
                            ? Colors.white.withValues(alpha: 0.4)
                            : definition.color.withValues(alpha: 0.45),
                        width: 1.5,
                      ),
                      boxShadow: isEarned
                          ? [
                              BoxShadow(
                                color: definition.color.withValues(alpha: 0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      definition.icon,
                      color: isEarned
                          ? Colors.white
                          : definition.color.withValues(alpha: 0.95),
                      size: 26,
                    ),
                  ),

                  // Önizleme veya Kazanıldı mini rozet rozeti
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: isEarned ? Colors.green : definition.color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? theme.colorScheme.surface : Colors.white,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        isEarned ? Icons.check_rounded : Icons.visibility_rounded,
                        size: 11,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),

              // Rozet Bilgileri ve İlerleme
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Başlık ve Rozet Durum Rozeti
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            definition.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                        ),
                        if (isEarned)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: definition.color,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Kazanıldı ✓',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: definition.color.withValues(alpha: isDark ? 0.25 : 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: definition.color.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.visibility_outlined,
                                  size: 11,
                                  color: definition.color,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  'Önizleme • +$badgePoints p',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: definition.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Kriter Açıklaması
                    Text(
                      definition.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),

                    if (isEarned && earnedBadge != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        '${earnedBadge!.habitName != null ? '${earnedBadge!.habitName} • ' : ''}${AppDateUtils.formatShortDayMonth(earnedBadge!.earnedAt)}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: definition.color,
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 10),
                      // Önizleme İlerleme Çubuğu
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progressRatio,
                          minHeight: 5,
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(definition.color),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$currentStreak / ${definition.thresholdDays} gün (${(progressRatio * 100).toInt()}%)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                          Text(
                            daysLeft > 0 ? '$daysLeft gün kaldı' : 'Eşiğe çok yakın!',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: definition.color,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Rozet Önizleme Detay Sayfası (%70 Yükseklik kuralı)
  void _showBadgePreviewSheet(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final progressRatio = (currentStreak / definition.thresholdDays).clamp(0.0, 1.0);
    final daysLeft = definition.thresholdDays - currentStreak;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        return Container(
          height: MediaQuery.of(modalCtx).size.height * 0.70,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.6),
            ),
          ),
          child: Column(
            children: [
              // Kaydırma Çubuğu & Başlık
              Container(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Column(
                  children: [
                    Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outline,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 48),
                        Text(
                          isEarned ? 'Kazanılan Rozet' : 'Rozet Önizlemesi',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(modalCtx),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Kaydırılabilir İçerik
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Büyük Rozet Madalyası
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              definition.color,
                              definition.color.withValues(alpha: 0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: definition.color.withValues(alpha: 0.45),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Icon(
                          definition.icon,
                          size: 46,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 18),

                      Text(
                        definition.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Lig Puanı Etiketi
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: definition.color.withValues(alpha: isDark ? 0.25 : 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: definition.color.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          'Haftalık Lig Ödülü: +$badgePoints Puan',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: definition.color,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        definition.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // İlerleme veya Başarı Kutusu
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isEarned ? 'Durum' : 'Kazanma İlerlemesi',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  isEarned
                                      ? 'Tamamlandı ✓'
                                      : '$currentStreak / ${definition.thresholdDays} gün',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: isEarned ? Colors.green : definition.color,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: isEarned ? 1.0 : progressRatio,
                                minHeight: 8,
                                backgroundColor: theme.colorScheme.surface,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isEarned ? Colors.green : definition.color,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              isEarned
                                  ? 'Tebrikler! Bu rozeti başarıyla koleksiyonuna ekledin.'
                                  : daysLeft > 0
                                      ? 'Bu rozeti ve +$badgePoints lig puanını kazanmak için alışkanlık serini $daysLeft gün daha sürdür.'
                                      : 'Serin hedef eşiği aştı, bugün tamamla ve rozeti kap!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.4,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Motivasyon Notu
                      Row(
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              AppConstants.motivationMessage(currentStreak),
                              style: TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      ElevatedButton(
                        onPressed: () => Navigator.pop(modalCtx),
                        child: const Text('Anladım, Harika!'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
