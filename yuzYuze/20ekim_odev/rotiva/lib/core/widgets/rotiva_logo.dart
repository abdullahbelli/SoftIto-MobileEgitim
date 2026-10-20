import 'package:flutter/material.dart';

/// Rotiva özel vektörel logosu.
/// Yuvarlatılmış kare içinde kesintisiz bir yol eğrisine dönüşen stilize 'R' harfi ve konum pini.
class RotivaLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool showSubtitle;
  final Color? color;

  const RotivaLogo({
    super.key,
    this.size = 64,
    this.showText = false,
    this.showSubtitle = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = color ?? theme.colorScheme.primary;

    Widget icon = SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RotivaLogoPainter(
          primaryColor: primaryColor,
          accentColor: theme.colorScheme.secondary,
          isDark: theme.brightness == Brightness.dark,
        ),
      ),
    );

    if (!showText) {
      return icon;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(height: 12),
        Text(
          'ROTIVA',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 3.5,
            color: theme.colorScheme.onSurface,
          ),
        ),
        if (showSubtitle) ...[
          const SizedBox(height: 4),
          Text(
            'Araç Kiralama ve Takip',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ],
    );
  }
}

class _RotivaLogoPainter extends CustomPainter {
  final Color primaryColor;
  final Color accentColor;
  final bool isDark;

  _RotivaLogoPainter({
    required this.primaryColor,
    required this.accentColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Yuvarlatılmış Dış Kutu (Arka Plan Rozeti)
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      Radius.circular(w * 0.24),
    );

    final bgPaint = Paint()
      ..shader = LinearGradient(
        colors: isDark
            ? [const Color(0xFF232A34), const Color(0xFF161B22)]
            : [primaryColor.withOpacity(0.12), accentColor.withOpacity(0.24)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawRRect(rrect, bgPaint);

    // Kutu Kenar Çizgisi
    final borderPaint = Paint()
      ..color = primaryColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.03;
    canvas.drawRRect(rrect, borderPaint);

    // 2. Stilize 'R' ve Yol Eğrisi Çizimi
    final roadPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = w * 0.09;

    // Dikey sol direk (R gövdesi)
    final stemPath = Path()
      ..moveTo(w * 0.30, h * 0.74)
      ..lineTo(w * 0.30, h * 0.28);
    canvas.drawPath(stemPath, roadPaint);

    // R üst yuvarlağı ve yola dönüşen dinamik sağ bacak
    final curvePath = Path()
      ..moveTo(w * 0.30, h * 0.28)
      ..cubicTo(
        w * 0.65,
        h * 0.24, // Üst eğim
        w * 0.72,
        h * 0.44, // Sağ dönüş
        w * 0.36,
        h * 0.48, // R göbeğine dönüş
      )
      // Kesintisiz otoban yoluna uzanan alt eğri (Highway Ribbon)
      ..cubicTo(
        w * 0.52,
        h * 0.50,
        w * 0.62,
        h * 0.66,
        w * 0.74,
        h * 0.72, // Hedefe giden yol
      );
    canvas.drawPath(curvePath, roadPaint);

    // 3. Yol Şeridi (İç beyaz/açık kesikli detay)
    final stripePaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = w * 0.025;

    final stripePath = Path()
      ..moveTo(w * 0.38, h * 0.36)
      ..cubicTo(w * 0.58, h * 0.34, w * 0.58, h * 0.44, w * 0.44, h * 0.46)
      ..cubicTo(w * 0.54, h * 0.52, w * 0.60, h * 0.64, w * 0.68, h * 0.68);
    canvas.drawPath(stripePath, stripePaint);

    // 4. Konum İğnesi / Hedef Bitiş Noktası (Pin Dot)
    final pinPaint = Paint()
      ..color = isDark ? const Color(0xFFFF922B) : const Color(0xFF0288D1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.74, h * 0.72), w * 0.065, pinPaint);

    // Nokta içi parlama
    final dotCenterPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.74, h * 0.72), w * 0.025, dotCenterPaint);
  }

  @override
  bool shouldRepaint(covariant _RotivaLogoPainter oldDelegate) {
    return oldDelegate.primaryColor != primaryColor ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.isDark != isDark;
  }
}
