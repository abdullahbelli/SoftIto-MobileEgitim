import 'package:flutter/foundation.dart';
import '../models/leaderboard_user.dart';

/// Yarışma ve Liderlik Durum Yöneticisi (ValueNotifier Tabanlı)
class CompetitionController {
  final ValueNotifier<int> userStreak = ValueNotifier<int>(14);

  final ValueNotifier<List<LeaderboardUser>> leaderboard =
      ValueNotifier<List<LeaderboardUser>>([
    const LeaderboardUser(
      id: '1',
      name: 'Ece Demir',
      rank: 1,
      streakDays: 42,
      badgesCount: 12,
    ),
    const LeaderboardUser(
      id: '2',
      name: 'Burak Yılmaz',
      rank: 2,
      streakDays: 35,
      badgesCount: 9,
    ),
    const LeaderboardUser(
      id: '3',
      name: 'Selin Kaya',
      rank: 3,
      streakDays: 28,
      badgesCount: 8,
    ),
    const LeaderboardUser(
      id: '4',
      name: 'Sen (Kullanıcı)',
      rank: 4,
      streakDays: 14,
      badgesCount: 5,
      isCurrentUser: true,
    ),
    const LeaderboardUser(
      id: '5',
      name: 'Kaan Öztürk',
      rank: 5,
      streakDays: 12,
      badgesCount: 4,
    ),
  ]);

  void boostStreak() {
    userStreak.value += 1;
    final updated = leaderboard.value.map((user) {
      if (user.isCurrentUser) {
        return user.copyWith(streakDays: userStreak.value);
      }
      return user;
    }).toList();
    leaderboard.value = updated;
  }

  void dispose() {
    userStreak.dispose();
    leaderboard.dispose();
  }
}
