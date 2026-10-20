import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';

/// "İş Fikrim Var" / "İş Fikrim Yok" Seçim Alanı
class IdeaSelectionToggle extends StatelessWidget {
  final bool hasIdea;
  final ValueChanged<bool> onSelectionChanged;

  const IdeaSelectionToggle({
    super.key,
    required this.hasIdea,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'İş Fikri Durumu',
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _ToggleCard(
                title: 'İş Fikrim Var',
                icon: Icons.lightbulb_rounded,
                isSelected: hasIdea,
                onTap: () => onSelectionChanged(true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ToggleCard(
                title: 'İş Fikrim Yok',
                icon: Icons.explore_rounded,
                isSelected: !hasIdea,
                onTap: () => onSelectionChanged(false),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ToggleCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isSelected
        ? AppColors.oceanBlue
        : (isDark ? AppColors.obsidianBorder : AppColors.lightBorder);
    final bgColor = isSelected
        ? AppColors.oceanBlue.withAlpha(25)
        : Colors.transparent;
    final activeColor = isSelected
        ? AppColors.oceanBlue
        : (isDark ? AppColors.textSecondary : AppColors.textLightSecondary);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: isSelected ? 1.8 : 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: activeColor,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: activeColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
