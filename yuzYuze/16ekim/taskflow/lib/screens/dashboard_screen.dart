import 'package:flutter/material.dart';

import '../models/part_model.dart';

class DashboardScreen extends StatelessWidget {
  final List<PartModel> parts;

  const DashboardScreen({super.key, required this.parts});

  // Fiyatları okunabilir hale getirir.
  String _money(double value) {
    final parts = value.toStringAsFixed(0).split('.');
    final digits = parts[0];
    return digits.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
  }

  @override
  Widget build(BuildContext context) {
    // fold: Stokları ve envanter değerlerini toplar.
    final totalStock = parts.fold<int>(0, (sum, p) => sum + p.stock);

    final totalValue = parts.fold<double>(
      0,
      (sum, p) => sum + p.price * p.stock,
    );

    // Kritik stok: 5 adet ve altı.
    final lowParts = parts.where((p) => p.stock <= 5).toList();

    final healthy = parts.isEmpty
        ? 0.0
        : (parts.length - lowParts.length) / parts.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Genel Bakış",
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w900,
              color: Color(0xFF111827),
            ),
          ),
          const Text(
            "Deponuzun güncel stok durumu",
            style: TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 22),

          // Üstte büyük, koyu renkli envanter kartı.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "TOPLAM STOK DEĞERİ",
                      style: TextStyle(
                        color: Color(0xFFCBD5E1),
                        fontSize: 12,
                        letterSpacing: 1.4,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF273244),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.warehouse_outlined,
                        color: Color(0xFFF97316),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "${_money(totalValue)} ₺",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "${parts.length} ürün çeşidi • $totalStock adet stok",
                  style: const TextStyle(color: Color(0xFF94A3B8)),
                ),

                const SizedBox(height: 26),

                // Alt bölüm: Stok sağlığı.
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Stok Sağlığı",
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      "%${(healthy * 100).round()}",
                      style: const TextStyle(
                        color: Color(0xFFFB923C),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                LinearProgressIndicator(
                  value: healthy,
                  minHeight: 9,
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xFFF97316),
                  backgroundColor: const Color(0xFF334155),
                ),
              ],
            ),
          ),

          const SizedBox(height: 26),

          const Text(
            "Depo İstatistikleri",
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 14),

          // İki sütunlu istatistik kartları.
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 145,
            children: [
              _statCard(
                "Ürün Çeşidi",
                "${parts.length}",
                Icons.category_outlined,
                const Color(0xFF2563EB),
              ),
              _statCard(
                "Toplam Stok",
                "$totalStock",
                Icons.inventory_2_outlined,
                const Color(0xFF059669),
              ),
              _statCard(
                "Kritik Stok",
                "${lowParts.length}",
                Icons.warning_amber_rounded,
                const Color(0xFFDC2626),
              ),
              _statCard(
                "Stoku Yeterli",
                "${parts.length - lowParts.length}",
                Icons.verified_outlined,
                const Color(0xFFEA580C),
              ),
            ],
          ),

          const SizedBox(height: 28),

          Row(
            children: [
              const Expanded(
                child: Text(
                  "Stok Uyarıları",
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                "${lowParts.length} kayıt",
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Kritik stok yoksa başarı mesajı göster.
          if (lowParts.isEmpty)
            _warningCard(
              "Stoklar yeterli",
              "Kritik stok seviyesinde ürün bulunmuyor.",
              false,
            )
          else
            // List.generate: Kritik parçalar kadar kart üretir.
            ...lowParts.map((part) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _warningCard(
                  part.name,
                  "${part.brand} • ${part.stock} adet kaldı",
                  true,
                ),
              );
            }),
        ],
      ),
    );
  }

  // Tekrar kullanılan istatistik kartı.
  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
          ),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  // Kritik stok kartı.
  Widget _warningCard(String title, String subtitle, bool warning) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: warning
                  ? const Color(0xFFFEF2F2)
                  : const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              warning ? Icons.error_outline : Icons.check_circle_outline,
              color: warning ? Colors.red : Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
