import 'package:flutter/material.dart'; // Material Design arayüz bileşenleri kütüphanesi.

import 'core/theme/app_theme.dart'; // Light ve Dark tema renk paletlerini içeren sınıf.
import 'core/theme/theme_controller.dart'; // Tema modunu (Açık/Koyu) yöneten denetleyici.
import 'core/widgets/rotiva_scope.dart'; // Bağımlılıkları widget ağacına sağlayan InheritedWidget.
import 'data/repositories/app_repository.dart'; // Veri işlemlerini yöneten merkezi depo.
import 'features/admin/view/admin_shell_screen.dart'; // Yönetici panelinin ana kabuk ekranı.
import 'features/auth/view/welcome_screen.dart'; // Giriş yapılmadığında açılan karşılama ekranı.
import 'features/home/view/customer_shell_screen.dart'; // Müşterinin ana kabuk ekranı.

/// Rotiva ana uygulama widget'ı.
/// Tema yönetimini, repository veri akışını ve ana rota yönlendirmesini sağlar.
class RotivaApp extends StatelessWidget {
  final AppRepository repository; // Merkezi veri deposu referansı.
  final ThemeController themeController; // Tema durumu denetleyicisi referansı.

  // Constructor: Gerekli (required) bağımlılıkları dışarıdan alır ve değişmez (const) olarak tanımlar.
  const RotivaApp({
    super.key,
    required this.repository,
    required this.themeController,
  });

  @override
  Widget build(BuildContext context) {
    // RotivaScope ile repository ve themeController'ı alt widget'ların erişimine açıyoruz.
    return RotivaScope(
      repository: repository,
      themeController: themeController,
      // ListenableBuilder: Hem veri tabanındaki hem de temadaki değişiklikleri dinleyip ekranı yeniler.
      child: ListenableBuilder(
        listenable: Listenable.merge([repository, themeController]),
        builder: (context, _) {
          return MaterialApp(
            title: 'Rotiva - Araç Kiralama ve Takip', // Uygulama başlığı.
            debugShowCheckedModeBanner:
                false, // Sağ üstteki hata ayıklama bandını gizler.
            theme: AppTheme.lightTheme, // Açık tema konfigürasyonu.
            darkTheme: AppTheme.darkTheme, // Koyu tema konfigürasyonu.
            themeMode: themeController
                .themeMode, // Seçili aktif tema modu (Açık/Koyu/Sistem).
            home: _determineInitialScreen(), // Kullanıcının oturum durumuna göre ilk açılacak ekran.
          );
        },
      ),
    );
  }

  /// Kullanıcının giriş yapıp yapmadığına ve rolüne göre gösterilecek ekranı belirler.
  Widget _determineInitialScreen() {
    // Kullanıcı henüz oturum açmamışsa karşılama ekranına yönlendirilir.
    if (!repository.isAuthenticated) {
      return const WelcomeScreen();
    }
    // Oturum açan kullanıcı yönetici ise yönetici paneli açılır.
    if (repository.isAdmin) {
      return const AdminShellScreen();
    }
    // Müşteri rolündeki kullanıcılar için müşteri ana ekranı açılır.
    return const CustomerShellScreen();
  }
}
