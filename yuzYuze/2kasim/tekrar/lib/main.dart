import 'package:flutter/material.dart';

import 'tekrar3_state.dart';

// router yapısı bu dosyada kullanacağımız içn dahil ettik

void main() {
  // Uygulamanın başlangıç noktası
  runApp(const MyApp()); // MyApp widgetını çalıştırarak uygulamayı başlatır
}

class MyApp extends StatelessWidget {
  // Kendi içinde değişen state tutmayan ana uygulama widgetı
  const MyApp({
    super.key,
  }); // Widgetın oluşturulmasını ve flutter tarafından takip edilmesini sağlar

  @override // Üst sınıftaki build metodunu yeniden tanımlar
  Widget build(BuildContext context) {
    // Uygulamanın arayüz ve yönlendirme yapısını oluşturur
    return MaterialApp.router(
      // Router sistemiyle ekranlar arasında geçiş yapılmasını sağlar
      debugShowCheckedModeBanner: false, // Sağ üstteki debug yazısını gizler
      routerConfig: uygulamaRotalari, // Sayfa yollarını ve yönlendirme kurallarını tanımlayan router yapılandırmasını kullanır (tekrar3 ten geliyor)
    );
  }
}
