import 'package:flutter/material.dart'; // Flutter Material tasarım kütüphanesini içe aktarır.
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod durum yönetimi ConsumerStatefulWidget desteğini sağlar.
import 'package:go_router/go_router.dart'; // Sayfa yönlendirme (context.push) kütüphanesini içe aktarır.

import '../controllers/rooms_controller.dart'; // Oda kontrol sağlayıcısını içe aktarır.

/// Odaya Katılma Alt Sayfası (JoinRoomSheet)
/// Kullanıcının davet kodu (joinCode) girerek var olan bir çalışma odasına katılması için açılan alt paneldir.
class JoinRoomSheet extends ConsumerStatefulWidget {
  const JoinRoomSheet({super.key});

  @override // Widget durum yönetim nesnesini oluşturur.
  ConsumerState<JoinRoomSheet> createState() => _JoinRoomSheetState();
}

/// Odaya katılma alt sayfasının durum yönetimi sınıfı
class _JoinRoomSheetState extends ConsumerState<JoinRoomSheet> {
  final _formKey = GlobalKey<FormState>(); // Form geçerlilik denetleyicisi.
  final _codeController =
      TextEditingController(); // Oda kodu metin alanı denetleyicisi.
  bool _isLoading =
      false; // Arama ve odaya giriş sürerken butonları kilitleyen bayrak.

  @override // Panel kapatıldığında metin denetleyicisini hafızadan siler.
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  /// Odaya Gir butonuna tıklandığında çalışan katılma fonksiyonu
  Future<void> _handleJoin() async {
    // Kod alanının boş olup olmadığını denetler.
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true); // Yüklenme durumunu başlatır.
    final code = _codeController.text
        .trim()
        .toUpperCase(); // Kodu büyük harflere dönüştürür.

    try {
      // Girilen koda ait odayı controller üzerinden sorgular.
      final room = await ref
          .read(roomsControllerProvider.notifier)
          .joinRoomByCode(code);

      // Kod ile eşleşen bir oda bulunamadıysa kullanıcıyı uyarır.
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
        return; // İşlemi sonlandırır.
      }

      if (mounted) {
        Navigator.pop(context); // Önce alt paneli kapatır.
        // Kullanıcıyı bulunan odanın beyaz tahta sayfasına yönlendirir.
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
        setState(() => _isLoading = false); // Yükleme durumunu kapatır.
      }
    }
  }

  @override // Arayüzü inşa eder.
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Tema bilgilerini alır.
    final isDark = theme.brightness == Brightness.dark; // Koyu mod kontrolü.

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        // Açılan klavyenin arkasında kalmaması için alt boşluğa klavye yüksekliğini ekler.
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey, // Form doğrulama anahtarını bağlar.
        child: Column(
          mainAxisSize: MainAxisSize.min, // İçeriği kadar yer kaplar.
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Panel üstü sürükleme çubuğu
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

            // Başlık satırı
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
            // Açıklama
            Text(
              'Size iletilen davet kodunu girerek ortak çalışma tuvaline dahil olun.',
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.black54,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),

            // Oda Kodu Giriş Alanı
            TextFormField(
              controller: _codeController,
              autofocus: true, // Açılır açılmaz klavyeyi açar.
              textCapitalization: TextCapitalization
                  .characters, // Otomatik büyük harfe çevirir.
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

            // Odaya Gir Butonu
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
