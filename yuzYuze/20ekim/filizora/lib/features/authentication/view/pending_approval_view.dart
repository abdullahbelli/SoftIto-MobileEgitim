import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/app_theme_toggle_button.dart';
import '../../../../core/widgets/brand_palette_bar.dart';
import '../controller/auth_controller.dart';
import '../models/user_account.dart';

/// Yönetici Onayı Bekleme Ekranı
///
/// Kayıt olan ancak henüz yönetici onayı almamış kullanıcılar bu ekranda tutulur
/// ve ana özelliklere erişimleri kısıtlanır.
class PendingApprovalView extends StatelessWidget {
  final AuthController authController;
  final ThemeController themeController;

  const PendingApprovalView({
    super.key,
    required this.authController,
    required this.themeController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Başvuru Durumu'),
        actions: [
          AppThemeToggleButton(themeController: themeController),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(3),
          child: BrandPaletteBar(height: 3),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: ValueListenableBuilder<UserAccount?>(
            valueListenable: authController.currentUser,
            builder: (context, user, _) {
              if (user == null) {
                return const Center(child: Text('Kullanıcı oturumu bulunamadı.'));
              }
              return Column(
                children: [
                  const SizedBox(height: 12),
                  const _PendingStatusIcon(),
                  const SizedBox(height: 16),
                  _PendingStatusHeader(user: user),
                  const SizedBox(height: 16),
                  _InfoCard(user: user),
                  const SizedBox(height: 24),
                  _SimulationControls(authController: authController),
                  const SizedBox(height: 12),
                  _LogoutButton(onLogout: authController.logout),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PendingStatusIcon extends StatelessWidget {
  const _PendingStatusIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.amber.withAlpha(35),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.hourglass_top_rounded,
        color: AppColors.amber,
        size: 40,
      ),
    );
  }
}

class _PendingStatusHeader extends StatelessWidget {
  final UserAccount user;
  const _PendingStatusHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor = isDark ? AppColors.textSecondary : AppColors.textLightSecondary;

    return Column(
      children: [
        Text(
          'Yönetici Onayı Bekleniyor',
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Sayın ${user.fullName}, başvurunuz inceleniyor. Yönetici onayı tamamlandığında ana özellikler erişime açılacaktır.',
          style: context.textTheme.bodyMedium?.copyWith(
            color: secondaryTextColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final UserAccount user;
  const _InfoCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _InfoRow(label: 'E-posta:', value: user.email),
            const Divider(height: 16),
            _InfoRow(
              label: 'İş Fikri:',
              value: user.hasIdea ? (user.idea?.title ?? 'Belirtildi') : 'İş fikrim yok',
            ),
            const Divider(height: 16),
            const _InfoRow(
              label: 'Erişim Durumu:',
              value: 'Ana özellikler kilitli',
              valueColor: AppColors.amber,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor = isDark ? AppColors.textSecondary : AppColors.textLightSecondary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: context.textTheme.bodyMedium?.copyWith(color: secondaryTextColor),
        ),
        Text(
          value,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _SimulationControls extends StatelessWidget {
  final AuthController authController;
  const _SimulationControls({required this.authController});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.teal,
              foregroundColor: Colors.white,
            ),
            onPressed: authController.simulateAdminApproval,
            icon: const Icon(Icons.verified_user_outlined),
            label: const Text('Simülasyon: Yönetici Onayı Ver (Erişimi Aç)'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.oceanBlue,
              side: const BorderSide(color: AppColors.oceanBlue),
            ),
            onPressed: () => authController.loginAsRole(UserRole.admin),
            icon: const Icon(Icons.admin_panel_settings_outlined),
            label: const Text('Yönetici (Admin) Paneline Geçiş Yap'),
          ),
        ),
      ],
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onLogout;
  const _LogoutButton({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onLogout,
        icon: const Icon(Icons.logout_rounded),
        label: const Text('Farklı Hesapla Giriş / Çıkış'),
      ),
    );
  }
}
