// Flutter Material tasarım kütüphanesini içeri aktarıyoruz.
import 'package:flutter/material.dart';

// İletişim pencereleri, ortak AppBar ve kapsam sağlayıcısını içeri aktarıyoruz.
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/rotiva_app_bar.dart';
import '../../../core/widgets/rotiva_scope.dart';
// Karşılama ve giriş ekranını içeri aktarıyoruz.
import '../../auth/view/welcome_screen.dart';
// Yönetici sekmelerini içeri aktarıyoruz.
import 'admin_customers_tab.dart';
import 'admin_dashboard_tab.dart';
import 'admin_rentals_tab.dart';
import 'admin_vehicles_tab.dart';

/// Yönetici Paneli Ana Kabuğu (Shell).
/// Dashboard (Özet), Araç Yönetimi (CRUD), Kiralama Takibi ve Müşteri Listesi sekmeleri arasında geçiş sağlar.
class AdminShellScreen extends StatefulWidget {
  // Statik const constructor tanımlıyoruz.
  const AdminShellScreen({super.key});

  @override
  State<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends State<AdminShellScreen> {
  // Aktif sekmenin indeksini tutan durum değişkeni (0: Özet, 1: Araçlar, 2: Kiralamalar, 3: Müşteriler).
  int _currentIndex = 0;

  /// Seçili sekmeye göre AppBar başlığını dinamik olarak döndüren yardımcı metot.
  String _getTabTitle(int index) {
    switch (index) {
      case 0:
        return 'Yönetici Paneli • Özet';
      case 1:
        return 'Yönetici Paneli • Araç Yönetimi';
      case 2:
        return 'Yönetici Paneli • Kiralamalar';
      case 3:
        return 'Yönetici Paneli • Müşteriler';
      default:
        return 'Yönetici Paneli';
    }
  }

  /// Yöneticinin oturumunu kapatmasını sağlayan onaylı çıkış fonksiyonu.
  Future<void> _handleLogout() async {
    // Çıkış öncesi kullanıcıya onay iletişim kutusu gösteriyoruz.
    final confirm = await RotivaDialogs.showConfirmationDialog(
      context: context,
      title: 'Çıkış Yap',
      message: 'Hesabınızdan çıkış yapmak istediğinize emin misiniz?',
      confirmText: 'Çıkış Yap',
      cancelText: 'İptal',
      isDestructive: true, // Kırmızı tehlike stili veriyoruz.
    );

    // Kullanıcı onayladıysa ve widget ağaçta aktifse (mounted) çıkış yapıyoruz.
    if (confirm && mounted) {
      await RotivaScope.of(context).repository.logout();
      if (mounted) {
        // Geri tuşuyla yönetici paneline dönülememesi için geçmişi temizleyerek karşılama ekranına yönlendiriyoruz.
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Yönetici sekmelerinin listesini oluşturuyoruz.
    final screens = const [
      AdminDashboardTab(),
      AdminVehiclesTab(),
      AdminRentalsTab(),
      AdminCustomersTab(),
    ];

    return Scaffold(
      // Ortak Rotiva AppBar'ı dinamik başlık ve çıkış butonu ile kullanıyoruz.
      appBar: RotivaAppBar(
        titleText: _getTabTitle(_currentIndex),
        actions: [
          IconButton(
            tooltip: 'Yönetici Çıkışı',
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      // Sekmeler arası geçişte durumun (scroll pozisyonu vb.) korunması için IndexedStack kullanıyoruz.
      body: SafeArea(
        top: false, // AppBar zaten üst güvenli alanı yönetir.
        child: IndexedStack(index: _currentIndex, children: screens),
      ),
      // Material 3 standartlarında alt navigasyon çubuğu (NavigationBar).
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex, // Seçili sekme indeksi
        onDestinationSelected: (index) => setState(
          () => _currentIndex = index,
        ), // Tıklanınca durumu güncelliyoruz.
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Özet',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_car_outlined),
            selectedIcon: Icon(Icons.directions_car),
            label: 'Araçlar (CRUD)',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Kiralamalar',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Müşteriler',
          ),
        ],
      ),
    );
  }
}
