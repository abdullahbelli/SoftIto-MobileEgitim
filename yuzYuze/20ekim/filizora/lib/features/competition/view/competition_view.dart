import 'package:flutter/material.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/app_theme_toggle_button.dart';
import '../controllers/competition_controller.dart';
import '../models/leaderboard_user.dart';
import '../widgets/challenge_banner.dart';
import '../widgets/leaderboard_tile.dart';
import '../widgets/podium_card.dart';

/// Yarışma ve Liderlik Tablosu Ana Görünümü (StatelessWidget + ValueNotifier mimarisi)
class CompetitionView extends StatelessWidget {
  final CompetitionController controller;
  final ThemeController? themeController;

  const CompetitionView({
    super.key,
    required this.controller,
    this.themeController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppLogo(size: 26),
            SizedBox(width: 10),
            Text('Susadım v1 • Yarışma'),
          ],
        ),
        actions: [
          if (themeController != null)
            AppThemeToggleButton(themeController: themeController!),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ValueListenableBuilder<int>(
              valueListenable: controller.userStreak,
              builder: (context, streak, _) {
                return ChallengeBanner(
                  streakDays: streak,
                  onBoost: controller.boostStreak,
                );
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Haftalık Şampiyonlar Podyumu',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<List<LeaderboardUser>>(
              valueListenable: controller.leaderboard,
              builder: (context, list, _) {
                return PodiumCard(topThree: list.take(3).toList());
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Genel Sıralama',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<List<LeaderboardUser>>(
              valueListenable: controller.leaderboard,
              builder: (context, list, _) {
                return Column(
                  children: list.map((user) => LeaderboardTile(user: user)).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
