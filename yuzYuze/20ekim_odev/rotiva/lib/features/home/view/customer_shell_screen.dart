import 'package:flutter/material.dart';

import '../../rentals/view/my_rentals_tab_view.dart';
import '../../profile/view/profile_tab_view.dart';
import '../../vehicles/view/vehicles_tab_view.dart';
import 'home_tab_view.dart';

/// Müşteri ana kabuğu (Shell).
/// Ana Sayfa, Araçlar, Kiralamalarım ve Profil sekmeleri arasında geçiş sağlar.
class CustomerShellScreen extends StatefulWidget {
  final int initialTabIndex;

  const CustomerShellScreen({super.key, this.initialTabIndex = 0});

  @override
  State<CustomerShellScreen> createState() => CustomerShellScreenState();
}

class CustomerShellScreenState extends State<CustomerShellScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
  }

  void switchTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeTabView(onNavigateToVehicles: () => switchTab(1)),
      const VehiclesTabView(),
      const MyRentalsTabView(),
      const ProfileTabView(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: switchTab,
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
