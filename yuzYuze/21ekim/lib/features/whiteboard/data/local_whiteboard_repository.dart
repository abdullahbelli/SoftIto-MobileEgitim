import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/app_constants.dart';
import '../domain/board_object.dart';
import '../domain/whiteboard_repository.dart';

/// Tuval nesnelerini SharedPreferences üzerinde yerel ve kalıcı tutan repository
class LocalWhiteboardRepository implements WhiteboardRepository {
  final SharedPreferences _prefs;

  LocalWhiteboardRepository(this._prefs);

  String _getKey(String roomId) =>
      '${AppConstants.prefsKeyObjectsPrefix}$roomId';

  List<BoardObject> _getInitialDemoObjects() {
    final now = DateTime.now();
    return [
      // Hoş Geldiniz Post-it Notu
      StickyNoteObject(
        id: 'demo_sticky_welcome',
        createdBy: 'user_demo_1',
        createdAt: now,
        bounds: const Rect.fromLTWH(-240, -140, 200, 180),
        text:
            'BoardConnect\'e Hoş Geldiniz! 🚀\n\n'
            '• Sonsuz tuvalde pan & zoom yapın\n'
            '• Şekil, çizim ve post-it ekleyin\n'
            '• Raptiye ile nesneleri sabitleyin',
        noteColor: const Color(0xFFFEF08A), // Sarı post-it
        authorName: 'Ali Demir',
      ),

      // Mimari Kutusu
      ShapeObject(
        id: 'demo_shape_rect',
        type: 'rectangle',
        createdBy: 'user_demo_1',
        createdAt: now,
        bounds: const Rect.fromLTWH(80, -120, 240, 140),
        strokeColor: const Color(0xFFF59E0B),
        strokeWidth: 3.5,
        isFilled: true,
        fillColor: const Color(0xFFF59E0B).withValues(alpha: 0.12),
      ),

      // Başlık Metni
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

      // Bağlantı Oku
      ShapeObject(
        id: 'demo_arrow_1',
        type: 'arrow',
        createdBy: 'user_demo_1',
        createdAt: now,
        bounds: const Rect.fromLTRB(-30, -50, 70, -50),
        strokeColor: const Color(0xFF06B6D4),
        strokeWidth: 3.0,
      ),

      // Çizim
      StrokeObject(
        id: 'demo_stroke_check',
        createdBy: 'user_demo_1',
        createdAt: now,
        points: const [Offset(110, 50), Offset(125, 75), Offset(160, 30)],
        color: const Color(0xFF10B981),
        strokeWidth: 4.0,
      ),
    ];
  }

  @override
  Future<List<BoardObject>> getObjects(String roomId) async {
    final raw = _prefs.getString(_getKey(roomId));
    if (raw == null) {
      // Eğer varsayılan demo odasıysa örnek içerik yükle
      if (roomId == 'room_demo_default') {
        final initial = _getInitialDemoObjects();
        await saveObjects(roomId, initial);
        return initial;
      }
      return [];
    }

    try {
      final list = json.decode(raw) as List<dynamic>;
      return list
          .map((item) => BoardObject.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveObjects(String roomId, List<BoardObject> objects) async {
    final list = objects.map((o) => o.toMap()).toList();
    await _prefs.setString(_getKey(roomId), json.encode(list));
  }

  @override
  Future<void> clearObjects(String roomId) async {
    await _prefs.remove(_getKey(roomId));
  }
}
