// Flutter Material tasarım bileşenlerini içeri aktarıyoruz.
import 'package:flutter/material.dart';

// Müşteri sekmelerini (Ana Sayfa, Araçlar, Kiralamalarım, Profil) içeri aktarıyoruz.
import '../../rentals/view/my_rentals_tab_view.dart';
import '../../profile/view/profile_tab_view.dart';
import '../../vehicles/view/vehicles_tab_view.dart';
import 'home_tab_view.dart';

/// Müşteri ana kabuk ekranı (Customer Shell).
/// Ana Sayfa, Araçlar, Kiralamalarım ve Profil sekmeleri arasında IndexedStack ile durum kaybetmeden geçiş sağlar.
class CustomerShellScreen extends StatefulWidget {
  // İlk açılışta seçili olması istenen sekme indeksi (Varsayılan 0: Ana Sayfa)
  final int initialTabIndex;

  const CustomerShellScreen({super.key, this.initialTabIndex = 0});

  @override
  State<CustomerShellScreen> createState() => CustomerShellScreenState();
}

class CustomerShellScreenState extends State<CustomerShellScreen> {
  // Seçili aktif sekmenin indeksini tutan durum değişkeni
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    // Başlangıç sekmesini widget parametresinden alıyoruz.
    _currentIndex = widget.initialTabIndex;
  }

  /// Sekmeler arası programatik geçişi sağlayan genel metot (Profil veya Home üzerinden çağrılabilir)
  void switchTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    // Sekme widget'larının listesini tanımlıyoruz.
    final screens = [
      HomeTabView(
        onNavigateToVehicles: () => switchTab(1),
      ), // Filtreli listeye geçiş tetikleyicisi
      const VehiclesTabView(),
      const MyRentalsTabView(),
      const ProfileTabView(),
    ];

    return Scaffold(
      // Sekmeler arası geçişlerde scroll durumunun ve verilerin sıfırlanmaması için IndexedStack kullanıyoruz.
      body: IndexedStack(index: _currentIndex, children: screens),
      // Material Design 3 alt navigasyon çubuğu (NavigationBar)
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected:
            switchTab, // Kullanıcı tıkladığında ilgili sekmeye geçiyoruz.
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_car_outlined),
            selectedIcon: Icon(Icons.directions_car),
            label: 'Araçlar',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Kiralamalarım',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
