import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_logo.dart';
import '../controllers/auth_controller.dart';
import '../../../rooms/presentation/controllers/rooms_controller.dart';

/// Misafir Giriş Ekranı
class GuestLoginScreen extends ConsumerStatefulWidget {
  const GuestLoginScreen({super.key});

  @override
  ConsumerState<GuestLoginScreen> createState() => _GuestLoginScreenState();
}

class _GuestLoginScreenState extends ConsumerState<GuestLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Misafir Kullanıcı');
  final _roomCodeController = TextEditingController(text: 'BC-DEMO');
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _roomCodeController.dispose();
    super.dispose();
  }

  Future<void> _handleGuestEnter() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final name = _nameController.text.trim();
      final code = _roomCodeController.text.trim().toUpperCase();

      await ref
          .read(authControllerProvider.notifier)
          .guestLogin(name: name, roomCode: code);

      // Odayı bul veya misafir için demo oda sağla
      final room = await ref.read(roomsRepositoryProvider).getRoomByCode(code);
      final targetRoomId = room != null ? room.id : 'room_demo_default';

      if (mounted) {
        context.go(
          '/whiteboard/$targetRoomId',
          extra: {'roomName': room?.name ?? 'Ortak Demo Odası'},
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
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

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const AppLogo(size: 32),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Card(
                elevation: isDark ? 2 : 0,
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.grey.withValues(alpha: 0.2),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 40,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.15,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.group_outlined,
                            size: 32,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 20),

                        Text(
                          'Misafir Olarak Katıl',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Hesap oluşturmadan doğrudan bir odaya katılabilir ve tüm çizim araçlarını kullanabilirsiniz.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),

                        // İsim Alanı
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Görünecek İsminiz',
                            prefixIcon: Icon(Icons.badge_outlined),
                            hintText: 'Örn: Ahmet Yılmaz',
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Lütfen bir isim girin.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Oda Kodu Alanı
                        TextFormField(
                          controller: _roomCodeController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: const InputDecoration(
                            labelText: 'Oda / Oturum Kodu',
                            prefixIcon: Icon(Icons.tag_rounded),
                            hintText: 'Örn: BC-DEMO',
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Lütfen oda kodunu girin.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Odaya Gir Butonu
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleGuestEnter,
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
                        const SizedBox(height: 16),

                        TextButton(
                          onPressed: () => context.pop(),
                          child: const Text('Giriş Ekranına Geri Dön'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
