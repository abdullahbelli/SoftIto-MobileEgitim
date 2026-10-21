import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod durum yönetimi paketini içe aktarır.

import 'package:boardconnect/app/theme/theme_provider.dart'; // SharedPreferences sağlayıcısını içe aktarır.

import '../../data/local_room_repository.dart'; // Yerel oda veri deposunu içe aktarır.
import '../../domain/room_model.dart'; // Oda veri modelini içe aktarır.
import '../../domain/room_repository.dart'; // Oda deposu sözleşmesini (arayüzünü) içe aktarır.

/// Odalar Repository Provider'ı
/// SharedPreferences nesnesini LocalRoomRepository'e enjekte ederek bağımlılığı sağlar.
final roomsRepositoryProvider = Provider<RoomRepository>((ref) {
  final prefs = ref.watch(
    sharedPreferencesProvider,
  ); // SharedPreferences bağımlılığını okur.
  return LocalRoomRepository(prefs); // Somut depo sınıfını döndürür.
});

/// Odalar Durum Yöneticisi (RoomsController)
/// `StateNotifier<AsyncValue<List<RoomModel>>>`, odalar listesini asenkron olarak
/// (yükleniyor, liste geldi, hata oluştu durumlarıyla) yöneten kontrolördür.
class RoomsController extends StateNotifier<AsyncValue<List<RoomModel>>> {
  final RoomRepository _repository; // Oda işlemleri deposu referansı.

  // Kurucu fonksiyon: Başlangıçta yükleniyor (loading) durumunu atar ve hemen kayıtlı odaları yükler.
  RoomsController(this._repository) : super(const AsyncValue.loading()) {
    loadRooms(); // Odaları hafızadan çeker.
  }

  /// Mevcut odaların listesini depodan çekip duruma yansıtan fonksiyon.
  Future<void> loadRooms() async {
    try {
      final rooms = await _repository
          .getRooms(); // Depodan aktif odaları sorgular.
      state = AsyncValue.data(
        rooms,
      ); // Odaları duruma bağlar; UI otomatik olarak listeyi çizer.
    } catch (e, st) {
      state = AsyncValue.error(e, st); // Hata durumunu kaydeder.
    }
  }

  /// Yeni bir çalışma odası oluşturur ve ardından odalar listesini yeniler.
  Future<RoomModel> createRoom({
    required String name,
    required int maxParticipants,
    required String ownerId,
    required String ownerName,
  }) async {
    try {
      // Depodan yeni oda oluşturur.
      final newRoom = await _repository.createRoom(
        name: name,
        maxParticipants: maxParticipants,
        ownerId: ownerId,
        ownerName: ownerName,
      );
      await loadRooms(); // UI listesini güncel tutmak için odaları yeniden yükler.
      return newRoom; // Oluşturulan odayı sayfaya döndürür.
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow; // Hatayı çağıran widget'ın yakalaması için tekrar fırlatır.
    }
  }

  /// Bir odayı siler ve ardından güncel listeyi yeniden yükler.
  Future<void> deleteRoom(String roomId) async {
    try {
      await _repository.deleteRoom(roomId); // Depodan silme işlemini çağırır.
      await loadRooms(); // Silinen odanın ekrandan kaybolması için listeyi yeniler.
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Katılım koduyla odayı sorgulayan yardımcı fonksiyon.
  Future<RoomModel?> joinRoomByCode(String code) async {
    return await _repository.getRoomByCode(code);
  }
}

/// RoomsController'ı arayüze sunan StateNotifierProvider nesnesi.
final roomsControllerProvider =
    StateNotifierProvider<RoomsController, AsyncValue<List<RoomModel>>>((ref) {
      final repo = ref.watch(roomsRepositoryProvider); // Depoyu çözer.
      return RoomsController(repo); // Yeni denetleyici nesnesi üretir.
    });
