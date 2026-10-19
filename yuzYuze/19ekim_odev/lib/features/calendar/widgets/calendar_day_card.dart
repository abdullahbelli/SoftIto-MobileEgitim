import 'package:flutter/material.dart';
import '../models/calendar_model.dart';

/// Takvimdeki her bir günü temsil eden kart bileşeni.
class CalendarDayCard extends StatelessWidget {
  final CalendarDayModel dayModel;
  final VoidCallback onTap;

  const CalendarDayCard({
    super.key,
    required this.dayModel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Renk ve stil hesaplamaları
    final isSelected = dayModel.isSelected;
    final isToday = dayModel.isToday;
    final isCurrentMonth = dayModel.isCurrentMonth;

    Color? backgroundColor;
    Color textColor;
    Border? border;

    if (isSelected) {
      backgroundColor = colorScheme.primary;
      textColor = colorScheme.onPrimary;
    } else if (isToday) {
      backgroundColor = colorScheme.primaryContainer.withValues(alpha: 0.35);
      textColor = colorScheme.primary;
      border = Border.all(color: colorScheme.primary, width: 1.5);
    } else {
      backgroundColor = Colors.transparent;
      textColor = isCurrentMonth
          ? colorScheme.onSurface
          : colorScheme.onSurface.withValues(alpha: 0.3);
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: border,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Gün Numarası
            Text(
              '${dayModel.date.day}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: (isToday || isSelected)
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: textColor,
              ),
            ),

            // Günlük Varsa Gösterilen Nokta / İşaret
            if (dayModel.hasDiary)
              Positioned(
                bottom: 4,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
