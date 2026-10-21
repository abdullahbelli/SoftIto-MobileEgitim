import 'package:flutter/material.dart';

import '../controllers/whiteboard_controller.dart';
import '../../domain/board_object.dart';
import 'text_edit_dialog.dart';

/// Seçili nesnenin sağ üst köşesinde görünen aksiyon kontrolleri
class ObjectActionOverlay extends StatelessWidget {
  final WhiteboardState state;
  final WhiteboardController controller;

  const ObjectActionOverlay({
    super.key,
    required this.state,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final selectedObj = state.selectedObject;
    if (selectedObj == null) return const SizedBox.shrink();

    final worldBounds = selectedObj.getBounds();
    // Sağ üst köşenin ekran koordinatını hesapla
    final screenTopRight = controller.worldToScreen(worldBounds.topRight);

    // Ekran dışına taşmaması için sınırla
    final screenSize = MediaQuery.of(context).size;
    final posX = (screenTopRight.dx + 8).clamp(8.0, screenSize.width - 160.0);
    final posY = (screenTopRight.dy - 48).clamp(80.0, screenSize.height - 80.0);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPinned = selectedObj.isPinned;
    final isTextEditable =
        selectedObj is StickyNoteObject || selectedObj is TextObject;

    return Positioned(
      left: posX,
      top: posY,
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(12),
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isPinned
                  ? Colors.redAccent.withValues(alpha: 0.6)
                  : (isDark ? Colors.white12 : Colors.black12),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Raptiye (Sabitleme) Butonu
              IconButton(
                icon: Icon(
                  isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                  color: isPinned ? Colors.redAccent : Colors.grey,
                  size: 20,
                ),
                tooltip: isPinned ? 'Sabitlemeyi Kaldır' : 'Nesneyi Sabitle',
                onPressed: () {
                  controller.togglePinSelectedObject();
                },
              ),

              // Metin Düzenleme Butonu (Post-it veya Metin ise)
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

                    showDialog(
                      context: context,
                      builder: (ctx) => TextEditDialog(
                        title: selectedObj is StickyNoteObject
                            ? 'Post-it Notunu Düzenle'
                            : 'Metni Düzenle',
                        initialText: initialText,
                        onSave: (newText) {
                          controller.updateObjectText(selectedObj.id, newText);
                        },
                      ),
                    );
                  },
                ),

              // Çöp Kutusu (Silme) Butonu
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                  size: 20,
                ),
                tooltip: 'Nesneyi Sil',
                onPressed: () {
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
