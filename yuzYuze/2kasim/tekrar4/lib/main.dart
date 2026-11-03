import 'package:flutter/material.dart';

import 'urun_listesi_ekrani.dart'; // Ürün listesi ekranını uygulamaya dahil eder

void main() {
  // Uygulamanın başlangıç noktası
  runApp(const MyApp()); // MyApp widgeını çalıştırarak uygulamayı başlatır
}

class MyApp extends StatelessWidget {
  // Değişebilir State nesnesi olmayan ana uygulama widgetını tanımlar
  const MyApp({
    super.key,
  }); // Widgetın oluşturulmasını ve flutter tarafından takip edilmesini sağlar

  @override // Üst sınıftaki build metodunu yeniden tanımlar
  Widget build(BuildContext context) {
    // Uygulamanın temel arayüz yapısı
    return MaterialApp(
      // Uygulamanın tema ve başlangıç ekranı gibi ayarlarını yönetir
      debugShowCheckedModeBanner: false, // debug yazısını gizler
      home: const UrunListesiEkrani(), // Uygulama açıldığında ürün listesi ekranını gösterir ( açılınca gösterilecek ilk ekran burada belirlenir)
    );
  }
}
