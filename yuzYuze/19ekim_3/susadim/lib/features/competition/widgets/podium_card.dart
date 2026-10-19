import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../models/leaderboard_user.dart';

/// Liderlik podyumu (İlk 3 derece - 40 satır kuralına uygun)
class PodiumCard extends StatelessWidget {
  final List<LeaderboardUser> topThree;

  const PodiumCard({super.key, required this.topThree});

  @override
  Widget build(BuildContext context) {
    if (topThree.length < 3) return const SizedBox.shrink();
    final first = topThree[0];
    final second = topThree[1];
    final third = topThree[2];

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildPodiumStep(context, second, rank: '2', height: 75, color: AppColors.neonCyan),
            _buildPodiumStep(context, first, rank: '1', height: 105, color: AppColors.neonAmber),
            _buildPodiumStep(context, third, rank: '3', height: 60, color: AppColors.neonTeal),
          ],
        ),
      ),
    );
  }

  Widget _buildPodiumStep(BuildContext context, LeaderboardUser user, {required String rank, required double height, required Color color}) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.workspace_premium_rounded, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          user.name,
          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          '🔥 ${user.streakDays} gün',
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          width: 72,
          height: height,
          decoration: BoxDecoration(
            color: color.withAlpha(30),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(color: color.withAlpha(100)),
          ),
          alignment: Alignment.center,
          child: Text(
            '#$rank',
            style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
