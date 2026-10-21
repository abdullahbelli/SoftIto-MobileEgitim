import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/rooms_controller.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

/// Oda Oluşturma Bottom Sheet'i
class CreateRoomSheet extends ConsumerStatefulWidget {
  const CreateRoomSheet({super.key});

  @override
  ConsumerState<CreateRoomSheet> createState() => _CreateRoomSheetState();
}

class _CreateRoomSheetState extends ConsumerState<CreateRoomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  int _maxParticipants = 10;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final user = ref.read(authControllerProvider).value;
    final ownerId = user?.id ?? 'guest_user';
    final ownerName = user?.displayName ?? 'Kullanıcı';

    try {
      final newRoom = await ref
          .read(roomsControllerProvider.notifier)
          .createRoom(
            name: _nameController.text.trim(),
            maxParticipants: _maxParticipants,
            ownerId: ownerId,
            ownerName: ownerName,
          );

      if (mounted) {
        Navigator.pop(context); // Bottom sheet kapat
        context.push(
          '/whiteboard/${newRoom.id}',
          extra: {'roomName': newRoom.name},
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sürükleme Tutamacı
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Icon(
                  Icons.add_to_photos_rounded,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Text(
                  'Yeni Oda Oluştur',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Odanız için bir başlık belirleyin ve katılımcı sınırını ayarlayın.',
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.black54,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),

            // Oda Adı
            TextFormField(
              controller: _nameController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Oda Adı',
                hintText: 'Örn: Ürün Tasarım Değerlendirmesi',
                prefixIcon: Icon(Icons.meeting_room_outlined),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Lütfen oda adını girin.';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Kişi Sayısı
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Maksimum Katılımcı:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$_maxParticipants Kişi',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            Slider(
              value: _maxParticipants.toDouble(),
              min: 2,
              max: 30,
              divisions: 28,
              activeColor: theme.colorScheme.primary,
              onChanged: (val) {
                setState(() {
                  _maxParticipants = val.round();
                });
              },
            ),
            const SizedBox(height: 20),

            // Oluştur Butonu
            ElevatedButton(
              onPressed: _isLoading ? null : _handleCreate,
              child: _isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.black,
                      ),
                    )
                  : const Text('Odayı Oluştur ve Tuvale Geç'),
            ),
          ],
        ),
      ),
    );
  }
}
