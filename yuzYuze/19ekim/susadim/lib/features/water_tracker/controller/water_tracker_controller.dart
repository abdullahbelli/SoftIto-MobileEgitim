import 'package:flutter/foundation.dart';
import '../models/water_log.dart';

class WaterTrackerController extends ChangeNotifier {
  WaterTrackerController({this.dailyTargetMl = 2500});

  final int dailyTargetMl;
  final List<WaterLog> _logs = <WaterLog>[];
  List<WaterLog> get logs => List.unmodifiable(_logs);

  int get totalConsumedMl =>
      _logs.fold<int>(0, (sum, item) => sum + item.amountMl);

  double get progressRatio {
    if (dailyTargetMl == 0) return 0.0;
    final ratio = totalConsumedMl / dailyTargetMl;
    return ratio > 1.0 ? 1.0 : ratio;
  }

  int get remainingMl {
    final remaining = dailyTargetMl - totalConsumedMl;
    return remaining < 0 ? 0 : remaining;
  }

  void addWater(int amountMl, {String label = 'Su'}) {
    if (amountMl <= 0) return;
    final log = WaterLog(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      amountMl: amountMl,
      timestamp: DateTime.now(),
      label: label,
    );
    _logs.insert(0, log);
    notifyListeners();
  }

  void removeLog(String id) {
    _logs.removeWhere((log) => log.id == id);
    notifyListeners();
  }

  void resetToday() {
    _logs.clear();
    notifyListeners();
  }
}
