import 'package:flutter/material.dart';

//kullanılacak ekranlar projeye dahil edilir
import 'screens/01_layout_screen.dart';
import 'screens/02_market_list_screen.dart';
import 'screens/03_transfer_form_screen.dart';

void main() {
  runApp(const DtmMasterApp()); // Ana widgetı çalıştırarak uygulamayı başlatır
}

// =====================================================
// 1. UYGULAMANIN ANA WIDGET'I
//
// StatelessWidget:
// Kendi içerisinde değişen bir state tutmaz.
//
// MaterialApp:
// Tema, uygulama başlığı ve başlangıç ekranını belirler.
// =====================================================
class DtmMasterApp extends StatelessWidget {
  // Durumu değişmeyen ana uygulama widgetını tanımlar
  const DtmMasterApp({
    super.key,
  }); // Widget'ın oluşturulmasını ve flutter tarafından takip edilmesini sağlar

  @override // Üst sınıftaki build metodunu yeniden tanımlar
  Widget build(BuildContext context) {
    // Uygulamanın temel arayüz yapısını oluşturur
    return MaterialApp(
      // Tema, başlık ve başlangıç ekranını yönetir
      debugShowCheckedModeBanner: false, // Sağ üstteki debug yazısını gizler
      title: "DTM Flutter Sınıfı", // Uygulamanın başlığı

      theme: ThemeData(
        // Uygulama genelindeki tasarım ayarları
        useMaterial3: true, // Material 3 tasarım sistemini etkinleştirir

        colorScheme: ColorScheme.fromSeed(
          // Ana renkten uyumlu bir renk paleti oluşturur
          seedColor: const Color(0xFF6366F1), // Renk paletinin temel rengi
          brightness: Brightness.light, // Açık renk teması
        ),

        scaffoldBackgroundColor: const Color(
          0xFFF8FAFC,
        ), // Ekranların varsayılan arka plan rengi

        appBarTheme: const AppBarTheme(
          // Üst menülerin ortak görünümü
          backgroundColor: Colors.white, // Üst menünün arka planını beyaz yapar
          foregroundColor: Color(
            0xFF0F172A,
          ), // Üst menüdeki yazı ve ikonların rengi
          centerTitle: true, // Üst menü başlığını ortalar
          elevation: 0, // Üst menünün gölgesini kaldırır
        ),
      ),

      home: const LiveCanvasScreen(), // Uygulama açıldığında gösterilecek ilk ekran
    );
  }
}

// =====================================================
// 2. ANA EKRAN
//
// StatefulWidget kullanıyoruz çünkü kullanıcı
// sekmeler arasında geçiş yaptığında seçilen
// sayfanın indeksini değiştirmemiz gerekiyor.
// =====================================================
class LiveCanvasScreen extends StatefulWidget {
  // Durumu değişebilen ve sekme geçişlerini destekleyen ekranı tanımlar
  const LiveCanvasScreen({
    super.key,
  }); // Ekranın oluşturulmasını ve widget ağacında takip edilmesini sağlar

  @override // Üst sınıftaki createState metodunu yeniden tanımlar
  State<LiveCanvasScreen> createState() => _LiveCanvasScreenState(); // Ekranın değişen durumunu yönetecek State nesnesini oluşturur
}

class _LiveCanvasScreenState extends State<LiveCanvasScreen> {
  // Aktif sekmeyi ve ekranın durumunu yönetir
  // Aktif sekmenin indeksini tutar.
  int _selectedIndex = 0; // Başlangıçta ilk sekmenin seçili olmasını sağlar

  // Uygulamadaki ekranlarımız.
  // IndexedStack ile birlikte kullanıldığında sekmeler arasında geçiş yaparken ekranların widget statleri korunabilir.
  static const List<Widget> _screens = [
    // Alt menüde gösterilecek ekranları bir listede tutar
    LayoutStylingScreen(), // Birinci sekmede ana sayfayı gösterir
    MarketGridListScreen(), // İkinci sekmede piyasa ve işlem listesini gösterir
    TransferFormScreen(), // Üçüncü sekmede para transferi formunu gösterir
  ];

  static const List<String> _titles = [
    // Her sekme için üst menüde gösterilecek başlıkları
    "DTM Ana Sayfa",
    "Piyasalar & İşlemler",
    "Para Transferi",
  ];

  // =====================================================
  // 3. SEKME DEĞİŞTİRME
  //
  // setState:
  // _selectedIndex değiştiğinde ekran güncellenir.
  // =====================================================
  void _onTabSelected(int index) {
    // Kullanıcının seçtiği sekmenin indeksini alır
    setState(() {
      // Değişen sekme bilgisini fluttera bildirerek arayüzü günceller
      _selectedIndex =
          index; // Aktif sekmeyi kullanıcının seçtiği sekmeyle değiştirir
    });
  }

  // =====================================================
  // 4. BİLDİRİM GÖSTERME
  //
  // ScaffoldMessenger:
  // Kullanıcıya geçici bir SnackBar mesajı gösterir.
  // =====================================================
  void _showNotifications() {
    // Bildirim butonuna basıldığında mesaj gösterir
    ScaffoldMessenger.of(context).showSnackBar(
      // Mevcut ekranda geçici bir bildirim mesajı açar
      const SnackBar(
        // Ekranın alt kısmında kısa süreli mesaj kutusu oluşturur
        content: Text(
          "Şu anda yeni bildiriminiz bulunmuyor.",
        ), // Kullanıcıya gösterilecek mesaj
        duration: Duration(seconds: 2), // Mesajın iki saniye görünmesini sağlar
        behavior: SnackBarBehavior
            .floating, // Mesajı ekranın üzerinde yüzen kutu şeklinde gösterir
      ),
    );
  }

  // =====================================================
  // 5. ANA ARAYÜZ
  // =====================================================
  @override // Üst sınıftaki build metodunu yeniden tanımlar
  Widget build(BuildContext context) {
    // Aktif sekmeye göre ana ekranın arayüzünü oluşturur
    return Scaffold(
      // Üst menü, içerik ve alt navigasyonu bir araya getirir
      backgroundColor: const Color(0xFFF8FAFC),
      // ÜST MENÜ
      appBar: AppBar(
        // Ekranın üst kısmındaki uygulama çubuğunu oluşturur
        title: Text(
          _titles[_selectedIndex], // Aktif sekmeye ait başlığı listeden alıp gösterir
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),

        centerTitle: true, // Başlığı üst menünün ortasına hizalar
        backgroundColor: Colors.white,
        elevation: 0, // Üst menünün gölgesini kaldırır
        // Bildirim butonu
        actions: [
          // Üst menünün sağ tarafındaki butonları tutar
          IconButton(
            // Tıklanabilir bildirim ikonu
            icon: const Icon(Icons.notifications_active_outlined),
            tooltip:
                "Bildirimler", // İkon üzerine gelindiğinde açıklama gösterir
            onPressed: _showNotifications, // Butona basıldığında bildirim metodunu çalıştırır
          ),
        ],
      ),

      // =================================================
      // GÖVDE
      //
      // IndexedStack:
      // Bütün ekranları widget ağacında tutar,
      // ancak yalnızca seçilen ekranı gösterir.
      //
      // index:
      // Hangi ekranın görüneceğini belirler.
      // =================================================
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ), // Aktif sekmenin ekranını gösterirken diğer ekranların durumunu korur
      // =================================================
      // ALT NAVİGASYON MENÜSÜ
      //
      // NavigationBar:
      // Material 3 alt navigasyon bileşenidir.
      //
      // selectedIndex:
      // Aktif sekmeyi belirtir.
      //
      // onDestinationSelected:
      // Kullanıcı sekmeye tıkladığında çalışır.
      // =================================================
      bottomNavigationBar: NavigationBar(
        // Ekranlar arasında geçiş yapılabilen alt menüyü oluşturur
        selectedIndex: _selectedIndex, // Alt menüde hangi sekmenin seçili olduğunu belirler

        onDestinationSelected:
            _onTabSelected, // Sekmeye tıklandığında seçilen indeksi günceller

        backgroundColor: Colors.white,

        indicatorColor: const Color(
          0xFFE0E7FF,
        ), // Seçili sekmenin arkasındaki vurgu rengi

        height: 72, // Alt menünün yüksekliği

        labelBehavior: NavigationDestinationLabelBehavior
            .alwaysShow, // Tüm sekmelerin isimlerini sürekli görünür tutar

        destinations: const [
          // Alt menüde gösterilecek sekmeleri tanımlar
          // ANA SAYFA
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
            ), // Sekme seçili değilken çizgili ev ikonunu gösterir
            selectedIcon: Icon(
              Icons.home,
              color: Color(0xFF6366F1),
            ), // Sekme seçiliyken dolu ve renkli ev ikonunu gösterir
            label: "Ana Sayfa", // Sekmenin adı
          ),

          // PİYASALAR
          NavigationDestination(
            icon: Icon(
              Icons.grid_view_outlined,
            ), // Sekme seçili değilken çizgili ızgara ikonunu gösterir
            selectedIcon: Icon(
              Icons.grid_view,
              color: Color(0xFF6366F1),
            ), // Sekme seçiliyken dolu ve renkli ızgara ikonunu gösterir
            label: "Piyasalar", // Sekmenin adı
          ),

          // TRANSFER
          NavigationDestination(
            icon: Icon(
              Icons.swap_horiz_outlined,
            ), // Sekme seçili değilken transfer ikonunu gösterir
            selectedIcon: Icon(
              Icons.swap_horiz,
              color: Color(0xFF6366F1),
            ), // Sekme seçiliyken renkli transfer ikonunu gösterir
            label: "Transfer", // Sekmenin adı
          ),
        ],
      ),
    );
  }
}
