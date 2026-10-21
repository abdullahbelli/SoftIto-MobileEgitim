import 'dart:math';

import 'package:flutter/material.dart';

/// Tuval nesnesi temel soyut sınıfı
abstract class BoardObject {
  final String id;
  final String type;
  final bool isPinned;
  final int zIndex;
  final String createdBy;
  final DateTime createdAt;

  const BoardObject({
    required this.id,
    required this.type,
    this.isPinned = false,
    this.zIndex = 0,
    required this.createdBy,
    required this.createdAt,
  });

  /// Nesnenin dünya koordinatlarındaki sınır kutusu
  Rect getBounds();

  /// Verilen dünya koordinatındaki noktanın nesneye isabet edip etmediğini kontrol eder
  bool containsPoint(Offset point, {double hitSlop = 8.0});

  /// Nesneyi dünya koordinatlarında delta kadar öteler
  BoardObject movedBy(Offset delta);

  /// Sabitleme durumunu değiştirir
  BoardObject withPinned(bool pinned);

  Map<String, dynamic> toMap();

  static BoardObject fromMap(Map<String, dynamic> map) {
    final type = map['type'] as String? ?? 'stroke';
    switch (type) {
      case 'stroke':
        return StrokeObject.fromMap(map);
      case 'rectangle':
      case 'ellipse':
      case 'line':
      case 'arrow':
        return ShapeObject.fromMap(map);
      case 'text':
        return TextObject.fromMap(map);
      case 'sticky_note':
        return StickyNoteObject.fromMap(map);
      case 'image':
        return ImageObject.fromMap(map);
      default:
        return StrokeObject.fromMap(map);
    }
  }
}

/// Serbest çizim (Kalem) nesnesi
class StrokeObject extends BoardObject {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;

  const StrokeObject({
    required super.id,
    super.type = 'stroke',
    super.isPinned = false,
    super.zIndex = 0,
    required super.createdBy,
    required super.createdAt,
    required this.points,
    required this.color,
    this.strokeWidth = 3.0,
  });

  @override
  Rect getBounds() {
    if (points.isEmpty) return Rect.zero;
    double minX = points.first.dx;
    double maxX = points.first.dx;
    double minY = points.first.dy;
    double maxY = points.first.dy;

    for (final p in points) {
      if (p.dx < minX) minX = p.dx;
      if (p.dx > maxX) maxX = p.dx;
      if (p.dy < minY) minY = p.dy;
      if (p.dy > maxY) maxY = p.dy;
    }
    return Rect.fromLTRB(
      minX - strokeWidth,
      minY - strokeWidth,
      maxX + strokeWidth,
      maxY + strokeWidth,
    );
  }

  @override
  bool containsPoint(Offset point, {double hitSlop = 8.0}) {
    final bounds = getBounds().inflate(hitSlop);
    if (!bounds.contains(point)) return false;

    final threshold = (strokeWidth / 2) + hitSlop;
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      if (_distanceToSegment(point, p1, p2) <= threshold) {
        return true;
      }
    }
    return false;
  }

  double _distanceToSegment(Offset p, Offset v, Offset w) {
    final l2 = (v - w).distanceSquared;
    if (l2 == 0) return (p - v).distance;
    final t = max(
      0.0,
      min(1.0, ((p - v).dx * (w - v).dx + (p - v).dy * (w - v).dy) / l2),
    );
    final projection = v + (w - v) * t;
    return (p - projection).distance;
  }

  @override
  StrokeObject movedBy(Offset delta) {
    if (isPinned) return this;
    final newPoints = points.map((p) => p + delta).toList();
    return StrokeObject(
      id: id,
      type: type,
      isPinned: isPinned,
      zIndex: zIndex,
      createdBy: createdBy,
      createdAt: createdAt,
      points: newPoints,
      color: color,
      strokeWidth: strokeWidth,
    );
  }

  @override
  StrokeObject withPinned(bool pinned) {
    return StrokeObject(
      id: id,
      type: type,
      isPinned: pinned,
      zIndex: zIndex,
      createdBy: createdBy,
      createdAt: createdAt,
      points: points,
      color: color,
      strokeWidth: strokeWidth,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'isPinned': isPinned,
      'zIndex': zIndex,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'color': color.toARGB32(),
      'strokeWidth': strokeWidth,
      'points': points.map((p) => {'x': p.dx, 'y': p.dy}).toList(),
    };
  }

  factory StrokeObject.fromMap(Map<String, dynamic> map) {
    final pointsList = (map['points'] as List<dynamic>? ?? [])
        .map(
          (p) => Offset((p['x'] as num).toDouble(), (p['y'] as num).toDouble()),
        )
        .toList();

    return StrokeObject(
      id: map['id'] ?? '',
      isPinned: map['isPinned'] ?? false,
      zIndex: map['zIndex'] ?? 0,
      createdBy: map['createdBy'] ?? '',
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      points: pointsList,
      color: Color(map['color'] ?? 0xFF000000),
      strokeWidth: (map['strokeWidth'] as num?)?.toDouble() ?? 3.0,
    );
  }
}

/// Şekil (Dikdörtgen, Elips, Çizgi, Ok) nesnesi
class ShapeObject extends BoardObject {
  final Rect bounds;
  final Color strokeColor;
  final double strokeWidth;
  final bool isFilled;
  final Color? fillColor;

  const ShapeObject({
    required super.id,
    required super.type, // 'rectangle', 'ellipse', 'line', 'arrow'
    super.isPinned = false,
    super.zIndex = 0,
    required super.createdBy,
    required super.createdAt,
    required this.bounds,
    required this.strokeColor,
    this.strokeWidth = 3.0,
    this.isFilled = false,
    this.fillColor,
  });

  @override
  Rect getBounds() => bounds;

  @override
  bool containsPoint(Offset point, {double hitSlop = 8.0}) {
    if (type == 'line' || type == 'arrow') {
      final p1 = bounds.topLeft;
      final p2 = bounds.bottomRight;
      final l2 = (p1 - p2).distanceSquared;
      if (l2 == 0) return (point - p1).distance <= hitSlop;
      final t = max(
        0.0,
        min(
          1.0,
          ((point - p1).dx * (p2 - p1).dx + (point - p1).dy * (p2 - p1).dy) /
              l2,
        ),
      );
      final projection = p1 + (p2 - p1) * t;
      return (point - projection).distance <= hitSlop + strokeWidth;
    }

    final inflated = bounds.inflate(hitSlop);
    if (!inflated.contains(point)) return false;

    if (isFilled) return true;

    // Yalnızca kenarlara yakınsa seçilsin
    final inner = bounds.deflate(hitSlop + strokeWidth);
    return !inner.contains(point);
  }

  @override
  ShapeObject movedBy(Offset delta) {
    if (isPinned) return this;
    return ShapeObject(
      id: id,
      type: type,
      isPinned: isPinned,
      zIndex: zIndex,
      createdBy: createdBy,
      createdAt: createdAt,
      bounds: bounds.shift(delta),
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      isFilled: isFilled,
      fillColor: fillColor,
    );
  }

  @override
  ShapeObject withPinned(bool pinned) {
    return ShapeObject(
      id: id,
      type: type,
      isPinned: pinned,
      zIndex: zIndex,
      createdBy: createdBy,
      createdAt: createdAt,
      bounds: bounds,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      isFilled: isFilled,
      fillColor: fillColor,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'isPinned': isPinned,
      'zIndex': zIndex,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'left': bounds.left,
      'top': bounds.top,
      'right': bounds.right,
      'bottom': bounds.bottom,
      'strokeColor': strokeColor.toARGB32(),
      'strokeWidth': strokeWidth,
      'isFilled': isFilled,
      'fillColor': fillColor?.toARGB32(),
    };
  }

  factory ShapeObject.fromMap(Map<String, dynamic> map) {
    final bounds = Rect.fromLTRB(
      (map['left'] as num).toDouble(),
      (map['top'] as num).toDouble(),
      (map['right'] as num).toDouble(),
      (map['bottom'] as num).toDouble(),
    );

    return ShapeObject(
      id: map['id'] ?? '',
      type: map['type'] ?? 'rectangle',
      isPinned: map['isPinned'] ?? false,
      zIndex: map['zIndex'] ?? 0,
      createdBy: map['createdBy'] ?? '',
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      bounds: bounds,
      strokeColor: Color(map['strokeColor'] ?? 0xFF000000),
      strokeWidth: (map['strokeWidth'] as num?)?.toDouble() ?? 3.0,
      isFilled: map['isFilled'] ?? false,
      fillColor: map['fillColor'] != null ? Color(map['fillColor']) : null,
    );
  }
}

/// Metin nesnesi
class TextObject extends BoardObject {
  final Offset position;
  final String text;
  final double fontSize;
  final Color color;
  final double width;
  final double height;

  const TextObject({
    required super.id,
    super.type = 'text',
    super.isPinned = false,
    super.zIndex = 0,
    required super.createdBy,
    required super.createdAt,
    required this.position,
    required this.text,
    this.fontSize = 20.0,
    this.color = Colors.black,
    this.width = 200.0,
    this.height = 60.0,
  });

  @override
  Rect getBounds() {
    return Rect.fromLTWH(position.dx, position.dy, width, height);
  }

  @override
  bool containsPoint(Offset point, {double hitSlop = 8.0}) {
    return getBounds().inflate(hitSlop).contains(point);
  }

  @override
  TextObject movedBy(Offset delta) {
    if (isPinned) return this;
    return TextObject(
      id: id,
      type: type,
      isPinned: isPinned,
      zIndex: zIndex,
      createdBy: createdBy,
      createdAt: createdAt,
      position: position + delta,
      text: text,
      fontSize: fontSize,
      color: color,
      width: width,
      height: height,
    );
  }

  @override
  TextObject withPinned(bool pinned) {
    return TextObject(
      id: id,
      type: type,
      isPinned: pinned,
      zIndex: zIndex,
      createdBy: createdBy,
      createdAt: createdAt,
      position: position,
      text: text,
      fontSize: fontSize,
      color: color,
      width: width,
      height: height,
    );
  }

  TextObject copyWithText(String newText) {
    return TextObject(
      id: id,
      type: type,
      isPinned: isPinned,
      zIndex: zIndex,
      createdBy: createdBy,
      createdAt: createdAt,
      position: position,
      text: newText,
      fontSize: fontSize,
      color: color,
      width: width,
      height: height,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'isPinned': isPinned,
      'zIndex': zIndex,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'posX': position.dx,
      'posY': position.dy,
      'text': text,
      'fontSize': fontSize,
      'color': color.toARGB32(),
      'width': width,
      'height': height,
    };
  }

  factory TextObject.fromMap(Map<String, dynamic> map) {
    return TextObject(
      id: map['id'] ?? '',
      isPinned: map['isPinned'] ?? false,
      zIndex: map['zIndex'] ?? 0,
      createdBy: map['createdBy'] ?? '',
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      position: Offset(
        (map['posX'] as num).toDouble(),
        (map['posY'] as num).toDouble(),
      ),
      text: map['text'] ?? '',
      fontSize: (map['fontSize'] as num?)?.toDouble() ?? 20.0,
      color: Color(map['color'] ?? 0xFF000000),
      width: (map['width'] as num?)?.toDouble() ?? 200.0,
      height: (map['height'] as num?)?.toDouble() ?? 60.0,
    );
  }
}

/// Post-it (Sticky Note) nesnesi
class StickyNoteObject extends BoardObject {
  final Rect bounds;
  final String text;
  final Color noteColor;
  final String authorName;

  const StickyNoteObject({
    required super.id,
    super.type = 'sticky_note',
    super.isPinned = false,
    super.zIndex = 0,
    required super.createdBy,
    required super.createdAt,
    required this.bounds,
    required this.text,
    this.noteColor = const Color(0xFFFEF08A), // Varsayılan sarı post-it
    this.authorName = 'Ali',
  });

  @override
  Rect getBounds() => bounds;

  @override
  bool containsPoint(Offset point, {double hitSlop = 8.0}) {
    return bounds.inflate(hitSlop).contains(point);
  }

  @override
  StickyNoteObject movedBy(Offset delta) {
    if (isPinned) return this;
    return StickyNoteObject(
      id: id,
      type: type,
      isPinned: isPinned,
      zIndex: zIndex,
      createdBy: createdBy,
      createdAt: createdAt,
      bounds: bounds.shift(delta),
      text: text,
      noteColor: noteColor,
      authorName: authorName,
    );
  }

  @override
  StickyNoteObject withPinned(bool pinned) {
    return StickyNoteObject(
      id: id,
      type: type,
      isPinned: pinned,
      zIndex: zIndex,
      createdBy: createdBy,
      createdAt: createdAt,
      bounds: bounds,
      text: text,
      noteColor: noteColor,
      authorName: authorName,
    );
  }

  StickyNoteObject copyWithText(String newText) {
    return StickyNoteObject(
      id: id,
      type: type,
      isPinned: isPinned,
      zIndex: zIndex,
      createdBy: createdBy,
      createdAt: createdAt,
      bounds: bounds,
      text: newText,
      noteColor: noteColor,
      authorName: authorName,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'isPinned': isPinned,
      'zIndex': zIndex,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'left': bounds.left,
      'top': bounds.top,
      'width': bounds.width,
      'height': bounds.height,
      'text': text,
      'noteColor': noteColor.toARGB32(),
      'authorName': authorName,
    };
  }

  factory StickyNoteObject.fromMap(Map<String, dynamic> map) {
    final bounds = Rect.fromLTWH(
      (map['left'] as num).toDouble(),
      (map['top'] as num).toDouble(),
      (map['width'] as num).toDouble(),
      (map['height'] as num).toDouble(),
    );

    return StickyNoteObject(
      id: map['id'] ?? '',
      isPinned: map['isPinned'] ?? false,
      zIndex: map['zIndex'] ?? 0,
      createdBy: map['createdBy'] ?? '',
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      bounds: bounds,
      text: map['text'] ?? '',
      noteColor: Color(map['noteColor'] ?? 0xFFFEF08A),
      authorName: map['authorName'] ?? '',
    );
  }
}

/// Görsel nesnesi
class ImageObject extends BoardObject {
  final Rect bounds;
  final String imageUrl;
  final String label;

  const ImageObject({
    required super.id,
    super.type = 'image',
    super.isPinned = false,
    super.zIndex = 0,
    required super.createdBy,
    required super.createdAt,
    required this.bounds,
    required this.imageUrl,
    this.label = 'Görsel',
  });

  @override
  Rect getBounds() => bounds;

  @override
  bool containsPoint(Offset point, {double hitSlop = 8.0}) {
    return bounds.inflate(hitSlop).contains(point);
  }

  @override
  ImageObject movedBy(Offset delta) {
    if (isPinned) return this;
    return ImageObject(
      id: id,
      type: type,
      isPinned: isPinned,
      zIndex: zIndex,
      createdBy: createdBy,
      createdAt: createdAt,
      bounds: bounds.shift(delta),
      imageUrl: imageUrl,
      label: label,
    );
  }

  @override
  ImageObject withPinned(bool pinned) {
    return ImageObject(
      id: id,
      type: type,
      isPinned: pinned,
      zIndex: zIndex,
      createdBy: createdBy,
      createdAt: createdAt,
      bounds: bounds,
      imageUrl: imageUrl,
      label: label,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'isPinned': isPinned,
      'zIndex': zIndex,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'left': bounds.left,
      'top': bounds.top,
      'width': bounds.width,
      'height': bounds.height,
      'imageUrl': imageUrl,
      'label': label,
    };
  }

  factory ImageObject.fromMap(Map<String, dynamic> map) {
    final bounds = Rect.fromLTWH(
      (map['left'] as num).toDouble(),
      (map['top'] as num).toDouble(),
      (map['width'] as num).toDouble(),
      (map['height'] as num).toDouble(),
    );

    return ImageObject(
      id: map['id'] ?? '',
      isPinned: map['isPinned'] ?? false,
      zIndex: map['zIndex'] ?? 0,
      createdBy: map['createdBy'] ?? '',
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      bounds: bounds,
      imageUrl: map['imageUrl'] ?? '',
      label: map['label'] ?? 'Görsel',
    );
  }
}
