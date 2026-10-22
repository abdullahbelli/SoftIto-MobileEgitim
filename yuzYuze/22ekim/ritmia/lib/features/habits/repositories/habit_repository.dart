import '../models/habit.dart';
import '../models/habit_day_progress.dart';

/// Alışkanlıklar ve günlük ilerleme kayıtları için Repository sözleşmesi.
/// SQLite veya uzak sunucu veri kaynağına geçişi soyutlar.
abstract interface class HabitRepository {
  Future<List<Habit>> getHabits();
  Future<Habit> addHabit(Habit habit);
  Future<Habit> updateHabit(Habit habit);
  Future<void> deleteHabit(String habitId);
  Future<Map<String, HabitDayProgress>> getProgressMap();
  Future<HabitDayProgress> saveProgress(HabitDayProgress progress);
}
