import 'room_model.dart'; // Oda veri modelini içe aktarır.

/// Odalar için soyut repository arayüzü (Interface)
/// Bu arayüz, odaların listelenmesi, aranması, oluşturulması ve silinmesi işlemlerinin sözleşmesini tanımlar.
/// Somut sınıf (LocalRoomRepository veya SupabaseRoomRepository) bu sözleşmeyi uygulayarak veriye erişir.
abstract class RoomRepository {
  /// Sistemdeki aktif ve silinmemiş odaların listesini asenkron olarak getirir.
  Future<List<RoomModel>> getRooms();

  /// Benzersiz oda kimliğine (ID) göre odayı sorgular.
  /// Bulunamazsa null döndürür.
  Future<RoomModel?> getRoomById(String id);

  /// Katılımcının girdiği kısa katılım koduna (Örn: "BC-1234") göre odayı sorgular.
  /// Bulunamazsa null döndürür.
  Future<RoomModel?> getRoomByCode(String code);

  /// Yeni bir çalışma odası oluşturur ve odaya ait benzersiz ID, kod ve bağlantı üretir.
  /// [name]: Oda adı
  /// [maxParticipants]: Maksimum katılımcı kapasitesi
  /// [ownerId]: Odayı oluşturan kullanıcının kimliği
  /// [ownerName]: Odayı oluşturan kullanıcının adı
  /// Oluşturulan [RoomModel] nesnesini döndürür.
  Future<RoomModel> createRoom({
    required String name,
    required int maxParticipants,
    required String ownerId,
    required String ownerName,
  });

  /// Belirtilen kimliğe sahip odayı sistemden siler (veya silindi olarak işaretler).
  /// [roomId]: Silinecek odanın benzersiz kimliği.
  Future<void> deleteRoom(String roomId);

  /// Oda bilgilerini (ad, katılımcı sayısı vb.) günceller.
  /// [room]: Güncel bilgileri içeren oda modeli.
  Future<void> updateRoom(RoomModel room);
}
