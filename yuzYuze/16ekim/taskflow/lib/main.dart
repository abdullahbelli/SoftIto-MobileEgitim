import 'package:flutter/material.dart';

import 'models/part_model.dart';
import 'screens/dashboard_screen.dart';
import 'screens/part_list_screen.dart';
import 'screens/add_part_screen.dart';

void main() {
  runApp(const AutoPartsApp());
}

class AutoPartsApp extends StatelessWidget {
  const AutoPartsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "AutoParts Garage",

      // Uygulamanın genel tasarım ayarları.
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF97316),
          primary: const Color(0xFFF97316),
        ),

        // Form kutularının ortak görünümü.
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 17,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),
      ),

      home: const AutoPartsHome(),
    );
  }
}

// StatefulWidget:
// Ortak stok verilerini ve aktif sayfayı yönetir.
class AutoPartsHome extends StatefulWidget {
  const AutoPartsHome({super.key});

  @override
  State<AutoPartsHome> createState() => _AutoPartsHomeState();
}

class _AutoPartsHomeState extends State<AutoPartsHome> {
  int _selectedIndex = 0;

  // Örnek envanter verileri.
  final List<PartModel> _parts = [
    const PartModel(
      id: "1",
      name: "Yağ Filtresi",
      partCode: "YF-001",
      brand: "Hyundai",
      category: "Filtre",
      price: 450,
      stock: 25,
    ),
    const PartModel(
      id: "2",
      name: "Fren Balatası",
      partCode: "FB-002",
      brand: "Toyota",
      category: "Fren",
      price: 1250,
      stock: 8,
    ),
    const PartModel(
      id: "3",
      name: "Hava Filtresi",
      partCode: "HF-003",
      brand: "Renault",
      category: "Filtre",
      price: 350,
      stock: 3,
    ),
    const PartModel(
      id: "4",
      name: "Triger Seti",
      partCode: "TS-004",
      brand: "Volkswagen",
      category: "Motor",
      price: 3200,
      stock: 12,
    ),
  ];

  // Yeni parça ekler ve parça listesine geçer.
  void _addPart(PartModel part) {
    setState(() {
      _parts.add(part);
      _selectedIndex = 1;
    });
  }

  // Aynı parça kodunun tekrar kaydedilmesini önler.
  bool _partCodeExists(String code) {
    return _parts.any(
      (part) => part.partCode.toLowerCase() == code.trim().toLowerCase(),
    );
  }

  // Stok artırma veya azaltma.
  void _changeStock(String id, int change) {
    final index = _parts.indexWhere((part) => part.id == id);

    if (index == -1) return;

    final newStock = _parts[index].stock + change;

    // Stok sıfırın altına düşemez.
    if (newStock < 0) return;

    setState(() {
      _parts[index] = _parts[index].copyWith(stock: newStock);
    });
  }

  // Sekme değiştirme işlemi.
  void _changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(parts: _parts),
      PartListScreen(parts: _parts, onStockChange: _changeStock),
      AddPartScreen(onPartAdded: _addPart, partCodeExists: _partCodeExists),
    ];

    return Scaffold(
      // Daha sade ve markalı üst menü.
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        foregroundColor: Colors.white,
        toolbarHeight: 72,

        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: const Color(0xFFF97316),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(Icons.car_repair, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "AUTOPARTS",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  "GARAGE • STOK YÖNETİMİ",
                  style: TextStyle(
                    fontSize: 9,
                    color: Color(0xFF94A3B8),
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ],
        ),

        actions: [
          IconButton(
            tooltip: "Yeni Parça",
            onPressed: () => _changeTab(2),
            icon: const Icon(Icons.add_box_outlined),
          ),
        ],
      ),

      // Ekranlar arasında state koruyarak geçiş.
      body: IndexedStack(index: _selectedIndex, children: screens),

      // Material 3 alt navigasyon.
      bottomNavigationBar: NavigationBar(
        height: 75,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFFFEDD5),
        selectedIndex: _selectedIndex,
        onDestinationSelected: _changeTab,

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: Color(0xFFF97316)),
            label: "Panel",
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2, color: Color(0xFFF97316)),
            label: "Envanter",
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle, color: Color(0xFFF97316)),
            label: "Parça Ekle",
          ),
        ],
      ),
    );
  }
}
