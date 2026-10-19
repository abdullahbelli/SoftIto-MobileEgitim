/// Su tüketim kaydı için immutable veri modeli
class WaterLog {
  final String id;
  final int amountMl;
  final DateTime timestamp;

  const WaterLog({
    required this.id,
    required this.amountMl,
    required this.timestamp,
  });

  WaterLog copyWith({
    String? id,
    int? amountMl,
    DateTime? timestamp,
  }) {
    return WaterLog(
      id: id ?? this.id,
      amountMl: amountMl ?? this.amountMl,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  factory WaterLog.fromJson(Map<String, dynamic> json) {
    return WaterLog(
      id: json['id'] as String? ?? '',
      amountMl: json['amountMl'] as int? ?? 0,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amountMl': amountMl,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
