import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/water_log.dart';

class WaterHistoryTile extends StatelessWidget {
  const WaterHistoryTile({
    required this.log,
    required this.onDelete,
    super.key,
  });

  final WaterLog log;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final hour = log.timestamp.hour.toString().padLeft(2, '0');
    final minute = log.timestamp.minute.toString().padLeft(2, '0');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.obsidianCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.obsidianBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.neonCyan.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.water_drop, color: AppColors.neonCyan, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${log.amountMl} ml ${log.label}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'Saat: $hour:$minute',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.textTertiary, size: 20),
            onPressed: onDelete,
            tooltip: 'Kaydı Sil',
          ),
        ],
      ),
    );
  }
}
