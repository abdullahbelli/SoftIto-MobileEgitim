import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/app_theme_toggle_button.dart';
import '../../../../core/widgets/brand_palette_bar.dart';
import '../../authentication/controller/auth_controller.dart';
import '../../authentication/models/user_account.dart';

/// Yönetici Paneli — Girişimci Başvuru ve Giriş Onaylama Ekranı
class AdminDashboardView extends StatefulWidget {
  final AuthController authController;
  final ThemeController themeController;

  const AdminDashboardView({
    super.key,
    required this.authController,
    required this.themeController,
  });

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings_rounded, color: AppColors.oceanBlue),
            SizedBox(width: 8),
            Text('Yönetici Paneli (Admin)'),
          ],
        ),
        actions: [
          AppThemeToggleButton(themeController: widget.themeController),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Çıkış Yap / Rol Değiştir',
            onPressed: widget.authController.logout,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(51),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(icon: Icon(Icons.pending_actions_rounded), text: 'Onay Bekleyenler'),
                  Tab(icon: Icon(Icons.people_alt_rounded), text: 'Tüm Kullanıcılar'),
                ],
              ),
              const BrandPaletteBar(height: 3),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: widget.authController.allUsers,
          builder: (context, _) {
            final allUsers = widget.authController.allUsers.value;
            final pendingUsers = widget.authController.pendingUsers;
            final approvedUsers = widget.authController.approvedUsers;

            return Column(
              children: [
                _AdminStatsHeader(
                  pendingCount: pendingUsers.length,
                  approvedCount: approvedUsers.length,
                  totalCount: allUsers.where((u) => u.role == UserRole.entrepreneur).length,
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _PendingUsersList(
                        pendingUsers: pendingUsers,
                        onApprove: (id) {
                          widget.authController.approveUser(id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Girişimcinin başvurusu onaylandı!'),
                              backgroundColor: AppColors.teal,
                            ),
                          );
                        },
                        onReject: (id) {
                          widget.authController.rejectUser(id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Girişimcinin başvurusu reddedildi.'),
                              backgroundColor: AppColors.red,
                            ),
                          );
                        },
                      ),
                      _AllUsersList(allUsers: allUsers),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AdminStatsHeader extends StatelessWidget {
  final int pendingCount;
  final int approvedCount;
  final int totalCount;

  const _AdminStatsHeader({
    required this.pendingCount,
    required this.approvedCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _StatBadgeCard(
              label: 'Bekleyen',
              value: '$pendingCount',
              color: AppColors.amber,
              icon: Icons.hourglass_top_rounded,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatBadgeCard(
              label: 'Onaylı',
              value: '$approvedCount',
              color: AppColors.teal,
              icon: Icons.verified_user_rounded,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatBadgeCard(
              label: 'Toplam Girişimci',
              value: '$totalCount',
              color: AppColors.oceanBlue,
              icon: Icons.groups_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBadgeCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatBadgeCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(isDark ? 30 : 20),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}

class _PendingUsersList extends StatelessWidget {
  final List<UserAccount> pendingUsers;
  final ValueChanged<String> onApprove;
  final ValueChanged<String> onReject;

  const _PendingUsersList({
    required this.pendingUsers,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    if (pendingUsers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 48, color: AppColors.teal),
            SizedBox(height: 12),
            Text('Onay bekleyen başvuru bulunmamaktadır.'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pendingUsers.length,
      itemBuilder: (context, index) {
        final user = pendingUsers[index];
        return _UserApprovalCard(
          user: user,
          onApprove: () => onApprove(user.id),
          onReject: () => onReject(user.id),
        );
      },
    );
  }
}

class _UserApprovalCard extends StatelessWidget {
  final UserAccount user;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _UserApprovalCard({
    required this.user,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.amber.withAlpha(40),
                  child: Text(
                    user.fullName.isNotEmpty ? user.fullName.substring(0, 1) : 'G',
                    style: const TextStyle(color: AppColors.amber, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        user.email,
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.amber.withAlpha(30),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Onay Bekliyor',
                    style: TextStyle(fontSize: 11, color: AppColors.amber, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            if (user.hasIdea && user.idea != null) ...[
              Text(
                'İş Fikri: ${user.idea!.title}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Sektör: ${user.idea!.sector}',
                style: const TextStyle(fontSize: 13, color: AppColors.teal, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                user.idea!.description,
                style: const TextStyle(fontSize: 13),
              ),
            ] else ...[
              const Text(
                'Kayıt Beyanı: İş fikri henüz belirtilmedi (Rehberlik aşamasında).',
                style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.red,
                    side: const BorderSide(color: AppColors.red),
                  ),
                  onPressed: onReject,
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text('Reddet'),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: onApprove,
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Başvuruyu Onayla'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AllUsersList extends StatelessWidget {
  final List<UserAccount> allUsers;

  const _AllUsersList({required this.allUsers});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allUsers.length,
      itemBuilder: (context, index) {
        final user = allUsers[index];
        final isApproved = user.isApproved;
        final badgeColor = isApproved ? AppColors.teal : (user.isPending ? AppColors.amber : AppColors.red);

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: badgeColor.withAlpha(30),
              child: Icon(
                user.role == UserRole.admin
                    ? Icons.admin_panel_settings_rounded
                    : (user.role == UserRole.investor ? Icons.attach_money_rounded : Icons.person_rounded),
                color: badgeColor,
                size: 20,
              ),
            ),
            title: Text(
              user.fullName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${user.email} • ${user.role.displayName}'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor.withAlpha(30),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                user.approvalStatus.displayName,
                style: TextStyle(color: badgeColor, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }
}
