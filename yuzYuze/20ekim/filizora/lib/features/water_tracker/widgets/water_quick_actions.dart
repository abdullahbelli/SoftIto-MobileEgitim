import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Hızlı su ekleme butonları (40 satır kuralına uygun)
class WaterQuickActions extends StatelessWidget {
  final ValueChanged<int> onAddWater;
  final VoidCallback onReset;

  const WaterQuickActions({
    super.key,
    required this.onAddWater,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = theme.cardTheme.color ?? theme.colorScheme.surface;
    final borderColor = isDark ? AppColors.obsidianBorder : AppColors.lightBorder;
    final accentColor = isDark ? AppColors.neonCyan : AppColors.neonTeal;

    return Row(
      children: [
        _buildActionButton(label: '+250 ml', amount: 250, bg: cardBg, border: borderColor, fg: accentColor),
        const SizedBox(width: 8),
        _buildActionButton(label: '+500 ml', amount: 500, bg: cardBg, border: borderColor, fg: accentColor),
        const SizedBox(width: 8),
        _buildActionButton(label: '+750 ml', amount: 750, bg: cardBg, border: borderColor, fg: accentColor),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          onPressed: onReset,
          tooltip: 'Sıfırla',
          style: IconButton.styleFrom(
            backgroundColor: cardBg,
            foregroundColor: AppColors.neonCrimson,
            side: BorderSide(color: borderColor),
          ),
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required int amount,
    required Color bg,
    required Color border,
    required Color fg,
  }) {
    return Expanded(
      child: FilledButton.tonal(
        onPressed: () => onAddWater(amount),
        style: FilledButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: border),
          ),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
