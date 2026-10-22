import 'package:flutter/foundation.dart';
import '../../../core/utils/date_utils.dart';
import '../models/habit.dart';
import '../models/habit_day_progress.dart';
import '../repositories/habit_repository.dart';
import '../services/habit_streak_service.dart';

/// Alışkanlıklar ekranı ve kart etkileşimlerinin durumunu yöneten MVC Controller.
/// View katmanına alışkanlık listesi, genel seri (streak) ve ilerleme verilerini sunar.
class HabitController extends ChangeNotifier {
  final HabitRepository _repository;
  final HabitStreakService _streakService;

  List<Habit> _habits = [];
  Map<String, HabitDayProgress> _progressMap = {};
  bool _isLoading = false;
  String? _errorMessage;

  HabitController(this._repository, this._streakService);

  List<Habit> get habits => _habits;
  List<Habit> get activeHabits => _habits.where((h) => !h.isArchived).toList();
  Map<String, HabitDayProgress> get progressMap => _progressMap;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Genel seri (o gün planlanan tüm alışkanlıklar yapıldıysa artan alev serisi)
  int get overallStreak => _streakService.calculateOverallStreak(
        habits: _habits,
        progressMap: _progressMap,
      );

  /// Alışkanlığa özel ardışık planlı gün serisi
  int getHabitStreak(Habit habit) => _streakService.calculateHabitStreak(
        habit: habit,
        progressMap: _progressMap,
      );

  /// Belirtilen tarihteki ilerlemeyi döner (varsayılan: bugün)
  HabitDayProgress? getProgress(String habitId, [DateTime? date]) {
    final targetDate = date ?? DateTime.now();
    final dateStr = AppDateUtils.toDateString(targetDate);
    return _progressMap['${habitId}_$dateStr'];
  }

  /// Verileri yükler
  Future<void> loadHabits() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _habits = await _repository.getHabits();
      _progressMap = await _repository.getProgressMap();
    } catch (e) {
      _errorMessage = 'Alışkanlıklar yüklenirken bir sorun oluştu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Yeni alışkanlık ekler
  Future<bool> addHabit(Habit habit) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final saved = await _repository.addHabit(habit);
      _habits.add(saved);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Alışkanlık eklenemedi: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mevcut alışkanlığı günceller
  Future<bool> updateHabit(Habit habit) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _repository.updateHabit(habit);
      final index = _habits.indexWhere((h) => h.id == updated.id);
      if (index != -1) {
        _habits[index] = updated;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Alışkanlık güncellenemedi: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Alışkanlığı siler (Soft delete)
  Future<bool> deleteHabit(String habitId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteHabit(habitId);
      final index = _habits.indexWhere((h) => h.id == habitId);
      if (index != -1) {
        _habits[index] = _habits[index].copyWith(archivedAt: DateTime.now());
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Alışkanlık silinemedi: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Hedefi tamamlandı/tamamlanmadı durumuna göre değiştirir (Toggle)
  Future<void> toggleProgress(String habitId, [DateTime? date]) async {
    final habit = _habits.firstWhere((h) => h.id == habitId, orElse: () => throw Exception('Alışkanlık bulunamadı'));
    final targetDate = date ?? DateTime.now();
    final dateStr = AppDateUtils.toDateString(targetDate);
    final key = '${habitId}_$dateStr';

    final current = _progressMap[key];
    final isAlreadyCompleted = current != null && current.isCompleted;

    final newAmount = isAlreadyCompleted ? 0.0 : habit.targetValue;
    final progress = HabitDayProgress(
      habitId: habitId,
      localDate: dateStr,
      amount: newAmount,
      targetSnapshot: habit.targetValue,
      completedAt: newAmount >= habit.targetValue ? DateTime.now() : null,
      scheduleSnapshot: habit.scheduledWeekdays,
      updatedAt: DateTime.now(),
    );

    _progressMap[key] = progress;
    notifyListeners();

    await _repository.saveProgress(progress);
  }

  /// Hedef miktarını artırır (Örn: Adet veya dakika için +1)
  Future<void> incrementProgress(String habitId, [DateTime? date, double step = 1.0]) async {
    final habit = _habits.firstWhere((h) => h.id == habitId);
    final targetDate = date ?? DateTime.now();
    final dateStr = AppDateUtils.toDateString(targetDate);
    final key = '${habitId}_$dateStr';

    final current = _progressMap[key];
    final currentAmount = current?.amount ?? 0.0;
    final newAmount = currentAmount + step;

    final progress = HabitDayProgress(
      habitId: habitId,
      localDate: dateStr,
      amount: newAmount,
      targetSnapshot: habit.targetValue,
      completedAt: newAmount >= habit.targetValue ? DateTime.now() : null,
      scheduleSnapshot: habit.scheduledWeekdays,
      updatedAt: DateTime.now(),
    );

    _progressMap[key] = progress;
    notifyListeners();

    await _repository.saveProgress(progress);
  }

  /// Hedef miktarını azaltır
  Future<void> decrementProgress(String habitId, [DateTime? date, double step = 1.0]) async {
    final habit = _habits.firstWhere((h) => h.id == habitId);
    final targetDate = date ?? DateTime.now();
    final dateStr = AppDateUtils.toDateString(targetDate);
    final key = '${habitId}_$dateStr';

    final current = _progressMap[key];
    final currentAmount = current?.amount ?? 0.0;
    final newAmount = (currentAmount - step).clamp(0.0, double.infinity);

    final progress = HabitDayProgress(
      habitId: habitId,
      localDate: dateStr,
      amount: newAmount,
      targetSnapshot: habit.targetValue,
      completedAt: newAmount >= habit.targetValue ? DateTime.now() : null,
      scheduleSnapshot: habit.scheduledWeekdays,
      updatedAt: DateTime.now(),
    );

    _progressMap[key] = progress;
    notifyListeners();

    await _repository.saveProgress(progress);
  }
}
