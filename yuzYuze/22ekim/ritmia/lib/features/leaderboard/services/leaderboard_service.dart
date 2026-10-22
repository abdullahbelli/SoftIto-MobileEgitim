import '../models/league_member.dart';

/// Lig hareket bölgeleri (Terfi / Korunma / Düşme)
enum LeagueZone {
  promote,  // Üst lige yükselme
  maintain, // Mevcut ligi koruma
  demote,   // Alt lige düşme
}

/// Liderlik tablosu puanlama ve terfi/düşme hesaplamaları servisi.
/// project.md Bölüm 6'daki 15 kişilik grup ve min(5, floor(N/3)) kurallarını tam uygular.
class LeaderboardService {
  /// Belirli bir sıralamadaki (0 tabanlı) üyenin lig hareket bölgesini hesaplar
  LeagueZone calculateMemberZone({
    required int rankZeroIndexed,
    required int totalMembers,
  }) {
    if (totalMembers <= 2) {
      return LeagueZone.maintain;
    }

    final int zoneCount;
    if (totalMembers <= 10) {
      // Çakışmayı önlemek için min(5, floor(N/3))
      zoneCount = (totalMembers ~/ 3).clamp(0, 5);
    } else {
      zoneCount = 5;
    }

    if (zoneCount > 0 && rankZeroIndexed < zoneCount) {
      return LeagueZone.promote;
    } else if (zoneCount > 0 && rankZeroIndexed >= (totalMembers - zoneCount)) {
      return LeagueZone.demote;
    } else {
      return LeagueZone.maintain;
    }
  }

  /// Üyeleri kurallara göre sıralar:
  /// 1. Puan (azalan)
  /// 2. Tamamlanan alışkanlık sayısı (azalan)
  /// 3. En yüksek seri (azalan)
  List<LeagueMember> sortMembers(List<LeagueMember> members) {
    final list = List<LeagueMember>.from(members);
    list.sort((a, b) {
      if (b.score != a.score) {
        return b.score.compareTo(a.score);
      }
      if (b.completedHabitsCount != a.completedHabitsCount) {
        return b.completedHabitsCount.compareTo(a.completedHabitsCount);
      }
      return b.maxStreak.compareTo(a.maxStreak);
    });
    return list;
  }

  /// Bir gün için kazanılabilecek puanı hesaplar (Maksimum 55 puan sınırı)
  int calculateDailyPoints({
    required int completedCount,
    required bool allPlannedCompleted,
  }) {
    if (completedCount <= 0) return 0;
    // En fazla 5 tamamlanan alışkanlık puanı (5 x 10 = 50)
    final habitPoints = (completedCount.clamp(0, 5)) * 10;
    // Günlük bonus (+5)
    final bonus = allPlannedCompleted ? 5 : 0;
    return habitPoints + bonus;
  }
}
