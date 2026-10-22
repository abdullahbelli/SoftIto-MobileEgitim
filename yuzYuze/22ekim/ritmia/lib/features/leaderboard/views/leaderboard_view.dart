import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../habits/controllers/habit_controller.dart';
import '../controllers/leaderboard_controller.dart';
import '../models/league_member.dart';
import '../services/leaderboard_service.dart';

/// Liderlik Panosu Ekranı (Leaderboard View).
/// İsteğe bağlı katılım, 15 kişilik lig grubu, ilk 5 yükselme / son 5 düşme kuralları,
/// derece rozetleri ve açıkça belirtilen demo lig etiketini barındırır.
class LeaderboardView extends StatefulWidget {
  const LeaderboardView({super.key});

  @override
  State<LeaderboardView> createState() => _LeaderboardViewState();
}

class _LeaderboardViewState extends State<LeaderboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLeagueData();
    });
  }

  void _loadLeagueData() {
    final authCtrl = context.read<AuthController>();
    final habitCtrl = context.read<HabitController>();
    final leaderboardCtrl = context.read<LeaderboardController>();

    final user = authCtrl.currentUser;
    if (user != null && user.leaderboardOptIn) {
      leaderboardCtrl.loadWeeklyLeague(
        user: user,
        userScore: habitCtrl.overallStreak * 15 + 40,
        userCompletedCount: habitCtrl.overallStreak * 2 + 3,
        userMaxStreak: habitCtrl.overallStreak,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authCtrl = context.watch<AuthController>();
    final leaderboardCtrl = context.watch<LeaderboardController>();

    final user = authCtrl.currentUser;
    final isOptedIn = user?.leaderboardOptIn ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Liderlik Panosu'),
      ),
      body: !isOptedIn
          ? _buildOptInInvitation(context, theme, isDark, authCtrl)
          : _buildLeaderboardContent(context, theme, isDark, leaderboardCtrl),
    );
  }

  /// Katılım Daveti Ekranı (İsteğe bağlı katılım kuralı)
  Widget _buildOptInInvitation(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    AuthController authCtrl,
  ) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.emoji_events_rounded,
                size: 54,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Yarışmaya Katılmak İster misin?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Haftalık liglerde 15 kişilik gruplarda ritmini yarıştır! '
              'İlk 5 kişi üst lige yükselir, dereceye girenler madalya rozetleri kazanır. '
              'Katılım tamamen isteğe bağlıdır.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                await authCtrl.updateLeaderboardOptIn(true);
                _loadLeagueData();
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
              ),
              child: const Text('Evet, Yarışmaya Katıl'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Kişisel takibinize devam edebilirsiniz. Dilediğiniz zaman katılabilirsiniz.'),
                  ),
                );
              },
              child: const Text('Şimdilik Değil'),
            ),
          ],
        ),
      ),
    );
  }

  /// Aktif Liderlik Sıralaması
  Widget _buildLeaderboardContent(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    LeaderboardController leaderboardCtrl,
  ) {
    if (leaderboardCtrl.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final league = leaderboardCtrl.currentLeague;
    if (league == null) {
      return const Center(child: Text('Lig verisi bulunamadı.'));
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // Demo Lig Uyarısı (project.md Kuralı)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: isDark ? 0.2 : 0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: Colors.amber, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Demo lig — örnek veriler. Gerçek kullanıcı sıralaması sunucu altyapısı gerektirir.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Lig Kademesi ve Bilgi Kartı
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withValues(alpha: isDark ? 0.3 : 0.15),
                theme.colorScheme.primaryContainer.withValues(alpha: isDark ? 0.2 : 0.3),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.shield_rounded, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${league.tier} Ligi (Grup 1)',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Hafta: ${league.weekId} • ${league.members.length}/${AppConstants.maxLeagueMembers} Katılımcı',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Kurallar Özeti
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.arrow_upward_rounded, color: Colors.green, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'İlk 5 Yükselir',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green[700]),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.arrow_downward_rounded, color: Colors.red, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Son 5 Düşer',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red[700]),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // 15 Kişilik Sıralama Listesi
        ...List.generate(league.members.length, (index) {
          final member = league.members[index];
          final rank = index + 1;
          final zone = leaderboardCtrl.service.calculateMemberZone(
            rankZeroIndexed: index,
            totalMembers: league.members.length,
          );

          return _buildMemberTile(context, theme, isDark, member, rank, zone);
        }),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildMemberTile(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    LeagueMember member,
    int rank,
    LeagueZone zone,
  ) {
    final isUser = member.isCurrentUser;

    final zoneColor = switch (zone) {
      LeagueZone.promote => Colors.green,
      LeagueZone.demote => Colors.red,
      LeagueZone.maintain => Colors.grey,
    };

    final zoneIcon = switch (zone) {
      LeagueZone.promote => Icons.arrow_upward_rounded,
      LeagueZone.demote => Icons.arrow_downward_rounded,
      LeagueZone.maintain => Icons.horizontal_rule_rounded,
    };

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isUser
            ? theme.colorScheme.primary.withValues(alpha: isDark ? 0.25 : 0.15)
            : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUser
              ? theme.colorScheme.primary
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: isUser ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Sıralama Numarası veya Madalya
          SizedBox(
            width: 32,
            child: _buildRankBadge(rank),
          ),
          const SizedBox(width: 8),

          // Baş Harf / Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: isUser
                ? theme.colorScheme.primary
                : (isDark ? AppColors.darkSurfaceVariant : AppColors.lightPrimaryContainer),
            child: Text(
              member.displayName.isNotEmpty ? member.displayName[0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isUser
                    ? Colors.white
                    : (isDark ? AppColors.darkTextPrimary : AppColors.lightOnPrimaryContainer),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // İsim
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.displayName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isUser ? FontWeight.bold : FontWeight.w600,
                    color: isUser
                        ? theme.colorScheme.primary
                        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${member.completedHabitsCount} tamamlama • ${member.maxStreak} gün seri',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Puan
          Text(
            '${member.score} p',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 10),

          // Terfi/Düşme Oku
          Icon(zoneIcon, size: 16, color: zoneColor),
        ],
      ),
    );
  }

  Widget _buildRankBadge(int rank) {
    if (rank == 1) {
      return const Icon(Icons.military_tech_rounded, color: AppColors.goldMedal, size: 24);
    } else if (rank == 2) {
      return const Icon(Icons.military_tech_rounded, color: AppColors.silverMedal, size: 24);
    } else if (rank == 3) {
      return const Icon(Icons.military_tech_rounded, color: AppColors.bronzeMedal, size: 24);
    } else {
      return Center(
        child: Text(
          '$rank',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
      );
    }
  }
}
