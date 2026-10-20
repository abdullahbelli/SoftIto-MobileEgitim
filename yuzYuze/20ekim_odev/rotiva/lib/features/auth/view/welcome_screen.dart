import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/rotiva_logo.dart';
import '../../../core/widgets/rotiva_scope.dart';
import 'admin_login_screen.dart';
import 'customer_login_screen.dart';
import 'register_screen.dart';

/// Rotiva açılış ve karşılama ekranı.
/// Müşteri Girişi, Kayıt Ol ve Yönetici Girişi seçeneklerini sunar.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeController = RotivaScope.of(context).themeController;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: theme.brightness == Brightness.dark
                ? 'Açık Temaya Geç'
                : 'Koyu Temaya Geç',
            icon: Icon(
              theme.brightness == Brightness.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              color: theme.brightness == Brightness.dark
                  ? const Color(0xFFFF922B)
                  : const Color(0xFF1565C0),
            ),
            onPressed: () => themeController.toggleTheme(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo ve Marka Başlığı
                  const RotivaLogo(
                    size: 96,
                    showText: true,
                    showSubtitle: true,
                  ),
                  const SizedBox(height: 36),

                  // Tanıtıcı Kart
                  Card(
                    elevation: 0,
                    color: theme.colorScheme.surfaceContainerHighest
                        .withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildFeatureRow(
                            icon: Icons.directions_car_outlined,
                            text: 'Geniş model yelpazesi & anında kiralama',
                            context: context,
                          ),
                          const SizedBox(height: 10),
                          _buildFeatureRow(
                            icon: Icons.local_offer_outlined,
                            text: 'Şubede nakit ödemede %10 anında indirim',
                            context: context,
                          ),
                          const SizedBox(height: 10),
                          _buildFeatureRow(
                            icon: Icons.location_city_outlined,
                            text: 'Şubeden veya doğrudan adrese teslimat',
                            context: context,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Giriş Yap Butonu (Müşteri)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.login),
                      label: const Text('Giriş Yap'),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CustomerLoginScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Kayıt Ol Butonu
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.person_add_outlined),
                      label: const Text('Yeni Hesap Oluştur'),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Divider(height: 24),

                  // Yönetici Girişi (Demo)
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.secondary,
                    ),
                    icon: const Icon(Icons.admin_panel_settings_outlined),
                    label: const Text('Yönetici Girişi (Demo Panel)'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AdminLoginScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 8),
                  Text(
                    'SoftIto Mobil Eğitim Projesi • ${AppConstants.appVersion}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(
                        0.7,
                      ),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required String text,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
