import 'package:flutter/material.dart'; // Material Design ve CustomPainter için gerekli Flutter paketi.

/// Rotiva özel vektörel logosu.
/// Harici görsel veya SVG dosyasına ihtiyaç duymadan, Flutter'ın Canvas ve CustomPainter
/// mekanizmasıyla doğrudan piksel bağımsız (vektörel) olarak çizilir.
/// Yuvarlatılmış kare içinde kesintisiz bir yol eğrisine dönüşen stilize 'R' harfi ve konum pini içerir.
class RotivaLogo extends StatelessWidget {
  final double size; // Logonun genişlik ve yükseklik boyutu (kare)
  final bool
  showText; // Logonun altında 'ROTIVA' marka adının yazılıp yazılmayacağı
  final bool showSubtitle; // 'Araç Kiralama ve Takip' sloganının gösterilip gösterilmeyeceği
  final Color? color; // Logoya özel bir renk verilmek istenirse (varsayılan: tema birincil rengi)

  const RotivaLogo({
    super.key,
    this.size = 64,
    this.showText = false,
    this.showSubtitle = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Aktif temayı alıyoruz.
    final primaryColor =
        color ??
        theme
            .colorScheme
            .primary; // Varsa verilen rengi, yoksa tema rengini alıyoruz.

    // CustomPaint widget'ı özel 2D çizim (Canvas) yapmamızı sağlar
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

    // Eğer marka adı istenmiyorsa sadece çizilen logo ikonunu döndürür
    if (!showText) {
      return icon;
    }

    // Karşılama ekranında olduğu gibi logo + yazı + slogan isteniyorsa sütun içinde dizilir
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(height: 12),
        // Büyük 'ROTIVA' marka başlığı
        Text(
          'ROTIVA',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 3.5, // Harfler arası geniş açıklık
            color: theme.colorScheme.onSurface,
          ),
        ),
        if (showSubtitle) ...[
          const SizedBox(height: 4),
          // Alt açıklama sloganı
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

/// Logonun piksel piksel matematiksel eğrilerle çizimini yapan CustomPainter sınıfı.
class _RotivaLogoPainter extends CustomPainter {
  final Color primaryColor; // Ana çizgi rengi
  final Color accentColor; // Gradyan arka plan vurgusu
  final bool isDark; // Koyu temaya uygun çizim ayarı

  _RotivaLogoPainter({
    required this.primaryColor,
    required this.accentColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width; // Tuvalin genişliği
    final h = size.height; // Tuvalin yüksekliği

    // 1. Yuvarlatılmış Dış Kutu (Arka Plan Rozeti)
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      Radius.circular(
        w * 0.24,
      ), // Genişliğin %24'ü oranında yuvarlatılmış köşeler
    );

    // Arka plan gradyan fırçası (LinearGradient)
    final bgPaint = Paint()
      ..shader = LinearGradient(
        colors: isDark
            ? [const Color(0xFF232A34), const Color(0xFF161B22)]
            : [primaryColor.withOpacity(0.12), accentColor.withOpacity(0.24)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawRRect(rrect, bgPaint); // Arka plan kutusunu tuvale çiziyoruz

    // Kutu Kenar Çizgisi (İnce ve şık sınır)
    final borderPaint = Paint()
      ..color = primaryColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.03;
    canvas.drawRRect(rrect, borderPaint);

    // 2. Stilize 'R' ve Yol Eğrisi Çizimi
    final roadPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle
          .stroke // Dolgu değil sadece çizgi çiziyoruz
      ..strokeCap = StrokeCap
          .round // Çizgi uçlarını yuvarlak yapıyoruz
      ..strokeJoin = StrokeJoin
          .round // Köşe birleşimlerini yumuşatıyoruz
      ..strokeWidth = w * 0.09;

    // Dikey sol direk (R harfinin sol bacağı)
    final stemPath = Path()
      ..moveTo(w * 0.30, h * 0.74)
      ..lineTo(w * 0.30, h * 0.28);
    canvas.drawPath(stemPath, roadPaint);

    // R üst yuvarlağı ve yola dönüşen dinamik sağ bacak (Bézier eğrileri - cubicTo)
    final curvePath = Path()
      ..moveTo(w * 0.30, h * 0.28)
      ..cubicTo(
        w * 0.65,
        h * 0.24, // Üst eğim tepe noktası
        w * 0.72,
        h * 0.44, // Sağ dönüş noktası
        w * 0.36,
        h * 0.48, // R harfinin göbeğine geri dönüş
      )
      // Kesintisiz otoban yoluna uzanan alt eğri (Highway Ribbon)
      ..cubicTo(
        w * 0.52,
        h * 0.50,
        w * 0.62,
        h * 0.66,
        w * 0.74,
        h * 0.72, // Hedefe giden yol bitişi
      );
    canvas.drawPath(curvePath, roadPaint);

    // 3. Yol Şeridi (İç beyaz/açık kesikli yol detayı)
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

    // Nokta içi parlama (Beyaz minik merkez)
    final dotCenterPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.74, h * 0.72), w * 0.025, dotCenterPaint);
  }

  // Renk veya tema değiştiğinde tuvalin yeniden çizilip çizilmeyeceğini belirler
  @override
  bool shouldRepaint(covariant _RotivaLogoPainter oldDelegate) {
    return oldDelegate.primaryColor != primaryColor ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.isDark != isDark;
  }
}
