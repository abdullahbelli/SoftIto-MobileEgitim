import 'board_object.dart'; // Beyaz tahtadaki çizim, şekil ve metin nesnelerinin temel sınıfını içe aktarır.

/// Whiteboard nesneleri için soyut repository arayüzü (WhiteboardRepository)
/// Belirli bir odadaki tuval elemanlarının getirilmesi, kaydedilmesi ve silinmesi işlemlerinin sözleşmesini tanımlar.
abstract class WhiteboardRepository {
  /// Belirtilen odaya ait tüm tuval nesnelerini (çizgi, şekil, post-it vb.) hafızadan asenkron olarak getirir.
  /// [roomId]: Nesneleri çekilecek odanın kimliği.
  Future<List<BoardObject>> getObjects(String roomId);

  /// Bir odanın mevcut tüm tuval nesnelerini kalıcı depolamaya (SharedPreferences veya Supabase) kaydeder.
  /// [roomId]: Hedef oda kimliği.
  /// [objects]: Kaydedilecek nesneler listesi.
  Future<void> saveObjects(String roomId, List<BoardObject> objects);

  /// Bir odanın tuvalinde bulunan tüm nesneleri temizler/sıfırlar.
  /// [roomId]: Temizlenecek odanın kimliği.
  Future<void> clearObjects(String roomId);
}
