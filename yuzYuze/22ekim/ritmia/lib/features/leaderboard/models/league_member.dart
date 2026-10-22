/// Lig üyesi veri modeli.
/// Liderlik tablosundaki yarışmacının puanını, sıralamasını ve durumunu tutar.
class LeagueMember {
  final String id;
  final String leagueId;
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final int score;
  final int completedHabitsCount;
  final int maxStreak;
  final bool isCurrentUser;

  const LeagueMember({
    required this.id,
    required this.leagueId,
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    required this.score,
    required this.completedHabitsCount,
    required this.maxStreak,
    this.isCurrentUser = false,
  });

  LeagueMember copyWith({
    String? id,
    String? leagueId,
    String? userId,
    String? displayName,
    String? avatarUrl,
    int? score,
    int? completedHabitsCount,
    int? maxStreak,
    bool? isCurrentUser,
  }) {
    return LeagueMember(
      id: id ?? this.id,
      leagueId: leagueId ?? this.leagueId,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      score: score ?? this.score,
      completedHabitsCount: completedHabitsCount ?? this.completedHabitsCount,
      maxStreak: maxStreak ?? this.maxStreak,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'leagueId': leagueId,
      'userId': userId,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'score': score,
      'completedHabitsCount': completedHabitsCount,
      'maxStreak': maxStreak,
      'isCurrentUser': isCurrentUser,
    };
  }

  factory LeagueMember.fromMap(Map<String, dynamic> map) {
    return LeagueMember(
      id: map['id'] as String,
      leagueId: map['leagueId'] as String,
      userId: map['userId'] as String,
      displayName: map['displayName'] as String,
      avatarUrl: map['avatarUrl'] as String?,
      score: (map['score'] as num?)?.toInt() ?? 0,
      completedHabitsCount: (map['completedHabitsCount'] as num?)?.toInt() ?? 0,
      maxStreak: (map['maxStreak'] as num?)?.toInt() ?? 0,
      isCurrentUser: map['isCurrentUser'] as bool? ?? false,
    );
  }
}
