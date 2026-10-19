import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/leaderboard_user.dart';

class LeaderboardTile extends StatelessWidget {
  const LeaderboardTile({
    required this.user,
    required this.onChallengeToggle,
    super.key,
  });

  final LeaderboardUser user;
  final VoidCallback onChallengeToggle;

  @override
  Widget build(BuildContext context) {
    final borderColor = user.isCurrentUser
        ? AppColors.neonCyan.withValues(alpha: 0.5)
        : AppColors.obsidianBorder;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: user.isCurrentUser
            ? AppColors.neonCyan.withValues(alpha: 0.08)
            : AppColors.obsidianCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '#${user.rank}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    if (user.isCurrentUser) ...[
                      const SizedBox(width: 6),
                      _buildCurrentBadge(),
                    ],
                  ],
                ),
                Text(
                  '${user.streakDays} gün seri • ${user.totalScore} XP',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          if (!user.isCurrentUser) _buildChallengeButton(),
        ],
      ),
    );
  }

  Widget _buildCurrentBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.neonCyan.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'SEN',
        style: TextStyle(
          color: AppColors.neonCyan,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildChallengeButton() {
    return TextButton.icon(
      onPressed: onChallengeToggle,
      style: TextButton.styleFrom(
        foregroundColor:
            user.isChallenged ? AppColors.neonCrimson : AppColors.neonLime,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      icon: Icon(
        user.isChallenged ? Icons.check_circle : Icons.sports_mma,
        size: 16,
      ),
      label: Text(
        user.isChallenged ? 'Meydan Okundu' : 'Meydan Oku',
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}
