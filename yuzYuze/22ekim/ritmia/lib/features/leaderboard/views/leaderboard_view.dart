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
/// derece rozetleri, detaylı Ligler Tanıtım Rehberi ve açıkça belirtilen demo lig etiketini barındırır.
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
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: 'Ligler ve Kurallar Rehberi',
            onPressed: () => _showLeaguesGuide(context),
          ),
        ],
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
            const SizedBox(height: 24),

            // Ligler Tanıtımı Butonu
            OutlinedButton.icon(
              onPressed: () => _showLeaguesGuide(context),
              icon: const Icon(Icons.auto_stories_rounded),
              label: const Text('Ligler ve Puan Rehberini İncele'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 14),

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
        const SizedBox(height: 14),

        // Lig Kademesi ve Bilgi Kartı
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withValues(alpha: isDark ? 0.35 : 0.15),
                theme.colorScheme.primaryContainer.withValues(alpha: isDark ? 0.25 : 0.35),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.35),
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

        // Ligler Tanıtımı & Rehber Kartı
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showLeaguesGuide(context),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outline,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.25 : 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.auto_stories_rounded,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ligler ve Puan Sistemi Tanıtımı',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '5 lig kademesi, terfi kuralları ve puanlama detayları',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: theme.colorScheme.primary,
                    size: 22,
                  ),
                ],
              ),
            ),
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
                    'İlk 5 Yükselir 🚀',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green[700]),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.arrow_downward_rounded, color: Colors.red, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Son 5 Düşer 🔻',
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
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUser
              ? theme.colorScheme.primary
              : theme.colorScheme.outline,
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
                : theme.colorScheme.surfaceContainerHighest,
            child: Text(
              member.displayName.isNotEmpty ? member.displayName[0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isUser
                    ? Colors.white
                    : (isDark ? AppColors.darkTextPrimary : theme.colorScheme.onSurface),
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

  /// Ligler ve Puan Sistemi Tanıtımı (%70 Yükseklik Kuralı ve Kaydırma)
  void _showLeaguesGuide(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final tiers = [
      (
        name: 'Tohum Ligi',
        icon: Icons.grass_rounded,
        color: const Color(0xFF10B981),
        desc: 'Yolculuğun başlangıcı. Alışkanlık ritmini oluşturmaya başlayan yeni üyelerin temel ligi.',
      ),
      (
        name: 'Filiz Ligi',
        icon: Icons.spa_rounded,
        color: const Color(0xFF059669),
        desc: 'Kök salanlar. Düzenli adımlarla serisini büyüten ve haftalık hedeflerine sadık kalanlar.',
      ),
      (
        name: 'Tomurcuk Ligi',
        icon: Icons.local_florist_rounded,
        color: const Color(0xFFEC4899),
        desc: 'İstikrar basamağı. Zor günleri aşıp ritmini güçlü tutan kararlı katılımcılar.',
      ),
      (
        name: 'Çiçek Ligi',
        icon: Icons.psychology_rounded,
        color: const Color(0xFF8B5CF6),
        desc: 'Ustalık ligi. Yüksek disiplin, düzenli günlük tamamlama ve güçlü serilere sahip olanlar.',
      ),
      (
        name: 'Yıldız Ligi',
        icon: Icons.star_rounded,
        color: const Color(0xFFEAB308),
        desc: 'Zirve! Ritmia\'nın en istikrarlı, şampiyon alışkanlık ustalarının mücadele ettiği en üst kademe.',
      ),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        return Container(
          height: MediaQuery.of(modalCtx).size.height * 0.70,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.6),
            ),
          ),
          child: Column(
            children: [
              // Üst Sürükleme Çubuğu ve Başlık
              Container(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Column(
                  children: [
                    Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outline,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 48),
                        const Text(
                          'Ligler ve Kurallar Rehberi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(modalCtx),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Kaydırılabilir İçerik
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Giriş Kartı
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
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.emoji_events_rounded, color: AppColors.goldMedal, size: 36),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Text(
                                'Her hafta 15 kişilik dengeli gruplarda yarış, serilerini koru ve ligleri tırman!',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Bölüm 1: 5 Lig Kademesi
                      const Text(
                        '5 Lig Kademesi',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      ...tiers.map((tier) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: tier.color.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: tier.color.withValues(alpha: isDark ? 0.3 : 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(tier.icon, color: tier.color, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tier.name,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: tier.color,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      tier.desc,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 20),

                      // Bölüm 2: Haftalık Terfi & Düşme Kuralları
                      const Text(
                        'Terfi ve Düşme Kuralları',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.colorScheme.outline),
                        ),
                        child: Column(
                          children: [
                            _buildRuleRow(
                              icon: Icons.groups_rounded,
                              iconColor: theme.colorScheme.primary,
                              title: '15 Kişilik Gruplar',
                              desc: 'Her hafta rastgele dengeli 15 katılımcılık gruplar oluşturulur.',
                              isDark: isDark,
                            ),
                            const Divider(height: 16),
                            _buildRuleRow(
                              icon: Icons.arrow_upward_rounded,
                              iconColor: Colors.green,
                              title: 'İlk 5 Sıra: Yükselir 🚀',
                              desc: 'Haftayı ilk 5 içinde tamamlayanlar bir üst lige terfi eder.',
                              isDark: isDark,
                            ),
                            const Divider(height: 16),
                            _buildRuleRow(
                              icon: Icons.horizontal_rule_rounded,
                              iconColor: Colors.grey,
                              title: 'Orta 5 Sıra: Korunur ⏸️',
                              desc: '6 ile 10. sıra arasındakiler mevcut liginde kalır.',
                              isDark: isDark,
                            ),
                            const Divider(height: 16),
                            _buildRuleRow(
                              icon: Icons.arrow_downward_rounded,
                              iconColor: Colors.red,
                              title: 'Son 5 Sıra: Düşer 🔻',
                              desc: 'Son 5 sıradaki katılımcılar bir alt lige düşer.',
                              isDark: isDark,
                            ),
                            const Divider(height: 16),
                            _buildRuleRow(
                              icon: Icons.military_tech_rounded,
                              iconColor: AppColors.goldMedal,
                              title: 'Madalyalar 🥇🥈🥉',
                              desc: 'İlk 3 dereceye girenler profillerinde sergilenecek madalya rozeti kazanır.',
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Bölüm 3: Puanlama Sistemi
                      const Text(
                        'Puanlama Mantığı',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.colorScheme.outline),
                        ),
                        child: Column(
                          children: [
                            _buildRuleRow(
                              icon: Icons.check_circle_rounded,
                              iconColor: Colors.green,
                              title: 'Alışkanlık Tamamlama (+10 Puan)',
                              desc: 'Planlanan her tamamlanmış alışkanlık için 10 puan kazanırsın.',
                              isDark: isDark,
                            ),
                            const Divider(height: 16),
                            _buildRuleRow(
                              icon: Icons.star_rounded,
                              iconColor: AppColors.goldMedal,
                              title: 'Günlük Tamamlama Bonusu (+5 Puan)',
                              desc: 'Günün tüm planlı alışkanlıklarını tamamlarsan ek 5 puan verilir.',
                              isDark: isDark,
                            ),
                            const Divider(height: 16),
                            _buildRuleRow(
                              icon: Icons.auto_awesome_rounded,
                              iconColor: theme.colorScheme.primary,
                              title: 'Rozet Başarı Puanları',
                              desc: '7 Günlük Seri (+20p) • 30 Günlük Seri (+60p) • 365 Günlük Seri (+200p) tek seferlik lig puanı kazandırır.',
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      ElevatedButton(
                        onPressed: () => Navigator.pop(modalCtx),
                        child: const Text('Anladım, Teşekkürler'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRuleRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String desc,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
