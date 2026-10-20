import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/app_theme_toggle_button.dart';
import '../../../../core/widgets/brand_palette_bar.dart';
import '../../authentication/controller/auth_controller.dart';
import '../../mentor_matching/controller/mentor_matching_controller.dart';
import '../../mentor_matching/models/match_request.dart';

/// Yatırımcı & Mentor Portalı — Bekleyen İstekleri İnceleme ve Yanıtlama Ekranı
class InvestorDashboardView extends StatefulWidget {
  final MentorMatchingController mentorController;
  final AuthController authController;
  final ThemeController themeController;

  const InvestorDashboardView({
    super.key,
    required this.mentorController,
    required this.authController,
    required this.themeController,
  });

  @override
  State<InvestorDashboardView> createState() => _InvestorDashboardViewState();
}

class _InvestorDashboardViewState extends State<InvestorDashboardView> with SingleTickerProviderStateMixin {
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
    final currentInvestor = widget.authController.currentUser.value;
    final investorName = currentInvestor?.fullName ?? 'Yatırımcı & Mentor';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.handshake_rounded, color: AppColors.oceanBlue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Yatırımcı Portalı • $investorName',
                style: const TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
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
                  Tab(icon: Icon(Icons.inbox_rounded), text: 'Bekleyen İstekler'),
                  Tab(icon: Icon(Icons.verified_rounded), text: 'Eşleştiğim Girişimciler'),
                ],
              ),
              const BrandPaletteBar(height: 3),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: widget.mentorController.matchRequests,
          builder: (context, _) {
            final allRequests = widget.mentorController.matchRequests.value;
            final pendingRequests = widget.mentorController.pendingRequests;
            final acceptedRequests = widget.mentorController.acceptedRequests;

            return Column(
              children: [
                _InvestorStatsHeader(
                  pendingCount: pendingRequests.length,
                  acceptedCount: acceptedRequests.length,
                  totalCount: allRequests.length,
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _PendingRequestsList(
                        requests: pendingRequests,
                        onAccept: (req) {
                          widget.mentorController.acceptMatchRequest(req.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${req.entrepreneurName} ile eşleşme kabul edildi!'),
                              backgroundColor: AppColors.teal,
                            ),
                          );
                        },
                        onDecline: (req) {
                          widget.mentorController.declineMatchRequest(req.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${req.entrepreneurName} eşleşme isteği reddedildi.'),
                              backgroundColor: AppColors.red,
                            ),
                          );
                        },
                      ),
                      _AcceptedRequestsList(requests: acceptedRequests),
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

class _InvestorStatsHeader extends StatelessWidget {
  final int pendingCount;
  final int acceptedCount;
  final int totalCount;

  const _InvestorStatsHeader({
    required this.pendingCount,
    required this.acceptedCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              label: 'Bekleyen İstek',
              value: '$pendingCount',
              color: AppColors.amber,
              icon: Icons.mark_email_unread_rounded,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatCard(
              label: 'Aktif Eşleşme',
              value: '$acceptedCount',
              color: AppColors.teal,
              icon: Icons.check_circle_rounded,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatCard(
              label: 'Toplam İstek',
              value: '$totalCount',
              color: AppColors.oceanBlue,
              icon: Icons.forum_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
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

class _PendingRequestsList extends StatelessWidget {
  final List<MatchRequest> requests;
  final ValueChanged<MatchRequest> onAccept;
  final ValueChanged<MatchRequest> onDecline;

  const _PendingRequestsList({
    required this.requests,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: AppColors.textSecondary),
            SizedBox(height: 12),
            Text(
              'Bekleyen yeni eşleşme isteği bulunmamaktadır.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final req = requests[index];
        return _MatchRequestCard(
          request: req,
          onAccept: () => onAccept(req),
          onDecline: () => onDecline(req),
        );
      },
    );
  }
}

class _MatchRequestCard extends StatelessWidget {
  final MatchRequest request;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _MatchRequestCard({
    required this.request,
    required this.onAccept,
    required this.onDecline,
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
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.oceanBlue.withAlpha(30),
                  child: Text(
                    request.entrepreneurName.substring(0, 1),
                    style: const TextStyle(color: AppColors.oceanBlue, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.entrepreneurName,
                        style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Hedef Mentor: ${request.mentorName}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
                    'İstek Bekliyor',
                    style: TextStyle(fontSize: 11, color: AppColors.amber, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Text(
              request.ideaTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.teal.withAlpha(25),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                request.ideaSector,
                style: const TextStyle(fontSize: 11, color: AppColors.teal, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              request.message,
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.red,
                    side: const BorderSide(color: AppColors.red),
                  ),
                  onPressed: onDecline,
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text('Reddet'),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: onAccept,
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                  label: const Text('Eşleşmeyi Kabul Et'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AcceptedRequestsList extends StatelessWidget {
  final List<MatchRequest> requests;

  const _AcceptedRequestsList({required this.requests});

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.handshake_outlined, size: 48, color: AppColors.textSecondary),
            SizedBox(height: 12),
            Text(
              'Henüz kabul edilmiş aktif bir eşleşme yok.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final req = requests[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: AppColors.teal,
              foregroundColor: Colors.white,
              child: Icon(Icons.check_rounded),
            ),
            title: Text(req.entrepreneurName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${req.ideaTitle} • ${req.ideaSector}'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.teal.withAlpha(30),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Eşleşildi',
                style: TextStyle(color: AppColors.teal, fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ),
          ),
        );
      },
    );
  }
}
