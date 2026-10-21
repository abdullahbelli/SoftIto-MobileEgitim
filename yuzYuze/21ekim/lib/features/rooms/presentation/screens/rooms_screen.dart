import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../app/theme/theme_provider.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/rooms_controller.dart';
import '../widgets/create_room_sheet.dart';
import '../widgets/join_room_sheet.dart';
import '../widgets/room_card.dart';

/// Çalışmalar ve Odalar Ekranı (Rooms)
class RoomsScreen extends ConsumerStatefulWidget {
  const RoomsScreen({super.key});

  @override
  ConsumerState<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends ConsumerState<RoomsScreen> {
  String _searchQuery = '';

  void _openCreateRoom() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const CreateRoomSheet(),
    );
  }

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

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tema Vurgu Rengini Değiştir'),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: AppTheme.accentColorOptions.map((color) {
            final isSelected = ref.watch(accentColorProvider) == color;
            return InkWell(
              onTap: () {
                ref.read(accentColorProvider.notifier).setAccentColor(color);
                Navigator.pop(ctx);
              },
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final userAsync = ref.watch(authControllerProvider);
    final roomsAsync = ref.watch(roomsControllerProvider);
    final currentUser = userAsync.value;

    return Scaffold(
      appBar: AppBar(
        title: const AppLogo(size: 32),
        actions: [
          // Vurgu Rengi Seçici
          IconButton(
            icon: Icon(
              Icons.palette_outlined,
              color: theme.colorScheme.primary,
            ),
            tooltip: 'Vurgu Rengini Seç',
            onPressed: _showColorPicker,
          ),

          // Açık / Koyu Tema Geçişi
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
            tooltip: isDark ? 'Aydınlık Tema' : 'Karanlık Tema',
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
          ),

          // Kullanıcı Profili & Çıkış
          PopupMenuButton<String>(
            tooltip: 'Profil Seçenekleri',
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
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
              const PopupMenuDivider(),
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
        child: RefreshIndicator(
          onRefresh: () =>
              ref.read(roomsControllerProvider.notifier).loadRooms(),
          child: CustomScrollView(
            slivers: [
              // Üst Karşılama ve Hızlı Butonlar
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

                          // Butonlar (Büyük ekranda yan yana)
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

                      // Arama Alanı
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

              // Odalar Grid / Liste
              roomsAsync.when(
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
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
                data: (rooms) {
                  final filtered = rooms.where((r) {
                    if (_searchQuery.isEmpty) return true;
                    return r.name.toLowerCase().contains(_searchQuery) ||
                        r.joinCode.toLowerCase().contains(_searchQuery);
                  }).toList();

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

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    sliver: SliverLayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = 1;
                        if (constraints.crossAxisExtent > 900) {
                          crossAxisCount = 3;
                        } else if (constraints.crossAxisExtent > 600) {
                          crossAxisCount = 2;
                        }

                        return SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                mainAxisExtent: 165,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final room = filtered[index];
                            return RoomCard(
                              room: room,
                              isOwner: true,
                              onEnter: () {
                                context.push(
                                  '/whiteboard/${room.id}',
                                  extra: {'roomName': room.name},
                                );
                              },
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
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      ),
    );
  }
}
