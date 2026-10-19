import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../controller/competition_controller.dart';

class UserStreakBanner extends StatelessWidget {
  const UserStreakBanner({
    required this.controller,
    super.key,
  });

  final CompetitionController controller;

  @override
  Widget build(BuildContext context) {
    final me = controller.currentUser;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            _buildStreakFlame(me.streakDays),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${me.streakDays} Günlük Seri! 🔥',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Ligde #${me.rank}. sıradasın • ${me.totalScore} XP',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            IconButton.filledTonal(
              onPressed: controller.boostCurrentUserStreak,
              icon: const Icon(Icons.bolt, color: AppColors.neonLime),
              tooltip: 'Seriyi Arttır',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakFlame(int days) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.neonAmber.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.neonAmber.withValues(alpha: 0.4)),
      ),
      child: const Center(
        child: Icon(Icons.local_fire_department, color: AppColors.neonAmber, size: 28),
      ),
    );
  }
}
