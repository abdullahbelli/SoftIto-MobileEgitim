import 'package:flutter/material.dart'; // Flutter Material tasarım kütüphanesini içe aktarır.
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod durum yönetimi ConsumerStatefulWidget desteğini sağlar.
import 'package:go_router/go_router.dart'; // Sayfa yönlendirme (context.go, context.push) kütüphanesini içe aktarır.

import '../../../../app/theme/app_theme.dart'; // Tema renk paletini içe aktarır.
import '../../../../app/theme/theme_provider.dart'; // Tema modu ve renk sağlayıcılarını içe aktarır.
import '../../../../core/widgets/app_logo.dart'; // BoardConnect logo bileşenini içe aktarır.
import '../../../auth/presentation/controllers/auth_controller.dart'; // Kullanıcı oturum durumunu yöneten controller.
import '../controllers/rooms_controller.dart'; // Odalar durum denetleyicisi.
import '../widgets/create_room_sheet.dart'; // Oda oluşturma modal panel widget'ı.
import '../widgets/join_room_sheet.dart'; // Odaya katılma modal panel widget'ı.
import '../widgets/room_card.dart'; // Her bir odayı listeleyen kart widget'ı.

/// Çalışmalar ve Odalar Ekranı (RoomsScreen)
/// Kullanıcının tüm çalışma odalarını listelediği, arama yaptığı, yeni oda açtığı ve tuvale geçtiği ana merkezdir.
class RoomsScreen extends ConsumerStatefulWidget {
  const RoomsScreen({super.key});

  @override // Widget durum nesnesini üretir.
  ConsumerState<RoomsScreen> createState() => _RoomsScreenState();
}

/// Odalar ekranının durum yönetimi sınıfı
class _RoomsScreenState extends ConsumerState<RoomsScreen> {
  String _searchQuery = ''; // Arama çubuğuna yazılan filtreleme metni.

  /// Yeni oda oluşturma alt sayfasını (Bottom Sheet) açan fonksiyon.
  void _openCreateRoom() {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Klavyeyle birlikte tam yükseklik kontrolü sağlar.
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const CreateRoomSheet(),
    );
  }

  /// Odaya katılma alt sayfasını açan fonksiyon.
  void _openJoinRoom() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const JoinRoomSheet(),
    );
  }

  /// Kullanıcının uygulamanın sarı/turuncu/mavi vb. vurgu rengini seçebileceği renk paleti diyaloğunu açar.
  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tema Vurgu Rengini Değiştir'),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          // AppTheme içindeki tüm hazır renk alternatiflerini yuvarlak butonlar olarak haritalar.
          children: AppTheme.accentColorOptions.map((color) {
            // Seçili olan rengin aktifliğini denetler.
            final isSelected = ref.watch(accentColorProvider) == color;
            return InkWell(
              onTap: () {
                // Seçilen yeni rengi Riverpod StateNotifier üzerinden kaydeder.
                ref.read(accentColorProvider.notifier).setAccentColor(color);
                Navigator.pop(ctx); // Renk seçilince diyaloğu kapatır.
              },
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  // Seçili renge beyaz çerçeve ve parıltı gölgesi ekler.
                  border: isSelected
                      ? Border.all(color: Colors.white, width: 3)
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.6),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                // Seçili olana onay (check) ikonu koyar.
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.black, size: 24)
                    : null,
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  @override // Arayüzü inşa eden metot.
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Tema bilgilerini alır.
    final isDark = theme.brightness == Brightness.dark; // Koyu mod kontrolü.
    // Riverpod ile oturum açmış kullanıcı ve odalar listesini reaktif olarak izler.
    final userAsync = ref.watch(authControllerProvider);
    final roomsAsync = ref.watch(roomsControllerProvider);
    final currentUser = userAsync.value; // Aktif kullanıcı modeli.

    return Scaffold(
      appBar: AppBar(
        title: const AppLogo(size: 32), // Logo başlığı.
        actions: [
          // Tema Vurgu Rengi Seçici Butonu
          IconButton(
            icon: Icon(
              Icons.palette_outlined,
              color: theme.colorScheme.primary,
            ),
            tooltip: 'Vurgu Rengini Seç',
            onPressed: _showColorPicker,
          ),

          // Açık / Koyu Tema Değiştirme Butonu (Güneş/Ay ikonu)
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
            tooltip: isDark ? 'Aydınlık Tema' : 'Karanlık Tema',
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
          ),

          // Kullanıcı Profil Menüsü & Çıkış Yap Açılır Menüsü (PopupMenuButton)
          PopupMenuButton<String>(
            tooltip: 'Profil Seçenekleri',
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
              // Kullanıcı adının ilk harfini profil resmi yerine gösterir.
              child: Text(
                currentUser?.username.isNotEmpty == true
                    ? currentUser!.username[0].toUpperCase()
                    : 'U',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            itemBuilder: (ctx) => [
              // Kullanıcı adı ve e-posta bilgi satırı
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentUser?.displayName ?? 'Kullanıcı',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      currentUser?.email ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(), // Menü ayırıcı çizgisi.
              // Çıkış Yap butonu
              PopupMenuItem(
                value: 'logout',
                child: const Row(
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      size: 18,
                      color: Colors.redAccent,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Çıkış Yap',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ],
                ),
              ),
            ],
            onSelected: (val) async {
              if (val == 'logout') {
                // Oturumu kapatır ve giriş ekranına yönlendirir.
                await ref.read(authControllerProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/login');
                }
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        // Aşağı kaydırarak yenileme (pull-to-refresh) mekanizması.
        child: RefreshIndicator(
          onRefresh: () =>
              ref.read(roomsControllerProvider.notifier).loadRooms(),
          // Gelişmiş kaydırma ve sliver düzeni için CustomScrollView kullanılır.
          child: CustomScrollView(
            slivers: [
              // Üst Karşılama Başlığı, Aksiyon Butonları ve Arama Çubuğu
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Çalışmalarınız ve Odalar',
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Ortak beyaz tahtalarınıza katılın veya yeni bir oda açarak ekibinizi davet edin.',
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white60
                                        : Colors.black54,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Odaya Katıl ve Yeni Oda Oluştur butonları
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              OutlinedButton.icon(
                                onPressed: _openJoinRoom,
                                icon: const Icon(Icons.meeting_room_outlined),
                                label: const Text('Odaya Katıl'),
                              ),
                              ElevatedButton.icon(
                                onPressed: _openCreateRoom,
                                icon: const Icon(Icons.add_rounded),
                                label: const Text('Yeni Oda Oluştur'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Oda Arama Metin Alanı
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Oda adı veya kodu ile ara...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF1E293B)
                              : Colors.white,
                        ),
                        // Kullanıcı arama kutusuna yazdıkça listeyi anında filtreler.
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val.trim().toLowerCase();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Odalar Listesi / Izgara (Grid) Durum Yönetimi (AsyncValue.when)
              roomsAsync.when(
                // Yüklenme durumu: Ortalanmış dairesel ilerleme çubuğu.
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                // Hata durumu: Hata mesajı ve Yeniden Dene butonu.
                error: (e, _) => SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(height: 12),
                        Text('Odalar yüklenirken hata oluştu: $e'),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => ref
                              .read(roomsControllerProvider.notifier)
                              .loadRooms(),
                          child: const Text('Yeniden Dene'),
                        ),
                      ],
                    ),
                  ),
                ),
                // Veri başarıyla geldiğinde çalışan bölüm:
                data: (rooms) {
                  // Arama terimine göre odayı filtreler (oda adı veya katılım koduna göre).
                  final filtered = rooms.where((r) {
                    if (_searchQuery.isEmpty) return true;
                    return r.name.toLowerCase().contains(_searchQuery) ||
                        r.joinCode.toLowerCase().contains(_searchQuery);
                  }).toList();

                  // Filtreleme sonucu hiçbir oda yoksa boş durum ekranı (Empty state) gösterir.
                  if (filtered.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.folder_open_rounded,
                              size: 64,
                              color: Colors.grey.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Henüz kayıtlı bir oda bulunmuyor.',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Yeni bir oda oluşturarak başlayabilirsiniz.',
                              style: TextStyle(
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: _openCreateRoom,
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('İlk Odanızı Oluşturun'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Responsive (Duyarlı) Izgara Düzeni: Ekran genişliğine göre sütun sayısını ayarlar.
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    sliver: SliverLayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = 1; // Mobilde 1 sütun.
                        if (constraints.crossAxisExtent > 900) {
                          crossAxisCount = 3; // Geniş masaüstü ekranda 3 sütun.
                        } else if (constraints.crossAxisExtent > 600) {
                          crossAxisCount = 2; // Tablet ve orta ekranda 2 sütun.
                        }

                        // SliverGrid ile odaları ızgara şeklinde çizer.
                        return SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                mainAxisExtent: 165, // Kart sabit yüksekliği.
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final room = filtered[index];
                            return RoomCard(
                              room: room,
                              isOwner: true,
                              // Odaya girildiğinde beyaz tahta ekranına yönlendirir.
                              onEnter: () {
                                context.push(
                                  '/whiteboard/${room.id}',
                                  extra: {'roomName': room.name},
                                );
                              },
                              // Oda silindiğinde depodan siler ve SnackBar bildirimi gösterir.
                              onDelete: () async {
                                await ref
                                    .read(roomsControllerProvider.notifier)
                                    .deleteRoom(room.id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '"${room.name}" odası silindi.',
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                            );
                          }, childCount: filtered.length),
                        );
                      },
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 40),
              ), // Sayfa altı boşluğu.
            ],
          ),
        ),
      ),
    );
  }
}
