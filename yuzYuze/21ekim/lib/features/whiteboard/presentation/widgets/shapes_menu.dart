import 'package:flutter/material.dart';

/// Şekil seçim açılır menüsü
class ShapesMenu extends StatelessWidget {
  final String activeShapeType;
  final ValueChanged<String> onShapeSelected;

  const ShapesMenu({
    super.key,
    required this.activeShapeType,
    required this.onShapeSelected,
  });

  static const List<Map<String, dynamic>> shapes = [
    {
      'id': 'rectangle',
      'label': 'Dikdörtgen',
      'icon': Icons.crop_square_rounded,
    },
    {'id': 'ellipse', 'label': 'Daire / Elips', 'icon': Icons.circle_outlined},
    {'id': 'line', 'label': 'Çizgi', 'icon': Icons.horizontal_rule_rounded},
    {'id': 'arrow', 'label': 'Yön Oku', 'icon': Icons.arrow_right_alt_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 180,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: shapes.map((shape) {
          final isSelected = activeShapeType == shape['id'];
          return InkWell(
            onTap: () => onShapeSelected(shape['id']),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              color: isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.15)
                  : Colors.transparent,
              child: Row(
                children: [
                  Icon(
                    shape['icon'] as IconData,
                    size: 20,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : (isDark ? Colors.white70 : Colors.black87),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    shape['label'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                  const Spacer(),
                  if (isSelected)
                    Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
