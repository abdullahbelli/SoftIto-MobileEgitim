import 'package:flutter/material.dart'; // Flutter'ın temel Material Design bileşenlerini içe aktarıyoruz.

import 'app.dart'; // Uygulamanın kök widget'ı olan RotivaApp sınıfını içe aktarıyoruz.
import 'core/theme/theme_controller.dart'; // Açık/koyu tema durumunu yöneten denetleyiciyi dahil ediyoruz.
import 'data/repositories/app_repository.dart'; // Veri işlemlerini (araçlar, kiralamalar, kullanıcılar) yürüten depoyu dahil ediyoruz.

/// Uygulamanın başlangıç noktası (Giriş fonksiyonu).
void main() async {
  // Flutter widget ağacı başlatılmadan önce asenkron işlemlerin güvenle çalışması için bağlayıcıyı başlatıyoruz.
  WidgetsFlutterBinding.ensureInitialized();

  // Tema yöneticisi nesnesini oluşturuyoruz.
  final themeController = ThemeController();
  // Kaydedilmiş tema tercihini (açık/koyu) yerel depolamadan asenkron olarak yüklüyoruz.
  await themeController.loadTheme();

  // Uygulamanın merkezi veri deposu nesnesini oluşturuyoruz.
  final repository = AppRepository();
  // Mock verileri veya yerel olarak saklanan kayıtları belleğe yüklüyoruz.
  await repository.initialize();

  // Hazırlanan bağımlılıkları parametre olarak vererek uygulamayı ayağa kaldırıyoruz.
  runApp(RotivaApp(repository: repository, themeController: themeController));
}
