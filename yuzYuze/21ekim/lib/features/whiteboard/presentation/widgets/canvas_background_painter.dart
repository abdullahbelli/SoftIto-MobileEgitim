import 'package:flutter/material.dart';

import '../../domain/canvas_theme.dart';

/// Tuval arka plan deseni çizicisi (Sonsuz Pan & Zoom destekli)
class CanvasBackgroundPainter extends CustomPainter {
  final CanvasBackgroundPattern pattern;
  final Offset pan;
  final double scale;
  final bool isDark;

  const CanvasBackgroundPainter({
    required this.pattern,
    required this.pan,
    required this.scale,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Düz tuval ise arka plan rengiyle doldur
    final bgColor = isDark ? const Color(0xFF090D16) : const Color(0xFFF8FAFC);
    canvas.drawRect(Offset.zero & size, Paint()..color = bgColor);

    if (pattern == CanvasBackgroundPattern.plain) return;

    final primaryLineColor = isDark
        ? Colors.white.withValues(alpha: 0.07)
        : const Color(0xFF0F172A).withValues(alpha: 0.08);

    final gridSpacing = 40.0 * scale;
    if (gridSpacing < 10) return; // Aşırı küçükse çizme

    final startX = pan.dx % gridSpacing;
    final startY = pan.dy % gridSpacing;

    switch (pattern) {
      case CanvasBackgroundPattern.grid:
        final linePaint = Paint()
          ..color = primaryLineColor
          ..strokeWidth = 1.0;

        for (double x = startX; x <= size.width; x += gridSpacing) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
        }
        for (double y = startY; y <= size.height; y += gridSpacing) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
        }
        break;

      case CanvasBackgroundPattern.ruled:
        final linePaint = Paint()
          ..color = primaryLineColor
          ..strokeWidth = 1.0;

        for (double y = startY; y <= size.height; y += gridSpacing) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
        }
        break;

      case CanvasBackgroundPattern.dots:
        final dotPaint = Paint()
          ..color = primaryLineColor
          ..style = PaintingStyle.fill;

        final dotRadius = (1.5 * scale).clamp(1.0, 3.0);
        for (double x = startX; x <= size.width; x += gridSpacing) {
          for (double y = startY; y <= size.height; y += gridSpacing) {
            canvas.drawCircle(Offset(x, y), dotRadius, dotPaint);
          }
        }
        break;

      case CanvasBackgroundPattern.plain:
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CanvasBackgroundPainter oldDelegate) {
    return oldDelegate.pattern != pattern ||
        oldDelegate.pan != pan ||
        oldDelegate.scale != scale ||
        oldDelegate.isDark != isDark;
  }
}
