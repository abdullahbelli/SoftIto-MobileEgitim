import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/rooms_controller.dart';

/// Odaya Katılma Bottom Sheet'i
class JoinRoomSheet extends ConsumerStatefulWidget {
  const JoinRoomSheet({super.key});

  @override
  ConsumerState<JoinRoomSheet> createState() => _JoinRoomSheetState();
}

class _JoinRoomSheetState extends ConsumerState<JoinRoomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleJoin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final code = _codeController.text.trim().toUpperCase();

    try {
      final room = await ref
          .read(roomsControllerProvider.notifier)
          .joinRoomByCode(code);

      if (room == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bu kod ile eşleşen aktif bir oda bulunamadı.'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      if (mounted) {
        Navigator.pop(context);
        context.push('/whiteboard/${room.id}', extra: {'roomName': room.name});
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
                Icon(Icons.login_rounded, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Text(
                  'Odaya Katıl',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Size iletilen davet kodunu girerek ortak çalışma tuvaline dahil olun.',
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.black54,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: _codeController,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Oda Kodu',
                hintText: 'Örn: BC-DEMO veya BC-8392',
                prefixIcon: Icon(Icons.tag_rounded),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Lütfen oda kodunu girin.';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _isLoading ? null : _handleJoin,
              child: _isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.black,
                      ),
                    )
                  : const Text('Odaya Gir'),
            ),
          ],
        ),
      ),
    );
  }
}
