/// Kazanılmış rozet modeli.
/// Rozetin kimliğini, hangi alışkanlıktan kazanıldığını ve tarihini tutar.
class EarnedBadge {
  final String id;
  final String badgeId;
  final String userId;
  final String? habitId;
  final String? habitName;
  final DateTime earnedAt;

  const EarnedBadge({
    required this.id,
    required this.badgeId,
    required this.userId,
    this.habitId,
    this.habitName,
    required this.earnedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'badgeId': badgeId,
      'userId': userId,
      'habitId': habitId,
      'habitName': habitName,
      'earnedAt': earnedAt.toIso8601String(),
    };
  }

  factory EarnedBadge.fromMap(Map<String, dynamic> map) {
    return EarnedBadge(
      id: map['id'] as String,
      badgeId: map['badgeId'] as String,
      userId: map['userId'] as String? ?? 'user_1',
      habitId: map['habitId'] as String?,
      habitName: map['habitName'] as String?,
      earnedAt: map['earnedAt'] != null
          ? DateTime.tryParse(map['earnedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
