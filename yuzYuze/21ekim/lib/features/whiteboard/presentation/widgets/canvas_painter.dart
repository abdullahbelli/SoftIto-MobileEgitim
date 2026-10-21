import 'dart:math';

import 'package:flutter/material.dart';

import '../../domain/board_object.dart';
import '../../domain/participant.dart';

/// Sonsuz Tuval Nesneleri ve Katılımcı Çizicisi
class CanvasPainter extends CustomPainter {
  final List<BoardObject> objects;
  final BoardObject? currentDrawing;
  final String? selectedObjectId;
  final Offset pan;
  final double scale;
  final List<WhiteboardParticipant> participants;
  final bool isDark;

  const CanvasPainter({
    required this.objects,
    this.currentDrawing,
    this.selectedObjectId,
    required this.pan,
    required this.scale,
    this.participants = const [],
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    // Dünya koordinatlarına geçiş
    canvas.translate(pan.dx, pan.dy);
    canvas.scale(scale);

    // 1. Kalıcı nesneleri çiz
    for (final obj in objects) {
      _drawObject(canvas, obj);
    }

    // 2. Aktif çizilmekte olan nesneyi çiz
    if (currentDrawing != null) {
      _drawObject(canvas, currentDrawing!);
    }

    // 3. Seçili nesne sınır kutusu ve tutamaçları
    if (selectedObjectId != null) {
      for (final obj in objects) {
        if (obj.id == selectedObjectId) {
          _drawSelectionBox(canvas, obj.getBounds(), obj.isPinned);
          break;
        }
      }
    }

    // 4. Katılımcıların canlı konum etiketleri ve imleçleri
    for (final participant in participants) {
      _drawParticipant(canvas, participant);
    }

    canvas.restore();
  }

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

  void _drawStroke(Canvas canvas, StrokeObject stroke) {
    if (stroke.points.isEmpty) return;

    final paint = Paint()
      ..color = stroke.color
      ..strokeWidth = stroke.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    if (stroke.points.length == 1) {
      canvas.drawCircle(stroke.points.first, stroke.strokeWidth / 2, paint);
      return;
    }

    final path = Path()..moveTo(stroke.points.first.dx, stroke.points.first.dy);
    for (int i = 1; i < stroke.points.length; i++) {
      path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  void _drawShape(Canvas canvas, ShapeObject shape) {
    final strokePaint = Paint()
      ..color = shape.strokeColor
      ..strokeWidth = shape.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final fillPaint = shape.isFilled && shape.fillColor != null
        ? (Paint()
            ..color = shape.fillColor!
            ..style = PaintingStyle.fill)
        : null;

    final rect = shape.bounds;

    switch (shape.type) {
      case 'rectangle':
        final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
        if (fillPaint != null) canvas.drawRRect(rrect, fillPaint);
        canvas.drawRRect(rrect, strokePaint);
        break;

      case 'ellipse':
        if (fillPaint != null) canvas.drawOval(rect, fillPaint);
        canvas.drawOval(rect, strokePaint);
        break;

      case 'line':
        canvas.drawLine(rect.topLeft, rect.bottomRight, strokePaint);
        break;

      case 'arrow':
        _drawArrow(canvas, rect.topLeft, rect.bottomRight, strokePaint);
        break;
    }
  }

  void _drawArrow(Canvas canvas, Offset start, Offset end, Paint paint) {
    canvas.drawLine(start, end, paint);

    final angle = atan2(end.dy - start.dy, end.dx - start.dx);
    final arrowLength = (paint.strokeWidth * 4.5).clamp(14.0, 28.0);
    const arrowAngle = pi / 6;

    final path = Path();
    path.moveTo(end.dx, end.dy);
    path.lineTo(
      end.dx - arrowLength * cos(angle - arrowAngle),
      end.dy - arrowLength * sin(angle - arrowAngle),
    );
    path.moveTo(end.dx, end.dy);
    path.lineTo(
      end.dx - arrowLength * cos(angle + arrowAngle),
      end.dy - arrowLength * sin(angle + arrowAngle),
    );
    canvas.drawPath(path, paint);
  }

  void _drawStickyNote(Canvas canvas, StickyNoteObject note) {
    final rect = note.bounds;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(10));

    // Post-it gölgesi
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawRRect(rrect.shift(const Offset(2, 4)), shadowPaint);

    // Arka plan rengi
    final bgPaint = Paint()
      ..color = note.noteColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, bgPaint);

    // Kenarlık
    final borderPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(rrect, borderPaint);

    // Not Metni
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
      maxLines: 8,
      ellipsis: '...',
    );
    textPainter.layout(maxWidth: rect.width - 24);
    textPainter.paint(canvas, Offset(rect.left + 12, rect.top + 16));

    // Yazar adı alt etiketi
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

  void _drawImage(Canvas canvas, ImageObject img) {
    final rect = img.bounds;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));

    // Çerçeve
    final bgPaint = Paint()
      ..color = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, bgPaint);

    final borderPaint = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.4)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(rrect, borderPaint);

    // Resim simgesi ve etiket
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
    textPainter.paint(
      canvas,
      Offset(
        rect.center.dx - textPainter.width / 2,
        rect.center.dy - textPainter.height / 2,
      ),
    );
  }

  void _drawSelectionBox(Canvas canvas, Rect bounds, bool isPinned) {
    final inflated = bounds.inflate(6);
    final selectionPaint = Paint()
      ..color = isPinned ? Colors.redAccent : const Color(0xFFF59E0B)
      ..strokeWidth = 2.0 / scale
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(
      RRect.fromRectAndRadius(inflated, Radius.circular(6 / scale)),
      selectionPaint,
    );

    // Köşe tutamaçları
    final handlePaint = Paint()
      ..color = isPinned ? Colors.redAccent : const Color(0xFFF59E0B)
      ..style = PaintingStyle.fill;

    final handleRadius = 4.5 / scale;
    canvas.drawCircle(inflated.topLeft, handleRadius, handlePaint);
    canvas.drawCircle(inflated.topRight, handleRadius, handlePaint);
    canvas.drawCircle(inflated.bottomLeft, handleRadius, handlePaint);
    canvas.drawCircle(inflated.bottomRight, handleRadius, handlePaint);
  }

  void _drawParticipant(Canvas canvas, WhiteboardParticipant participant) {
    final pos = participant.worldPosition;
    final color = participant.color;

    // İmleç Noktası
    final cursorPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // İmleç Oku
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

    // Katılımcı İsim Rozeti (Kendi renginde arka plan)
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

    final badgeRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        pos.dx + 18,
        pos.dy + 12,
        textPainter.width + 12,
        textPainter.height + 6,
      ),
      const Radius.circular(6),
    );

    canvas.drawRRect(badgeRect, cursorPaint);
    textPainter.paint(canvas, Offset(pos.dx + 24, pos.dy + 15));
  }

  @override
  bool shouldRepaint(covariant CanvasPainter oldDelegate) {
    return true;
  }
}
