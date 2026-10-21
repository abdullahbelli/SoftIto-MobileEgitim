import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/download_helper.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../rooms/presentation/controllers/rooms_controller.dart';
import '../../../rooms/presentation/widgets/share_room_dialog.dart';
import '../../domain/canvas_theme.dart';
import '../../domain/participant.dart';
import '../controllers/whiteboard_controller.dart';
import '../widgets/canvas_background_painter.dart';
import '../widgets/canvas_painter.dart';
import '../widgets/object_action_overlay.dart';
import '../widgets/text_edit_dialog.dart';
import '../widgets/whiteboard_toolbar.dart';

/// Sonsuz Tuval (Whiteboard) Ekranı
class WhiteboardScreen extends ConsumerStatefulWidget {
  final String roomId;
  final String roomName;

  const WhiteboardScreen({
    super.key,
    required this.roomId,
    this.roomName = 'Ortak Çalışma Odası',
  });

  @override
  ConsumerState<WhiteboardScreen> createState() => _WhiteboardScreenState();
}

class _WhiteboardScreenState extends ConsumerState<WhiteboardScreen> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  bool _hasShownJoinNotification = false;

  @override
  void initState() {
    super.initState();
    _triggerDemoJoinNotification();
  }

  void _triggerDemoJoinNotification() {
    // Katılımcı giriş snackbar simülasyonu
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && !_hasShownJoinNotification) {
        _hasShownJoinNotification = true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF06B6D4), // Selin'in rengi
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Selin Yılmaz giriş yaptı'),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  Future<void> _exportPng(WhiteboardController controller) async {
    try {
      final boundary =
          _repaintBoundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final bytes = byteData.buffer.asUint8List();
      final filename =
          'boardconnect_${widget.roomId}_${DateTime.now().millisecondsSinceEpoch}.png';

      DownloadHelper.downloadBytes(bytes, filename, 'image/png');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PNG görseli başarıyla indirildi!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PNG dışa aktarılırken hata: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _exportSvg(WhiteboardController controller) {
    try {
      final svgString = controller.exportSvg();
      final filename =
          'boardconnect_${widget.roomId}_${DateTime.now().millisecondsSinceEpoch}.svg';

      DownloadHelper.downloadText(svgString, filename, 'image/svg+xml');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SVG vektör dosyası başarıyla indirildi!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('SVG dışa aktarılırken hata: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _confirmClearCanvas(WhiteboardController controller) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.cleaning_services_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Tuvali Temizle'),
          ],
        ),
        content: const Text(
          'Bu odadaki tüm çizim ve nesneleri silmek istediğinize emin misiniz?',
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
              controller.clearCanvas();
            },
            child: const Text('Evet, Temizle'),
          ),
        ],
      ),
    );
  }

  void _openStickyNoteDialog(
    BuildContext context,
    WhiteboardController controller,
  ) {
    final screenSize = MediaQuery.of(context).size;
    final centerWorld = controller.screenToWorld(
      Offset(screenSize.width / 2, screenSize.height / 2),
    );

    showDialog(
      context: context,
      builder: (ctx) => TextEditDialog(
        title: 'Yeni Post-it Not Ekle',
        showColorPicker: true,
        onSave: (text) {
          if (text.isNotEmpty) {
            controller.addStickyNote(
              centerWorld,
              text,
              const Color(0xFFFEF08A),
            );
          }
        },
      ),
    );
  }

  void _openTextDialog(BuildContext context, WhiteboardController controller) {
    final screenSize = MediaQuery.of(context).size;
    final centerWorld = controller.screenToWorld(
      Offset(screenSize.width / 2, screenSize.height / 2),
    );

    showDialog(
      context: context,
      builder: (ctx) => TextEditDialog(
        title: 'Tuvale Metin Ekle',
        onSave: (text) {
          if (text.isNotEmpty) {
            controller.addText(centerWorld, text);
          }
        },
      ),
    );
  }

  void _openImageDialog(BuildContext context, WhiteboardController controller) {
    final screenSize = MediaQuery.of(context).size;
    final centerWorld = controller.screenToWorld(
      Offset(screenSize.width / 2, screenSize.height / 2),
    );

    final textController = TextEditingController(text: 'Proje Mimari Şeması');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Görsel Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tuvale yerleştirilecek görsel için bir etiket belirleyin:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                labelText: 'Görsel Başlığı / Etiketi',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              controller.addImage(centerWorld, textController.text.trim());
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = ref.watch(whiteboardControllerProvider(widget.roomId));
    final controller = ref.read(
      whiteboardControllerProvider(widget.roomId).notifier,
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Odalar Listesine Dön',
          onPressed: () => context.go('/rooms'),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            const AppLogo(size: 28, compact: true),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 220),
              child: Text(
                widget.roomName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          // Katılımcı Avatarları ve "+N" rozeti
          _buildParticipantsArea(context, state.participants),
          const SizedBox(width: 8),

          // Davet Butonu
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(80, 36),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              side: BorderSide(
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
              ),
            ),
            icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
            label: const Text('Davet', style: TextStyle(fontSize: 12)),
            onPressed: () async {
              final room = await ref
                  .read(roomsRepositoryProvider)
                  .getRoomById(widget.roomId);
              if (room != null && context.mounted) {
                showDialog(
                  context: context,
                  builder: (ctx) => ShareRoomDialog(room: room),
                );
              }
            },
          ),
          const SizedBox(width: 8),

          // Tuval Arka Plan Deseni Menüsü
          PopupMenuButton<CanvasBackgroundPattern>(
            tooltip: 'Tuval Arka Planı',
            icon: Icon(state.pattern.icon, size: 20),
            itemBuilder: (ctx) => CanvasBackgroundPattern.values.map((p) {
              final isSelected = state.pattern == p;
              return PopupMenuItem(
                value: p,
                child: Row(
                  children: [
                    Icon(
                      p.icon,
                      size: 18,
                      color: isSelected ? theme.colorScheme.primary : null,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      p.label,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected ? theme.colorScheme.primary : null,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onSelected: (p) => controller.setPattern(p),
          ),

          // Dışa Aktarma (PNG / SVG) Menüsü
          PopupMenuButton<String>(
            tooltip: 'Dışa Aktar ve İndir',
            icon: const Icon(Icons.download_rounded, size: 20),
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'png',
                child: Row(
                  children: [
                    Icon(Icons.image_outlined, size: 18),
                    SizedBox(width: 10),
                    Text('PNG Olarak İndir'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'svg',
                child: Row(
                  children: [
                    Icon(Icons.code_rounded, size: 18),
                    SizedBox(width: 10),
                    Text('SVG Vektör İndir'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_sweep_rounded,
                      size: 18,
                      color: Colors.redAccent,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Tuvali Temizle',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ],
                ),
              ),
            ],
            onSelected: (val) {
              if (val == 'png') {
                _exportPng(controller);
              } else if (val == 'svg') {
                _exportSvg(controller);
              } else if (val == 'clear') {
                _confirmClearCanvas(controller);
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // 1. Arka Plan Çizicisi (Grid, Kareli, Çizgili, Kâğıt)
          Positioned.fill(
            child: CustomPaint(
              painter: CanvasBackgroundPainter(
                pattern: state.pattern,
                pan: state.pan,
                scale: state.scale,
                isDark: isDark,
              ),
            ),
          ),

          // 2. Etkileşimli Sonsuz Çizim Tuvali
          Positioned.fill(
            child: Listener(
              onPointerSignal: (pointerSignal) {
                // Fare tekerleğiyle yakınlaştırma / uzaklaştırma (Zoom)
                if (pointerSignal is PointerScrollEvent) {
                  final zoomFactor = pointerSignal.scrollDelta.dy > 0
                      ? 0.9
                      : 1.1;
                  controller.updateZoom(
                    state.scale * zoomFactor,
                    pointerSignal.position,
                  );
                }
              },
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onScaleStart: (details) {
                  if (details.pointerCount > 1 ||
                      state.activeTool == WhiteboardTool.pan) {
                    // İki parmakla veya Pan aracıyla gezinme
                    return;
                  }
                  controller.onPointerDown(details.localFocalPoint);
                },
                onScaleUpdate: (details) {
                  if (details.pointerCount > 1) {
                    // İki parmakla yakınlaştırma
                    controller.updateZoom(
                      state.scale * details.scale,
                      details.localFocalPoint,
                    );
                    controller.updatePan(details.focalPointDelta);
                    return;
                  }

                  if (state.activeTool == WhiteboardTool.pan) {
                    controller.updatePan(details.focalPointDelta);
                  } else {
                    controller.onPointerMove(
                      details.localFocalPoint,
                      screenDelta: details.focalPointDelta,
                    );
                  }
                },
                onScaleEnd: (details) {
                  controller.onPointerUp();
                },
                child: RepaintBoundary(
                  key: _repaintBoundaryKey,
                  child: CustomPaint(
                    painter: CanvasPainter(
                      objects: state.objects,
                      currentDrawing: state.currentDrawing,
                      selectedObjectId: state.selectedObjectId,
                      pan: state.pan,
                      scale: state.scale,
                      participants: state.participants,
                      isDark: isDark,
                    ),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
          ),

          // 3. Seçili Nesne Aksiyon Kutusu (Raptiye, Sil, Düzenle)
          ObjectActionOverlay(state: state, controller: controller),

          // 4. Whiteboard Araç Çubuğu (Toolbar)
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: Center(
              child: WhiteboardToolbar(
                state: state,
                controller: controller,
                onAddStickyNote: () =>
                    _openStickyNoteDialog(context, controller),
                onAddText: () => _openTextDialog(context, controller),
                onAddImage: () => _openImageDialog(context, controller),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsArea(
    BuildContext context,
    List<WhiteboardParticipant> participants,
  ) {
    if (participants.isEmpty) return const SizedBox.shrink();

    const maxVisible = 3;
    final visibleList = participants.take(maxVisible).toList();
    final remaining = participants.length - maxVisible;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(visibleList.length, (index) {
            final p = visibleList[index];
            return Container(
              margin: const EdgeInsets.only(right: 4),
              child: CircleAvatar(
                radius: 14,
                backgroundColor: p.color,
                child: Text(
                  p.name.isNotEmpty ? p.name[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          }),
        ),
        if (remaining > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '+$remaining',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }
}
