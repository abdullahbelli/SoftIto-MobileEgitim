import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../models/badge_definition.dart';
import '../../models/earned_badge.dart';

/// Rozet Görsel Bileşeni (BadgeItem).
/// Kazanılmış rozetlerde ışıltılı gradient ve detaylar;
/// kilitli rozetlerde silik ve kilit simgesi sunar.
class BadgeItem extends StatelessWidget {
  final BadgeDefinition definition;
  final EarnedBadge? earnedBadge;

  const BadgeItem({
    super.key,
    required this.definition,
    this.earnedBadge,
  });

  bool get isEarned => earnedBadge != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEarned
            ? definition.color.withValues(alpha: isDark ? 0.2 : 0.1)
            : (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isEarned
              ? definition.color.withValues(alpha: 0.6)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: isEarned ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          // Rozet Madalyon / İkon Alanı
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: isEarned
                  ? LinearGradient(
                      colors: [
                        definition.color,
                        definition.color.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isEarned ? null : (isDark ? Colors.black26 : Colors.black12),
              shape: BoxShape.circle,
              boxShadow: isEarned
                  ? [
                      BoxShadow(
                        color: definition.color.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              isEarned ? definition.icon : Icons.lock_outline_rounded,
              color: isEarned ? Colors.white : (isDark ? Colors.white38 : Colors.black38),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),

          // Rozet Bilgileri
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      definition.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isEarned
                            ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                            : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                      ),
                    ),
                    if (isEarned) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: definition.color,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Kazanıldı',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  definition.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
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
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
