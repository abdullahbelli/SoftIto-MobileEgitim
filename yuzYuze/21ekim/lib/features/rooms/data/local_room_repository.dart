import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../core/config/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../domain/room_model.dart';
import '../domain/room_repository.dart';

/// Odaları SharedPreferences üzerinden yerel ve kalıcı saklayan repository
class LocalRoomRepository implements RoomRepository {
  final SharedPreferences _prefs;
  final _uuid = const Uuid();

  LocalRoomRepository(this._prefs) {
    _initDefaultRooms();
  }

  void _initDefaultRooms() {
    final existing = _prefs.getString(AppConstants.prefsKeyRooms);
    if (existing == null) {
      final now = DateTime.now();
      final defaultRooms = [
        RoomModel(
          id: 'room_demo_default',
          name: 'Sprint Planlama & Fikir Odası',
          ownerId: 'user_demo_1',
          ownerName: 'Ali Demir',
          joinCode: 'BC-DEMO',
          shareLink: 'https://boardconnect.app/join/BC-DEMO',
          maxParticipants: 10,
          participantCount: 3,
          createdAt: now.subtract(const Duration(days: 2)),
          updatedAt: now.subtract(const Duration(hours: 3)),
        ),
        RoomModel(
          id: 'room_demo_design',
          name: 'Mobil UI Taslak & Whiteboard',
          ownerId: 'user_demo_1',
          ownerName: 'Ali Demir',
          joinCode: 'BC-DESIGN',
          shareLink: 'https://boardconnect.app/join/BC-DESIGN',
          maxParticipants: 8,
          participantCount: 2,
          createdAt: now.subtract(const Duration(days: 5)),
          updatedAt: now.subtract(const Duration(days: 1)),
        ),
      ];

      final encoded = json.encode(defaultRooms.map((r) => r.toMap()).toList());
      _prefs.setString(AppConstants.prefsKeyRooms, encoded);
    }
  }

  List<RoomModel> _getRoomsList() {
    final raw = _prefs.getString(AppConstants.prefsKeyRooms);
    if (raw == null) return [];
    try {
      final list = json.decode(raw) as List<dynamic>;
      return list
          .map((item) => RoomModel.fromMap(item as Map<String, dynamic>))
          .where((r) => !r.isDeleted)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveRoomsList(List<RoomModel> rooms) async {
    final encoded = json.encode(rooms.map((r) => r.toMap()).toList());
    await _prefs.setString(AppConstants.prefsKeyRooms, encoded);
  }

  String _generateJoinCode() {
    final random = Random();
    final number = 1000 + random.nextInt(9000);
    return 'BC-$number';
  }

  @override
  Future<List<RoomModel>> getRooms() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _getRoomsList();
  }

  @override
  Future<RoomModel?> getRoomById(String id) async {
    final rooms = _getRoomsList();
    try {
      return rooms.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<RoomModel?> getRoomByCode(String code) async {
    final rooms = _getRoomsList();
    final cleanCode = code.trim().toUpperCase();
    try {
      return rooms.firstWhere((r) => r.joinCode.toUpperCase() == cleanCode);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<RoomModel> createRoom({
    required String name,
    required int maxParticipants,
    required String ownerId,
    required String ownerName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final rooms = _getRoomsList();
    final joinCode = _generateJoinCode();
    final now = DateTime.now();

    final newRoom = RoomModel(
      id: 'room_${_uuid.v4().substring(0, 8)}',
      name: name.trim(),
      ownerId: ownerId,
      ownerName: ownerName,
      joinCode: joinCode,
      shareLink: 'https://boardconnect.app/join/$joinCode',
      maxParticipants: maxParticipants,
      participantCount: 1,
      createdAt: now,
      updatedAt: now,
    );

    rooms.insert(0, newRoom);
    await _saveRoomsList(rooms);
    return newRoom;
  }

  @override
  Future<void> deleteRoom(String roomId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final rooms = _getRoomsList();
    final updated = rooms.where((r) => r.id != roomId).toList();

    if (rooms.length == updated.length) {
      throw const AppException('Silinecek oda bulunamadı.');
    }

    await _saveRoomsList(updated);
    // İlgili odanın tuval nesnelerini de temizle
    await _prefs.remove('${AppConstants.prefsKeyObjectsPrefix}$roomId');
  }

  @override
  Future<void> updateRoom(RoomModel room) async {
    final rooms = _getRoomsList();
    final index = rooms.indexWhere((r) => r.id == room.id);
    if (index != -1) {
      rooms[index] = room.copyWith(updatedAt: DateTime.now());
      await _saveRoomsList(rooms);
    }
  }
}
