import 'dart:math'; // Matematiksel formüller (min, max, karekök) ve mesafe hesaplamaları için içe aktarır.

import 'package:flutter/material.dart'; // Flutter geometri sınıfları (Rect, Offset, Color) için içe aktarır.

/// Tuval nesnesi temel soyut sınıfı (BoardObject)
/// Tahta üzerindeki tüm elemanların (kalem çizimi, şekil, metin, post-it, görsel) ortak özelliklerini ve davranışlarını belirler.
abstract class BoardObject {
  final String id; // Nesnenin benzersiz kimlik numarası (UUID).
  final String type; // Nesne türü ('stroke', 'rectangle', 'ellipse', 'line', 'arrow', 'text', 'sticky_note', 'image').
  final bool isPinned; // Nesnenin panoda kilitli/sabitli olup olmadığını belirler (sabitliyse taşınamaz).
  final int zIndex; // Katman sırası (derinlik); yüksek zIndex önde çizilir.
  final String createdBy; // Nesneyi çizen/oluşturan kullanıcının kimliği.
  final DateTime createdAt; // Nesnenin oluşturulma tarihi.

  // Değişmez kurucu fonksiyon.
  const BoardObject({
    required this.id,
    required this.type,
    this.isPinned = false, // Varsayılan olarak nesne kilitli değildir.
    this.zIndex = 0,
    required this.createdBy,
    required this.createdAt,
  });

  /// Nesnenin dünya koordinatlarındaki çevreleyen sınır kutusunu (Rect) döndürür.
  Rect getBounds();

  /// Verilen dünya koordinatındaki noktanın (tıklama veya dokunma) nesneye isabet edip etmediğini kontrol eder.
  /// [hitSlop]: Dokunma hassasiyeti payı (piksel cinsinden tolerans boşluğu).
  bool containsPoint(Offset point, {double hitSlop = 8.0});

  /// Nesneyi dünya koordinatlarında delta (dx, dy) kadar öteler (taşır).
  BoardObject movedBy(Offset delta);

  /// Nesnenin sabitleme (isPinned) özelliğini güncelleyerek yeni kopyasını üretir.
  BoardObject withPinned(bool pinned);

  /// Nesneyi JSON haritasına dönüştürür.
  Map<String, dynamic> toMap();

  /// Polimorfik fabrika fonksiyonu: JSON tip alanına ('type') bakarak uygun somut nesneyi üretir.
  static BoardObject fromMap(Map<String, dynamic> map) {
    final type = map['type'] as String? ?? 'stroke';
    switch (type) {
      case 'stroke':
        return StrokeObject.fromMap(map); // Serbest çizim
      case 'rectangle':
      case 'ellipse':
      case 'line':
      case 'arrow':
        return ShapeObject.fromMap(map); // Geometrik şekiller
      case 'text':
        return TextObject.fromMap(map); // Metin kutusu
      case 'sticky_note':
        return StickyNoteObject.fromMap(map); // Post-it not
      case 'image':
        return ImageObject.fromMap(map); // Görsel
      default:
        return StrokeObject.fromMap(
          map,
        ); // Bilinmeyen durumlarda varsayılan çizgi
    }
  }
}

/// Serbest çizim (Kalem / Fırça) nesnesi
/// Kullanıcının parmağı veya faresiyle tuval üzerine çizdiği noktalar dizisini (points) saklar.
class StrokeObject extends BoardObject {
  final List<Offset> points; // Çizgiyi oluşturan sıralı koordinat noktaları.
  final Color color; // Çizgi rengi.
  final double strokeWidth; // Çizgi kalınlığı (piksel).

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

  @override // Çizginin etrafını saran en küçük dikdörtgeni hesaplar.
  Rect getBounds() {
    if (points.isEmpty) return Rect.zero; // Nokta yoksa sıfır boyut.
    double minX = points.first.dx;
    double maxX = points.first.dx;
    double minY = points.first.dy;
    double maxY = points.first.dy;

    // Tüm noktaları gezerek minimum ve maksimum x-y değerlerini bulur.
    for (final p in points) {
      if (p.dx < minX) minX = p.dx;
      if (p.dx > maxX) maxX = p.dx;
      if (p.dy < minY) minY = p.dy;
      if (p.dy > maxY) maxY = p.dy;
    }
    // Kalınlık payını da ekleyerek sınır dikdörtgeni (Rect) oluşturur.
    return Rect.fromLTRB(
      minX - strokeWidth,
      minY - strokeWidth,
      maxX + strokeWidth,
      maxY + strokeWidth,
    );
  }

  @override // Tıklanan noktanın serbest çizgi segmentlerinden herhangi birine yakın olup olmadığını belirler.
  bool containsPoint(Offset point, {double hitSlop = 8.0}) {
    // Önce genel sınır kutusunu kontrol ederek gereksiz döngüyü önler (Bounding Box erken eleme optimizasyonu).
    final bounds = getBounds().inflate(hitSlop);
    if (!bounds.contains(point)) return false;

    // Çizginin yarıçapı + dokunma toleransı.
    final threshold = (strokeWidth / 2) + hitSlop;
    // Çizginin her iki ardışık noktası arasındaki doğru parçasına olan en kısa mesafeyi hesaplar.
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      if (_distanceToSegment(point, p1, p2) <= threshold) {
        return true; // Nokta çizgiye yeterince yakınsa isabet kabul edilir.
      }
    }
    return false;
  }

  // Bir P noktasının V ve W noktaları arasındaki doğru parçasına olan en kısa Öklid mesafesini hesaplar.
  double _distanceToSegment(Offset p, Offset v, Offset w) {
    final l2 =
        (v - w).distanceSquared; // İki nokta arasındaki mesafenin karesi.
    if (l2 == 0)
      return (p - v)
          .distance; // Doğru parçası tek bir noktaysa doğrudan mesafe.
    // İzdüşüm katsayısını [0, 1] aralığında sınırlandırır (vektörel skaler çarpım).
    final t = max(
      0.0,
      min(1.0, ((p - v).dx * (w - v).dx + (p - v).dy * (w - v).dy) / l2),
    );
    final projection =
        v + (w - v) * t; // Doğru üzerindeki en yakın izdüşüm noktası.
    return (p - projection).distance; // İzdüşüm noktasına olan uzaklık.
  }

  @override // Çizgiyi taşıma fonksiyonu.
  StrokeObject movedBy(Offset delta) {
    if (isPinned) return this; // Kilitliyse taşınmaz.
    // Her noktaya delta (kayma) miktarını ekler.
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

  @override // Kilit durumunu güncelleyen kopyalama metodu.
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

  @override // Modeli JSON haritasına çevirir.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'isPinned': isPinned,
      'zIndex': zIndex,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'color': color.toARGB32(), // 32-bit ARGB tam sayı renk değeri.
      'strokeWidth': strokeWidth,
      'points': points
          .map((p) => {'x': p.dx, 'y': p.dy})
          .toList(), // Noktalar dizisi.
    };
  }

  // Haritadan serbest çizim nesnesi inşa eden fabrika metodu.
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

/// Geometrik Şekil (Dikdörtgen, Elips, Çizgi, Ok) nesnesi
class ShapeObject extends BoardObject {
  final Rect bounds; // Şeklin konum ve boyutunu belirten dikdörtgen.
  final Color strokeColor; // Dış çizgi kontur rengi.
  final double strokeWidth; // Kontur çizgi kalınlığı.
  final bool isFilled; // Şeklin içinin boyalı olup olmadığı.
  final Color? fillColor; // Şekil iç dolgu rengi (opsiyonel).

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

  @override // Şeklin kapladığı sınır kutusunu döner.
  Rect getBounds() => bounds;

  @override // Şekle tıklanıp tıklanmadığını geometrisine göre hesaplar.
  bool containsPoint(Offset point, {double hitSlop = 8.0}) {
    // Çizgi ve ok için doğru parçasına olan yakınlık formülü kullanılır:
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

    // Dikdörtgen veya Elips için:
    final inflated = bounds.inflate(
      hitSlop,
    ); // Dış sınırlara tolerans payı ekler.
    if (!inflated.contains(point)) return false;

    // Eğer şeklin içi boyalıysa tüm iç alan tıklanabilir sayılır.
    if (isFilled) return true;

    // İçi boşsa sadece kenarlarına dokunulduğunda seçilsin diye iç kısmı hariç tutar.
    final inner = bounds.deflate(hitSlop + strokeWidth);
    return !inner.contains(point);
  }

  @override // Şekli delta kadar kaydırır.
  ShapeObject movedBy(Offset delta) {
    if (isPinned) return this;
    return ShapeObject(
      id: id,
      type: type,
      isPinned: isPinned,
      zIndex: zIndex,
      createdBy: createdBy,
      createdAt: createdAt,
      bounds: bounds.shift(delta), // Dikdörtgeni delta kadar öteler.
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      isFilled: isFilled,
      fillColor: fillColor,
    );
  }

  @override // Sabitleme durumunu günceller.
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

  @override // JSON haritasına dönüştürür.
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

  // Haritadan ShapeObject nesnesi kurar.
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

/// Metin nesnesi (TextObject)
/// Tuvale serbestçe eklenen metin bloklarını temsil eder.
class TextObject extends BoardObject {
  final Offset position; // Metnin sol üst köşe konumu.
  final String text; // Görüntülenecek yazı içeriği.
  final double fontSize; // Yazı tipi boyutu.
  final Color color; // Yazı rengi.
  final double width; // Metin kutusu genişliği.
  final double height; // Metin kutusu yüksekliği.

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

  @override // Metin kutusunun sınırlarını döner.
  Rect getBounds() {
    return Rect.fromLTWH(position.dx, position.dy, width, height);
  }

  @override // Metin kutusunun içine tıklanıp tıklanmadığını denetler.
  bool containsPoint(Offset point, {double hitSlop = 8.0}) {
    return getBounds().inflate(hitSlop).contains(point);
  }

  @override // Metin kutusunu yeni konuma öteler.
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

  @override // Kilit durumunu günceller.
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

  /// Metin içeriği düzenlendiğinde yeni metinli kopyasını üretir.
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

  @override // JSON haritasına dönüştürür.
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

  // Haritadan TextObject nesnesi üretir.
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
/// Beyaz tahta üzerine renkli yapışkan notlar yapıştırmayı sağlar.
class StickyNoteObject extends BoardObject {
  final Rect bounds; // Not kağıdının konumu ve boyutları.
  final String text; // Notun içerisindeki metin.
  final Color noteColor; // Not kağıdının arka plan rengi (sarı, mavi vb.).
  final String authorName; // Notu yazan kişinin adı.

  const StickyNoteObject({
    required super.id,
    super.type = 'sticky_note',
    super.isPinned = false,
    super.zIndex = 0,
    required super.createdBy,
    required super.createdAt,
    required this.bounds,
    required this.text,
    this.noteColor = const Color(
      0xFFFEF08A,
    ), // Varsayılan sıcak sarı post-it rengi.
    this.authorName = 'Ali',
  });

  @override // Not kağıdının sınırlarını döner.
  Rect getBounds() => bounds;

  @override // Not kağıdına tıklanıp tıklanmadığını denetler.
  bool containsPoint(Offset point, {double hitSlop = 8.0}) {
    return bounds.inflate(hitSlop).contains(point);
  }

  @override // Not kağıdını taşır.
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

  @override // Sabitleme durumunu günceller.
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

  /// Notun içeriğindeki metni güncelleyip yeni kopya döndürür.
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

  @override // JSON haritasına dönüştürür.
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

  // Haritadan StickyNoteObject üretir.
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

/// Tuvale yüklenen Görsel / Resim nesnesi (ImageObject)
class ImageObject extends BoardObject {
  final Rect bounds; // Görselin tuval üzerindeki konumu ve boyutları.
  final String imageUrl; // Görselin dosya yolu veya web adresi.
  final String label; // Görselin alt başlığı / etiketi.

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

  @override // Görsel sınır kutusu.
  Rect getBounds() => bounds;

  @override // Görsele dokunulup dokunulmadığını denetler.
  bool containsPoint(Offset point, {double hitSlop = 8.0}) {
    return bounds.inflate(hitSlop).contains(point);
  }

  @override // Görseli taşır.
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

  @override // Sabitleme durumunu günceller.
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

  @override // JSON haritasına dönüştürür.
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

  // Haritadan ImageObject nesnesi oluşturur.
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
