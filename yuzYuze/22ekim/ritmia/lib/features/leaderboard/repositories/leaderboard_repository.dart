import '../../auth/models/user_profile.dart';
import '../models/league.dart';

/// Liderlik panosu için Repository sözleşmesi.
/// Gerçek sunucu entegrasyonu için arayüz tanımı sunar.
abstract interface class LeaderboardRepository {
  Future<League> getWeeklyLeague({
    required String weekId,
    required UserProfile user,
    required int userScore,
    required int userCompletedCount,
    required int userMaxStreak,
  });
}
