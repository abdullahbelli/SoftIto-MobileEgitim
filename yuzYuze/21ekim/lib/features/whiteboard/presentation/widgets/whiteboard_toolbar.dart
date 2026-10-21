import 'dart:async'; // Zamanlayıcı (Timer) işlemleri için Dart asenkron kütüphanesini içe aktarır.

import 'package:flutter/material.dart'; // Flutter Material tasarım kütüphanesini içe aktarır.

import '../controllers/whiteboard_controller.dart'; // Tuval durumu, aracı ve kontrolörünü içe aktarır.
import 'shapes_menu.dart'; // Şekil seçim açılır menüsünü içe aktarır.

/// Whiteboard Araç Çubuğu (Responsive, Web/Masaüstü ve Mobil Uyumlu)
/// Kullanıcının çizim, silgi, şekil, metin, not ve görsel araçlarını seçtiği,
/// renk ve çizgi kalınlığını ayarladığı, geri/ileri aldığı ana yüzen araç çubuğudur.
class WhiteboardToolbar extends StatefulWidget {
  final WhiteboardState state; // Tuvalin anlık araç ve renk durumları.
  final WhiteboardController controller; // Araç seçimlerini yöneten kontrolör.
  final VoidCallback
  onAddStickyNote; // Post-it ekleme diyaloğunu açan geri çağırma fonksiyonu.
  final VoidCallback
  onAddText; // Metin ekleme diyaloğunu açan geri çağırma fonksiyonu.
  final VoidCallback
  onAddImage; // Görsel ekleme aksiyonunu tetikleyen fonksiyon.

  const WhiteboardToolbar({
    super.key,
    required this.state,
    required this.controller,
    required this.onAddStickyNote,
    required this.onAddText,
    required this.onAddImage,
  });

  @override // Widget durum yönetim nesnesini üretir.
  State<WhiteboardToolbar> createState() => _WhiteboardToolbarState();
}

/// Araç çubuğu durum yönetimi sınıfı
class _WhiteboardToolbarState extends State<WhiteboardToolbar> {
  bool _isDimmed = false; // Mobilde araç çubuğunun çizim alanını kapatmaması için soluklaşma (dim) bayrağı.
  Timer? _inactivityTimer; // Hareketsizlik durumunu takip eden zamanlayıcı.

  // Hızlı erişim renk paleti (Siyah, Sarı, Mavi, Yeşil, Kırmızı, Mor).
  static const List<Color> quickColors = [
    Color(0xFF0F172A), // Koyu Lacivert / Siyah
    Color(0xFFF59E0B), // Amber / Sarı
    Color(0xFF3B82F6), // Mavi
    Color(0xFF10B981), // Yeşil
    Color(0xFFEF4444), // Kırmızı
    Color(0xFF8B5CF6), // Mor
  ];

  // Çizgi kalınlığı seçenekleri (İnce: 2px, Orta: 4px, Kalın: 8px).
  static const List<double> strokeWidths = [2.0, 4.0, 8.0];

  @override // Başlatıcı metot.
  void initState() {
    super.initState();
    _resetInactivityTimer(); // Sayfa açılınca hareketsizlik sayacını başlatır.
  }

  @override // Üst widget güncellendiğinde tetiklenir (Lifecycle: didUpdateWidget).
  void didUpdateWidget(covariant WhiteboardToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _resetInactivityTimer(); // Herhangi bir durum güncellendiğinde sayacı sıfırlar.
  }

  @override // Bellek temizliği metodu.
  void dispose() {
    _inactivityTimer?.cancel(); // Zamanlayıcıyı durdurur.
    super.dispose();
  }

  // Kullanıcı etkileşimde bulunduğunda sayacı sıfırlayan ve barı tekrar netleştiren metot.
  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    if (_isDimmed) {
      setState(() => _isDimmed = false); // Barı tekrar tam görünür yapar.
    }
    // Mobil ekranda 5 saniye boyunca araç çubuğuna dokunulmazsa çizimi engellememek için saydamlaştırır (%35 opaklık).
    _inactivityTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => _isDimmed = true);
      }
    });
  }

  // Şekiller butonuna basıldığında butonun hemen üstünde mini bir açılır menü (ShapesMenu) gösterir.
  void _showShapesMenu(BuildContext context, Offset buttonPosition) {
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (overlay == null) return;

    showDialog(
      context: context,
      barrierColor: Colors.transparent, // Arka planı karartmaz.
      builder: (ctx) => Stack(
        children: [
          // Dışarıya tıklandığında menüyü kapatmak için tüm ekranı kaplayan şeffaf algılayıcı.
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => Navigator.pop(ctx),
            ),
          ),
          // Şekiller butonunun tam üzerine denk gelen konumda menüyü açar.
          Positioned(
            left: buttonPosition.dx - 40,
            bottom: MediaQuery.of(context).size.height - buttonPosition.dy + 12,
            child: ShapesMenu(
              activeShapeType: widget.state.activeShapeType,
              onShapeSelected: (shapeId) {
                widget.controller.setActiveShapeType(
                  shapeId,
                ); // Yeni şekil tipini seçer.
                Navigator.pop(ctx); // Menüyü kapatır.
              },
            ),
          ),
        ],
      ),
    );
  }

  @override // Araç çubuğu arayüzünü çizer.
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Temayı okur.
    final isDark = theme.brightness == Brightness.dark; // Koyu mod kontrolü.
    final isMobile =
        MediaQuery.of(context).size.width <
        768; // 768 pikselden dar ise mobil cihaz kabul edilir.

    return GestureDetector(
      onTap: _resetInactivityTimer, // Çubuğa dokunulduğunda sayacı sıfırlar.
      // Saydamlaşma geçişini pürüzsüz animasyonla yapmak için AnimatedOpacity kullanılır.
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: (isMobile && _isDimmed)
            ? 0.35
            : 1.0, // Mobilde hareketsizken %35 saydamlık.
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(
              20,
            ), // Yuvarlatılmış hap (pill) tasarımı.
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
          // Dar ekranlarda butonların yatayda kaydırılabilmesini sağlar.
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Seçim ve Taşıma Aracı (Select Tool)
                _buildToolButton(
                  icon: Icons.near_me_rounded,
                  tooltip: 'Seç ve Taşı (V)',
                  isSelected: widget.state.activeTool == WhiteboardTool.select,
                  onPressed: () {
                    _resetInactivityTimer();
                    widget.controller.setActiveTool(WhiteboardTool.select);
                  },
                ),

                // 2. Pan / Tuvali Serbest Kaydırma Aracı (Hand Tool)
                _buildToolButton(
                  icon: Icons.pan_tool_rounded,
                  tooltip: 'Tuvali Kaydır (H)',
                  isSelected: widget.state.activeTool == WhiteboardTool.pan,
                  onPressed: () {
                    _resetInactivityTimer();
                    widget.controller.setActiveTool(WhiteboardTool.pan);
                  },
                ),

                _buildDivider(isDark), // Dikey ayırıcı çizgi.
                // 3. Serbest Çizim Kalemi (Pen Tool)
                _buildToolButton(
                  icon: Icons.edit_rounded,
                  tooltip: 'Çizim Kalemi (P)',
                  isSelected: widget.state.activeTool == WhiteboardTool.pen,
                  onPressed: () {
                    _resetInactivityTimer();
                    widget.controller.setActiveTool(WhiteboardTool.pen);
                  },
                ),

                // 4. Silgi Aracı (Eraser Tool)
                _buildToolButton(
                  icon: Icons.auto_fix_high_rounded,
                  tooltip: 'Silgi (E)',
                  isSelected: widget.state.activeTool == WhiteboardTool.eraser,
                  onPressed: () {
                    _resetInactivityTimer();
                    widget.controller.setActiveTool(WhiteboardTool.eraser);
                  },
                ),

                // 5. Şekil Ekleme Aracı (Shapes Tool)
                Builder(
                  builder: (btnContext) => _buildToolButton(
                    icon: _getShapeIcon(widget.state.activeShapeType),
                    tooltip: 'Şekiller (R)',
                    isSelected: widget.state.activeTool == WhiteboardTool.shape,
                    onPressed: () {
                      _resetInactivityTimer();
                      // Butonun ekrandaki mutlak piksel konumunu hesaplar ve menüyü açar.
                      final renderBox =
                          btnContext.findRenderObject() as RenderBox?;
                      if (renderBox != null) {
                        final offset = renderBox.localToGlobal(Offset.zero);
                        _showShapesMenu(context, offset);
                      }
                    },
                  ),
                ),

                // 6. Bağımsız Metin Ekleme Aracı (Text Tool)
                _buildToolButton(
                  icon: Icons.title_rounded,
                  tooltip: 'Metin Ekle (T)',
                  isSelected: widget.state.activeTool == WhiteboardTool.text,
                  onPressed: () {
                    _resetInactivityTimer();
                    widget.onAddText(); // Metin ekleme diyaloğunu açar.
                  },
                ),

                // 7. Post-it Yapışkan Not Ekleme Aracı (Sticky Note Tool)
                _buildToolButton(
                  icon: Icons.note_alt_rounded,
                  tooltip: 'Post-it Not Ekle (N)',
                  isSelected:
                      widget.state.activeTool == WhiteboardTool.stickyNote,
                  onPressed: () {
                    _resetInactivityTimer();
                    widget.onAddStickyNote(); // Not ekleme diyaloğunu açar.
                  },
                ),

                // 8. Görsel Yükleme Aracı (Image Tool)
                _buildToolButton(
                  icon: Icons.image_outlined,
                  tooltip: 'Görsel Ekle (I)',
                  isSelected: widget.state.activeTool == WhiteboardTool.image,
                  onPressed: () {
                    _resetInactivityTimer();
                    widget.onAddImage(); // Görsel ekleme işlemini başlatır.
                  },
                ),

                _buildDivider(isDark), // Ayırıcı.
                // Hızlı Renk Paleti Daireleri
                Row(
                  children: quickColors.map((color) {
                    final isSelected = widget.state.activeColor == color;
                    return InkWell(
                      onTap: () {
                        _resetInactivityTimer();
                        widget.controller.setActiveColor(
                          color,
                        ); // Çizim rengini değiştirir.
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
                            width: isSelected
                                ? 2.5
                                : 1, // Seçili olana kalın çerçeve.
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                _buildDivider(isDark),

                // Çizgi Kalınlığı Seçiciler (2px, 4px, 8px)
                Row(
                  children: strokeWidths.map((w) {
                    final isSelected = widget.state.activeStrokeWidth == w;
                    return InkWell(
                      onTap: () {
                        _resetInactivityTimer();
                        widget.controller.setActiveStrokeWidth(
                          w,
                        ); // Çizgi kalınlığını günceller.
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
                          height: w, // Çizgi kalınlığı kadar yükseklik vererek önizleme sağlar.
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

                // Geri Al (Undo) Butonu
                IconButton(
                  icon: const Icon(Icons.undo_rounded, size: 20),
                  tooltip: 'Geri Al',
                  // Geri alınacak işlem yoksa (canUndo == false) buton kilitlenir (null).
                  onPressed: widget.state.canUndo
                      ? () {
                          _resetInactivityTimer();
                          widget.controller.undo();
                        }
                      : null,
                ),
                // İleri Al (Redo) Butonu
                IconButton(
                  icon: const Icon(Icons.redo_rounded, size: 20),
                  tooltip: 'İleri Al',
                  // İleri alınacak işlem yoksa buton kilitlenir.
                  onPressed: widget.state.canRedo
                      ? () {
                          _resetInactivityTimer();
                          widget.controller.redo();
                        }
                      : null,
                ),

                _buildDivider(isDark),

                // Uzaklaştır (Zoom Out) Butonu
                IconButton(
                  icon: const Icon(Icons.remove_rounded, size: 18),
                  tooltip: 'Uzaklaştır',
                  onPressed: () {
                    _resetInactivityTimer();
                    widget.controller.zoomOut();
                  },
                ),
                // Yakınlaştırma Yüzdesi Metni (Tıklanınca kamerayı %100'e ve merkeze sıfırlar)
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
                      '${(widget.state.scale * 100).toInt()}%', // Yakınlaştırma oranını yüzde olarak yazar.
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                // Yakınlaştır (Zoom In) Butonu
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

  // Ortak araç butonu inşa edici yardımcı metot.
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
        color: isSelected
            ? theme.colorScheme.primary
            : Colors.transparent, // Seçili butona sarı/vurgu zemin boyası.
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: 20,
          color: isSelected
              ? Colors
                    .black // Sarı buton üzerinde siyah kontrast ikon.
              : (isDark ? Colors.white70 : Colors.black87),
        ),
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
  }

  // Araç grupları arasına ince dikey ayırıcı çizgi koyan yardımcı metot.
  Widget _buildDivider(bool isDark) {
    return Container(
      height: 24,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      color: isDark ? Colors.white12 : Colors.black12,
    );
  }

  // Seçili olan şekil türüne göre uygun simgeyi döndüren yardımcı fonksiyon.
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
