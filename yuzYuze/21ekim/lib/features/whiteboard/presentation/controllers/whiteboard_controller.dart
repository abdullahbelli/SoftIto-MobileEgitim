// ignore_for_file: prefer_initializing_formals

import 'package:flutter/material.dart'; // Flutter Material arayüz ve grafik sınıflarını (Color, Offset, Rect) içe aktarır.
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod durum yönetimi StateNotifier yapısını içe aktarır.
import 'package:uuid/uuid.dart'; // Yeni çizim nesnelerine benzersiz kimlikler üretmek için içe aktarır.

import 'package:boardconnect/app/theme/theme_provider.dart'; // SharedPreferences sağlayıcısını içe aktarır.
import 'package:boardconnect/core/config/app_constants.dart'; // Min/max zoom sınırlarını içe aktarır.
import 'package:boardconnect/features/auth/presentation/controllers/auth_controller.dart'; // Oturum açmış aktif kullanıcıyı almak için içe aktarır.

import '../../data/local_whiteboard_repository.dart'; // Yerel tuval veri deposunu içe aktarır.
import '../../domain/board_object.dart'; // Tuval nesnesi temel ve alt sınıflarını içe aktarır.
import '../../domain/canvas_theme.dart'; // Tuval ızgara deseni enum türünü içe aktarır.
import '../../domain/participant.dart'; // Katılımcı veri modelini içe aktarır.
import '../../domain/whiteboard_repository.dart'; // Tuval veri deposu sözleşmesini içe aktarır.

/// Beyaz Tahta Aktif Araçları (WhiteboardTool)
/// Kullanıcının araç çubuğundan seçebileceği tüm çizim ve etkileşim modları.
enum WhiteboardTool {
  select, // Nesneleri seçme, taşıma ve boyutlandırma modu (V kısayolu).
  pen, // Serbest çizim kalemi modu (P kısayolu).
  eraser, // Dokunulan nesneleri silme modu (E kısayolu).
  shape, // Dikdörtgen, elips, çizgi ve ok çizme modu (R kısayolu).
  text, // Serbest metin ekleme modu (T kısayolu).
  stickyNote, // Renkli yapışkan not (post-it) ekleme modu (N kısayolu).
  image, // Tuvale görsel yükleme modu (I kısayolu).
  pan, // Çizim yapmadan tüm tuvali kaydırma modu (H kısayolu).
}

/// Beyaz Tahta Durum Modeli (WhiteboardState)
/// Tuvalin tüm anlık verilerini (nesneler, kamera konumu, yakınlaştırma, aktif araç vb.) tutan değişmez durum sınıfıdır.
class WhiteboardState {
  final String roomId; // Tahtanın ait olduğu odanın kimlik numarası.
  final bool
  isLoading; // Nesnelerin yerel depodan okunma sürecini belirten bayrak.
  final List<BoardObject> objects; // Tuvaldeki tüm nesnelerin listesi.
  final Offset pan; // Kameranın dünya koordinatlarındaki kayma (ofset) miktarı.
  final double scale; // Kameranın mevcut yakınlaştırma (zoom) ölçeği.
  final WhiteboardTool activeTool; // O an seçili olan çizim/etkileşim aracı.
  final String activeShapeType; // Şekil aracı aktifken çizilecek şeklin türü ('rectangle', 'ellipse', 'line', 'arrow').
  final Color activeColor; // Çizimlerde ve şekillerde kullanılan birincil renk.
  final double activeStrokeWidth; // Çizgi kalınlığı (piksel).
  final CanvasBackgroundPattern
  pattern; // Zemin ızgara deseni (düz, kareli, çizgili, noktalı).
  final String?
  selectedObjectId; // Kullanıcının o an seçtiği nesnenin kimliği (yoksa null).
  final BoardObject? currentDrawing; // Kullanıcı parmağını basılı tutarken anlık çizilen geçici nesne.
  final List<WhiteboardParticipant>
  participants; // Odadaki diğer canlı katılımcıların listesi.
  final bool canUndo; // Geri alınabilecek işlem var mı?
  final bool canRedo; // İleri alınabilecek işlem var mı?

  // Değişmez kurucu metot.
  const WhiteboardState({
    required this.roomId,
    this.isLoading = true,
    this.objects = const [],
    this.pan = Offset.zero,
    this.scale = 1.0,
    this.activeTool = WhiteboardTool.select,
    this.activeShapeType = 'rectangle',
    this.activeColor = const Color(0xFF0F172A),
    this.activeStrokeWidth = 3.0,
    this.pattern = CanvasBackgroundPattern.grid,
    this.selectedObjectId,
    this.currentDrawing,
    this.participants = const [],
    this.canUndo = false,
    this.canRedo = false,
  });

  /// O an seçili olan nesnenin kendisini döndüren kolaylık 'getter' fonksiyonu.
  BoardObject? get selectedObject {
    if (selectedObjectId == null) return null;
    try {
      return objects.firstWhere((o) => o.id == selectedObjectId);
    } catch (_) {
      return null;
    }
  }

  /// Mevcut durumun belirli alanlarını güncelleyerek yeni bir WhiteboardState nesnesi kopyalayan fonksiyon.
  WhiteboardState copyWith({
    String? roomId,
    bool? isLoading,
    List<BoardObject>? objects,
    Offset? pan,
    double? scale,
    WhiteboardTool? activeTool,
    String? activeShapeType,
    Color? activeColor,
    double? activeStrokeWidth,
    CanvasBackgroundPattern? pattern,
    String? selectedObjectId,
    bool clearSelectedObjectId = false, // Seçimi sıfırlamak için özel bayrak.
    BoardObject? currentDrawing,
    bool clearCurrentDrawing =
        false, // Aktif çizimi temizlemek için özel bayrak.
    List<WhiteboardParticipant>? participants,
    bool? canUndo,
    bool? canRedo,
  }) {
    return WhiteboardState(
      roomId: roomId ?? this.roomId,
      isLoading: isLoading ?? this.isLoading,
      objects: objects ?? this.objects,
      pan: pan ?? this.pan,
      scale: scale ?? this.scale,
      activeTool: activeTool ?? this.activeTool,
      activeShapeType: activeShapeType ?? this.activeShapeType,
      activeColor: activeColor ?? this.activeColor,
      activeStrokeWidth: activeStrokeWidth ?? this.activeStrokeWidth,
      pattern: pattern ?? this.pattern,
      selectedObjectId: clearSelectedObjectId
          ? null
          : (selectedObjectId ?? this.selectedObjectId),
      currentDrawing: clearCurrentDrawing
          ? null
          : (currentDrawing ?? this.currentDrawing),
      participants: participants ?? this.participants,
      canUndo: canUndo ?? this.canUndo,
      canRedo: canRedo ?? this.canRedo,
    );
  }
}

/// Repository Provider: Yerel tuval nesnesi deposunu Riverpod ağacına sunar.
final whiteboardRepositoryProvider = Provider<WhiteboardRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalWhiteboardRepository(prefs);
});

/// Whiteboard Notifier / Controller
/// Tuval üzerindeki tüm çizim, sürükleme, kamera hareketi, geri/ileri alma (Undo/Redo)
/// ve dışa aktarma (SVG/PNG) iş mantığını yöneten merkezi sınıftır.
class WhiteboardController extends StateNotifier<WhiteboardState> {
  final WhiteboardRepository _repository; // Veri saklama deposu.
  final String _currentUserId; // Odayı kullanan kullanıcının kimliği.
  final String _currentUserName; // Odayı kullanan kullanıcının adı.
  final _uuid = const Uuid(); // Benzersiz ID üreteci.

  // Geri alma yığını: Geçmiş nesne listesi durumlarını saklar (Undo Stack).
  final List<List<BoardObject>> _undoStack = [];
  // İleri alma yığını: Geri alınmış durumları saklar (Redo Stack).
  final List<List<BoardObject>> _redoStack = [];

  // Çizim ve sürükleme esnasında kullanılan geçici dünya koordinatları.
  Offset? _dragStartWorld; // Sürüklemenin başladığı dünya koordinatı.
  Offset? _lastDragWorld; // Son fare hareketinin dünya koordinatı.
  bool _isMovingObject =
      false; // Seçili nesnenin taşınmakta olup olmadığını belirten bayrak.

  WhiteboardController({
    required WhiteboardRepository repository,
    required String roomId,
    required String currentUserId,
    required String currentUserName,
  }) : _repository = repository,
       _currentUserId = currentUserId,
       _currentUserName = currentUserName,
       super(WhiteboardState(roomId: roomId)) {
    loadObjects(); // Nesneleri depodan yükler.
    _initSimulatedParticipants(); // Ortak çalışma hissi vermek için simüle edilmiş katılımcıları başlatır.
  }

  // Ortak çalışma odasına örnek canlı katılımcılar ve imleç konumları ekler.
  void _initSimulatedParticipants() {
    final demoParticipants = [
      const WhiteboardParticipant(
        id: 'user_selin',
        name: 'Selin Yılmaz',
        color: Color(0xFF06B6D4), // Camgöbeği
        worldPosition: Offset(-120, -50),
      ),
      const WhiteboardParticipant(
        id: 'user_mert',
        name: 'Mert Kaya',
        color: Color(0xFFF97316), // Turuncu
        worldPosition: Offset(180, -20),
      ),
      const WhiteboardParticipant(
        id: 'user_zeynep',
        name: 'Zeynep Ak',
        color: Color(0xFFA855F7), // Mor
        worldPosition: Offset(40, 120),
      ),
    ];
    state = state.copyWith(participants: demoParticipants);
  }

  /// Odaya ait kayıtlı nesneleri yerel depodan asenkron olarak yükler.
  Future<void> loadObjects() async {
    state = state.copyWith(isLoading: true);
    final objects = await _repository.getObjects(state.roomId);
    state = state.copyWith(isLoading: false, objects: objects);
  }

  /// Bir değişiklik yapılmadan hemen önce mevcut durumu geri alma (Undo) yığınına kaydeder.
  void _pushUndo() {
    _undoStack.add(
      List.from(state.objects),
    ); // Mevcut listenin sığ kopyasını ekler.
    if (_undoStack.length > 30) {
      _undoStack.removeAt(
        0,
      ); // Bellek taşmasını önlemek için en fazla 30 adım saklar.
    }
    _redoStack
        .clear(); // Yeni bir işlem yapıldığında ileri alma yığını sıfırlanır.
    state = state.copyWith(canUndo: true, canRedo: false);
  }

  /// Son yapılan işlemi geri alan fonksiyon (Undo)
  void undo() {
    if (_undoStack.isEmpty) return; // Geri alınacak işlem yoksa çık.
    _redoStack.add(
      List.from(state.objects),
    ); // Mevcut durumu ileri alma yığınına atar.
    final prev = _undoStack.removeLast(); // Son geçmiş durumu çeker.
    state = state.copyWith(
      objects: prev,
      canUndo: _undoStack.isNotEmpty,
      canRedo: true,
      clearSelectedObjectId: true,
    );
    _repository.saveObjects(state.roomId, prev); // Geri alınan durumu kaydeder.
  }

  /// Geri alınmış işlemi tekrar ileri alan fonksiyon (Redo)
  void redo() {
    if (_redoStack.isEmpty) return;
    _undoStack.add(List.from(state.objects));
    final next = _redoStack.removeLast();
    state = state.copyWith(
      objects: next,
      canUndo: true,
      canRedo: _redoStack.isNotEmpty,
      clearSelectedObjectId: true,
    );
    _repository.saveObjects(state.roomId, next);
  }

  // Koordinat Dönüşümleri (Matematik Motoru):
  /// Ekrandaki piksel koordinatını (farenin/parmağın dokunduğu yer) tuvalin dünya koordinatına dönüştürür.
  Offset screenToWorld(Offset screenPoint) {
    return (screenPoint - state.pan) / state.scale;
  }

  /// Tuval dünya koordinatını cihaz ekranındaki piksel konumuna dönüştürür.
  Offset worldToScreen(Offset worldPoint) {
    return worldPoint * state.scale + state.pan;
  }

  // Kamera Pan & Zoom Metotları:
  /// Tuvali parmak veya el aracıyla delta kadar serbestçe kaydırır.
  void updatePan(Offset delta) {
    state = state.copyWith(pan: state.pan + delta);
  }

  /// İki parmakla kıstırma (pinch-to-zoom) veya fare tekerleğiyle odak noktasına göre yakınlaştırma yapar.
  /// Odak noktası (focalPoint) sabit kalarak yakınlaştırma yapılır (kullanıcı deneyimi standardı).
  void updateZoom(double newScale, Offset focalPoint) {
    final clamped = newScale.clamp(
      AppConstants.minZoom,
      AppConstants.maxZoom,
    ); // Zoom sınırlarına hapseder.
    final worldFocal =
        (focalPoint - state.pan) /
        state.scale; // Odak noktasının dünya koordinatını bulur.
    final newPan =
        focalPoint - worldFocal * clamped; // Yeni pan miktarını hesaplar.
    state = state.copyWith(scale: clamped, pan: newPan);
  }

  /// Yakınlaştırma oranını %25 artırır.
  void zoomIn() {
    final target = (state.scale * 1.25).clamp(
      AppConstants.minZoom,
      AppConstants.maxZoom,
    );
    state = state.copyWith(scale: target);
  }

  /// Yakınlaştırma oranını %25 azaltır.
  void zoomOut() {
    final target = (state.scale / 1.25).clamp(
      AppConstants.minZoom,
      AppConstants.maxZoom,
    );
    state = state.copyWith(scale: target);
  }

  /// Kamerayı başlangıç noktasına (pan: (0,0) ve scale: 1.0) sıfırlar.
  void resetCamera() {
    state = state.copyWith(pan: Offset.zero, scale: 1.0);
  }

  // Araç ve Tema Ayarları:
  /// Aktif aracı değiştirir (seçim harici bir araca geçilirse seçili nesneyi bırakır).
  void setActiveTool(WhiteboardTool tool) {
    state = state.copyWith(
      activeTool: tool,
      clearSelectedObjectId: tool != WhiteboardTool.select,
    );
  }

  /// Çizilecek aktif şekil tipini ('rectangle', 'ellipse', 'line', 'arrow') ayarlar.
  void setActiveShapeType(String shapeType) {
    state = state.copyWith(
      activeTool: WhiteboardTool.shape,
      activeShapeType: shapeType,
    );
  }

  /// Çizim rengini değiştirir.
  void setActiveColor(Color color) {
    state = state.copyWith(activeColor: color);
  }

  /// Çizgi kalınlığını günceller.
  void setActiveStrokeWidth(double width) {
    state = state.copyWith(activeStrokeWidth: width);
  }

  /// Tuval arka plan ızgara desenini ayarlar.
  void setPattern(CanvasBackgroundPattern pattern) {
    state = state.copyWith(pattern: pattern);
  }

  // Pointer / Dokunma ve Çizim Olayları:
  /// Kullanıcı ekrana dokunduğunda veya fareye tıkladığında (onPointerDown) çalışan metot.
  void onPointerDown(Offset screenPoint) {
    final worldPoint = screenToWorld(
      screenPoint,
    ); // Ekran noktasını dünya koordinatına çevirir.
    _dragStartWorld = worldPoint; // Başlangıç noktasını kaydeder.
    _lastDragWorld = worldPoint;

    switch (state.activeTool) {
      case WhiteboardTool.select:
        // En üstte (önde) çizilmiş nesneden başlayarak dokunulan nesneyi arar.
        BoardObject? hitObject;
        for (final obj in state.objects.reversed) {
          if (obj.containsPoint(worldPoint)) {
            hitObject = obj;
            break;
          }
        }

        if (hitObject != null) {
          state = state.copyWith(
            selectedObjectId: hitObject.id,
          ); // Nesneyi seçili yapar.
          _isMovingObject = !hitObject
              .isPinned; // Nesne kilitli değilse taşınabilir işaretler.
        } else {
          state = state.copyWith(
            clearSelectedObjectId: true,
          ); // Boşluğa tıklandıysa seçimi kaldırır.
          _isMovingObject = false;
        }
        break;

      case WhiteboardTool.pen:
        // Kalem ile ilk noktayı içeren yeni bir serbest çizim nesnesi başlatır.
        final stroke = StrokeObject(
          id: 'stroke_${_uuid.v4().substring(0, 8)}',
          createdBy: _currentUserId,
          createdAt: DateTime.now(),
          points: [worldPoint],
          color: state.activeColor,
          strokeWidth: state.activeStrokeWidth,
        );
        state = state.copyWith(currentDrawing: stroke);
        break;

      case WhiteboardTool.eraser:
        // Dokunulan yerdeki nesneyi anında siler.
        _eraseAt(worldPoint);
        break;

      case WhiteboardTool.shape:
        // Yeni bir geometrik şekil çizimini başlatır (başlangıç ve bitiş noktası aynıdır).
        final shape = ShapeObject(
          id: 'shape_${_uuid.v4().substring(0, 8)}',
          type: state.activeShapeType,
          createdBy: _currentUserId,
          createdAt: DateTime.now(),
          bounds: Rect.fromPoints(worldPoint, worldPoint),
          strokeColor: state.activeColor,
          strokeWidth: state.activeStrokeWidth,
        );
        state = state.copyWith(currentDrawing: shape);
        break;

      case WhiteboardTool.pan:
      case WhiteboardTool.text:
      case WhiteboardTool.stickyNote:
      case WhiteboardTool.image:
        break;
    }
  }

  /// Kullanıcı parmağını/faresini hareket ettirdiğinde (onPointerMove) çalışan metot.
  void onPointerMove(Offset screenPoint, {Offset? screenDelta}) {
    final worldPoint = screenToWorld(screenPoint); // Güncel dünya konumu.

    switch (state.activeTool) {
      case WhiteboardTool.select:
        // Seçili nesne taşınıyorsa yeni koordinatına öteler.
        if (_isMovingObject &&
            state.selectedObjectId != null &&
            _lastDragWorld != null) {
          final delta = worldPoint - _lastDragWorld!;
          final updatedObjects = state.objects.map((obj) {
            if (obj.id == state.selectedObjectId && !obj.isPinned) {
              return obj.movedBy(delta);
            }
            return obj;
          }).toList();
          state = state.copyWith(objects: updatedObjects);
        }
        break;

      case WhiteboardTool.pen:
        // Kalem çizimine yeni noktayı ekler ve geçici çizimi günceller.
        if (state.currentDrawing is StrokeObject) {
          final current = state.currentDrawing as StrokeObject;
          final newPoints = List<Offset>.from(current.points)..add(worldPoint);
          final updated = StrokeObject(
            id: current.id,
            createdBy: current.createdBy,
            createdAt: current.createdAt,
            points: newPoints,
            color: current.color,
            strokeWidth: current.strokeWidth,
          );
          state = state.copyWith(currentDrawing: updated);
        }
        break;

      case WhiteboardTool.eraser:
        _eraseAt(
          worldPoint,
        ); // Silgiyi sürüklerken temas edilen nesneleri siler.
        break;

      case WhiteboardTool.shape:
        // Şeklin sınır dikdörtgenini başlangıç noktasından güncel noktaya kadar genişletir.
        if (state.currentDrawing is ShapeObject && _dragStartWorld != null) {
          final current = state.currentDrawing as ShapeObject;
          final updatedBounds = Rect.fromPoints(_dragStartWorld!, worldPoint);
          final updated = ShapeObject(
            id: current.id,
            type: current.type,
            createdBy: current.createdBy,
            createdAt: current.createdAt,
            bounds: updatedBounds,
            strokeColor: current.strokeColor,
            strokeWidth: current.strokeWidth,
            isFilled: current.isFilled,
            fillColor: current.fillColor,
          );
          state = state.copyWith(currentDrawing: updated);
        }
        break;

      case WhiteboardTool.pan:
        if (screenDelta != null) {
          updatePan(screenDelta); // Tuvali sürükleme yönünde kaydırır.
        }
        break;

      case WhiteboardTool.text:
      case WhiteboardTool.stickyNote:
      case WhiteboardTool.image:
        break;
    }

    _lastDragWorld = worldPoint; // Son konumu günceller.
  }

  /// Kullanıcı parmağını ekrandan kaldırdığında (onPointerUp) çalışan metot.
  void onPointerUp() {
    // Çizilmekte olan bir nesne varsa kalıcı listeye aktarır ve hafızaya kaydeder.
    if (state.currentDrawing != null) {
      _pushUndo(); // Geri alma yığınına ekler.
      final updated = List<BoardObject>.from(state.objects)
        ..add(state.currentDrawing!);
      state = state.copyWith(objects: updated, clearCurrentDrawing: true);
      _repository.saveObjects(state.roomId, updated); // Diske kalıcı kaydeder.
    } else if (_isMovingObject) {
      // Nesne taşıma bittiyse son pozisyonu kaydeder.
      _pushUndo();
      _repository.saveObjects(state.roomId, state.objects);
    }

    // Geçici değişkenleri sıfırlar.
    _isMovingObject = false;
    _dragStartWorld = null;
    _lastDragWorld = null;
  }

  // Belirtilen koordinattaki nesneleri silen yardımcı metot.
  void _eraseAt(Offset worldPoint) {
    final toRemove = <BoardObject>[];
    for (final obj in state.objects) {
      if (obj.containsPoint(worldPoint, hitSlop: 12.0)) {
        toRemove.add(
          obj,
        ); // 12 piksel toleransla isabet edenleri listeye ekler.
      }
    }

    if (toRemove.isNotEmpty) {
      _pushUndo(); // Silmeden önce durumu yedekler.
      final updated = state.objects
          .where((o) => !toRemove.contains(o))
          .toList();
      state = state.copyWith(
        objects: updated,
        clearSelectedObjectId: toRemove.any(
          (o) => o.id == state.selectedObjectId,
        ),
      );
      _repository.saveObjects(
        state.roomId,
        updated,
      ); // Güncel listeyi kaydeder.
    }
  }

  // Nesne Aksiyonları (Sabitleme & Silme & Metin Güncelleme):
  /// Seçili nesneyi siler.
  void deleteSelectedObject() {
    if (state.selectedObjectId == null) return;
    _pushUndo();
    final updated = state.objects
        .where((o) => o.id != state.selectedObjectId)
        .toList();
    state = state.copyWith(objects: updated, clearSelectedObjectId: true);
    _repository.saveObjects(state.roomId, updated);
  }

  /// Seçili nesnenin raptiye (sabitleme) durumunu açar veya kapatır.
  void togglePinSelectedObject() {
    if (state.selectedObjectId == null) return;
    _pushUndo();
    final updated = state.objects.map((o) {
      if (o.id == state.selectedObjectId) {
        return o.withPinned(!o.isPinned);
      }
      return o;
    }).toList();
    state = state.copyWith(objects: updated);
    _repository.saveObjects(state.roomId, updated);
  }

  /// Post-it veya Metin nesnesinin metin içeriğini günceller.
  void updateObjectText(String objectId, String newText) {
    _pushUndo();
    final updated = state.objects.map((o) {
      if (o.id == objectId) {
        if (o is StickyNoteObject) {
          return o.copyWithText(newText);
        } else if (o is TextObject) {
          return o.copyWithText(newText);
        }
      }
      return o;
    }).toList();
    state = state.copyWith(objects: updated);
    _repository.saveObjects(state.roomId, updated);
  }

  /// Tuvale yeni bir Post-it notu ekler.
  void addStickyNote(Offset worldPos, String text, Color color) {
    _pushUndo();
    final note = StickyNoteObject(
      id: 'sticky_${_uuid.v4().substring(0, 8)}',
      createdBy: _currentUserId,
      createdAt: DateTime.now(),
      bounds: Rect.fromLTWH(worldPos.dx, worldPos.dy, 180, 160),
      text: text,
      noteColor: color,
      authorName: _currentUserName,
    );
    final updated = List<BoardObject>.from(state.objects)..add(note);
    state = state.copyWith(
      objects: updated,
      selectedObjectId: note.id,
      activeTool: WhiteboardTool.select,
    );
    _repository.saveObjects(state.roomId, updated);
  }

  /// Tuvale yeni bağımsız metin ekler.
  void addText(Offset worldPos, String text) {
    _pushUndo();
    final textObj = TextObject(
      id: 'text_${_uuid.v4().substring(0, 8)}',
      createdBy: _currentUserId,
      createdAt: DateTime.now(),
      position: worldPos,
      text: text,
      fontSize: 20,
      color: state.activeColor,
      width: 220,
      height: 70,
    );
    final updated = List<BoardObject>.from(state.objects)..add(textObj);
    state = state.copyWith(
      objects: updated,
      selectedObjectId: textObj.id,
      activeTool: WhiteboardTool.select,
    );
    _repository.saveObjects(state.roomId, updated);
  }

  /// Tuvale görsel yer tutucu kutusu ekler.
  void addImage(Offset worldPos, String label) {
    _pushUndo();
    final img = ImageObject(
      id: 'img_${_uuid.v4().substring(0, 8)}',
      createdBy: _currentUserId,
      createdAt: DateTime.now(),
      bounds: Rect.fromLTWH(worldPos.dx, worldPos.dy, 220, 160),
      imageUrl:
          'https://images.unsplash.com/photo-1542744094-3a31f272c490?w=400',
      label: label,
    );
    final updated = List<BoardObject>.from(state.objects)..add(img);
    state = state.copyWith(
      objects: updated,
      selectedObjectId: img.id,
      activeTool: WhiteboardTool.select,
    );
    _repository.saveObjects(state.roomId, updated);
  }

  /// Tuvaldeki tüm nesneleri temizler/sıfırlar.
  void clearCanvas() {
    _pushUndo();
    state = state.copyWith(
      objects: [],
      clearSelectedObjectId: true,
      clearCurrentDrawing: true,
    );
    _repository.clearObjects(state.roomId);
  }

  // SVG Serileştirici (Dışa Aktarma):
  /// Tuvaldeki tüm nesneleri vektörel W3C SVG XML metnine dönüştüren dışa aktarma fonksiyonu.
  String exportSvg() {
    if (state.objects.isEmpty) {
      return '<svg xmlns="http://www.w3.org/2000/svg" width="800" height="600" viewBox="0 0 800 600"></svg>';
    }

    // 1. Adım: Tüm nesnelerin kapladığı ortak sınır kutusunu (Bounding Box) hesaplar.
    Rect totalBounds = state.objects.first.getBounds();
    for (final obj in state.objects) {
      totalBounds = totalBounds.expandToInclude(obj.getBounds());
    }
    totalBounds = totalBounds.inflate(
      40,
    ); // Çevreye 40 piksel estetik boşluk payı ekler.

    final minX = totalBounds.left;
    final minY = totalBounds.top;
    final width = totalBounds.width;
    final height = totalBounds.height;

    // 2. Adım: SVG metnini StringBuffer ile birleştirir.
    final buffer = StringBuffer();
    buffer.writeln(
      '<svg xmlns="http://www.w3.org/2000/svg" '
      'width="${width.toInt()}" height="${height.toInt()}" '
      'viewBox="$minX $minY $width $height">',
    );
    buffer.writeln('  <!-- BoardConnect Whiteboard Export -->');
    buffer.writeln('  <defs>');
    // Ok uçları için tekrar kullanılabilir marker tanımlar.
    buffer.writeln(
      '    <marker id="arrowhead" markerWidth="10" markerHeight="7" '
      'refX="9" refY="3.5" orient="auto">'
      '<polygon points="0 0, 10 3.5, 0 7" fill="#F59E0B" />'
      '</marker>',
    );
    buffer.writeln('  </defs>');

    // 3. Adım: Her bir nesneyi kendi SVG XML etiketine dönüştürür.
    for (final obj in state.objects) {
      if (obj is StrokeObject) {
        if (obj.points.length > 1) {
          final colorHex = _colorToHex(obj.color);
          buffer.write('  <path d="M ${obj.points[0].dx} ${obj.points[0].dy} ');
          for (int i = 1; i < obj.points.length; i++) {
            buffer.write('L ${obj.points[i].dx} ${obj.points[i].dy} ');
          }
          buffer.writeln(
            '" fill="none" stroke="$colorHex" '
            'stroke-width="${obj.strokeWidth}" stroke-linecap="round" stroke-linejoin="round" />',
          );
        }
      } else if (obj is ShapeObject) {
        final strokeHex = _colorToHex(obj.strokeColor);
        final fillHex = obj.isFilled && obj.fillColor != null
            ? _colorToHex(obj.fillColor!)
            : 'none';

        switch (obj.type) {
          case 'rectangle':
            buffer.writeln(
              '  <rect x="${obj.bounds.left}" y="${obj.bounds.top}" '
              'width="${obj.bounds.width}" height="${obj.bounds.height}" '
              'rx="8" ry="8" fill="$fillHex" stroke="$strokeHex" stroke-width="${obj.strokeWidth}" />',
            );
            break;
          case 'ellipse':
            final cx = obj.bounds.center.dx;
            final cy = obj.bounds.center.dy;
            final rx = obj.bounds.width / 2;
            final ry = obj.bounds.height / 2;
            buffer.writeln(
              '  <ellipse cx="$cx" cy="$cy" rx="$rx" ry="$ry" '
              'fill="$fillHex" stroke="$strokeHex" stroke-width="${obj.strokeWidth}" />',
            );
            break;
          case 'line':
            buffer.writeln(
              '  <line x1="${obj.bounds.left}" y1="${obj.bounds.top}" '
              'x2="${obj.bounds.right}" y2="${obj.bounds.bottom}" '
              'stroke="$strokeHex" stroke-width="${obj.strokeWidth}" stroke-linecap="round" />',
            );
            break;
          case 'arrow':
            buffer.writeln(
              '  <line x1="${obj.bounds.left}" y1="${obj.bounds.top}" '
              'x2="${obj.bounds.right}" y2="${obj.bounds.bottom}" '
              'stroke="$strokeHex" stroke-width="${obj.strokeWidth}" '
              'stroke-linecap="round" marker-end="url(#arrowhead)" />',
            );
            break;
        }
      } else if (obj is StickyNoteObject) {
        final fillHex = _colorToHex(obj.noteColor);
        buffer.writeln(
          '  <g transform="translate(${obj.bounds.left}, ${obj.bounds.top})">',
        );
        buffer.writeln(
          '    <rect width="${obj.bounds.width}" height="${obj.bounds.height}" '
          'rx="6" ry="6" fill="$fillHex" stroke="#CBD5E1" stroke-width="1" />',
        );
        buffer.writeln(
          '    <text x="12" y="32" font-family="sans-serif" font-size="14" fill="#0F172A">'
          '${_escapeXml(obj.text)}</text>',
        );
        buffer.writeln('  </g>');
      } else if (obj is TextObject) {
        final colorHex = _colorToHex(obj.color);
        buffer.writeln(
          '  <text x="${obj.position.dx}" y="${obj.position.dy + obj.fontSize}" '
          'font-family="sans-serif" font-size="${obj.fontSize}" fill="$colorHex">'
          '${_escapeXml(obj.text)}</text>',
        );
      }
    }

    buffer.writeln('</svg>');
    return buffer.toString();
  }

  // Flutter Color nesnesini 6 haneli '#RRGGBB' hex formatına çeviren yardımcı metot.
  String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  // XML içinde bozulmaya yol açabilecek karakterleri (&, <, >, ", ') kaçış dizilerine dönüştüren metot.
  String _escapeXml(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }
}

/// Aile bazlı Whiteboard Provider (oda ID'sine göre her oda için bağımsız controller örneği üretir)
/// 'autoDispose' oda kapatıldığında belleği otomatik olarak serbest bırakır.
final whiteboardControllerProvider = StateNotifierProvider.autoDispose
    .family<WhiteboardController, WhiteboardState, String>((ref, roomId) {
      final repo = ref.watch(whiteboardRepositoryProvider);
      final user = ref.watch(authControllerProvider).value;
      return WhiteboardController(
        repository: repo,
        roomId: roomId,
        currentUserId: user?.id ?? 'guest_user',
        currentUserName: user?.displayName ?? 'Kullanıcı',
      );
    });
