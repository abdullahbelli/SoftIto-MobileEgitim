/// Alışkanlık veri modeli.
/// Alışkanlığın adını, kategorisini, hedef türünü (tamamlandı/adet/dakika),
/// planlanan günlerini ve geçerlilik tarihlerini saklar.
class Habit {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String category;
  final String iconKey;
  final String accentColorKey;
  final String targetType; // 'check', 'count', 'duration'
  final double targetValue; // Hedef miktar (örn: 1 kez, 20 sayfa, 30 dk)
  final List<int> scheduledWeekdays; // 1 = Pazartesi ... 7 = Pazar
  final DateTime startDate;
  final DateTime? endDate;
  final String? reminderTime;
  final DateTime? archivedAt; // Soft delete için
  final DateTime createdAt;
  final DateTime updatedAt;

  const Habit({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.category,
    this.iconKey = 'default',
    this.accentColorKey = 'pink',
    this.targetType = 'check',
    this.targetValue = 1.0,
    this.scheduledWeekdays = const [1, 2, 3, 4, 5, 6, 7], // Varsayılan her gün
    required this.startDate,
    this.endDate,
    this.reminderTime,
    this.archivedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Belirtilen tarihte bu alışkanlığın planlanıp planlanmadığını kontrol eder
  bool isScheduledOn(DateTime date) {
    if (archivedAt != null) return false;

    final dateOnly = DateTime(date.year, date.month, date.day);
    final startOnly = DateTime(startDate.year, startDate.month, startDate.day);
    if (dateOnly.isBefore(startOnly)) return false;

    if (endDate != null) {
      final endOnly = DateTime(endDate!.year, endDate!.month, endDate!.day);
      if (dateOnly.isAfter(endOnly)) return false;
    }

    return scheduledWeekdays.contains(date.weekday);
  }

  bool get isArchived => archivedAt != null;

  Habit copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? category,
    String? iconKey,
    String? accentColorKey,
    String? targetType,
    double? targetValue,
    List<int>? scheduledWeekdays,
    DateTime? startDate,
    DateTime? endDate,
    String? reminderTime,
    DateTime? archivedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Habit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      iconKey: iconKey ?? this.iconKey,
      accentColorKey: accentColorKey ?? this.accentColorKey,
      targetType: targetType ?? this.targetType,
      targetValue: targetValue ?? this.targetValue,
      scheduledWeekdays: scheduledWeekdays ?? this.scheduledWeekdays,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reminderTime: reminderTime ?? this.reminderTime,
      archivedAt: archivedAt ?? this.archivedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'category': category,
      'iconKey': iconKey,
      'accentColorKey': accentColorKey,
      'targetType': targetType,
      'targetValue': targetValue,
      'scheduledWeekdays': scheduledWeekdays,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'reminderTime': reminderTime,
      'archivedAt': archivedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'] as String,
      userId: map['userId'] as String? ?? 'user_1',
      name: map['name'] as String,
      description: map['description'] as String?,
      category: map['category'] as String? ?? 'Diğer',
      iconKey: map['iconKey'] as String? ?? 'default',
      accentColorKey: map['accentColorKey'] as String? ?? 'pink',
      targetType: map['targetType'] as String? ?? 'check',
      targetValue: (map['targetValue'] as num?)?.toDouble() ?? 1.0,
      scheduledWeekdays: (map['scheduledWeekdays'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [1, 2, 3, 4, 5, 6, 7],
      startDate: map['startDate'] != null
          ? DateTime.tryParse(map['startDate'] as String) ?? DateTime.now()
          : DateTime.now(),
      endDate: map['endDate'] != null
          ? DateTime.tryParse(map['endDate'] as String)
          : null,
      reminderTime: map['reminderTime'] as String?,
      archivedAt: map['archivedAt'] != null
          ? DateTime.tryParse(map['archivedAt'] as String)
          : null,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
