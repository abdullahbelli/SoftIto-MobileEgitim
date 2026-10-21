import 'package:flutter/material.dart'; // Flutter Material tasarım kütüphanesini içe aktarır.

/// Şekil seçim açılır menüsü (ShapesMenu)
/// Araç çubuğundaki Şekiller butonuna basıldığında açılan ve Dikdörtgen, Daire/Elips, Çizgi ve Ok arasından seçim yaptıran mini menüdür.
class ShapesMenu extends StatelessWidget {
  final String activeShapeType; // O an seçili olan şeklin kimliği ('rectangle', 'ellipse', 'line', 'arrow').
  final ValueChanged<String> onShapeSelected; // Kullanıcı yeni bir şekil seçtiğinde tetiklenen geri çağırma (callback) fonksiyonu.

  const ShapesMenu({
    super.key,
    required this.activeShapeType,
    required this.onShapeSelected,
  });

  // Menüde listelenecek şekil tanımları (ID, Türkçe etiket ve simge).
  static const List<Map<String, dynamic>> shapes = [
    {
      'id': 'rectangle',
      'label': 'Dikdörtgen',
      'icon': Icons.crop_square_rounded,
    },
    {'id': 'ellipse', 'label': 'Daire / Elips', 'icon': Icons.circle_outlined},
    {'id': 'line', 'label': 'Çizgi', 'icon': Icons.horizontal_rule_rounded},
    {'id': 'arrow', 'label': 'Yön Oku', 'icon': Icons.arrow_right_alt_rounded},
  ];

  @override // Menü kartı arayüzünü oluşturur.
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Temayı alır.
    final isDark = theme.brightness == Brightness.dark; // Koyu mod kontrolü.

    return Container(
      width: 180, // Menü genişliği.
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
        boxShadow: [
          // Menünün altındaki derinlik gölgesi.
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // İçeriği kadar dikey yer kaplar.
        // Her şekil seçeneğini tıklanabilir bir satır (InkWell) olarak listeler.
        children: shapes.map((shape) {
          // Bu satırdaki şeklin aktif şekil olup olmadığını kontrol eder.
          final isSelected = activeShapeType == shape['id'];
          return InkWell(
            onTap: () => onShapeSelected(
              shape['id'],
            ), // Tıklanınca seçilen şekil ID'sini bildirir.
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              // Seçili satırın arka planını vurgu renginde hafifçe boyar.
              color: isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.15)
                  : Colors.transparent,
              child: Row(
                children: [
                  // Şekil ikonu
                  Icon(
                    shape['icon'] as IconData,
                    size: 20,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : (isDark ? Colors.white70 : Colors.black87),
                  ),
                  const SizedBox(width: 12),
                  // Şekil adı metni
                  Text(
                    shape['label'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                  const Spacer(), // Onay ikonunu en sağa iter.
                  // Seçili ise en sağda beliren onay (checkmark) ikonu
                  if (isSelected)
                    Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
