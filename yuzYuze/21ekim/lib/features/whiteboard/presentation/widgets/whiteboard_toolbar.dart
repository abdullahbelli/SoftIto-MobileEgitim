import 'dart:async';

import 'package:flutter/material.dart';

import '../controllers/whiteboard_controller.dart';
import 'shapes_menu.dart';

/// Whiteboard Araç Çubuğu (Responsive, Web/Masaüstü ve Mobil Uyumlu)
class WhiteboardToolbar extends StatefulWidget {
  final WhiteboardState state;
  final WhiteboardController controller;
  final VoidCallback onAddStickyNote;
  final VoidCallback onAddText;
  final VoidCallback onAddImage;

  const WhiteboardToolbar({
    super.key,
    required this.state,
    required this.controller,
    required this.onAddStickyNote,
    required this.onAddText,
    required this.onAddImage,
  });

  @override
  State<WhiteboardToolbar> createState() => _WhiteboardToolbarState();
}

class _WhiteboardToolbarState extends State<WhiteboardToolbar> {
  bool _isDimmed = false;
  Timer? _inactivityTimer;

  static const List<Color> quickColors = [
    Color(0xFF0F172A), // Koyu Lacivert / Siyah
    Color(0xFFF59E0B), // Amber / Sarı
    Color(0xFF3B82F6), // Mavi
    Color(0xFF10B981), // Yeşil
    Color(0xFFEF4444), // Kırmızı
    Color(0xFF8B5CF6), // Mor
  ];

  static const List<double> strokeWidths = [2.0, 4.0, 8.0];

  @override
  void initState() {
    super.initState();
    _resetInactivityTimer();
  }

  @override
  void didUpdateWidget(covariant WhiteboardToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _resetInactivityTimer();
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    super.dispose();
  }

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    if (_isDimmed) {
      setState(() => _isDimmed = false);
    }
    // Mobil ekranda 5 saniye hareketsizlik sonrası saydamlaşsın
    _inactivityTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => _isDimmed = true);
      }
    });
  }

  void _showShapesMenu(BuildContext context, Offset buttonPosition) {
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (overlay == null) return;

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (ctx) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => Navigator.pop(ctx),
            ),
          ),
          Positioned(
            left: buttonPosition.dx - 40,
            bottom: MediaQuery.of(context).size.height - buttonPosition.dy + 12,
            child: ShapesMenu(
              activeShapeType: widget.state.activeShapeType,
              onShapeSelected: (shapeId) {
                widget.controller.setActiveShapeType(shapeId);
                Navigator.pop(ctx);
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 768;

    return GestureDetector(
      onTap: _resetInactivityTimer,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: (isMobile && _isDimmed) ? 0.35 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: isDark
                  ? Colors.white10
                  : Colors.black.withValues(alpha: 0.08),
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Seçim Aracı
                _buildToolButton(
                  icon: Icons.near_me_rounded,
                  tooltip: 'Seç ve Taşı (V)',
                  isSelected: widget.state.activeTool == WhiteboardTool.select,
                  onPressed: () {
                    _resetInactivityTimer();
                    widget.controller.setActiveTool(WhiteboardTool.select);
                  },
                ),

                // 2. Pan / Kaydırma Aracı
                _buildToolButton(
                  icon: Icons.pan_tool_rounded,
                  tooltip: 'Tuvali Kaydır (H)',
                  isSelected: widget.state.activeTool == WhiteboardTool.pan,
                  onPressed: () {
                    _resetInactivityTimer();
                    widget.controller.setActiveTool(WhiteboardTool.pan);
                  },
                ),

                _buildDivider(isDark),

                // 3. Kalem
                _buildToolButton(
                  icon: Icons.edit_rounded,
                  tooltip: 'Çizim Kalemi (P)',
                  isSelected: widget.state.activeTool == WhiteboardTool.pen,
                  onPressed: () {
                    _resetInactivityTimer();
                    widget.controller.setActiveTool(WhiteboardTool.pen);
                  },
                ),

                // 4. Silgi
                _buildToolButton(
                  icon: Icons.auto_fix_high_rounded,
                  tooltip: 'Silgi (E)',
                  isSelected: widget.state.activeTool == WhiteboardTool.eraser,
                  onPressed: () {
                    _resetInactivityTimer();
                    widget.controller.setActiveTool(WhiteboardTool.eraser);
                  },
                ),

                // 5. Şekiller
                Builder(
                  builder: (btnContext) => _buildToolButton(
                    icon: _getShapeIcon(widget.state.activeShapeType),
                    tooltip: 'Şekiller (R)',
                    isSelected: widget.state.activeTool == WhiteboardTool.shape,
                    onPressed: () {
                      _resetInactivityTimer();
                      final renderBox =
                          btnContext.findRenderObject() as RenderBox?;
                      if (renderBox != null) {
                        final offset = renderBox.localToGlobal(Offset.zero);
                        _showShapesMenu(context, offset);
                      }
                    },
                  ),
                ),

                // 6. Metin
                _buildToolButton(
                  icon: Icons.title_rounded,
                  tooltip: 'Metin Ekle (T)',
                  isSelected: widget.state.activeTool == WhiteboardTool.text,
                  onPressed: () {
                    _resetInactivityTimer();
                    widget.onAddText();
                  },
                ),

                // 7. Post-it Not
                _buildToolButton(
                  icon: Icons.note_alt_rounded,
                  tooltip: 'Post-it Not Ekle (N)',
                  isSelected:
                      widget.state.activeTool == WhiteboardTool.stickyNote,
                  onPressed: () {
                    _resetInactivityTimer();
                    widget.onAddStickyNote();
                  },
                ),

                // 8. Resim Ekleme
                _buildToolButton(
                  icon: Icons.image_outlined,
                  tooltip: 'Görsel Ekle (I)',
                  isSelected: widget.state.activeTool == WhiteboardTool.image,
                  onPressed: () {
                    _resetInactivityTimer();
                    widget.onAddImage();
                  },
                ),

                _buildDivider(isDark),

                // Renk Seçiciler
                Row(
                  children: quickColors.map((color) {
                    final isSelected = widget.state.activeColor == color;
                    return InkWell(
                      onTap: () {
                        _resetInactivityTimer();
                        widget.controller.setActiveColor(color);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : (isDark ? Colors.white30 : Colors.black26),
                            width: isSelected ? 2.5 : 1,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                _buildDivider(isDark),

                // Çizgi Kalınlığı Seçiciler
                Row(
                  children: strokeWidths.map((w) {
                    final isSelected = widget.state.activeStrokeWidth == w;
                    return InkWell(
                      onTap: () {
                        _resetInactivityTimer();
                        widget.controller.setActiveStrokeWidth(w);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary.withValues(
                                  alpha: 0.15,
                                )
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Container(
                          width: 14,
                          height: w,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : (isDark ? Colors.white60 : Colors.black54),
                            borderRadius: BorderRadius.circular(w / 2),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                _buildDivider(isDark),

                // Geri Al / İleri Al
                IconButton(
                  icon: const Icon(Icons.undo_rounded, size: 20),
                  tooltip: 'Geri Al',
                  onPressed: widget.state.canUndo
                      ? () {
                          _resetInactivityTimer();
                          widget.controller.undo();
                        }
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.redo_rounded, size: 20),
                  tooltip: 'İleri Al',
                  onPressed: widget.state.canRedo
                      ? () {
                          _resetInactivityTimer();
                          widget.controller.redo();
                        }
                      : null,
                ),

                _buildDivider(isDark),

                // Yakınlaştırma Yüzdesi ve Butonları
                IconButton(
                  icon: const Icon(Icons.remove_rounded, size: 18),
                  tooltip: 'Uzaklaştır',
                  onPressed: () {
                    _resetInactivityTimer();
                    widget.controller.zoomOut();
                  },
                ),
                InkWell(
                  onTap: () {
                    _resetInactivityTimer();
                    widget.controller.resetCamera();
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    child: Text(
                      '${(widget.state.scale * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_rounded, size: 18),
                  tooltip: 'Yakınlaştır',
                  onPressed: () {
                    _resetInactivityTimer();
                    widget.controller.zoomIn();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String tooltip,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: isSelected ? theme.colorScheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: 20,
          color: isSelected
              ? Colors.black
              : (isDark ? Colors.white70 : Colors.black87),
        ),
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      height: 24,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      color: isDark ? Colors.white12 : Colors.black12,
    );
  }

  IconData _getShapeIcon(String type) {
    switch (type) {
      case 'rectangle':
        return Icons.crop_square_rounded;
      case 'ellipse':
        return Icons.circle_outlined;
      case 'line':
        return Icons.horizontal_rule_rounded;
      case 'arrow':
        return Icons.arrow_right_alt_rounded;
      default:
        return Icons.crop_square_rounded;
    }
  }
}
