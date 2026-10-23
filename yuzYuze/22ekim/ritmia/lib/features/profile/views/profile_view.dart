import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/theme_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/models/user_profile.dart';
import '../../badges/models/badge_definition.dart';
import '../../badges/services/badge_service.dart';
import '../../badges/views/widgets/badge_item.dart';
import '../../habits/controllers/habit_controller.dart';
import 'widgets/edit_profile_sheet.dart';

/// Profil Ekranı (Profile View).
/// Kullanıcı bilgileri, istatistikler, rozetler, açık/koyu tema değiştirme,
/// vurgu rengi seçimi, lig katılım kontrolü ve çıkış yapma işlevlerini içerir.
class ProfileView extends StatefulWidget {
  final bool autoOpenEdit;

  const ProfileView({
    super.key,
    this.autoOpenEdit = false,
  });

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  void initState() {
    super.initState();
    if (widget.autoOpenEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final authCtrl = context.read<AuthController>();
        final user = authCtrl.currentUser;
        if (user != null && mounted) {
          _openEditProfile(context, user, authCtrl);
        }
      });
    }
  }

  void _openEditProfile(BuildContext context, UserProfile user, AuthController authCtrl) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditProfileSheet(
        profile: user,
        onSave: (updated) => authCtrl.updateProfile(updated),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context, AuthController authCtrl) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text(
          'Oturumunuzu kapatmak istediğinize emin misiniz? Yerel verileriniz cihazda korunacaktır.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await authCtrl.logout();
      if (context.mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final authCtrl = context.watch<AuthController>();
    final habitCtrl = context.watch<HabitController>();
    final themeCtrl = context.watch<ThemeController>();

    final user = authCtrl.currentUser ??
        UserProfile(
          id: 'user_1',
          firstName: 'Ritmia',
          lastName: 'Kullanıcısı',
          email: 'demo@ritmia.app',
          username: 'demo_kullanici',
          joinedAt: DateTime.now(),
        );

    // Rozetleri hesapla
    final badgeService = BadgeService();
    final habitStreaks = {
      for (final h in habitCtrl.habits) h.id: habitCtrl.getHabitStreak(h),
    };
    final earnedBadges = badgeService.evaluateBadges(
      userId: user.id,
      habits: habitCtrl.habits,
      habitStreaks: habitStreaks,
      existingBadges: const [],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilim'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Profili Düzenle',
            onPressed: () => _openEditProfile(context, user, authCtrl),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Kullanıcı Başlık Kartı
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      user.initials,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.fullName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@${user.username} • ${user.email}',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kayıt Tarihi: ${AppDateUtils.formatShortDayMonth(user.joinedAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // İstatistik Kartları
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: 'Aktif Alışkanlık',
                    value: '${habitCtrl.activeHabits.length}',
                    icon: Icons.track_changes_rounded,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: 'Genel Seri',
                    value: '${habitCtrl.overallStreak} gün',
                    icon: Icons.local_fire_department_rounded,
                    color: AppColors.flameOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Rozetlerim Bölümü
            const Text(
              'Başarı Rozetleri',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...BadgeDefinition.allBadges.map((def) {
              final earned = earnedBadges.where((b) => b.badgeId == def.id).firstOrNull;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: BadgeItem(
                  definition: def,
                  earnedBadge: earned,
                  currentStreak: habitCtrl.overallStreak,
                ),
              );
            }),
            const SizedBox(height: 20),

            // Tema ve Görünüm Ayarları
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.outline,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Görünüm ve Tema',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),

                  // Tema Modu Seçimi (Aydınlık / Sistem / Karanlık)
                  SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.light,
                        label: Text('Aydınlık'),
                        icon: Icon(Icons.light_mode_outlined),
                      ),
                      ButtonSegment(
                        value: ThemeMode.system,
                        label: Text('Sistem'),
                        icon: Icon(Icons.settings_suggest_outlined),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        label: Text('Koyu'),
                        icon: Icon(Icons.dark_mode_outlined),
                      ),
                    ],
                    selected: {themeCtrl.themeMode},
                    onSelectionChanged: (set) {
                      themeCtrl.setThemeMode(set.first);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Vurgu Rengi Paleti
                  const Text(
                    'Vurgu Rengi',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: AppColors.accentColors.entries.map((entry) {
                      final isSelected = themeCtrl.accentColorKey == entry.key;
                      return GestureDetector(
                        onTap: () => themeCtrl.setAccentColor(entry.key),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: entry.value,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: entry.value.withValues(alpha: 0.5),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, color: Colors.white, size: 20)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Liderlik Katılım Tercihi
            Material(
              color: theme.colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: theme.colorScheme.outline,
                ),
              ),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Haftalık Lig Katılımı',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  user.leaderboardOptIn
                      ? 'Liderlik panosunda yarışıyorsunuz'
                      : 'Liderlik panosuna dahil değilsiniz',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                value: user.leaderboardOptIn,
                onChanged: (val) {
                  authCtrl.updateLeaderboardOptIn(val);
                },
              ),
            ),
            const SizedBox(height: 20),

            // Çıkış Yap Butonu
            OutlinedButton.icon(
              onPressed: () => _handleLogout(context, authCtrl),
              icon: const Icon(Icons.logout_rounded, color: Colors.red),
              label: const Text('Çıkış Yap', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.25 : 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
