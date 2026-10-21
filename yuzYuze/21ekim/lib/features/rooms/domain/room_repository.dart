import 'room_model.dart';

/// Odalar için soyut repository arayüzü
abstract class RoomRepository {
  /// Odaların listesini getirir
  Future<List<RoomModel>> getRooms();

  /// ID ile odayı getirir
  Future<RoomModel?> getRoomById(String id);

  /// Katılım kodu ile odayı getirir
  Future<RoomModel?> getRoomByCode(String code);

  /// Yeni oda oluşturur
  Future<RoomModel> createRoom({
    required String name,
    required int maxParticipants,
    required String ownerId,
    required String ownerName,
  });

  /// Odayı siler (yalnızca sahibi)
  Future<void> deleteRoom(String roomId);

  /// Odayı günceller
  Future<void> updateRoom(RoomModel room);
}
