import 'package:flutter/material.dart'; // Flutter Material tasarım bileşenlerini içe aktarır.

import '../../domain/board_object.dart'; // Tuval nesnesi modellerini içe aktarır.
import '../controllers/whiteboard_controller.dart'; // Tuval durumu ve controller sınıflarını içe aktarır.
import 'text_edit_dialog.dart'; // Metin düzenleme diyalog penceresini içe aktarır.

/// Seçili nesnenin sağ üst köşesinde yüzen aksiyon kontrolleri (ObjectActionOverlay)
/// Tuvalde bir nesne seçildiğinde üzerinde beliren raptiye (sabitleme), düzenleme ve silme butonlarını barındırır.
class ObjectActionOverlay extends StatelessWidget {
  final WhiteboardState
  state; // Tuvalin anlık durumu (seçili nesne bilgisi vb.).
  final WhiteboardController
  controller; // Aksiyonları tetikleyecek tuval denetleyicisi.

  const ObjectActionOverlay({
    super.key,
    required this.state,
    required this.controller,
  });

  @override // Arayüzü inşa eder.
  Widget build(BuildContext context) {
    // Tuvalde o an seçilmiş nesneyi alır.
    final selectedObj = state.selectedObject;
    // Eğer hiçbir nesne seçili değilse ekrana hiçbir şey çizmez (boş kutu).
    if (selectedObj == null) return const SizedBox.shrink();

    // Seçili nesnenin tuval dünya koordinatlarındaki sınırlarını okur.
    final worldBounds = selectedObj.getBounds();
    // Sağ üst köşe noktasını tuval dünya koordinatından ekran piksel koordinatına çevirir.
    final screenTopRight = controller.worldToScreen(worldBounds.topRight);

    // Menünün ekranın dışına taşmasını engellemek için koordinatları ekran sınırlarına kelepçeler (clamp).
    final screenSize = MediaQuery.of(context).size;
    final posX = (screenTopRight.dx + 8).clamp(8.0, screenSize.width - 160.0);
    final posY = (screenTopRight.dy - 48).clamp(80.0, screenSize.height - 80.0);

    final isDark =
        Theme.of(context).brightness == Brightness.dark; // Koyu mod kontrolü.
    final isPinned = selectedObj.isPinned; // Nesne kilitli mi?
    // Nesnenin metni düzenlenebilir bir tipte (Post-it veya Metin) olup olmadığını kontrol eder.
    final isTextEditable =
        selectedObj is StickyNoteObject || selectedObj is TextObject;

    // Stack içinde mutlak konumlandırma sağlamak için Positioned widget'ı kullanılır.
    return Positioned(
      left: posX,
      top: posY,
      child: Material(
        elevation: 6, // Yüzen panel derinlik gölgesi.
        borderRadius: BorderRadius.circular(12),
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isPinned
                  ? Colors.redAccent.withValues(
                      alpha: 0.6,
                    ) // Kilitliyse kırmızı çerçeve.
                  : (isDark ? Colors.white12 : Colors.black12),
            ),
          ),
          child: Row(
            mainAxisSize:
                MainAxisSize.min, // Yalnızca butonlar kadar yer kaplar.
            children: [
              // Raptiye (Sabitleme / Kilitleme) Butonu
              IconButton(
                icon: Icon(
                  isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                  color: isPinned ? Colors.redAccent : Colors.grey,
                  size: 20,
                ),
                tooltip: isPinned ? 'Sabitlemeyi Kaldır' : 'Nesneyi Sabitle',
                onPressed: () {
                  // Seçili nesnenin raptiye durumunu tersine çevirir.
                  controller.togglePinSelectedObject();
                },
              ),

              // Metin Düzenleme Butonu (Yalnızca Post-it veya Metin nesnesi seçiliyse görünür)
              if (isTextEditable)
                IconButton(
                  icon: const Icon(Icons.edit_note_rounded, size: 20),
                  tooltip: 'Metni Düzenle',
                  onPressed: () {
                    String initialText = '';
                    if (selectedObj is StickyNoteObject) {
                      initialText = selectedObj.text;
                    } else if (selectedObj is TextObject) {
                      initialText = selectedObj.text;
                    }

                    // Metin düzenleme modal penceresini açar.
                    showDialog(
                      context: context,
                      builder: (ctx) => TextEditDialog(
                        title: selectedObj is StickyNoteObject
                            ? 'Post-it Notunu Düzenle'
                            : 'Metni Düzenle',
                        initialText: initialText,
                        onSave: (newText) {
                          // Yeni metni controller üzerinden nesneye kaydeder.
                          controller.updateObjectText(selectedObj.id, newText);
                        },
                      ),
                    );
                  },
                ),

              // Çöp Kutusu (Nesneyi Silme) Butonu
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                  size: 20,
                ),
                tooltip: 'Nesneyi Sil',
                onPressed: () {
                  // Seçili nesneyi tuvalden siler.
                  controller.deleteSelectedObject();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
