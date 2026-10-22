import '../../auth/models/user_profile.dart';
import '../models/league.dart';
import '../models/league_member.dart';
import '../services/leaderboard_service.dart';
import 'leaderboard_repository.dart';

/// Gerçek backend bulunmadığı için açıkça etiketlenmiş demo lig veri kaynağı.
/// project.md Kuralı: Gerçek kullanıcıları taklit etmez, açıkça "Demo Yarışmacı"
/// etiketleriyle 15 kişilik simüle grup üretir.
class DemoLeaderboardRepository implements LeaderboardRepository {
  final LeaderboardService _service;

  DemoLeaderboardRepository(this._service);

  @override
  Future<League> getWeeklyLeague({
    required String weekId,
    required UserProfile user,
    required int userScore,
    required int userCompletedCount,
    required int userMaxStreak,
  }) async {
    // 14 adet örnek demo yarışmacı
    final demoParticipants = [
      const LeagueMember(
        id: 'demo_m_1',
        leagueId: 'league_tohum_1',
        userId: 'u_demo_1',
        displayName: 'Aylin R. (Demo)',
        score: 180,
        completedHabitsCount: 16,
        maxStreak: 7,
      ),
      const LeagueMember(
        id: 'demo_m_2',
        leagueId: 'league_tohum_1',
        userId: 'u_demo_2',
        displayName: 'Burak D. (Demo)',
        score: 165,
        completedHabitsCount: 15,
        maxStreak: 6,
      ),
      const LeagueMember(
        id: 'demo_m_3',
        leagueId: 'league_tohum_1',
        userId: 'u_demo_3',
        displayName: 'Ceren K. (Demo)',
        score: 150,
        completedHabitsCount: 14,
        maxStreak: 5,
      ),
      const LeagueMember(
        id: 'demo_m_4',
        leagueId: 'league_tohum_1',
        userId: 'u_demo_4',
        displayName: 'Deniz T. (Demo)',
        score: 140,
        completedHabitsCount: 13,
        maxStreak: 5,
      ),
      const LeagueMember(
        id: 'demo_m_5',
        leagueId: 'league_tohum_1',
        userId: 'u_demo_5',
        displayName: 'Emre S. (Demo)',
        score: 125,
        completedHabitsCount: 11,
        maxStreak: 4,
      ),
      const LeagueMember(
        id: 'demo_m_6',
        leagueId: 'league_tohum_1',
        userId: 'u_demo_6',
        displayName: 'Fatma Y. (Demo)',
        score: 110,
        completedHabitsCount: 10,
        maxStreak: 4,
      ),
      const LeagueMember(
        id: 'demo_m_7',
        leagueId: 'league_tohum_1',
        userId: 'u_demo_7',
        displayName: 'Gökhan B. (Demo)',
        score: 95,
        completedHabitsCount: 9,
        maxStreak: 3,
      ),
      const LeagueMember(
        id: 'demo_m_8',
        leagueId: 'league_tohum_1',
        userId: 'u_demo_8',
        displayName: 'Hilal M. (Demo)',
        score: 85,
        completedHabitsCount: 8,
        maxStreak: 3,
      ),
      const LeagueMember(
        id: 'demo_m_9',
        leagueId: 'league_tohum_1',
        userId: 'u_demo_9',
        displayName: 'İlker Ö. (Demo)',
        score: 75,
        completedHabitsCount: 7,
        maxStreak: 2,
      ),
      const LeagueMember(
        id: 'demo_m_10',
        leagueId: 'league_tohum_1',
        userId: 'u_demo_10',
        displayName: 'Jale A. (Demo)',
        score: 65,
        completedHabitsCount: 6,
        maxStreak: 2,
      ),
      const LeagueMember(
        id: 'demo_m_11',
        leagueId: 'league_tohum_1',
        userId: 'u_demo_11',
        displayName: 'Kemal N. (Demo)',
        score: 50,
        completedHabitsCount: 5,
        maxStreak: 2,
      ),
      const LeagueMember(
        id: 'demo_m_12',
        leagueId: 'league_tohum_1',
        userId: 'u_demo_12',
        displayName: 'Leyla V. (Demo)',
        score: 40,
        completedHabitsCount: 4,
        maxStreak: 1,
      ),
      const LeagueMember(
        id: 'demo_m_13',
        leagueId: 'league_tohum_1',
        userId: 'u_demo_13',
        displayName: 'Murat H. (Demo)',
        score: 30,
        completedHabitsCount: 3,
        maxStreak: 1,
      ),
      const LeagueMember(
        id: 'demo_m_14',
        leagueId: 'league_tohum_1',
        userId: 'u_demo_14',
        displayName: 'Nazlı E. (Demo)',
        score: 20,
        completedHabitsCount: 2,
        maxStreak: 1,
      ),
    ];

    // Aktif kullanıcının gerçek puanlarıyla lige dahil edilmesi
    final currentMember = LeagueMember(
      id: 'current_user_member',
      leagueId: 'league_tohum_1',
      userId: user.id,
      displayName: '${user.fullName.isNotEmpty ? user.fullName : user.username} (Sen)',
      score: userScore > 0 ? userScore : 100, // Yeni kullanıcıya örnek 100 veya gerçek puan
      completedHabitsCount: userCompletedCount > 0 ? userCompletedCount : 9,
      maxStreak: userMaxStreak > 0 ? userMaxStreak : 3,
      isCurrentUser: true,
    );

    final allMembers = [...demoParticipants, currentMember];
    final sortedMembers = _service.sortMembers(allMembers);

    return League(
      id: 'league_tohum_1',
      tier: 'Tohum',
      weekId: weekId,
      maxMembers: 15,
      members: sortedMembers,
    );
  }
}
