import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../controller/competition_controller.dart';
import '../widget/leaderboard_tile.dart';
import '../widget/podium_card.dart';
import '../widget/user_streak_banner.dart';

class CompetitionView extends StatelessWidget {
  const CompetitionView({
    required this.controller,
    super.key,
  });

  final CompetitionController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            UserStreakBanner(controller: controller),
            const SizedBox(height: 20),
            const Text(
              'Haftalık Podyum 🏆',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            PodiumCard(topThree: controller.topThree),
            const SizedBox(height: 24),
            const Text(
              'Tüm Sıralama',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...controller.users.map(
              (user) => LeaderboardTile(
                user: user,
                onChallengeToggle: () => controller.challengeUser(user.id),
              ),
            ),
          ],
        );
      },
    );
  }
}
