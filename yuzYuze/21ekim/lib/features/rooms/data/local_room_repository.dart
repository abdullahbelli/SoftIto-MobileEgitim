import 'dart:convert'; // Verileri JSON formatına dönüştürmek ve çözümlemek için kullanılır.
import 'dart:math'; // Rastgele 4 haneli oda kodu üretmek için matematik kütüphanesini içe aktarır.

import 'package:shared_preferences/shared_preferences.dart'; // Yerel kalıcı veri saklama kütüphanesi.
import 'package:uuid/uuid.dart'; // Benzersiz oda kimlikleri (UUID) oluşturmak için kullanılır.

import '../../../core/config/app_constants.dart'; // Depolama anahtar sabitlerini içe aktarır.
import '../../../core/errors/app_exception.dart'; // Özel hata sınıfını içe aktarır.
import '../domain/room_model.dart'; // Oda veri modelini içe aktarır.
import '../domain/room_repository.dart'; // Oda veri sözleşmesini (arayüzünü) içe aktarır.

/// Odaları SharedPreferences üzerinden yerel ve kalıcı saklayan repository
/// 'implements RoomRepository' ile oda yönetimi arayüzündeki tüm fonksiyonları yerel bellekte somutlaştırır.
class LocalRoomRepository implements RoomRepository {
  final SharedPreferences _prefs; // Cihaz hafızasına erişim nesnesi.
  final _uuid = const Uuid(); // Benzersiz ID oluşturucu.

  // Kurucu fonksiyon: SharedPreferences nesnesini alır ve ilk çalıştırmada varsayılan odaları hafızaya yazar.
  LocalRoomRepository(this._prefs) {
    _initDefaultRooms();
  }

  // Hafızada henüz hiç oda yoksa kullanıcıya hazır iki adet örnek demo çalışma odası ekler.
  void _initDefaultRooms() {
    final existing = _prefs.getString(
      AppConstants.prefsKeyRooms,
    ); // Kayıtlı oda verisini sorgular.
    if (existing == null) {
      final now = DateTime.now();
      // Örnek başlangıç odaları.
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
          createdAt: now.subtract(
            const Duration(days: 2),
          ), // 2 gün önce oluşturulmuş.
          updatedAt: now.subtract(
            const Duration(hours: 3),
          ), // 3 saat önce güncellenmiş.
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

      // Odalar listesini JSON dizesine dönüştürerek SharedPreferences'a yazar.
      final encoded = json.encode(defaultRooms.map((r) => r.toMap()).toList());
      _prefs.setString(AppConstants.prefsKeyRooms, encoded);
    }
  }

  // Cihaz hafızasındaki odaları JSON'dan çözüp liste olarak getiren özel yardımcı metot.
  List<RoomModel> _getRoomsList() {
    final raw = _prefs.getString(AppConstants.prefsKeyRooms);
    if (raw == null) return []; // Veri yoksa boş liste döner.
    try {
      final list = json.decode(
        raw,
      ) as List<dynamic>; // JSON dizisini List olarak çözümler.
      // Her JSON elemanını RoomModel'e dönüştürür ve silinmemiş olanları filtreler.
      return list
          .map((item) => RoomModel.fromMap(item as Map<String, dynamic>))
          .where((r) => !r.isDeleted)
          .toList();
    } catch (_) {
      return []; // Hata durumunda güvenli şekilde boş liste döner.
    }
  }

  // Güncel odalar listesini JSON olarak SharedPreferences'a kaydeden yardımcı metot.
  Future<void> _saveRoomsList(List<RoomModel> rooms) async {
    final encoded = json.encode(rooms.map((r) => r.toMap()).toList());
    await _prefs.setString(AppConstants.prefsKeyRooms, encoded);
  }

  // Yeni oda için "BC-XXXX" formatında rastgele 4 haneli katılım kodu üretir.
  String _generateJoinCode() {
    final random = Random();
    final number =
        1000 +
        random.nextInt(9000); // 1000 ile 9999 arasında rastgele tam sayı.
    return 'BC-$number';
  }

  @override // Tüm aktif odaları liste halinde döndürür.
  Future<List<RoomModel>> getRooms() async {
    await Future.delayed(
      const Duration(milliseconds: 200),
    ); // Hafif yapay gecikme simülasyonu.
    return _getRoomsList();
  }

  @override // Kimlik numarasına göre tek bir odayı bulur.
  Future<RoomModel?> getRoomById(String id) async {
    final rooms = _getRoomsList();
    try {
      // Listede kimliği eşleşen ilk odayı bulur.
      return rooms.firstWhere((r) => r.id == id);
    } catch (_) {
      return null; // Bulunamazsa null döner.
    }
  }

  @override // Paylaşım koduna göre odayı bulur (büyük-küçük harf duyarsız).
  Future<RoomModel?> getRoomByCode(String code) async {
    final rooms = _getRoomsList();
    final cleanCode = code
        .trim()
        .toUpperCase(); // Kodu temizleyip büyük harfe çevirir.
    try {
      return rooms.firstWhere((r) => r.joinCode.toUpperCase() == cleanCode);
    } catch (_) {
      return null;
    }
  }

  @override // Yeni bir oda oluşturur ve listeye ekler.
  Future<RoomModel> createRoom({
    required String name,
    required int maxParticipants,
    required String ownerId,
    required String ownerName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final rooms = _getRoomsList();
    final joinCode = _generateJoinCode(); // Benzersiz katılım kodu üretir.
    final now = DateTime.now();

    // Yeni oda nesnesini oluşturur.
    final newRoom = RoomModel(
      id: 'room_${_uuid.v4().substring(0, 8)}',
      name: name.trim(),
      ownerId: ownerId,
      ownerName: ownerName,
      joinCode: joinCode,
      shareLink: 'https://boardconnect.app/join/$joinCode', // Paylaşım bağlantısı oluşturur.
      maxParticipants: maxParticipants,
      participantCount: 1, // Başlangıçta oda sahibi 1 kişi.
      createdAt: now,
      updatedAt: now,
    );

    // Yeni oluşturulan odayı listenin en başına (en güncel olarak) ekler.
    rooms.insert(0, newRoom);
    await _saveRoomsList(rooms); // Listeyi diske yazar.
    return newRoom;
  }

  @override // Odayı ve odaya ait tuval çizim nesnelerini siler.
  Future<void> deleteRoom(String roomId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final rooms = _getRoomsList();
    // Silinecek id haricindeki odaları filtreleyerek yeni liste üretir.
    final updated = rooms.where((r) => r.id != roomId).toList();

    // Eğer listenin boyutu değişmediyse oda bulunamamış demektir.
    if (rooms.length == updated.length) {
      throw const AppException('Silinecek oda bulunamadı.');
    }

    await _saveRoomsList(updated); // Güncel odayı kaydeder.
    // İlgili odanın tuvalinde çizilmiş tüm nesneleri (şekiller, çizgiler vb.) hafızadan temizler.
    await _prefs.remove('${AppConstants.prefsKeyObjectsPrefix}$roomId');
  }

  @override // Mevcut bir odanın bilgilerini günceller.
  Future<void> updateRoom(RoomModel room) async {
    final rooms = _getRoomsList();
    final index = rooms.indexWhere(
      (r) => r.id == room.id,
    ); // Odanın liste indeksini bulur.
    if (index != -1) {
      // Güncellenme tarihini şu anki zaman yaparak nesneyi kopyalar.
      rooms[index] = room.copyWith(updatedAt: DateTime.now());
      await _saveRoomsList(rooms); // Kaydeder.
    }
  }
}
