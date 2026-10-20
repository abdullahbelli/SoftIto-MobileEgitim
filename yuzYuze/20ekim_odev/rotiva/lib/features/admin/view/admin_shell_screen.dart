import 'package:flutter/material.dart';

import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/rotiva_app_bar.dart';
import '../../../core/widgets/rotiva_scope.dart';
import '../../auth/view/welcome_screen.dart';
import 'admin_customers_tab.dart';
import 'admin_dashboard_tab.dart';
import 'admin_rentals_tab.dart';
import 'admin_vehicles_tab.dart';

/// Yönetici Paneli Ana Kabuğu (Shell).
/// Dashboard, Araç Yönetimi (CRUD), Kiralama Takibi ve Müşteri Listesi sekmeleri.
class AdminShellScreen extends StatefulWidget {
  const AdminShellScreen({super.key});

  @override
  State<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends State<AdminShellScreen> {
  int _currentIndex = 0;

  Future<void> _handleLogout() async {
    final confirm = await RotivaDialogs.showConfirmationDialog(
      context: context,
      title: 'Çıkış Yap',
      message: 'Hesabınızdan çıkış yapmak istediğinize emin misiniz?',
      confirmText: 'Çıkış Yap',
      cancelText: 'İptal',
      isDestructive: true,
    );

    if (confirm && mounted) {
      await RotivaScope.of(context).repository.logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = const [
      AdminDashboardTab(),
      AdminVehiclesTab(),
      AdminRentalsTab(),
      AdminCustomersTab(),
    ];

    return Scaffold(
      appBar: RotivaAppBar(
        titleText: 'Yönetici Paneli',
        actions: [
          IconButton(
            tooltip: 'Yönetici Çıkışı',
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
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
