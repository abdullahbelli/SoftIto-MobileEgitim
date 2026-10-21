import 'package:flutter/material.dart'; // Flutter Material tasarım bileşenlerini içe aktarır.
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod durum yönetimi ConsumerStatefulWidget desteğini sağlar.
import 'package:go_router/go_router.dart'; // Sayfa yönlendirme (context.push) kütüphanesini içe aktarır.

import '../../../auth/presentation/controllers/auth_controller.dart'; // Giriş yapmış kullanıcıyı okumak için içe aktarır.
import '../controllers/rooms_controller.dart'; // Oda oluşturma fonksiyonunu çağırmak için içe aktarır.

/// Oda Oluşturma Alt Sayfası (Bottom Sheet)
/// Kullanıcının alt açılır panelden (Modal Bottom Sheet) hızlıca yeni bir oda adı ve katılımcı limiti belirlemesini sağlar.
class CreateRoomSheet extends ConsumerStatefulWidget {
  const CreateRoomSheet({super.key});

  @override // Widget durum yönetim nesnesini üretir.
  ConsumerState<CreateRoomSheet> createState() => _CreateRoomSheetState();
}

/// Oda oluşturma alt sayfasının durum yönetimi sınıfı
class _CreateRoomSheetState extends ConsumerState<CreateRoomSheet> {
  final _formKey = GlobalKey<FormState>(); // Form geçerlilik denetleyicisi.
  final _nameController =
      TextEditingController(); // Oda adı metin kutusu denetleyicisi.
  int _maxParticipants =
      10; // Varsayılan maksimum katılımcı sayısı (başlangıç: 10).
  bool _isLoading = false; // İşlem sürerken çark gösteren yükleme bayrağı.

  @override // Panel kapatıldığında metin denetleyicisini hafızadan temizler (dispose).
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Odayı Oluştur butonuna tıklandığında çalışan fonksiyon
  Future<void> _handleCreate() async {
    // Oda adı boş girilmişse işlemi durdurur.
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true); // Yüklenme modunu açar.
    // O an oturum açmış kullanıcının ID ve isim bilgilerini alır.
    final user = ref.read(authControllerProvider).value;
    final ownerId = user?.id ?? 'guest_user';
    final ownerName = user?.displayName ?? 'Kullanıcı';

    try {
      // RoomsController üzerinden yeni oda oluşturur.
      final newRoom = await ref
          .read(roomsControllerProvider.notifier)
          .createRoom(
            name: _nameController.text.trim(),
            maxParticipants: _maxParticipants,
            ownerId: ownerId,
            ownerName: ownerName,
          );

      if (mounted) {
        Navigator.pop(
          context,
        ); // Önce alttan açılan bottom sheet panelini kapatır.
        // Ardından kullanıcıyı yeni oluşturulan odanın beyaz tahtasına yönlendirir.
        context.push(
          '/whiteboard/${newRoom.id}',
          extra: {'roomName': newRoom.name},
        );
      }
    } catch (e) {
      if (mounted) {
        // Hata durumunda SnackBar ile bildirim gösterir.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false); // Yükleme modunu kapatır.
      }
    }
  }

  @override // Alt panel arayüzünü inşa eder.
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Tema bilgilerini alır.
    final isDark = theme.brightness == Brightness.dark; // Koyu mod kontrolü.

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        // Klavye açıldığında formun klavye arkasında kalmaması için alt boşluğa klavye yüksekliğini ekler.
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey, // Doğrulama için form anahtarını bağlar.
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // Sadece içeriği kadar dikey yer kaplar.
          crossAxisAlignment: CrossAxisAlignment
              .stretch, // Elemanları tam yatay genişliğe yayar.
          children: [
            // Bottom sheet sürükleme tutamacı (modern arayüz göstergesi)
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

            // Başlık satırı ve simgesi
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
            // Alt açıklama
            Text(
              'Odanız için bir başlık belirleyin ve katılımcı sınırını ayarlayın.',
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.black54,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),

            // Oda Adı Metin Giriş Alanı
            TextFormField(
              controller: _nameController,
              autofocus: true, // Panel açıldığında otomatik olarak odaklanır ve klavyeyi açar.
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

            // Kişi Sayısı Seçim Başlığı ve Rozeti
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
            // Katılımcı sayısını ayarlayan kaydırıcı (Slider)
            Slider(
              value: _maxParticipants.toDouble(),
              min: 2, // En az 2 kişi
              max: 30, // En fazla 30 kişi
              divisions: 28, // 2'den 30'a 1'er adımlarla geçiş
              activeColor: theme.colorScheme.primary,
              onChanged: (val) {
                setState(() {
                  _maxParticipants = val.round(); // Değeri tam sayıya yuvarlar ve durumu günceller.
                });
              },
            ),
            const SizedBox(height: 20),

            // Odayı Oluştur Butonu
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
