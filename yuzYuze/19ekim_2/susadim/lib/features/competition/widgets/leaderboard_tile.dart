import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../models/leaderboard_user.dart';

/// Liderlik tablosu liste satırı (40 satır kuralına uygun)
class LeaderboardTile extends StatelessWidget {
  final LeaderboardUser user;

  const LeaderboardTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMe = user.isCurrentUser;
    final primaryAccent = isDark ? AppColors.neonCyan : AppColors.neonTeal;
    final cardBg = theme.cardTheme.color ?? theme.colorScheme.surface;
    final borderColor = isDark ? AppColors.obsidianBorder : AppColors.lightBorder;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? primaryAccent.withAlpha(25) : cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMe ? primaryAccent : borderColor,
          width: isMe ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '#${user.rank}',
              style: TextStyle(
                color: isMe ? primaryAccent : theme.textTheme.bodySmall?.color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: TextStyle(
                    color: isMe ? primaryAccent : theme.textTheme.titleMedium?.color,
                    fontWeight: isMe ? FontWeight.bold : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '🏅 ${user.badgesCount} rozet',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            '🔥 ${user.streakDays} gün',
            style: const TextStyle(
              color: AppColors.neonAmber,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
