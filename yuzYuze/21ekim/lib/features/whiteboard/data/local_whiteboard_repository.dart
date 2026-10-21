import 'dart:convert'; // JSON serileştirme işlemleri için kütüphaneyi içe aktarır.

import 'package:flutter/material.dart'; // Flutter geometri ve renk sınıflarını (Color, Rect, Offset) içe aktarır.
import 'package:shared_preferences/shared_preferences.dart'; // Cihaz hafızasında veri saklama kütüphanesi.

import '../../../core/config/app_constants.dart'; // Depolama anahtar sabitlerini içe aktarır.
import '../domain/board_object.dart'; // Tuval nesnesi sınıflarını içe aktarır.
import '../domain/whiteboard_repository.dart'; // Depo sözleşmesini içe aktarır.

/// Tuval nesnelerini SharedPreferences üzerinde yerel ve kalıcı tutan repository
/// 'implements WhiteboardRepository' diyerek tuval verilerini cihaz hafızasında saklar.
class LocalWhiteboardRepository implements WhiteboardRepository {
  final SharedPreferences _prefs; // Cihaz hafızası nesnesi.

  LocalWhiteboardRepository(this._prefs);

  // Belirli bir odaya ait nesnelerin anahtarını üretir (Örn: "bc_objects_room_room_123").
  String _getKey(String roomId) =>
      '${AppConstants.prefsKeyObjectsPrefix}$roomId';

  // Demo odası ilk kez açıldığında kullanıcıyı boş ekranla karşılamamak için başlangıç örnek nesnelerini üretir.
  List<BoardObject> _getInitialDemoObjects() {
    final now = DateTime.now();
    return [
      // Hoş Geldiniz Sarı Post-it Notu
      StickyNoteObject(
        id: 'demo_sticky_welcome',
        createdBy: 'user_demo_1',
        createdAt: now,
        bounds: const Rect.fromLTWH(
          -240,
          -140,
          200,
          180,
        ), // Tuval sol üst bölgesinde 200x180'lik not.
        text:
            'BoardConnect\'e Hoş Geldiniz! 🚀\n\n'
            '• Sonsuz tuvalde pan & zoom yapın\n'
            '• Şekil, çizim ve post-it ekleyin\n'
            '• Raptiye ile nesneleri sabitleyin',
        noteColor: const Color(0xFFFEF08A), // Klasik sarı post-it rengi.
        authorName: 'Ali Demir',
      ),

      // Sarı Vurgulu Mimari Dikdörtgen Kutusu
      ShapeObject(
        id: 'demo_shape_rect',
        type: 'rectangle',
        createdBy: 'user_demo_1',
        createdAt: now,
        bounds: const Rect.fromLTWH(80, -120, 240, 140),
        strokeColor: const Color(0xFFF59E0B),
        strokeWidth: 3.5,
        isFilled: true,
        fillColor: const Color(0xFFF59E0B)
            .withValues(alpha: 0.12), // Saydam sarı iç dolgu.
      ),

      // Kutu İçi Başlık Metni
      TextObject(
        id: 'demo_text_title',
        createdBy: 'user_demo_1',
        createdAt: now,
        position: const Offset(100, -80),
        text: 'Flutter Web + Canvas\nSonsuz Whiteboard',
        fontSize: 18,
        color: const Color(0xFF0F172A),
        width: 200,
        height: 60,
      ),

      // Post-it'ten Kutuya Doğru Yönelen Bağlantı Oku
      ShapeObject(
        id: 'demo_arrow_1',
        type: 'arrow',
        createdBy: 'user_demo_1',
        createdAt: now,
        bounds: const Rect.fromLTRB(-30, -50, 70, -50),
        strokeColor: const Color(0xFF06B6D4), // Camgöbeği rengi ok.
        strokeWidth: 3.0,
      ),

      // Yeşil Onay İmi (Checkmark) Kalem Çizimi
      StrokeObject(
        id: 'demo_stroke_check',
        createdBy: 'user_demo_1',
        createdAt: now,
        points: const [
          Offset(110, 50),
          Offset(125, 75),
          Offset(160, 30),
        ], // Onay tikini oluşturan 3 nokta.
        color: const Color(0xFF10B981), // Zümrüt yeşili.
        strokeWidth: 4.0,
      ),
    ];
  }

  @override // Odaya ait tüm nesneleri getirir.
  Future<List<BoardObject>> getObjects(String roomId) async {
    final raw = _prefs.getString(
      _getKey(roomId),
    ); // Odaya ait JSON metnini okur.
    if (raw == null) {
      // Eğer varsayılan demo odasıysa ve henüz boşsa örnek içerikleri kaydeder ve döner.
      if (roomId == 'room_demo_default') {
        final initial = _getInitialDemoObjects();
        await saveObjects(roomId, initial);
        return initial;
      }
      return []; // Diğer boş odalar için boş liste döner.
    }

    try {
      final list = json.decode(raw) as List<dynamic>;
      // Her JSON elemanını polimorfik olarak uygun BoardObject alt tipine dönüştürür.
      return list
          .map((item) => BoardObject.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return []; // Bozulma durumunda boş liste döner.
    }
  }

  @override // Odanın güncel nesneler listesini JSON olarak kaydeder.
  Future<void> saveObjects(String roomId, List<BoardObject> objects) async {
    final list = objects
        .map((o) => o.toMap())
        .toList(); // Tüm nesneleri haritaya dönüştürür.
    await _prefs.setString(
      _getKey(roomId),
      json.encode(list),
    ); // JSON dizesine çevirip yazar.
  }

  @override // Odanın çizim verilerini siler.
  Future<void> clearObjects(String roomId) async {
    await _prefs.remove(_getKey(roomId)); // İlgili anahtarı hafızadan kaldırır.
  }
}
