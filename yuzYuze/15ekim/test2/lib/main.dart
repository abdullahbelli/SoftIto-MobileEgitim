import 'package:flutter/material.dart';

void main() {
  // Uygulamanın başlangıç noktası
  runApp(
      const DtmMasterApp()); // DtmMasterApp widgetını çalıştırarak uygulamayı başlatır
}

class DtmMasterApp extends StatelessWidget {
  // Durumu değişmeyen ana uygulama widgetı

  const DtmMasterApp(
      {super.key}); // Widgetın oluşturulmasını ve flutter tarafından takip edilmesini sağlar

  @override // Üst sınıftaki build metodunu yeniden tanımlar
  Widget build(BuildContext context) {
    // Uygulamanın arayüz yapısını oluşturur
    return MaterialApp(
      // Uygulamanın tema, başlık ve başlangıç ekranını yönetir
      debugShowCheckedModeBanner: false, // Sağ üstteki debug yazısını gizler
      title: "DTM Flutter Sınıfı", // Uygulamanın başlığını belirler
      theme: ThemeData(
        // Uygulama genelinde kullanılacak tasarım ayarlarını belirler
        useMaterial3: true, // Material 3 tasarım sistemini etkinleştirir
        colorScheme: ColorScheme.fromSeed(
          // Belirlenen ana renkten uyumlu bir renk paleti oluşturur
          seedColor: const Color(0xFF6366F1), // Renk paletinin temel rengi
          brightness: Brightness.light, // Açık renk temasını kullanır
        ),
      ),
      home:
          const LiveCanvasScreen(), // Uygulama açıldığında gösterilecek ilk ekran
    );
  }
}

class LiveCanvasScreen extends StatelessWidget {
  // Durumu değişmeyen arayüz ekranı
  const LiveCanvasScreen(
      {super.key}); // Ekran widgetının oluşturulmasını ve takip edilmesini sağlar

  @override // Üst sınıftaki build metodunu yeniden tanımlar
  Widget build(BuildContext context) {
    // Ekranda gösterilecek arayüz bileşenlerini oluşturur
    return Scaffold(
      // AppBar ve body gibi temel ekran alanlarını oluşturur
      backgroundColor: const Color(0xFFF8FaFC), // Ekranın arka plan rengi
      appBar: AppBar(
        // Ekranın üst kısmındaki uygulama çubuğu
        title: const Text(
          // Üst çubukta gösterilecek başlık
          "DTM Canlı Arayüz",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true, // Başlığı üst çubuğun ortasına hizalar
        backgroundColor: Colors.white,
        elevation: 0, // Üst çubuğun gölgesini kaldırır
        actions: [
          // Üst çubuğun sağ tarafına eklenecek butonları tutar
          IconButton(
            // Tıklanabilir bir ikon butonu oluşturur
            icon: const Icon(Icons
                .notifications_active_outlined), // Butonda bildirim ikonunu gösterir
            onPressed: () {}, // Butona basıldığında çalışır şu an işlem yapmaz
          ),
        ],
      ),
      body: const Center(
        // Ekranın ana içeriğini ortalar
        child: Text("Buraya Canlı Arayüz Gelecek"),
      ),
    );
  }
}
