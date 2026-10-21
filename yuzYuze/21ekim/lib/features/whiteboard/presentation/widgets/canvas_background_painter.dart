import 'package:flutter/material.dart'; // Flutter Material ve 2D Canvas çizim araçlarını içe aktarır.

import '../../domain/canvas_theme.dart'; // Tuval arka plan desen türlerini (CanvasBackgroundPattern) içe aktarır.

/// Tuval arka plan deseni çizicisi (CanvasBackgroundPainter)
/// 'CustomPainter' sınıfından türetilmiştir; sonsuz pan (kaydırma) ve zoom (yakınlaştırma) hareketlerine göre
/// kareli, çizgili veya noktalı arka plan kılavuzlarını ekrana yüksek performansla çizer.
class CanvasBackgroundPainter extends CustomPainter {
  final CanvasBackgroundPattern
  pattern; // Seçilen arka plan deseni (düz, kareli, çizgili, noktalı).
  final Offset pan; // Tuvalin dünya koordinatlarındaki kayma (pan) miktarı.
  final double scale; // Tuvalin mevcut yakınlaştırma (zoom) ölçeği.
  final bool
  isDark; // Temanın koyu modda olup olmadığı (çizgi renk kontrastı için).

  const CanvasBackgroundPainter({
    required this.pattern,
    required this.pan,
    required this.scale,
    required this.isDark,
  });

  @override // Tuvalin ekrana her çizilişinde çalışan ana çizim fonksiyonu (Lifecycle: paint).
  void paint(Canvas canvas, Size size) {
    // 1. Adım: Tüm tuval alanını tema moduna uygun arka plan rengiyle boyar.
    final bgColor = isDark ? const Color(0xFF090D16) : const Color(0xFFF8FAFC);
    canvas.drawRect(Offset.zero & size, Paint()..color = bgColor);

    // Eğer düz (desensiz) zemin seçilmişse başka bir çizgi çizmeden fonksiyondan çıkar.
    if (pattern == CanvasBackgroundPattern.plain) return;

    // Kılavuz çizgilerinin veya noktalarının rengi (göz yormayacak şekilde düşük opaklıkta seçilir).
    final primaryLineColor = isDark
        ? Colors.white.withValues(alpha: 0.07) // Koyu temada %7 saydam beyaz.
        : const Color(0xFF0F172A)
              .withValues(alpha: 0.08); // Açık temada %8 saydam lacivert.

    // Izgara aralığını yakınlaştırma katsayısıyla çarpar (zoom yapıldığında ızgara büyür/küçülür).
    final gridSpacing = 40.0 * scale;
    // Izgara aşırı küçüldüğünde ekranın karmaşıklaşmasını ve performans kaybını önler.
    if (gridSpacing < 10) return;

    // Modülo (kalan) operatörü ile kaydırma ofsetini ızgara aralığına göre hesaplar.
    // Bu sayede sonsuz tuvalde sadece ekranda görünen pikseller çizilerek bellek korunur.
    final startX = pan.dx % gridSpacing;
    final startY = pan.dy % gridSpacing;

    // Desene göre ilgili çizim döngüsünü çalıştırır.
    switch (pattern) {
      case CanvasBackgroundPattern.grid:
        // Kareli defter deseni: Hem dikey hem yatay paralel çizgiler çizer.
        final linePaint = Paint()
          ..color = primaryLineColor
          ..strokeWidth = 1.0;

        // Dikey çizgiler (yukarıdan aşağıya).
        for (double x = startX; x <= size.width; x += gridSpacing) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
        }
        // Yatay çizgiler (soldan sağa).
        for (double y = startY; y <= size.height; y += gridSpacing) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
        }
        break;

      case CanvasBackgroundPattern.ruled:
        // Çizgili defter deseni: Yalnızca yatay çizgiler çizer.
        final linePaint = Paint()
          ..color = primaryLineColor
          ..strokeWidth = 1.0;

        for (double y = startY; y <= size.height; y += gridSpacing) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
        }
        break;

      case CanvasBackgroundPattern.dots:
        // Noktalı defter deseni: Kesişim noktalarına minik daireler (noktalar) çizer.
        final dotPaint = Paint()
          ..color = primaryLineColor
          ..style = PaintingStyle.fill;

        // Nokta yarıçapını yakınlaştırma ölçeğine göre 1 ile 3 piksel arasında sınırlar.
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

  @override // Yeniden çizim kararı veren metot (Lifecycle: shouldRepaint).
  // Sadece desen, kayma miktarı, ölçek veya tema modu değiştiğinde yeniden çizer, gereksiz GPU yükünü önler.
  bool shouldRepaint(covariant CanvasBackgroundPainter oldDelegate) {
    return oldDelegate.pattern != pattern ||
        oldDelegate.pan != pan ||
        oldDelegate.scale != scale ||
        oldDelegate.isDark != isDark;
  }
}
