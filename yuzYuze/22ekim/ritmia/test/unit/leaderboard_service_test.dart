import 'package:flutter_test/flutter_test.dart';
import 'package:ritmia/features/leaderboard/models/league_member.dart';
import 'package:ritmia/features/leaderboard/services/leaderboard_service.dart';

void main() {
  group('LeaderboardService Tests', () {
    late LeaderboardService service;

    setUp(() {
      service = LeaderboardService();
    });

    test('15 kişilik grupta ilk 5 yükselir, son 5 düşer, orta 5 korunur', () {
      const total = 15;

      // İlk 5 (indeks 0..4) -> promote
      for (int i = 0; i < 5; i++) {
        final zone = service.calculateMemberZone(rankZeroIndexed: i, totalMembers: total);
        expect(zone, LeagueZone.promote, reason: 'Index $i should promote');
      }

      // Orta 5 (indeks 5..9) -> maintain
      for (int i = 5; i < 10; i++) {
        final zone = service.calculateMemberZone(rankZeroIndexed: i, totalMembers: total);
        expect(zone, LeagueZone.maintain, reason: 'Index $i should maintain');
      }

      // Son 5 (indeks 10..14) -> demote
      for (int i = 10; i < 15; i++) {
        final zone = service.calculateMemberZone(rankZeroIndexed: i, totalMembers: total);
        expect(zone, LeagueZone.demote, reason: 'Index $i should demote');
      }
    });

    test('10 kişilik veya daha az grupta floor(N/3) kuralı çakışmayı önler', () {
      const total = 9; // 9 / 3 = 3 kişi yükselir, 3 kişi düşer, 3 kişi kalır

      expect(service.calculateMemberZone(rankZeroIndexed: 0, totalMembers: total), LeagueZone.promote);
      expect(service.calculateMemberZone(rankZeroIndexed: 2, totalMembers: total), LeagueZone.promote);
      expect(service.calculateMemberZone(rankZeroIndexed: 3, totalMembers: total), LeagueZone.maintain);
      expect(service.calculateMemberZone(rankZeroIndexed: 5, totalMembers: total), LeagueZone.maintain);
      expect(service.calculateMemberZone(rankZeroIndexed: 6, totalMembers: total), LeagueZone.demote);
      expect(service.calculateMemberZone(rankZeroIndexed: 8, totalMembers: total), LeagueZone.demote);
    });

    test('1-2 kişilik çok küçük gruplarda lig hareketi olmaz (maintain)', () {
      expect(service.calculateMemberZone(rankZeroIndexed: 0, totalMembers: 2), LeagueZone.maintain);
      expect(service.calculateMemberZone(rankZeroIndexed: 1, totalMembers: 2), LeagueZone.maintain);
    });

    test('Puan sıralaması ve eşitlik bozma kriterleri doğru çalışır', () {
      const m1 = LeagueMember(
        id: '1',
        leagueId: 'l1',
        userId: 'u1',
        displayName: 'A',
        score: 100,
        completedHabitsCount: 10,
        maxStreak: 5,
      );
      const m2 = LeagueMember(
        id: '2',
        leagueId: 'l1',
        userId: 'u2',
        displayName: 'B',
        score: 100,
        completedHabitsCount: 12, // Eşit puanda daha çok tamamlama öne geçer
        maxStreak: 4,
      );
      const m3 = LeagueMember(
        id: '3',
        leagueId: 'l1',
        userId: 'u3',
        displayName: 'C',
        score: 120, // En yüksek puan
        completedHabitsCount: 8,
        maxStreak: 3,
      );

      final sorted = service.sortMembers([m1, m2, m3]);
      expect(sorted[0].id, '3');
      expect(sorted[1].id, '2');
      expect(sorted[2].id, '1');
    });

    test('Günlük puan hesaplamasında maksimum 55 puan sınırı korunur', () {
      // 10 alışkanlık tamamlandı ve tümü bitti
      final points = service.calculateDailyPoints(completedCount: 10, allPlannedCompleted: true);
      // İlk 5 x 10 = 50 + 5 bonus = 55
      expect(points, 55);

      // 3 alışkanlık tamamlandı ve hepsi bitti
      final points3 = service.calculateDailyPoints(completedCount: 3, allPlannedCompleted: true);
      // 3 x 10 = 30 + 5 bonus = 35
      expect(points3, 35);
    });
  });
}
