import 'board_object.dart';

/// Whiteboard nesneleri için soyut repository arayüzü
abstract class WhiteboardRepository {
  /// Odaya ait tüm nesneleri getirir
  Future<List<BoardObject>> getObjects(String roomId);

  /// Odanın tüm nesnelerini kalıcı saklar
  Future<void> saveObjects(String roomId, List<BoardObject> objects);

  /// Odanın nesnelerini temizler
  Future<void> clearObjects(String roomId);
}
