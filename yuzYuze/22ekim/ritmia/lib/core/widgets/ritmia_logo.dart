import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Ritmia vektörel logosu: Dairesel ritim halkası, içinde filiz ve yükselen kıvılcım.
/// CustomPainter ile çizilerek her çözünürlükte keskin ve canlı görünür.
class RitmiaLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool showSlogan;
  final Color? color;

  const RitmiaLogo({
    super.key,
    this.size = 64,
    this.showText = false,
    this.showSlogan = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = color ?? Theme.of(context).colorScheme.primary;

    final logoWidget = SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RitmiaLogoPainter(
          primaryColor: primaryColor,
          sparkColor: AppColors.flameOrange,
          isDark: isDark,
        ),
      ),
    );

    if (!showText) return logoWidget;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        logoWidget,
        const SizedBox(height: 12),
        Text(
          'Ritmia',
          style: TextStyle(
            fontSize: size * 0.45,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        if (showSlogan) ...[
          const SizedBox(height: 4),
          Text(
            'Küçük adımlar, güçlü alışkanlıklar.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class _RitmiaLogoPainter extends CustomPainter {
  final Color primaryColor;
  final Color sparkColor;
  final bool isDark;

  _RitmiaLogoPainter({
    required this.primaryColor,
    required this.sparkColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. Dış Ritim Halkası (Geniş açı çizimi)
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.1
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: 0.0,
        endAngle: math.pi * 2,
        colors: [
          primaryColor.withValues(alpha: 0.25),
          primaryColor,
          sparkColor,
        ],
        stops: const [0.0, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.8),
      -math.pi * 0.8,
      math.pi * 1.6,
      false,
      ringPaint,
    );

    // 2. İç Filiz (Sprout leaf)
    final sproutPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = primaryColor;

    final leafPath = Path();
    final startP = Offset(center.dx, center.dy + radius * 0.45);
    final tipP = Offset(center.dx, center.dy - radius * 0.15);

    leafPath.moveTo(startP.dx, startP.dy);
    // Sol yaprak kıvrımı
    leafPath.quadraticBezierTo(
      center.dx - radius * 0.35,
      center.dy + radius * 0.15,
      tipP.dx,
      tipP.dy,
    );
    // Sağ yaprak kıvrımı
    leafPath.quadraticBezierTo(
      center.dx + radius * 0.35,
      center.dy + radius * 0.15,
      startP.dx,
      startP.dy,
    );
    leafPath.close();

    canvas.drawPath(leafPath, sproutPaint);

    // 3. Yükselen Kıvılcım (Ascending Spark / Flame dot)
    final sparkCenter = Offset(center.dx, center.dy - radius * 0.4);
    final sparkPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = sparkColor;

    canvas.drawCircle(sparkCenter, size.width * 0.09, sparkPaint);

    // Kıvılcım ışıltısı
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.03
      ..color = sparkColor.withValues(alpha: 0.4);

    canvas.drawCircle(sparkCenter, size.width * 0.13, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _RitmiaLogoPainter oldDelegate) {
    return oldDelegate.primaryColor != primaryColor ||
        oldDelegate.sparkColor != sparkColor ||
        oldDelegate.isDark != isDark;
  }
}
