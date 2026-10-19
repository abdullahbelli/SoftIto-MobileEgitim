import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Hızlı egzersiz ekleme butonları (40 satır kuralına uygun)
class WorkoutQuickButtons extends StatelessWidget {
  final void Function(String title, int duration, int calories) onAdd;

  const WorkoutQuickButtons({
    super.key,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = theme.cardTheme.color ?? theme.colorScheme.surface;
    final borderColor = isDark ? AppColors.obsidianBorder : AppColors.lightBorder;
    final limeColor = isDark ? AppColors.neonLime : const Color(0xFF16A34A);

    return Row(
      children: [
        _buildButton(
          title: 'Kardiyo',
          subtitle: '20 dk / 180 kcal',
          bg: cardBg,
          border: borderColor,
          textColor: limeColor,
          onTap: () => onAdd('Kardiyo Koşu', 20, 180),
        ),
        const SizedBox(width: 8),
        _buildButton(
          title: 'Ağırlık',
          subtitle: '30 dk / 220 kcal',
          bg: cardBg,
          border: borderColor,
          textColor: limeColor,
          onTap: () => onAdd('Ağırlık Fitness', 30, 220),
        ),
        const SizedBox(width: 8),
        _buildButton(
          title: 'HIIT',
          subtitle: '15 dk / 160 kcal',
          bg: cardBg,
          border: borderColor,
          textColor: limeColor,
          onTap: () => onAdd('HIIT Antrenman', 15, 160),
        ),
      ],
    );
  }

  Widget _buildButton({
    required String title,
    required String subtitle,
    required Color bg,
    required Color border,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
