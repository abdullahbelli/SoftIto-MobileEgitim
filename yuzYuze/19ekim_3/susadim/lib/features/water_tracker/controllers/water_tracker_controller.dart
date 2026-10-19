import 'package:flutter/foundation.dart';
import '../models/water_log.dart';

/// Su Takibi Durum Yöneticisi (ValueNotifier Tabanlı)
class WaterTrackerController {
  final ValueNotifier<int> currentWater = ValueNotifier<int>(1250);
  final ValueNotifier<List<WaterLog>> logs = ValueNotifier<List<WaterLog>>([
    WaterLog(
      id: '1',
      amountMl: 500,
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    WaterLog(
      id: '2',
      amountMl: 250,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    WaterLog(
      id: '3',
      amountMl: 500,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ]);

  final int dailyGoalWater = 2500; // ml cinsinden günlük hedef

  double get progress => (currentWater.value / dailyGoalWater).clamp(0.0, 1.0);

  void addWater(int amountMl) {
    currentWater.value += amountMl;
    final newLog = WaterLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amountMl: amountMl,
      timestamp: DateTime.now(),
    );
    logs.value = [newLog, ...logs.value];
  }

  void resetWater() {
    currentWater.value = 0;
    logs.value = [];
  }

  void dispose() {
    currentWater.dispose();
    logs.dispose();
  }
}
