import 'package:flutter/material.dart';

// Önceden oluşturduğumuz ekranlar.
// Dosya yollarını kendi proje yapına göre düzenle.
import 'screens/01_layout_screen.dart';
import 'screens/02_market_list_screen.dart';
import 'screens/03_transfer_form_screen.dart';

void main() {
  runApp(const DtmMasterApp());
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
  const DtmMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "DTM Flutter Sınıfı",

      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),

        scaffoldBackgroundColor: const Color(0xFFF8FAFC),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF0F172A),
          centerTitle: true,
          elevation: 0,
        ),
      ),

      home: const LiveCanvasScreen(),
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
  const LiveCanvasScreen({super.key});

  @override
  State<LiveCanvasScreen> createState() => _LiveCanvasScreenState();
}

class _LiveCanvasScreenState extends State<LiveCanvasScreen> {
  // Aktif sekmenin indeksini tutar.
  int _selectedIndex = 0;

  // Uygulamadaki ekranlarımız.
  //
  // IndexedStack ile birlikte kullanıldığında
  // sekmeler arasında geçiş yaparken ekranların
  // widget state'leri korunabilir.
  static const List<Widget> _screens = [
    LayoutStylingScreen(),
    MarketGridListScreen(),
    TransferFormScreen(),
  ];

  // Sekme başlıkları
  static const List<String> _titles = [
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
    setState(() {
      _selectedIndex = index;
    });
  }

  // =====================================================
  // 4. BİLDİRİM GÖSTERME
  //
  // ScaffoldMessenger:
  // Kullanıcıya geçici bir SnackBar mesajı gösterir.
  // =====================================================
  void _showNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Şu anda yeni bildiriminiz bulunmuyor."),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // =====================================================
  // 5. ANA ARAYÜZ
  // =====================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      // ÜST MENÜ
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),

        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,

        // Bildirim butonu
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined),
            tooltip: "Bildirimler",
            onPressed: _showNotifications,
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
      body: IndexedStack(index: _selectedIndex, children: _screens),

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
        selectedIndex: _selectedIndex,

        onDestinationSelected: _onTabSelected,

        backgroundColor: Colors.white,

        indicatorColor: const Color(0xFFE0E7FF),

        height: 72,

        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,

        destinations: const [
          // ANA SAYFA
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Color(0xFF6366F1)),
            label: "Ana Sayfa",
          ),

          // PİYASALAR
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view, color: Color(0xFF6366F1)),
            label: "Piyasalar",
          ),

          // TRANSFER
          NavigationDestination(
            icon: Icon(Icons.swap_horiz_outlined),
            selectedIcon: Icon(Icons.swap_horiz, color: Color(0xFF6366F1)),
            label: "Transfer",
          ),
        ],
      ),
    );
  }
}
