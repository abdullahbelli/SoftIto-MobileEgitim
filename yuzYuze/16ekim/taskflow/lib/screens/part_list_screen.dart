import 'package:flutter/material.dart';

import '../models/part_model.dart';

class PartListScreen extends StatefulWidget {
  final List<PartModel> parts;

  // Stok değişikliklerini ana ekrana bildirir.
  final void Function(String id, int change) onStockChange;

  const PartListScreen({
    super.key,
    required this.parts,
    required this.onStockChange,
  });

  @override
  State<PartListScreen> createState() => _PartListScreenState();
}

class _PartListScreenState extends State<PartListScreen> {
  // Kullanıcının arama kutusuna yazdığı metin.
  final TextEditingController _searchController = TextEditingController();

  String _searchText = "";
  String _category = "Tümü";

  final List<String> _categories = [
    "Tümü",
    "Motor",
    "Fren",
    "Filtre",
    "Elektrik",
    "Diğer",
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Stok miktarına göre etiket rengi.
  Color _stockColor(int stock) {
    if (stock == 0) return Colors.red;
    if (stock <= 5) return Colors.orange;
    return Colors.green;
  }

  // Stok miktarına göre açıklama.
  String _stockLabel(int stock) {
    if (stock == 0) return "TÜKENDİ";
    if (stock <= 5) return "KRİTİK STOK";
    return "STOKTA";
  }

  @override
  Widget build(BuildContext context) {
    // Hem kategoriye hem de arama metnine göre filtrele.
    final filteredParts = widget.parts.where((part) {
      final categoryMatch = _category == "Tümü" || part.category == _category;

      final query = _searchText.trim().toLowerCase();

      final searchMatch =
          part.name.toLowerCase().contains(query) ||
          part.brand.toLowerCase().contains(query) ||
          part.partCode.toLowerCase().contains(query);

      return categoryMatch && searchMatch;
    }).toList();

    return Column(
      children: [
        // Üst arama ve filtreleme alanı.
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Parça Envanteri",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Depodaki ürünleri ara ve yönet",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 18),

              // TextField:
              // Kullanıcı yazdıkça listeyi filtreler.
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchText = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Parça, marka veya kod ara...",
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchText.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchText = "");
                          },
                        )
                      : null,
                  fillColor: const Color(0xFFF8FAFC),
                ),
              ),

              const SizedBox(height: 18),

              // Yatay kaydırılabilen kategori filtreleri.
              SizedBox(
                height: 43,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final item = _categories[index];
                    final selected = item == _category;

                    return ChoiceChip(
                      label: Text(item),
                      selected: selected,
                      showCheckmark: false,
                      selectedColor: const Color(0xFF111827),
                      backgroundColor: const Color(0xFFF1F5F9),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? Colors.white
                            : const Color(0xFF334155),
                      ),
                      onSelected: (value) {
                        setState(() {
                          _category = item;
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Expanded:
        // Listenin geri kalan ekran alanını doldurmasını sağlar.
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Ürünler",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "${filteredParts.length} sonuç",
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              if (filteredParts.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(Icons.search_off, size: 54, color: Colors.grey),
                      SizedBox(height: 12),
                      Text("Aradığınız parça bulunamadı."),
                    ],
                  ),
                ),

              // Spread operator (...):
              // Listedeki her parça için widget üretir.
              ...filteredParts.map(
                (part) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildPartCard(part),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Her parça için detaylı stok kartı.
  Widget _buildPartCard(PartModel part) {
    final color = _stockColor(part.stock);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Parça için görsel simge alanı.
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.settings,
                  size: 31,
                  color: Color(0xFFF97316),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      part.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "${part.brand} • ${part.partCode}",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              // Stok durum rozeti.
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  _stockLabel(part.stock),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Text(
                part.category,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),

          const Divider(height: 28),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "BİRİM FİYAT",
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${part.price.toStringAsFixed(2)} ₺",
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              // Stok miktarı artırma / azaltma.
              Row(
                children: [
                  _stockButton(
                    Icons.remove,
                    part.stock > 0
                        ? () => widget.onStockChange(part.id, -1)
                        : null,
                  ),

                  SizedBox(
                    width: 43,
                    child: Text(
                      "${part.stock}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),

                  _stockButton(
                    Icons.add,
                    () => widget.onStockChange(part.id, 1),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Tekrar kullanılan stok kontrol butonu.
  Widget _stockButton(IconData icon, VoidCallback? onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        iconSize: 19,
        color: const Color(0xFF111827),
        constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
      ),
    );
  }
}
