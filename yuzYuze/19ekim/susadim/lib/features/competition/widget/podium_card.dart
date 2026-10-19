import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/leaderboard_user.dart';

class PodiumCard extends StatelessWidget {
  const PodiumCard({
    required this.topThree,
    super.key,
  });

  final List<LeaderboardUser> topThree;

  @override
  Widget build(BuildContext context) {
    if (topThree.length < 3) return const SizedBox.shrink();

    final first = topThree[0];
    final second = topThree[1];
    final third = topThree[2];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.obsidianCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.obsidianBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildPodiumStep(user: second, rank: 2, color: AppColors.podiumSilver, height: 80),
          _buildPodiumStep(user: first, rank: 1, color: AppColors.podiumGold, height: 110),
          _buildPodiumStep(user: third, rank: 3, color: AppColors.podiumBronze, height: 65),
        ],
      ),
    );
  }

  Widget _buildPodiumStep({
    required LeaderboardUser user,
    required int rank,
    required Color color,
    required double height,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: rank == 1 ? 24 : 20,
          backgroundColor: color.withValues(alpha: 0.2),
          child: Text(
            user.name.characters.first,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          user.name.split(' ').first,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          '${user.streakDays} gün',
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Container(
          width: 70,
          height: height,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: TextStyle(
                color: color,
                fontSize: rank == 1 ? 22 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
