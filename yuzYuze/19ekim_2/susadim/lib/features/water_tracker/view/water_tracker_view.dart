import 'package:flutter/material.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/app_theme_toggle_button.dart';
import '../controllers/water_tracker_controller.dart';
import '../models/water_log.dart';
import '../widgets/water_history_tile.dart';
import '../widgets/water_progress_card.dart';
import '../widgets/water_quick_actions.dart';

/// Su Takip Ana Görünümü (StatelessWidget + ValueNotifier mimarisi)
class WaterTrackerView extends StatelessWidget {
  final WaterTrackerController controller;
  final ThemeController? themeController;

  const WaterTrackerView({
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
            Text('Susadım v1 • Su Takibi'),
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
              valueListenable: controller.currentWater,
              builder: (context, current, _) {
                return WaterProgressCard(
                  current: current,
                  goal: controller.dailyGoalWater,
                );
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Hızlı Ekle',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            WaterQuickActions(
              onAddWater: controller.addWater,
              onReset: controller.resetWater,
            ),
            const SizedBox(height: 24),
            Text(
              'Bugünkü Kayıtlar',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<List<WaterLog>>(
              valueListenable: controller.logs,
              builder: (context, logs, _) {
                if (logs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text('Henüz bir su kaydı bulunmuyor.'),
                    ),
                  );
                }
                return Column(
                  children: logs.map((log) => WaterHistoryTile(log: log)).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
