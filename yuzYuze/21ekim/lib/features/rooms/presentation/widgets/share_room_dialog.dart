import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/room_model.dart';

/// Odayı Paylaşma ve Davet İletişim Penceresi
class ShareRoomDialog extends StatelessWidget {
  final RoomModel room;

  const ShareRoomDialog({super.key, required this.room});

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label panoya kopyalandı!'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.share_rounded, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Odayı Paylaş',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            room.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            'Arkadaşlarınızla aynı tuval üzerinde gerçek zamanlı çizim yapmak için bu bilgileri paylaşın.',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          const SizedBox(height: 20),

          // Katılım Kodu Kutusu
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Katılım Kodu',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    Text(
                      room.joinCode,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                IconButton.filledTonal(
                  icon: const Icon(Icons.copy_rounded, size: 20),
                  onPressed: () =>
                      _copyToClipboard(context, room.joinCode, 'Katılım kodu'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Paylaşım Bağlantısı Kutusu
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Doğrudan Davet Bağlantısı',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      Text(
                        room.shareLink,
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.link_rounded),
                  onPressed: () => _copyToClipboard(
                    context,
                    room.shareLink,
                    'Davet bağlantısı',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Kapat'),
        ),
      ],
    );
  }
}
