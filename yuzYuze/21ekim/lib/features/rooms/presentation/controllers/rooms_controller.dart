import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:boardconnect/app/theme/theme_provider.dart';

import '../../domain/room_model.dart';
import '../../domain/room_repository.dart';
import '../../data/local_room_repository.dart';

/// Odalar Repository Provider'ı
final roomsRepositoryProvider = Provider<RoomRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalRoomRepository(prefs);
});

/// Odalar Durum Yöneticisi
class RoomsController extends StateNotifier<AsyncValue<List<RoomModel>>> {
  final RoomRepository _repository;

  RoomsController(this._repository) : super(const AsyncValue.loading()) {
    loadRooms();
  }

  Future<void> loadRooms() async {
    try {
      final rooms = await _repository.getRooms();
      state = AsyncValue.data(rooms);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<RoomModel> createRoom({
    required String name,
    required int maxParticipants,
    required String ownerId,
    required String ownerName,
  }) async {
    try {
      final newRoom = await _repository.createRoom(
        name: name,
        maxParticipants: maxParticipants,
        ownerId: ownerId,
        ownerName: ownerName,
      );
      await loadRooms();
      return newRoom;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteRoom(String roomId) async {
    try {
      await _repository.deleteRoom(roomId);
      await loadRooms();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<RoomModel?> joinRoomByCode(String code) async {
    return await _repository.getRoomByCode(code);
  }
}

final roomsControllerProvider =
    StateNotifierProvider<RoomsController, AsyncValue<List<RoomModel>>>((ref) {
      final repo = ref.watch(roomsRepositoryProvider);
      return RoomsController(repo);
    });
