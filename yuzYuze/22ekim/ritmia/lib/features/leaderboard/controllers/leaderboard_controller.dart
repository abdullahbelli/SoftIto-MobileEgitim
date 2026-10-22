import 'package:flutter/foundation.dart';
import '../../../core/utils/date_utils.dart';
import '../../auth/models/user_profile.dart';
import '../models/league.dart';
import '../models/league_member.dart';
import '../repositories/leaderboard_repository.dart';
import '../services/leaderboard_service.dart';

/// Liderlik tablosu ekranının durumunu yöneten MVC Controller.
/// Lig üyelerini, sıralamayı ve kullanıcının hareket bölgesini View'e bildirir.
class LeaderboardController extends ChangeNotifier {
  final LeaderboardRepository _repository;
  final LeaderboardService _service;

  League? _currentLeague;
  bool _isLoading = false;
  String? _errorMessage;

  LeaderboardController(this._repository, this._service);

  League? get currentLeague => _currentLeague;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  LeaderboardService get service => _service;

  LeagueMember? get currentMember {
    if (_currentLeague == null) return null;
    return _currentLeague!.members.where((m) => m.isCurrentUser).firstOrNull;
  }

  int get currentUserRank {
    if (_currentLeague == null) return -1;
    final index = _currentLeague!.members.indexWhere((m) => m.isCurrentUser);
    return index != -1 ? index + 1 : -1;
  }

  Future<void> loadWeeklyLeague({
    required UserProfile user,
    required int userScore,
    required int userCompletedCount,
    required int userMaxStreak,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final weekId = AppDateUtils.weekId(DateTime.now());
      _currentLeague = await _repository.getWeeklyLeague(
        weekId: weekId,
        user: user,
        userScore: userScore,
        userCompletedCount: userCompletedCount,
        userMaxStreak: userMaxStreak,
      );
    } catch (e) {
      _errorMessage = 'Lig bilgileri yüklenemedi: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
