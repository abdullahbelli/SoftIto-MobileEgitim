import 'package:flutter/material.dart'; // Flutter Material tasarım kütüphanesini içe aktarır.

/// Metin ve Post-it not içerik düzenleme diyaloğu (TextEditDialog)
/// Kullanıcının yeni bir metin/not eklerken veya var olanı düzenlerken açılan çok satırlı düzenleme penceresidir.
class TextEditDialog extends StatefulWidget {
  final String
  title; // Diyalog penceresi başlığı (Örn: "Post-it Notunu Düzenle").
  final String initialText; // Düzenlenecek mevcut metin içeriği (varsa).
  final ValueChanged<String>
  onSave; // Kaydet butonuna basıldığında yeni metni ileten fonksiyon.
  final bool showColorPicker; // Not rengi seçicinin gösterilip gösterilmeyeceğini belirleyen bayrak.
  final Color? initialColor; // Başlangıçtaki seçili renk.
  final ValueChanged<Color>?
  onColorChanged; // Renk değiştirildiğinde tetiklenen geri çağırma fonksiyonu.

  const TextEditDialog({
    super.key,
    required this.title,
    this.initialText = '',
    required this.onSave,
    this.showColorPicker = false,
    this.initialColor,
    this.onColorChanged,
  });

  // Post-it notları için pastel tonlardaki renk seçenekleri paleti.
  static const List<Color> postItColors = [
    Color(0xFFFEF08A), // Klasik Sarı
    Color(0xFFBAE6FD), // Açık Gökyüzü Mavisi
    Color(0xFFBBF7D0), // Açık Nane Yeşili
    Color(0xFFFECDD3), // Açık Gül Pembesi
    Color(0xFFE9D5FF), // Açık Eflatun/Mor
    Color(0xFFFED7AA), // Açık Şeftali/Turuncu
  ];

  @override // Durum nesnesini üretir.
  State<TextEditDialog> createState() => _TextEditDialogState();
}

/// Metin düzenleme diyaloğunun durum yönetimi sınıfı
class _TextEditDialogState extends State<TextEditDialog> {
  late final TextEditingController _controller; // Metin kutusu denetleyicisi.
  late Color _selectedColor; // O an seçili olan post-it rengi.

  @override // Başlangıç durumunu hazırlar.
  void initState() {
    super.initState();
    // Gelen metni kontrolöre bağlar.
    _controller = TextEditingController(text: widget.initialText);
    // Gelen rengi veya varsayılan ilk rengi (sarı) seçili yapar.
    _selectedColor = widget.initialColor ?? TextEditDialog.postItColors[0];
  }

  @override // Bellek temizliği yapar.
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override // Diyalog arayüzünü çizer.
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Temayı alır.
    final isDark = theme.brightness == Brightness.dark; // Koyu mod kontrolü.

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ), // Yuvarlak köşeler.
      title: Text(
        widget.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: 380, // Genişlik sınırlaması.
        child: Column(
          mainAxisSize: MainAxisSize.min, // İçeriği kadar yer kaplar.
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Çok satırlı metin giriş alanı
            TextField(
              controller: _controller,
              autofocus: true, // Açıldığında imleci doğrudan içine yerleştirir.
              maxLines: 5, // En fazla 5 satıra kadar genişler.
              minLines: 3, // En az 3 satır yüksekliğindedir.
              decoration: InputDecoration(
                hintText: 'Metninizi veya notunuzu buraya yazın...',
                filled: true,
                fillColor: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFF1F5F9),
              ),
            ),
            // Eğer renk seçimi etkinleştirilmişse post-it renk paletini gösterir.
            if (widget.showColorPicker) ...[
              const SizedBox(height: 16),
              const Text(
                'Not Rengi Seçin:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                // Renk dairelerini yan yana dizer.
                children: TextEditDialog.postItColors.map((color) {
                  final isSelected = _selectedColor == color;
                  return InkWell(
                    onTap: () {
                      setState(
                        () => _selectedColor = color,
                      ); // Seçili rengi günceller.
                      widget.onColorChanged?.call(
                        color,
                      ); // Üst bileşene bildirir.
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        // Seçili olana kalın siyah çerçeve, diğerlerine ince çerçeve verir.
                        border: isSelected
                            ? Border.all(color: Colors.black87, width: 2.5)
                            : Border.all(color: Colors.black12, width: 1),
                      ),
                      // Seçili renge onay ikonu ekler.
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.black87,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
      actions: [
        // İptal butonu: Değişiklik yapmadan kapatır.
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        // Kaydet butonu: Yeni metni aktarıp kapatır.
        ElevatedButton(
          onPressed: () {
            widget.onSave(_controller.text.trim());
            Navigator.pop(context);
          },
          child: const Text('Kaydet'),
        ),
      ],
    );
  }
}
