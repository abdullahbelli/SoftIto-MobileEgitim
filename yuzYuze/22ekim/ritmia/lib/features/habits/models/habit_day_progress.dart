/// Günlük alışkanlık tamamlama ve ilerleme kaydı.
/// Bir alışkanlığın belirli bir gündeki miktarını ve hedefe ulaşma durumunu saklar.
/// Geçmiş günlerin hedeflerini korumak için targetSnapshot tutar.
class HabitDayProgress {
  final String habitId;
  final String localDate; // 'YYYY-MM-DD'
  final double amount;
  final double targetSnapshot;
  final DateTime? completedAt;
  final List<int> scheduleSnapshot;
  final DateTime updatedAt;

  const HabitDayProgress({
    required this.habitId,
    required this.localDate,
    required this.amount,
    required this.targetSnapshot,
    this.completedAt,
    this.scheduleSnapshot = const [1, 2, 3, 4, 5, 6, 7],
    required this.updatedAt,
  });

  /// Hedefe ulaşıldı mı?
  bool get isCompleted => amount >= targetSnapshot && targetSnapshot > 0;

  /// 0.0 ile 1.0 arasında tamamlanma oranı
  double get ratio {
    if (targetSnapshot <= 0) return 0.0;
    final r = amount / targetSnapshot;
    return r > 1.0 ? 1.0 : (r < 0.0 ? 0.0 : r);
  }

  HabitDayProgress copyWith({
    String? habitId,
    String? localDate,
    double? amount,
    double? targetSnapshot,
    DateTime? completedAt,
    List<int>? scheduleSnapshot,
    DateTime? updatedAt,
  }) {
    return HabitDayProgress(
      habitId: habitId ?? this.habitId,
      localDate: localDate ?? this.localDate,
      amount: amount ?? this.amount,
      targetSnapshot: targetSnapshot ?? this.targetSnapshot,
      completedAt: completedAt ?? this.completedAt,
      scheduleSnapshot: scheduleSnapshot ?? this.scheduleSnapshot,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'habitId': habitId,
      'localDate': localDate,
      'amount': amount,
      'targetSnapshot': targetSnapshot,
      'completedAt': completedAt?.toIso8601String(),
      'scheduleSnapshot': scheduleSnapshot,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory HabitDayProgress.fromMap(Map<String, dynamic> map) {
    return HabitDayProgress(
      habitId: map['habitId'] as String,
      localDate: map['localDate'] as String,
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      targetSnapshot: (map['targetSnapshot'] as num?)?.toDouble() ?? 1.0,
      completedAt: map['completedAt'] != null
          ? DateTime.tryParse(map['completedAt'] as String)
          : null,
      scheduleSnapshot: (map['scheduleSnapshot'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [1, 2, 3, 4, 5, 6, 7],
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
