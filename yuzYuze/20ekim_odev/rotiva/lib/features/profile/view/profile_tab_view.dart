import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/rotiva_app_bar.dart';
import '../../../core/widgets/rotiva_scope.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/status_badge.dart';
import '../../auth/view/welcome_screen.dart';
import '../../home/view/customer_shell_screen.dart';
import '../../rentals/models/rental.dart';

/// Müşteri Profil Sekmesi.
/// Kullanıcı bilgileri, profil düzenleme, kiralama özeti, müşteri puanı, tema ve çıkış yönetimi.
class ProfileTabView extends StatefulWidget {
  const ProfileTabView({super.key});

  @override
  State<ProfileTabView> createState() => _ProfileTabViewState();
}

class _ProfileTabViewState extends State<ProfileTabView> {
  // İki harfli kullanıcı baş harfleri (Örn: Ahmet Yılmaz -> AY)
  String _getInitials(String fullName) {
    if (fullName.trim().isEmpty) return 'R';
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  // Profil Bilgilerini Düzenleme (Ad, Soyad, E-posta, Telefon)
  void _editProfileInfo() async {
    final repository = RotivaScope.of(context).repository;
    final user = repository.currentUser;
    if (user == null) return;

    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: user.fullName);
    final emailController = TextEditingController(text: user.email);
    final phoneController = TextEditingController(text: user.phone);

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.edit_note, size: 24),
              SizedBox(width: 8),
              Text(
                'Profili Düzenle',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Ad Soyad',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) =>
                        RotivaValidators.validateRequired(v, 'Ad Soyad'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'E-posta Adresi',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: RotivaValidators.validateEmail,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Telefon Numarası',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: RotivaValidators.validatePhone,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('İptal'),
            ),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                final newEmail = emailController.text.trim().toLowerCase();
                // Başka bir kullanıcının aynı e-postayı kullanıp kullanmadığı kontrolü
                final emailTaken = repository.users.any(
                  (u) =>
                      u.id != user.id &&
                      u.email.trim().toLowerCase() == newEmail,
                );
                if (emailTaken) {
                  RotivaDialogs.showSnackBar(
                    ctx,
                    'Bu e-posta adresi başka bir hesap tarafından kullanılıyor.',
                    isError: true,
                  );
                  return;
                }

                final updatedUser = user.copyWith(
                  fullName: nameController.text.trim(),
                  email: newEmail,
                  phone: phoneController.text.trim(),
                );

                await repository.updateProfile(updatedUser);

                if (ctx.mounted) {
                  Navigator.of(ctx).pop();
                }
                if (!mounted) return;
                RotivaDialogs.showSnackBar(
                  context,
                  'Profil bilgileriniz başarıyla güncellendi.',
                  isSuccess: true,
                );
                setState(() {});
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
  }

  // Sürücü Belgelerini Güncelleme (Doğum Tarihi, Ehliyet Alış Tarihi)
  void _editDriverInfo() async {
    final repository = RotivaScope.of(context).repository;
    final user = repository.currentUser;
    if (user == null) return;

    DateTime? birthDate = user.driverBirthDate;
    DateTime? licenseDate = user.licenseIssueDate;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.badge_outlined, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Sürücü Bilgileri',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.cake_outlined),
                    title: const Text('Doğum Tarihi'),
                    subtitle: Text(
                      birthDate != null
                          ? RotivaDateUtils.formatTurkishDate(birthDate!)
                          : 'Belirtilmedi',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: const Icon(Icons.edit_calendar, size: 20),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: birthDate ?? DateTime(2000, 1, 1),
                        firstDate: DateTime(1950, 1, 1),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setDialogState(() => birthDate = picked);
                      }
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.credit_card_outlined),
                    title: const Text('Ehliyet Alış Tarihi'),
                    subtitle: Text(
                      licenseDate != null
                          ? RotivaDateUtils.formatTurkishDate(licenseDate!)
                          : 'Belirtilmedi',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: const Icon(Icons.edit_calendar, size: 20),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: licenseDate ?? DateTime(2020, 1, 1),
                        firstDate: DateTime(1970, 1, 1),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setDialogState(() => licenseDate = picked);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('İptal'),
                ),
                FilledButton(
                  onPressed: () async {
                    await repository.updateProfile(
                      user.copyWith(
                        driverBirthDate: birthDate,
                        licenseIssueDate: licenseDate,
                      ),
                    );
                    if (context.mounted) {
                      Navigator.of(ctx).pop();
                      RotivaDialogs.showSnackBar(
                        context,
                        'Sürücü bilgileriniz güncellendi.',
                        isSuccess: true,
                      );
                      setState(() {});
                    }
                  },
                  child: const Text('Kaydet'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Uygulama Hakkında Diyaloğu
  void _showAboutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF1565C0)),
              SizedBox(width: 8),
              Text(
                'Uygulama Hakkında',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${AppConstants.appName} — ${AppConstants.appTagline}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Sürüm: ${AppConstants.appVersion}',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(ctx).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Rotiva, SoftIto Mobil Geliştirme Eğitimi kapsamında hazırlanmış, backend gerektirmeyen, Material Design 3 standartlarında akıllı araç kiralama ve takip simülasyonudur.',
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 12),
              const Text(
                '• Renk kodlu araç ve yakıt rozetleri\n'
                '• %10 şube nakit indirimi kuralı\n'
                '• Çakışma önleyici kiralama takvimi\n'
                '• Dinamik M3 Açık/Koyu tema yönetimi',
                style: TextStyle(fontSize: 12, height: 1.4),
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Kapat'),
            ),
          ],
        );
      },
    );
  }

  // Çıkış Yapma Metodu (Madde 3 Gereksinimleri)
  Future<void> _handleLogout() async {
    final confirm = await RotivaDialogs.showConfirmationDialog(
      context: context,
      title: 'Çıkış Yap',
      message: 'Hesabınızdan çıkış yapmak istediğinize emin misiniz?',
      confirmText: 'Çıkış Yap',
      cancelText: 'İptal',
      isDestructive: true,
    );

    if (confirm && mounted) {
      await RotivaScope.of(context).repository.logout();
      if (!mounted) return;
      // Geri tuşuyla korumalı ekranlara dönülememesi için pushAndRemoveUntil kullanılır
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rotivaScope = RotivaScope.of(context);
    final repository = rotivaScope.repository;
    final themeController = rotivaScope.themeController;
    final user = repository.currentUser;

    // Kullanıcının kiralama istatistikleri
    final allCustomerRentals = user != null
        ? repository.getRentalsForCustomer(user.id)
        : <Rental>[];

    final activeRentals = allCustomerRentals
        .where(
          (r) =>
              r.rentalStatus == RentalStatus.active ||
              r.rentalStatus == RentalStatus.approved,
        )
        .toList();

    final completedRentals = allCustomerRentals
        .where((r) => r.rentalStatus == RentalStatus.completed)
        .toList();

    final birthDateStr = user?.driverBirthDate != null
        ? '${RotivaDateUtils.formatTurkishDate(user!.driverBirthDate!)} (${RotivaDateUtils.calculateExactAge(user.driverBirthDate!)} yaş)'
        : 'Belirtilmedi';

    final licenseStr = user?.licenseIssueDate != null
        ? '${RotivaDateUtils.formatTurkishDate(user!.licenseIssueDate!)} (${RotivaDateUtils.calculateExactLicenseYears(user.licenseIssueDate!)} yıllık sürücü)'
        : 'Belirtilmedi';

    final userScore = user?.userScore;

    return Scaffold(
      appBar: const RotivaAppBar(titleText: 'Profil & Hesabım'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ==================== KULLANICI KARTI ====================
            Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Avatar (Ad Soyad Baş Harfleri)
                        CircleAvatar(
                          radius: 34,
                          backgroundColor: theme.colorScheme.primary.withValues(
                            alpha: 0.15,
                          ),
                          child: Text(
                            _getInitials(user?.fullName ?? ''),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.primary,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      user?.fullName ?? 'Misafir Müşteri',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                          ),
                                    ),
                                  ),
                                  // Rol Rozeti (Müşteri / Yönetici)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      user?.role.displayName ?? 'Müşteri',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.email_outlined,
                                    size: 14,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      user?.email ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.phone_outlined,
                                    size: 14,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    user?.phone ?? '-',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 8),

                    // Müşteri Puanı & Profil Düzenle Butonu
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 5 Yıldız Üzerinden Müşteri Puanı
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              userScore != null
                                  ? '${userScore.toStringAsFixed(1)} / 5.0'
                                  : 'Puan yok',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(Müşteri Skoru)',
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        // Profil Düzenleme Butonu
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                          ),
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Profili Düzenle'),
                          onPressed: _editProfileInfo,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ==================== KİRALAMA BİLGİLERİM ====================
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.4,
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: 'Kiralama Bilgilerim',
                      padding: EdgeInsets.zero,
                      trailing: Text(
                        'Toplam: ${allCustomerRentals.length}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Kiralama İstatistik Kutucukları
                    Row(
                      children: [
                        Expanded(
                          child: _buildRentalStatBox(
                            title: 'Aktif / Onaylı',
                            count: activeRentals.length,
                            color: Colors.green,
                            context: context,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildRentalStatBox(
                            title: 'Tamamlanan',
                            count: completedRentals.length,
                            color: Colors.blue,
                            context: context,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildRentalStatBox(
                            title: 'Toplam Harcama',
                            countText: RotivaFormatters.formatCurrency(
                              allCustomerRentals
                                  .where(
                                    (r) =>
                                        r.rentalStatus !=
                                        RentalStatus.cancelled,
                                  )
                                  .fold<double>(
                                    0.0,
                                    (sum, r) => sum + r.finalPrice,
                                  ),
                            ),
                            color: Colors.purple,
                            context: context,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Son Kiralamaların Önizlemesi veya Boş Durum
                    if (allCustomerRentals.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.car_rental_outlined,
                              size: 32,
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Henüz bir araç kiralamadınız.',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Araçlar sekmesinden dilediğiniz aracı rezerve edebilirsiniz.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      // En son 2 kiralamanın hızlı kartı
                      ...allCustomerRentals
                          .take(2)
                          .map(
                            (rental) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.directions_car,
                                    size: 24,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          rental.vehicleName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          '${rental.reservationCode} • ${rental.rentalDays} Gün',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  StatusBadge.rental(rental.rentalStatus),
                                ],
                              ),
                            ),
                          ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.receipt_long, size: 16),
                          label: const Text('Tüm Kiralamalarımı Gör'),
                          onPressed: () {
                            // Kiralamalarım sekmesine geçiş
                            final shellState = context
                                .findAncestorStateOfType<
                                  CustomerShellScreenState
                                >();
                            if (shellState != null) {
                              shellState.switchTab(2);
                            }
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ==================== SÜRÜCÜ BELGELERİ ====================
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.4,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    SectionHeader(
                      title: 'Sürücü Belgeleri & Şartlar',
                      padding: EdgeInsets.zero,
                      trailing: TextButton.icon(
                        icon: const Icon(Icons.edit, size: 14),
                        label: const Text('Düzenle'),
                        onPressed: _editDriverInfo,
                      ),
                    ),
                    const Divider(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.cake_outlined),
                      title: const Text(
                        'Doğum Tarihi',
                        style: TextStyle(fontSize: 12),
                      ),
                      subtitle: Text(
                        birthDateStr,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.badge_outlined),
                      title: const Text(
                        'Ehliyet Durumu',
                        style: TextStyle(fontSize: 12),
                      ),
                      subtitle: Text(
                        licenseStr,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ==================== AYARLAR VE TEMA ====================
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.4,
              ),
              child: Column(
                children: [
                  const SectionHeader(title: 'Görünüm & Tema'),
                  ListTile(
                    leading: const Icon(Icons.light_mode_outlined),
                    title: const Text('Açık Tema (Mavi)'),
                    trailing: themeController.themeMode == ThemeMode.light
                        ? Icon(
                            Icons.check_circle,
                            color: theme.colorScheme.primary,
                          )
                        : null,
                    onTap: () => themeController.setThemeMode(ThemeMode.light),
                  ),
                  ListTile(
                    leading: const Icon(Icons.dark_mode_outlined),
                    title: const Text('Koyu Tema (Antrasit / Turuncu)'),
                    trailing: themeController.themeMode == ThemeMode.dark
                        ? Icon(
                            Icons.check_circle,
                            color: theme.colorScheme.primary,
                          )
                        : null,
                    onTap: () => themeController.setThemeMode(ThemeMode.dark),
                  ),
                  ListTile(
                    leading: const Icon(Icons.phone_android_outlined),
                    title: const Text('Sistem Varsayılanı'),
                    trailing: themeController.themeMode == ThemeMode.system
                        ? Icon(
                            Icons.check_circle,
                            color: theme.colorScheme.primary,
                          )
                        : null,
                    onTap: () => themeController.setThemeMode(ThemeMode.system),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('Uygulama Hakkında'),
                    subtitle: const Text('Rotiva v1.0.0 — Bilgi ve Sürüm'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showAboutDialog(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ==================== DEMO SIFIRLAMA ====================
            OutlinedButton.icon(
              icon: const Icon(Icons.restart_alt),
              label: const Text('Demo Verilerini Sıfırla (Seed)'),
              onPressed: () async {
                final confirm = await RotivaDialogs.showConfirmationDialog(
                  context: context,
                  title: 'Demo Verilerini Sıfırla',
                  message: 'Tüm araç, kiralama ve kullanıcı verileri başlangıç mock verilerine geri yüklenecektir.',
                  confirmText: 'Sıfırla',
                );
                if (confirm && mounted) {
                  await repository.resetToSeed();
                  if (!context.mounted) return;
                  RotivaDialogs.showSnackBar(
                    context,
                    'Tüm veriler fabrika ayarlarına sıfırlandı.',
                    isSuccess: true,
                  );
                }
              },
            ),
            const SizedBox(height: 12),

            // ==================== ÇIKIŞ YAP (GÖRÜNÜR BUTON) ====================
            FilledButton.tonalIcon(
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.error.withValues(
                  alpha: 0.12,
                ),
                foregroundColor: theme.colorScheme.error,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.logout),
              label: const Text(
                'Çıkış Yap',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              onPressed: _handleLogout,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildRentalStatBox({
    required String title,
    int? count,
    String? countText,
    required Color color,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.35 : 0.25),
        ),
      ),
      child: Column(
        children: [
          Text(
            countText ?? '${count ?? 0}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: countText != null ? 12 : 16,
              fontWeight: FontWeight.w800,
              color: isDark ? color : Color.alphaBlend(Colors.black38, color),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
