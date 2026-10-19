import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../controller/water_tracker_controller.dart';

class WaterQuickActions extends StatelessWidget {
  const WaterQuickActions({
    required this.controller,
    super.key,
  });

  final WaterTrackerController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildActionButton(
          amount: 200,
          label: 'Bardak (200 ml)',
          icon: Icons.local_drink_outlined,
        ),
        const SizedBox(width: 12),
        _buildActionButton(
          amount: 500,
          label: 'Matara (500 ml)',
          icon: Icons.water_drop_outlined,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required int amount,
    required String label,
    required IconData icon,
  }) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: () => controller.addWater(amount),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          foregroundColor: AppColors.neonCyan,
          side: const BorderSide(color: AppColors.obsidianBorder),
          backgroundColor: AppColors.obsidianCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Icon(icon, size: 20, color: AppColors.neonCyan),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
