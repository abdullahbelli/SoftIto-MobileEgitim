import 'package:flutter/material.dart'; // Flutter Material tasarım kütüphanesini içe aktarır.

import '../../domain/room_model.dart'; // Oda veri modelini içe aktarır.
import 'share_room_dialog.dart'; // Oda paylaşım diyalog penceresini içe aktarır.

/// Çalışmalar ekranındaki oda kartı bileşeni
/// Her bir çalışma odasını; başlığı, kodu, kurucusu, katılımcı sayısı ve işlem butonlarıyla kart şeklinde gösterir.
class RoomCard extends StatelessWidget {
  final RoomModel room; // Kartta görüntülenecek odaya ait veriler.
  final VoidCallback onEnter; // Odaya/tuvale giriş butonuna tıklandığında çalışacak geri çağırma (callback).
  final VoidCallback onDelete; // Oda silme işlemi onaylandığında çalışacak geri çağırma fonksiyonu.
  final bool isOwner; // Giriş yapmış kullanıcının bu odanın sahibi olup olmadığını belirten bayrak.

  const RoomCard({
    super.key,
    required this.room,
    required this.onEnter,
    required this.onDelete,
    this.isOwner = true, // Varsayılan olarak silme yetkisi verilir.
  });

  /// Kullanıcı silme ikonuna bastığında onay isteyen diyalog penceresini (AlertDialog) açar.
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(
              Icons.delete_outline_rounded,
              color: Colors.redAccent,
            ), // Kırmızı silme ikonu.
            SizedBox(width: 8),
            Text('Odayı Sil'),
          ],
        ),
        content: Text(
          '"${room.name}" odasını ve içerisindeki tuval çizimlerini kalıcı olarak silmek istediğinize emin misiniz?\n\nBu işlem geri alınamaz.',
        ),
        actions: [
          // Silmekten vazgeç butonu
          TextButton(
            onPressed: () => Navigator.pop(ctx), // Diyaloğu kapatır.
            child: const Text('Vazgeç'),
          ),
          // Kalıcı silmeyi onaylayan kırmızı buton
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx); // Önce diyaloğu kapatır.
              onDelete(); // Üst widget'tan iletilen silme fonksiyonunu tetikler.
            },
            child: const Text('Evet, Sil'),
          ),
        ],
      ),
    );
  }

  @override // Widget arayüzünü çizer.
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Tema bilgilerini alır.
    final isDark = theme.brightness == Brightness.dark; // Koyu mod kontrolü.

    return Card(
      elevation: isDark ? 2 : 0,
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18), // Yuvarlatılmış kart köşeleri.
        side: BorderSide(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey.withValues(alpha: 0.18),
        ),
      ),
      // Karta dokunulduğunda dalgalanma efekti (ripple) vermek ve tıklama algılamak için InkWell kullanılır.
      child: InkWell(
        onTap:
            onEnter, // Kartın herhangi bir yerine dokunulduğunda odaya girer.
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Üst Kısım: Çizim İkonu, Oda Adı, Katılım Kodu ve Silme Butonu
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Odanın çizim ikonu kutucuğu
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.draw_rounded,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Başlık ve Katılım Kodu Sütunu
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          room.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            // Katılım Kodu Rozeti (Badge)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.grey.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                room.joinCode,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Oda Sahibi Metni
                            Text(
                              'Kurucu: ${room.ownerName}',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white54 : Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Yalnızca oda sahibi ise görünen kırmızı silme çöp kutusu butonu
                  if (isOwner)
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                      tooltip: 'Odayı Sil',
                      onPressed: () => _confirmDelete(context),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Alt Bilgiler: Katılımcı Sayısı, Paylaşım Butonu ve Tuvale Giriş Butonu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Katılımcı sayısı göstergesi
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline_rounded,
                        size: 16,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${room.participantCount}/${room.maxParticipants} Katılımcı',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  // İşlem butonları
                  Row(
                    children: [
                      // Paylaşım bağlantısı ve kodunu gösteren diyalog butonu
                      IconButton(
                        icon: const Icon(Icons.share_outlined, size: 20),
                        tooltip: 'Paylaş',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => ShareRoomDialog(room: room),
                          );
                        },
                      ),
                      const SizedBox(width: 4),
                      // Tuvale doğrudan geçiş butonu
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(100, 38),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: onEnter,
                        icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                        label: const Text(
                          'Tuvale Gir',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
