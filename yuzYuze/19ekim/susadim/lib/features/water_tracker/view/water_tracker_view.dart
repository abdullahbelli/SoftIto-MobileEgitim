import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../controller/water_tracker_controller.dart';
import '../widget/water_history_tile.dart';
import '../widget/water_progress_card.dart';
import '../widget/water_quick_actions.dart';

class WaterTrackerView extends StatelessWidget {
  const WaterTrackerView({
    required this.controller,
    super.key,
  });

  final WaterTrackerController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            WaterProgressCard(controller: controller),
            const SizedBox(height: 16),
            WaterQuickActions(controller: controller),
            const SizedBox(height: 24),
            const Text(
              'Bugünkü Tüketim Geçmişi',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (controller.logs.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32.0),
                child: Center(
                  child: Text(
                    'Henüz su tüketimi kaydedilmedi.',
                    style: TextStyle(color: AppColors.textTertiary),
                  ),
                ),
              )
            else
              ...controller.logs.map(
                (log) => WaterHistoryTile(
                  log: log,
                  onDelete: () => controller.removeLog(log.id),
                ),
              ),
          ],
        );
      },
    );
  }
}
