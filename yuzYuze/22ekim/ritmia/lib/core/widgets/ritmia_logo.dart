import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Ritmia modern vektörel logosu:
/// Sürekli ritim akışını simgeleyen dinamik dalga, yükselen ivme alevi ve
/// temaya uyumlu gradient ışıltısı.
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
        painter: _RitmiaModernLogoPainter(
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
            fontSize: size * 0.42,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
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

class _RitmiaModernLogoPainter extends CustomPainter {
  final Color primaryColor;
  final Color sparkColor;
  final bool isDark;

  _RitmiaModernLogoPainter({
    required this.primaryColor,
    required this.sparkColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    // 1. Arka Plan Squircle (Yumuşak Işıltılı Kart)
    final bgRRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: w * 0.94, height: h * 0.94),
      Radius.circular(w * 0.28),
    );

    final bgGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        primaryColor.withValues(alpha: isDark ? 0.25 : 0.16),
        primaryColor.withValues(alpha: isDark ? 0.08 : 0.04),
      ],
    );

    final bgPaint = Paint()
      ..shader = bgGradient.createShader(bgRRect.outerRect)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(bgRRect, bgPaint);

    // İnce squircle kenarlık
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.03
      ..color = primaryColor.withValues(alpha: isDark ? 0.35 : 0.25);
    canvas.drawRRect(bgRRect, borderPaint);

    // 2. Dinamik "R" ve Ritim Nabız Dalgaları (Pulse Flow Wave)
    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.09
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [
          primaryColor,
          sparkColor,
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final wavePath = Path();
    // Sol alt ritim başlangıcı
    wavePath.moveTo(w * 0.26, h * 0.68);
    // İlk yükselen tepe
    wavePath.cubicTo(
      w * 0.30, h * 0.38,
      w * 0.42, h * 0.32,
      w * 0.50, h * 0.52,
    );
    // İkinci zirve ve kavis
    wavePath.cubicTo(
      w * 0.56, h * 0.68,
      w * 0.68, h * 0.64,
      w * 0.74, h * 0.38,
    );

    canvas.drawPath(wavePath, wavePaint);

    // 3. İç Ritim Halka / Çember Vurgusu
    final circlePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.05
      ..color = primaryColor.withValues(alpha: 0.45);

    canvas.drawCircle(Offset(w * 0.36, h * 0.42), w * 0.08, circlePaint);

    // 4. Yükselen İvme Kıvılcımı (Ascending Momentum Spark)
    final sparkCenter = Offset(w * 0.74, h * 0.32);
    final sparkPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = sparkColor;

    canvas.drawCircle(sparkCenter, w * 0.09, sparkPaint);

    // Kıvılcım ışıltı halkası
    final sparkHalo = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.025
      ..color = sparkColor.withValues(alpha: 0.5);

    canvas.drawCircle(sparkCenter, w * 0.13, sparkHalo);
  }

  @override
  bool shouldRepaint(covariant _RitmiaModernLogoPainter oldDelegate) {
    return oldDelegate.primaryColor != primaryColor ||
        oldDelegate.sparkColor != sparkColor ||
        oldDelegate.isDark != isDark;
  }
}
