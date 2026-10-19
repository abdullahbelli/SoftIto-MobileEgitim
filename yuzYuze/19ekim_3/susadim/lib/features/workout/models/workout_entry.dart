/// Egzersiz kaydı için immutable veri modeli
class WorkoutEntry {
  final String id;
  final String title;
  final int durationMinutes;
  final int burnedCalories;
  final DateTime timestamp;

  const WorkoutEntry({
    required this.id,
    required this.title,
    required this.durationMinutes,
    required this.burnedCalories,
    required this.timestamp,
  });

  WorkoutEntry copyWith({
    String? id,
    String? title,
    int? durationMinutes,
    int? burnedCalories,
    DateTime? timestamp,
  }) {
    return WorkoutEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      burnedCalories: burnedCalories ?? this.burnedCalories,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  factory WorkoutEntry.fromJson(Map<String, dynamic> json) {
    return WorkoutEntry(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      durationMinutes: json['durationMinutes'] as int? ?? 0,
      burnedCalories: json['burnedCalories'] as int? ?? 0,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'durationMinutes': durationMinutes,
      'burnedCalories': burnedCalories,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
