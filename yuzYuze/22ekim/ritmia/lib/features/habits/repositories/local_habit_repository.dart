import 'package:uuid/uuid.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/date_utils.dart';
import '../models/habit.dart';
import '../models/habit_day_progress.dart';
import 'habit_repository.dart';

/// Alışkanlıkların SharedPreferences üzerinden yerel kalıcılığını sağlayan implementasyon.
/// Uygulama ilk açıldığında zengin demo alışkanlıkları ve geçmiş kayıtları yükler.
class LocalHabitRepository implements HabitRepository {
  final StorageService _storageService;
  final Uuid _uuid = const Uuid();

  LocalHabitRepository(this._storageService);

  @override
  Future<List<Habit>> getHabits() async {
    final list = _storageService.getHabits();
    if (list.isEmpty) {
      // İlk açılışta örnek alışkanlıklar oluştur
      final initialHabits = _generateInitialDemoHabits();
      await _storageService.saveHabits(initialHabits.map((e) => e.toMap()).toList());

      // Örnek geçmiş tamamlama kayıtları oluştur
      final initialProgress = _generateInitialProgress(initialHabits);
      await _storageService.saveDayProgressMap(
        initialProgress.map((k, v) => MapEntry(k, v.toMap())),
      );

      return initialHabits;
    }
    return list.map((e) => Habit.fromMap(e)).toList();
  }

  @override
  Future<Habit> addHabit(Habit habit) async {
    final habits = await getHabits();
    final newHabit = habit.id.isEmpty
        ? habit.copyWith(id: _uuid.v4(), createdAt: DateTime.now(), updatedAt: DateTime.now())
        : habit;

    habits.add(newHabit);
    await _storageService.saveHabits(habits.map((e) => e.toMap()).toList());
    return newHabit;
  }

  @override
  Future<Habit> updateHabit(Habit habit) async {
    final habits = await getHabits();
    final index = habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      final updated = habit.copyWith(updatedAt: DateTime.now());
      habits[index] = updated;
      await _storageService.saveHabits(habits.map((e) => e.toMap()).toList());
      return updated;
    }
    return habit;
  }

  @override
  Future<void> deleteHabit(String habitId) async {
    final habits = await getHabits();
    final index = habits.indexWhere((h) => h.id == habitId);
    if (index != -1) {
      // Soft delete: Geçmiş istatistikleri ve takvimi korumak için archivedAt atanır
      final softDeleted = habits[index].copyWith(
        archivedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      habits[index] = softDeleted;
      await _storageService.saveHabits(habits.map((e) => e.toMap()).toList());
    }
  }

  @override
  Future<Map<String, HabitDayProgress>> getProgressMap() async {
    final map = _storageService.getDayProgressMap();
    return map.map((key, value) => MapEntry(key, HabitDayProgress.fromMap(value)));
  }

  @override
  Future<HabitDayProgress> saveProgress(HabitDayProgress progress) async {
    final map = _storageService.getDayProgressMap();
    final key = '${progress.habitId}_${progress.localDate}';
    final updatedProgress = progress.copyWith(updatedAt: DateTime.now());

    map[key] = updatedProgress.toMap();
    await _storageService.saveDayProgressMap(map);
    return updatedProgress;
  }

  List<Habit> _generateInitialDemoHabits() {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 10));

    return [
      Habit(
        id: 'demo_habit_1',
        userId: 'demo_user',
        name: 'Günde 2 Litre Su İç',
        description: 'Vücudun hidrasyonunu koru',
        category: 'Sağlık',
        iconKey: 'favorite',
        accentColorKey: 'blue',
        targetType: 'count',
        targetValue: 8.0, // 8 bardak
        scheduledWeekdays: const [1, 2, 3, 4, 5, 6, 7],
        startDate: start,
        createdAt: start,
        updatedAt: start,
      ),
      Habit(
        id: 'demo_habit_2',
        userId: 'demo_user',
        name: 'Kitap Oku (20 Sayfa)',
        description: 'Her akşam zihnini dinlendir',
        category: 'Öğrenme',
        iconKey: 'book',
        accentColorKey: 'purple',
        targetType: 'count',
        targetValue: 20.0,
        scheduledWeekdays: const [1, 2, 3, 4, 5, 6, 7],
        startDate: start,
        createdAt: start,
        updatedAt: start,
      ),
      Habit(
        id: 'demo_habit_3',
        userId: 'demo_user',
        name: '30 Dk Tempolu Yürüyüş',
        description: 'Açık havada ritmini yakala',
        category: 'Spor',
        iconKey: 'fitness',
        accentColorKey: 'orange',
        targetType: 'duration',
        targetValue: 30.0,
        scheduledWeekdays: const [1, 2, 3, 4, 5], // Hafta içi
        startDate: start,
        createdAt: start,
        updatedAt: start,
      ),
    ];
  }

  Map<String, HabitDayProgress> _generateInitialProgress(List<Habit> habits) {
    final result = <String, HabitDayProgress>{};
    final now = DateTime.now();

    // Son 3 gün için tamamlanma kayıtları üret (aktif streak göstermek için)
    for (int dayOffset = 1; dayOffset <= 3; dayOffset++) {
      final date = now.subtract(Duration(days: dayOffset));
      final dateStr = AppDateUtils.toDateString(date);

      for (final habit in habits) {
        if (habit.isScheduledOn(date)) {
          final key = '${habit.id}_$dateStr';
          result[key] = HabitDayProgress(
            habitId: habit.id,
            localDate: dateStr,
            amount: habit.targetValue,
            targetSnapshot: habit.targetValue,
            completedAt: date,
            scheduleSnapshot: habit.scheduledWeekdays,
            updatedAt: date,
          );
        }
      }
    }

    return result;
  }
}
