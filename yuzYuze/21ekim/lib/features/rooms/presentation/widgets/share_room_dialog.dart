import 'package:flutter/material.dart'; // Flutter Material arayüz bileşenlerini içe aktarır.
import 'package:flutter/services.dart'; // Panoya (Clipboard) metin kopyalamak için Flutter Services kütüphanesini içe aktarır.

import '../../domain/room_model.dart'; // Oda veri modelini içe aktarır.

/// Odayı Paylaşma ve Davet İletişim Penceresi (ShareRoomDialog)
/// Kullanıcıların oda kodunu veya doğrudan bağlantı linkini kopyalayarak ekip arkadaşlarına iletmesini sağlar.
class ShareRoomDialog extends StatelessWidget {
  final RoomModel room; // Paylaşılacak odaya ait bilgileri barındıran nesne.

  const ShareRoomDialog({super.key, required this.room});

  /// Metni cihazın panosuna kopyalayan ve kullanıcıya onay SnackBar'ı gösteren yardımcı fonksiyon.
  void _copyToClipboard(BuildContext context, String text, String label) {
    // Verilen metni işletim sistemi panosuna (clipboard) aktarır.
    Clipboard.setData(ClipboardData(text: text));
    // Başarıyla kopyalandığını belirten 2 saniyelik yüzen bildirim gösterir.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label panoya kopyalandı!'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override // Diyalog penceresi arayüzünü oluşturur.
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Temayı okur.
    final isDark = theme.brightness == Brightness.dark; // Koyu tema kontrolü.

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ), // Yuvarlak köşeli diyalog.
      // Diyalog başlık satırı
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
        mainAxisSize: MainAxisSize.min, // İçeriği kadar yer kaplar.
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Oda adı
          Text(
            room.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
          // Bilgilendirici açıklama
          Text(
            'Arkadaşlarınızla aynı tuval üzerinde gerçek zamanlı çizim yapmak için bu bilgileri paylaşın.',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          const SizedBox(height: 20),

          // Katılım Kodu Kutusu (Büyük kod ve kopyalama butonu)
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
                      room.joinCode, // Odanın kodu (Örn: "BC-DEMO").
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                // Kodu panoya kopyalayan buton
                IconButton.filledTonal(
                  icon: const Icon(Icons.copy_rounded, size: 20),
                  onPressed: () =>
                      _copyToClipboard(context, room.joinCode, 'Katılım kodu'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Paylaşım Bağlantısı Kutusu (Web linki ve kopyalama butonu)
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
                        room.shareLink, // Odanın tam internet adresi.
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Bağlantıyı kopyalama butonu
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
        // Diyaloğu kapatma butonu
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Kapat'),
        ),
      ],
    );
  }
}
