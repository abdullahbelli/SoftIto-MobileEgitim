class LeaderboardUser {
  const LeaderboardUser({
    required this.id,
    required this.name,
    required this.streakDays,
    required this.totalScore,
    required this.rank,
    this.isCurrentUser = false,
    this.isChallenged = false,
  });

  final String id;
  final String name;
  final int streakDays;
  final int totalScore;
  final int rank;
  final bool isCurrentUser;
  final bool isChallenged;

  LeaderboardUser copyWith({
    String? id,
    String? name,
    int? streakDays,
    int? totalScore,
    int? rank,
    bool? isCurrentUser,
    bool? isChallenged,
  }) {
    return LeaderboardUser(
      id: id ?? this.id,
      name: name ?? this.name,
      streakDays: streakDays ?? this.streakDays,
      totalScore: totalScore ?? this.totalScore,
      rank: rank ?? this.rank,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
      isChallenged: isChallenged ?? this.isChallenged,
    );
  }
}
