import 'package:flutter/material.dart'; // Flutter Material Design kütüphanesini içe aktarır.
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod ConsumerWidget ve WidgetRef gibi reaktif arayüz yapılarını içe aktarır.

import '../core/config/app_constants.dart'; // Uygulama genelinde kullanılan sabit değerleri (uygulama adı vb.) içe aktarır.
import 'router/app_router.dart'; // Sayfalar arası geçişi sağlayan go_router yapılandırmasını içe aktarır.
import 'theme/app_theme.dart'; // Açık ve koyu tema stillerini üreten fabrika sınıfını içe aktarır.
import 'theme/theme_provider.dart'; // Tema modunu ve renk tercihlerini yöneten Riverpod sağlayıcılarını içe aktarır.

/// BoardConnect ana uygulama widget'ı
/// 'ConsumerWidget', Riverpod sağlayıcılarını (provider) dinleyerek durum değiştikçe otomatik olarak yeniden inşa (rebuild) edilen bir StatelessWidget türüdür.
class BoardConnectApp extends ConsumerWidget {
  // Widget oluşturucu fonksiyonu (constructor); 'super.key' Flutter widget ağacında widget kimliğini üst sınıfa iletir.
  const BoardConnectApp({super.key});

  @override // Üst sınıfta (ConsumerWidget) tanımlı build metodunu ezer (override eder).
  Widget build(BuildContext context, WidgetRef ref) {
    // 'BuildContext' widget'ın ağaçtaki yerini, 'WidgetRef' ise Riverpod sağlayıcılarına erişimi temsil eder.
    // 'ref.watch', ilgili sağlayıcıdaki veri değiştiğinde bu widget'ın yeniden çizilmesini tetikler.
    final router = ref.watch(
      appRouterProvider,
    ); // Yönlendirici (go_router) nesnesini dinler.
    final themeMode = ref.watch(
      themeModeProvider,
    ); // Kullanıcının seçtiği tema modunu (açık/koyu/sistem) dinler.
    final accentColor = ref.watch(
      accentColorProvider,
    ); // Kullanıcının seçtiği dinamik vurgu rengini dinler.

    // MaterialApp.router, GoRouter gibi gelişmiş bildirimsel (declarative) sayfa yönlendirme sistemleriyle çalışan ana uygulama widget'ıdır.
    return MaterialApp.router(
      title: AppConstants.appName, // İşletim sisteminde veya web tarayıcı sekmesinde görünecek uygulama başlığı.
      debugShowCheckedModeBanner: false, // Geliştirme aşamasında sağ üst köşede çıkan kırmızı "DEBUG" şeridini gizler.
      routerConfig:
          router, // go_router yönlendirme yapılandırmasını uygulamaya bağlar.
      themeMode: themeMode, // Uygulamanın hangi tema modunda (ThemeMode.light, ThemeMode.dark, ThemeMode.system) çalışacağını belirler.
      theme: AppTheme.light(
        accentColor,
      ), // Açık tema için seçilen vurgu rengiyle hazırlanmış ThemeData nesnesi.
      darkTheme: AppTheme.dark(
        accentColor,
      ), // Koyu tema için seçilen vurgu rengiyle hazırlanmış ThemeData nesnesi.
    );
  }
}
