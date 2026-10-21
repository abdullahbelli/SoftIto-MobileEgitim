import 'package:flutter/material.dart';

import '../../domain/room_model.dart';
import 'share_room_dialog.dart';

/// Çalışmalar ekranındaki oda kartı bileşeni
class RoomCard extends StatelessWidget {
  final RoomModel room;
  final VoidCallback onEnter;
  final VoidCallback onDelete;
  final bool isOwner;

  const RoomCard({
    super.key,
    required this.room,
    required this.onEnter,
    required this.onDelete,
    this.isOwner = true,
  });

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Odayı Sil'),
          ],
        ),
        content: Text(
          '"${room.name}" odasını ve içerisindeki tuval çizimlerini kalıcı olarak silmek istediğinize emin misiniz?\n\nBu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              onDelete();
            },
            child: const Text('Evet, Sil'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: isDark ? 2 : 0,
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey.withValues(alpha: 0.18),
        ),
      ),
      child: InkWell(
        onTap: onEnter,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Üst Kısım: Başlık, Kod ve Silme
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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

              // Alt Bilgiler: Katılımcı Sayısı & Aksiyonlar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                  Row(
                    children: [
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
