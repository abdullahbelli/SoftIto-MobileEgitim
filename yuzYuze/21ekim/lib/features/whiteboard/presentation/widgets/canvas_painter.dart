import 'dart:math'; // Ok ucu açıları (atan2, cos, sin, pi) için matematik kütüphanesini içe aktarır.

import 'package:flutter/material.dart'; // Flutter 2D Canvas çizim nesneleri (Canvas, Paint, Path, TextPainter vb.) için içe aktarır.

import '../../domain/board_object.dart'; // Tahta nesnelerini (Stroke, Shape, Text, StickyNote, Image) içe aktarır.
import '../../domain/participant.dart'; // Canlı katılımcı modelini içe aktarır.

/// Sonsuz Tuval Nesneleri ve Katılımcı Çizicisi (CanvasPainter)
/// 'CustomPainter' sınıfından türer ve dünya koordinatlarındaki tüm nesneleri,
/// pan/zoom dönüşümlerini uygulayarak ekrana piksel piksel işler.
class CanvasPainter extends CustomPainter {
  final List<BoardObject> objects; // Tuvaldeki kalıcı çizim nesneleri listesi.
  final BoardObject? currentDrawing; // Kullanıcının o an parmağını kaldırmadan çizmekte olduğu geçici nesne.
  final String? selectedObjectId; // Kullanıcının seçtiği nesnenin kimliği (seçim kutusu için).
  final Offset pan; // Tuvalin dünya koordinatlarındaki kayma (pan) ofseti.
  final double scale; // Tuvalin mevcut yakınlaştırma (zoom) ölçeği.
  final List<WhiteboardParticipant>
  participants; // Odadaki diğer canlı kullanıcıların listesi.
  final bool isDark; // Temanın koyu modda olup olmadığı.

  const CanvasPainter({
    required this.objects,
    this.currentDrawing,
    this.selectedObjectId,
    required this.pan,
    required this.scale,
    this.participants = const [],
    required this.isDark,
  });

  @override // Tuvalin çizildiği ana metot (Lifecycle: paint).
  void paint(Canvas canvas, Size size) {
    canvas.save(); // Çizim matrisinin mevcut durumunu hafızaya kaydeder.

    // Dünya koordinatlarına geçiş dönüşümleri:
    // Tuvali kaydırma (pan) miktarı kadar öteler.
    canvas.translate(pan.dx, pan.dy);
    // Tuvali yakınlaştırma (zoom) katsayısı kadar ölçekler.
    canvas.scale(scale);

    // 1. Adım: Kayıtlı tüm kalıcı tuval nesnelerini sırayla çizer.
    for (final obj in objects) {
      _drawObject(canvas, obj);
    }

    // 2. Adım: Eğer şu an aktif bir çizim yapılıyorsa onu da tuvale yansıtır.
    if (currentDrawing != null) {
      _drawObject(canvas, currentDrawing!);
    }

    // 3. Adım: Kullanıcının seçtiği bir nesne varsa etrafına sarı/kırmızı seçim kutusu ve tutamaçlar çizer.
    if (selectedObjectId != null) {
      for (final obj in objects) {
        if (obj.id == selectedObjectId) {
          _drawSelectionBox(canvas, obj.getBounds(), obj.isPinned);
          break;
        }
      }
    }

    // 4. Adım: Odadaki diğer katılımcıların canlı fare/kalem imleçlerini ve isim rozetlerini çizer.
    for (final participant in participants) {
      _drawParticipant(canvas, participant);
    }

    canvas.restore(); // Matrisi orijinal durumuna geri döndürür (tuval dışındaki çizimleri etkilemez).
  }

  // Nesne tipine göre ilgili özel çizim fonksiyonuna yönlendiren dallanma metodu.
  void _drawObject(Canvas canvas, BoardObject obj) {
    if (obj is StrokeObject) {
      _drawStroke(canvas, obj);
    } else if (obj is ShapeObject) {
      _drawShape(canvas, obj);
    } else if (obj is StickyNoteObject) {
      _drawStickyNote(canvas, obj);
    } else if (obj is TextObject) {
      _drawText(canvas, obj);
    } else if (obj is ImageObject) {
      _drawImage(canvas, obj);
    }
  }

  // Serbest çizimleri (kalem vuruşlarını) çizen fonksiyon.
  void _drawStroke(Canvas canvas, StrokeObject stroke) {
    if (stroke.points.isEmpty) return;

    // Fırça boyama özellikleri.
    final paint = Paint()
      ..color = stroke.color
      ..strokeWidth = stroke.strokeWidth
      ..strokeCap = StrokeCap
          .round // Çizgi uçlarını yuvarlak yapar (doğal kalem hissi).
      ..strokeJoin = StrokeJoin
          .round // Çizgi kırılımlarını yumuşatır.
      ..style = PaintingStyle.stroke;

    // Tek bir noktaya dokunulmuşsa nokta (daire) çizer.
    if (stroke.points.length == 1) {
      canvas.drawCircle(stroke.points.first, stroke.strokeWidth / 2, paint);
      return;
    }

    // Noktalar zincirini birleştiren vektörel bir yol (Path) oluşturur.
    final path = Path()..moveTo(stroke.points.first.dx, stroke.points.first.dy);
    for (int i = 1; i < stroke.points.length; i++) {
      path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
    }
    canvas.drawPath(path, paint); // Yolu tuvale fırçayla döker.
  }

  // Geometrik şekilleri (dikdörtgen, elips, çizgi, ok) çizen fonksiyon.
  void _drawShape(Canvas canvas, ShapeObject shape) {
    // Şeklin dış kontur boyası.
    final strokePaint = Paint()
      ..color = shape.strokeColor
      ..strokeWidth = shape.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Varsa şeklin iç dolgu boyası.
    final fillPaint = shape.isFilled && shape.fillColor != null
        ? (Paint()
            ..color = shape.fillColor!
            ..style = PaintingStyle.fill)
        : null;

    final rect = shape.bounds;

    switch (shape.type) {
      case 'rectangle':
        // 8 piksel yuvarlatılmış köşeli dikdörtgen çizer.
        final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
        if (fillPaint != null) canvas.drawRRect(rrect, fillPaint);
        canvas.drawRRect(rrect, strokePaint);
        break;

      case 'ellipse':
        // Elips / çember çizer.
        if (fillPaint != null) canvas.drawOval(rect, fillPaint);
        canvas.drawOval(rect, strokePaint);
        break;

      case 'line':
        // Düz çizgi çizer.
        canvas.drawLine(rect.topLeft, rect.bottomRight, strokePaint);
        break;

      case 'arrow':
        // Ucu oklu çizgi çizer.
        _drawArrow(canvas, rect.topLeft, rect.bottomRight, strokePaint);
        break;
    }
  }

  // Doğru parçasının bitiş noktasına matematiksel olarak yönlü ok ucu çizen yardımcı fonksiyon.
  void _drawArrow(Canvas canvas, Offset start, Offset end, Paint paint) {
    canvas.drawLine(start, end, paint); // Gövde çizgisini çizer.

    // Bitiş noktasının açısını (radyan) hesaplar.
    final angle = atan2(end.dy - start.dy, end.dx - start.dx);
    // Ok ucu kanat uzunluğunu çizgi kalınlığına göre oranlar (14 ile 28 piksel arası).
    final arrowLength = (paint.strokeWidth * 4.5).clamp(14.0, 28.0);
    const arrowAngle = pi / 6; // 30 derecelik ok kanat açısı.

    // Ok ucunun iki kanadını çizen vektörel yol.
    final path = Path();
    path.moveTo(end.dx, end.dy);
    // Sol kanat
    path.lineTo(
      end.dx - arrowLength * cos(angle - arrowAngle),
      end.dy - arrowLength * sin(angle - arrowAngle),
    );
    path.moveTo(end.dx, end.dy);
    // Sağ kanat
    path.lineTo(
      end.dx - arrowLength * cos(angle + arrowAngle),
      end.dy - arrowLength * sin(angle + arrowAngle),
    );
    canvas.drawPath(path, paint);
  }

  // Post-it (yapışkan not) bileşenini gölgesi ve metniyle birlikte çizen fonksiyon.
  void _drawStickyNote(Canvas canvas, StickyNoteObject note) {
    final rect = note.bounds;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(10));

    // 1. Gerçekçi derinlik katan bulanık gölge çizimi.
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawRRect(rrect.shift(const Offset(2, 4)), shadowPaint);

    // 2. Post-it sarı/renkli zemin dolgusu.
    final bgPaint = Paint()
      ..color = note.noteColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, bgPaint);

    // 3. Çok hafif koyu dış sınır çizgisi.
    final borderPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(rrect, borderPaint);

    // 4. Not Metninin TextPainter ile yerleşimi ve çizimi.
    final textPainter = TextPainter(
      text: TextSpan(
        text: note.text.isEmpty ? 'Bir not yazın...' : note.text,
        style: TextStyle(
          color: note.text.isEmpty ? Colors.black38 : const Color(0xFF0F172A),
          fontSize: 14,
          fontFamily: 'Roboto',
          height: 1.3,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 8, // En fazla 8 satır.
      ellipsis: '...', // Taşarsa üç nokta koy.
    );
    textPainter.layout(
      maxWidth: rect.width - 24,
    ); // Kenarlardan 12'şer piksel iç boşluk bırakır.
    textPainter.paint(canvas, Offset(rect.left + 12, rect.top + 16));

    // 5. Notu oluşturan yazarın adını sağ alta italik olarak çizer.
    if (note.authorName.isNotEmpty) {
      final authorPainter = TextPainter(
        text: TextSpan(
          text: '— ${note.authorName}',
          style: TextStyle(
            color: Colors.black.withValues(alpha: 0.45),
            fontSize: 11,
            fontStyle: FontStyle.italic,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      authorPainter.layout(maxWidth: rect.width - 24);
      authorPainter.paint(
        canvas,
        Offset(rect.right - authorPainter.width - 12, rect.bottom - 20),
      );
    }
  }

  // Bağımsız metin nesnelerini çizen fonksiyon.
  void _drawText(Canvas canvas, TextObject textObj) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: textObj.text.isEmpty ? 'Metin girin...' : textObj.text,
        style: TextStyle(
          color: textObj.color,
          fontSize: textObj.fontSize,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: textObj.width);
    textPainter.paint(canvas, textObj.position);
  }

  // Görsel yer tutucu kutusunu ve etiketini çizen fonksiyon.
  void _drawImage(Canvas canvas, ImageObject img) {
    final rect = img.bounds;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));

    // Görsel zemin arka planı
    final bgPaint = Paint()
      ..color = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, bgPaint);

    // Çerçeve konturu
    final borderPaint = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.4)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(rrect, borderPaint);

    // Resim ikonu ve etiket yazısı
    final textPainter = TextPainter(
      text: TextSpan(
        text: '🖼 ${img.label}',
        style: TextStyle(
          color: isDark ? Colors.white70 : const Color(0xFF0F172A),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: rect.width - 20);
    // Metni kutunun tam ortasına hizalar.
    textPainter.paint(
      canvas,
      Offset(
        rect.center.dx - textPainter.width / 2,
        rect.center.dy - textPainter.height / 2,
      ),
    );
  }

  // Seçilen nesnenin etrafındaki seçim kutusunu ve 4 köşe tutamacını çizen yardımcı fonksiyon.
  void _drawSelectionBox(Canvas canvas, Rect bounds, bool isPinned) {
    final inflated = bounds.inflate(
      6,
    ); // Nesneden 6 piksel dışarı taşan çerçeve.
    // Nesne sabitlenmişse (kilitliyse) kırmızı, serbestse tema sarısı renkte çizer.
    final selectionPaint = Paint()
      ..color = isPinned ? Colors.redAccent : const Color(0xFFF59E0B)
      ..strokeWidth =
          2.0 /
          scale // Yakınlaştırmadan bağımsız sabit piksel kalınlığı sağlar.
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(
      RRect.fromRectAndRadius(inflated, Radius.circular(6 / scale)),
      selectionPaint,
    );

    // Köşelerdeki minik yuvarlak tutamaçlar
    final handlePaint = Paint()
      ..color = isPinned ? Colors.redAccent : const Color(0xFFF59E0B)
      ..style = PaintingStyle.fill;

    final handleRadius = 4.5 / scale;
    canvas.drawCircle(inflated.topLeft, handleRadius, handlePaint); // Sol üst
    canvas.drawCircle(inflated.topRight, handleRadius, handlePaint); // Sağ üst
    canvas.drawCircle(
      inflated.bottomLeft,
      handleRadius,
      handlePaint,
    ); // Sol alt
    canvas.drawCircle(
      inflated.bottomRight,
      handleRadius,
      handlePaint,
    ); // Sağ alt
  }

  // Diğer katılımcıların canlı imleçlerini ve kullanıcı isim etiketlerini çizen fonksiyon.
  void _drawParticipant(Canvas canvas, WhiteboardParticipant participant) {
    final pos =
        participant.worldPosition; // İmlecin dünya koordinatındaki konumu.
    final color = participant.color; // Katılımcıya ait renk.

    // İmleç boyası.
    final cursorPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Gerçekçi fare oku şekli çizen vektörel yol (Path).
    final path = Path()
      ..moveTo(pos.dx, pos.dy)
      ..lineTo(pos.dx + 16, pos.dy + 8)
      ..lineTo(pos.dx + 10, pos.dy + 12)
      ..lineTo(pos.dx + 14, pos.dy + 20)
      ..lineTo(pos.dx + 10, pos.dy + 22)
      ..lineTo(pos.dx + 6, pos.dy + 14)
      ..lineTo(pos.dx, pos.dy + 18)
      ..close();
    canvas.drawPath(path, cursorPaint);

    // Katılımcının Adının yazıldığı metin.
    final textPainter = TextPainter(
      text: TextSpan(
        text: participant.name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // İsmin arkasındaki renkli rozet kutucuğu.
    final badgeRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        pos.dx + 18,
        pos.dy + 12,
        textPainter.width + 12,
        textPainter.height + 6,
      ),
      const Radius.circular(6),
    );

    canvas.drawRRect(badgeRect, cursorPaint); // Rozet kutusunu boyar.
    textPainter.paint(
      canvas,
      Offset(pos.dx + 24, pos.dy + 15),
    ); // İsmi kutunun içine yazar.
  }

  @override // Tuval etkileşimli ve animasyonlu olduğu için sürekli güncel veriyi çizer.
  bool shouldRepaint(covariant CanvasPainter oldDelegate) {
    return true;
  }
}
