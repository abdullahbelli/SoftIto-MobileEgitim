import 'package:flutter/material.dart'; // Flutter Material Design arayüz kütüphanesini içe aktarır.
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod durum yönetimi ConsumerStatefulWidget desteğini içe aktarır.
import 'package:go_router/go_router.dart'; // Sayfa yönlendirme (context.go, context.pop) kütüphanesini içe aktarır.

import '../../../../core/widgets/app_logo.dart'; // Uygulama logosu widget'ını içe aktarır.
import '../../../rooms/presentation/controllers/rooms_controller.dart'; // Oda kontrol ve veri erişim sağlayıcılarını içe aktarır.
import '../controllers/auth_controller.dart'; // Kimlik doğrulama denetleyicisini içe aktarır.

/// Misafir Giriş Ekranı
/// Kullanıcıların kayıt olmadan sadece bir takma isim ve oda kodu girerek doğrudan tuvale katılmasını sağlar.
class GuestLoginScreen extends ConsumerStatefulWidget {
  const GuestLoginScreen({super.key});

  @override // Ekranın durum (state) nesnesini oluşturur.
  ConsumerState<GuestLoginScreen> createState() => _GuestLoginScreenState();
}

/// Misafir giriş ekranı durum yönetimi sınıfı
class _GuestLoginScreenState extends ConsumerState<GuestLoginScreen> {
  // Form alanlarının (TextFormField) doğrulanmasını (validation) kontrol eden global anahtar.
  final _formKey = GlobalKey<FormState>();
  // Misafirin rumuzunu tutan metin denetleyicisi (varsayılan test kolaylığı için 'Misafir Kullanıcı' atanmıştır).
  final _nameController = TextEditingController(text: 'Misafir Kullanıcı');
  // Girilen oda kodunu tutan metin denetleyicisi (varsayılan demo için 'BC-DEMO').
  final _roomCodeController = TextEditingController(text: 'BC-DEMO');
  bool _isLoading = false; // Giriş işlemi sürerken çark gösteren bayrak.

  @override // Ekrandan çıkıldığında bellek temizliği yapar.
  void dispose() {
    _nameController.dispose(); // İsim denetleyicisini serbest bırakır.
    _roomCodeController.dispose(); // Oda kodu denetleyicisini serbest bırakır.
    super.dispose();
  }

  /// Odaya misafir olarak giriş yapma butonu aksiyonu
  Future<void> _handleGuestEnter() async {
    // Formdaki tüm alanların doğrulama kurallarını (validator) çalıştırır; geçersizse işlemi durdurur.
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true); // Yüklenme durumunu başlatır.
    try {
      final name = _nameController.text.trim(); // İsmi alır.
      final code = _roomCodeController.text
          .trim()
          .toUpperCase(); // Oda kodunu büyük harfe çevirir.

      // Kimlik doğrulama controller'ı üzerinden misafir hesabı oluşturur.
      await ref
          .read(authControllerProvider.notifier)
          .guestLogin(name: name, roomCode: code);

      // Girilen koda ait bir oda var mı diye yerel depoda arar.
      final room = await ref.read(roomsRepositoryProvider).getRoomByCode(code);
      // Oda varsa onun id'sini, yoksa varsayılan demo oda id'sini hedefler.
      final targetRoomId = room != null ? room.id : 'room_demo_default';

      if (mounted) {
        // Doğrudan beyaz tahta ekranına yönlendirir ve oda adını ekstra parametre olarak aktarır.
        context.go(
          '/whiteboard/$targetRoomId',
          extra: {'roomName': room?.name ?? 'Ortak Demo Odası'},
        );
      }
    } catch (e) {
      if (mounted) {
        // Hata durumunda kırmızı uyarı bildirim çubuğu gösterir.
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
        setState(() => _isLoading = false); // Yükleme animasyonunu durdurur.
      }
    }
  }

  @override // Arayüzü inşa eder.
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Tema bilgilerini alır.
    final isDark = theme.brightness == Brightness.dark; // Koyu mod kontrolü.

    return Scaffold(
      // Sayfa üst çubuğu (AppBar)
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(), // Giriş ekranına geri döner.
        ),
        title: const AppLogo(size: 32),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 440,
              ), // Maksimum genişlik sınırı.
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
                    key: _formKey, // Form doğrulaması için anahtar bağlanır.
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Misafir grubu ikonu yuvarlak kutusu.
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

                        // Başlık
                        Text(
                          'Misafir Olarak Katıl',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        // Açıklama
                        Text(
                          'Hesap oluşturmadan doğrudan bir odaya katılabilir ve tüm çizim araçlarını kullanabilirsiniz.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),

                        // İsim Metin Giriş Alanı
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Görünecek İsminiz',
                            prefixIcon: Icon(Icons.badge_outlined),
                            hintText: 'Örn: Ahmet Yılmaz',
                          ),
                          // Boş bırakılmasını engelleyen doğrulayıcı fonksiyon.
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Lütfen bir isim girin.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Oda Kodu Giriş Alanı
                        TextFormField(
                          controller: _roomCodeController,
                          textCapitalization: TextCapitalization.characters, // Harfleri otomatik büyük harfe çevirir.
                          decoration: const InputDecoration(
                            labelText: 'Oda / Oturum Kodu',
                            prefixIcon: Icon(Icons.tag_rounded),
                            hintText: 'Örn: BC-DEMO',
                          ),
                          // Kodun boş girilmesini engelleyen doğrulayıcı.
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
                          onPressed: _isLoading ? null : _handleGuestEnter, // Tıklandığında misafir giriş fonksiyonunu çağırır.
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

                        // Giriş ekranına geri dönüş metin butonu.
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
