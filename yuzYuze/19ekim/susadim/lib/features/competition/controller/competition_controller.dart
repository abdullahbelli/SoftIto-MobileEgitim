import 'package:flutter/foundation.dart';
import '../models/leaderboard_user.dart';

class CompetitionController extends ChangeNotifier {
  CompetitionController() {
    _initDefaultUsers();
  }

  final List<LeaderboardUser> _users = <LeaderboardUser>[];

  List<LeaderboardUser> get users => List.unmodifiable(_users);

  LeaderboardUser get currentUser => _users.firstWhere(
        (u) => u.isCurrentUser,
        orElse: () => const LeaderboardUser(
          id: 'me',
          name: 'Sen',
          streakDays: 0,
          totalScore: 0,
          rank: 0,
          isCurrentUser: true,
        ),
      );

  List<LeaderboardUser> get topThree =>
      _users.length >= 3 ? _users.sublist(0, 3) : _users;

  List<LeaderboardUser> get remainingUsers =>
      _users.length > 3 ? _users.sublist(3) : <LeaderboardUser>[];

  void _initDefaultUsers() {
    _users.addAll(const [
      LeaderboardUser(
        id: '1',
        name: 'Mert Yılmaz',
        streakDays: 28,
        totalScore: 2800,
        rank: 1,
      ),
      LeaderboardUser(
        id: '2',
        name: 'Selin Kaya',
        streakDays: 24,
        totalScore: 2400,
        rank: 2,
      ),
      LeaderboardUser(
        id: '3',
        name: 'Burak Demir',
        streakDays: 21,
        totalScore: 2100,
        rank: 3,
      ),
      LeaderboardUser(
        id: 'me',
        name: 'Sen',
        streakDays: 19,
        totalScore: 1900,
        rank: 4,
        isCurrentUser: true,
      ),
      LeaderboardUser(
        id: '5',
        name: 'Ayşe Çelik',
        streakDays: 15,
        totalScore: 1500,
        rank: 5,
      ),
      LeaderboardUser(
        id: '6',
        name: 'Efe Koç',
        streakDays: 12,
        totalScore: 1200,
        rank: 6,
      ),
    ]);
  }

  void challengeUser(String userId) {
    final index = _users.indexWhere((u) => u.id == userId);
    if (index == -1) return;

    final target = _users[index];
    _users[index] = target.copyWith(isChallenged: !target.isChallenged);
    notifyListeners();
  }

  void boostCurrentUserStreak() {
    final myIndex = _users.indexWhere((u) => u.isCurrentUser);
    if (myIndex == -1) return;

    final me = _users[myIndex];
    final updatedDays = me.streakDays + 1;
    _users[myIndex] = me.copyWith(
      streakDays: updatedDays,
      totalScore: updatedDays * 100,
    );

    _sortAndReRank();
    notifyListeners();
  }

  void _sortAndReRank() {
    _users.sort((a, b) => b.streakDays.compareTo(a.streakDays));
    for (int i = 0; i < _users.length; i++) {
      _users[i] = _users[i].copyWith(rank: i + 1);
    }
  }
}
