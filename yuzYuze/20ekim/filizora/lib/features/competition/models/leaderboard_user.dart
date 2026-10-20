/// Liderlik tablosu yarışmacı veri modeli
class LeaderboardUser {
  final String id;
  final String name;
  final int rank;
  final int streakDays;
  final int badgesCount;
  final bool isCurrentUser;

  const LeaderboardUser({
    required this.id,
    required this.name,
    required this.rank,
    required this.streakDays,
    required this.badgesCount,
    this.isCurrentUser = false,
  });

  LeaderboardUser copyWith({
    String? id,
    String? name,
    int? rank,
    int? streakDays,
    int? badgesCount,
    bool? isCurrentUser,
  }) {
    return LeaderboardUser(
      id: id ?? this.id,
      name: name ?? this.name,
      rank: rank ?? this.rank,
      streakDays: streakDays ?? this.streakDays,
      badgesCount: badgesCount ?? this.badgesCount,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
    );
  }

  factory LeaderboardUser.fromJson(Map<String, dynamic> json) {
    return LeaderboardUser(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      rank: json['rank'] as int? ?? 0,
      streakDays: json['streakDays'] as int? ?? 0,
      badgesCount: json['badgesCount'] as int? ?? 0,
      isCurrentUser: json['isCurrentUser'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rank': rank,
      'streakDays': streakDays,
      'badgesCount': badgesCount,
      'isCurrentUser': isCurrentUser,
    };
  }
}
