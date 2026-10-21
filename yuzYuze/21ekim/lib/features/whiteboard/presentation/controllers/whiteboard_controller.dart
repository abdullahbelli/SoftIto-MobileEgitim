// ignore_for_file: prefer_initializing_formals

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:boardconnect/app/theme/theme_provider.dart';
import 'package:boardconnect/core/config/app_constants.dart';
import 'package:boardconnect/features/auth/presentation/controllers/auth_controller.dart';

import '../../data/local_whiteboard_repository.dart';
import '../../domain/board_object.dart';
import '../../domain/canvas_theme.dart';
import '../../domain/participant.dart';
import '../../domain/whiteboard_repository.dart';

/// Beyaz Tahta Aktif Araçları
enum WhiteboardTool {
  select, // Seçim ve taşıma
  pen, // Serbest çizim kalemi
  eraser, // Silgi
  shape, // Şekiller
  text, // Metin
  stickyNote, // Post-it not
  image, // Görsel
  pan, // Tuval kaydırma
}

/// Beyaz Tahta Durum Modeli
class WhiteboardState {
  final String roomId;
  final bool isLoading;
  final List<BoardObject> objects;
  final Offset pan;
  final double scale;
  final WhiteboardTool activeTool;
  final String activeShapeType; // 'rectangle', 'ellipse', 'line', 'arrow'
  final Color activeColor;
  final double activeStrokeWidth;
  final CanvasBackgroundPattern pattern;
  final String? selectedObjectId;
  final BoardObject? currentDrawing;
  final List<WhiteboardParticipant> participants;
  final bool canUndo;
  final bool canRedo;

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

  BoardObject? get selectedObject {
    if (selectedObjectId == null) return null;
    try {
      return objects.firstWhere((o) => o.id == selectedObjectId);
    } catch (_) {
      return null;
    }
  }

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
    bool clearSelectedObjectId = false,
    BoardObject? currentDrawing,
    bool clearCurrentDrawing = false,
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

/// Repository Provider
final whiteboardRepositoryProvider = Provider<WhiteboardRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalWhiteboardRepository(prefs);
});

/// Whiteboard Notifier / Controller
class WhiteboardController extends StateNotifier<WhiteboardState> {
  final WhiteboardRepository _repository;
  final String _currentUserId;
  final String _currentUserName;
  final _uuid = const Uuid();

  final List<List<BoardObject>> _undoStack = [];
  final List<List<BoardObject>> _redoStack = [];

  // Çizim ve etkileşim geçici durumları
  Offset? _dragStartWorld;
  Offset? _lastDragWorld;
  bool _isMovingObject = false;

  WhiteboardController({
    required WhiteboardRepository repository,
    required String roomId,
    required String currentUserId,
    required String currentUserName,
  }) : _repository = repository,
       _currentUserId = currentUserId,
       _currentUserName = currentUserName,
       super(WhiteboardState(roomId: roomId)) {
    loadObjects();
    _initSimulatedParticipants();
  }

  void _initSimulatedParticipants() {
    final demoParticipants = [
      const WhiteboardParticipant(
        id: 'user_selin',
        name: 'Selin Yılmaz',
        color: Color(0xFF06B6D4), // Cyan
        worldPosition: Offset(-120, -50),
      ),
      const WhiteboardParticipant(
        id: 'user_mert',
        name: 'Mert Kaya',
        color: Color(0xFFF97316), // Orange
        worldPosition: Offset(180, -20),
      ),
      const WhiteboardParticipant(
        id: 'user_zeynep',
        name: 'Zeynep Ak',
        color: Color(0xFFA855F7), // Purple
        worldPosition: Offset(40, 120),
      ),
    ];
    state = state.copyWith(participants: demoParticipants);
  }

  Future<void> loadObjects() async {
    state = state.copyWith(isLoading: true);
    final objects = await _repository.getObjects(state.roomId);
    state = state.copyWith(isLoading: false, objects: objects);
  }

  void _pushUndo() {
    _undoStack.add(List.from(state.objects));
    if (_undoStack.length > 30) {
      _undoStack.removeAt(0);
    }
    _redoStack.clear();
    state = state.copyWith(canUndo: true, canRedo: false);
  }

  void undo() {
    if (_undoStack.isEmpty) return;
    _redoStack.add(List.from(state.objects));
    final prev = _undoStack.removeLast();
    state = state.copyWith(
      objects: prev,
      canUndo: _undoStack.isNotEmpty,
      canRedo: true,
      clearSelectedObjectId: true,
    );
    _repository.saveObjects(state.roomId, prev);
  }

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

  // Koordinat Dönüşümleri
  Offset screenToWorld(Offset screenPoint) {
    return (screenPoint - state.pan) / state.scale;
  }

  Offset worldToScreen(Offset worldPoint) {
    return worldPoint * state.scale + state.pan;
  }

  // Kamera Pan & Zoom
  void updatePan(Offset delta) {
    state = state.copyWith(pan: state.pan + delta);
  }

  void updateZoom(double newScale, Offset focalPoint) {
    final clamped = newScale.clamp(AppConstants.minZoom, AppConstants.maxZoom);
    final worldFocal = (focalPoint - state.pan) / state.scale;
    final newPan = focalPoint - worldFocal * clamped;
    state = state.copyWith(scale: clamped, pan: newPan);
  }

  void zoomIn() {
    final target = (state.scale * 1.25).clamp(
      AppConstants.minZoom,
      AppConstants.maxZoom,
    );
    state = state.copyWith(scale: target);
  }

  void zoomOut() {
    final target = (state.scale / 1.25).clamp(
      AppConstants.minZoom,
      AppConstants.maxZoom,
    );
    state = state.copyWith(scale: target);
  }

  void resetCamera() {
    state = state.copyWith(pan: Offset.zero, scale: 1.0);
  }

  // Araç ve Tema Ayarları
  void setActiveTool(WhiteboardTool tool) {
    state = state.copyWith(
      activeTool: tool,
      clearSelectedObjectId: tool != WhiteboardTool.select,
    );
  }

  void setActiveShapeType(String shapeType) {
    state = state.copyWith(
      activeTool: WhiteboardTool.shape,
      activeShapeType: shapeType,
    );
  }

  void setActiveColor(Color color) {
    state = state.copyWith(activeColor: color);
  }

  void setActiveStrokeWidth(double width) {
    state = state.copyWith(activeStrokeWidth: width);
  }

  void setPattern(CanvasBackgroundPattern pattern) {
    state = state.copyWith(pattern: pattern);
  }

  // Pointer / Çizim Olayları
  void onPointerDown(Offset screenPoint) {
    final worldPoint = screenToWorld(screenPoint);
    _dragStartWorld = worldPoint;
    _lastDragWorld = worldPoint;

    switch (state.activeTool) {
      case WhiteboardTool.select:
        // En üstteki nesneden başlayarak tıklandı mı bak
        BoardObject? hitObject;
        for (final obj in state.objects.reversed) {
          if (obj.containsPoint(worldPoint)) {
            hitObject = obj;
            break;
          }
        }

        if (hitObject != null) {
          state = state.copyWith(selectedObjectId: hitObject.id);
          _isMovingObject = !hitObject.isPinned;
        } else {
          state = state.copyWith(clearSelectedObjectId: true);
          _isMovingObject = false;
        }
        break;

      case WhiteboardTool.pen:
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
        _eraseAt(worldPoint);
        break;

      case WhiteboardTool.shape:
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

  void onPointerMove(Offset screenPoint, {Offset? screenDelta}) {
    final worldPoint = screenToWorld(screenPoint);

    switch (state.activeTool) {
      case WhiteboardTool.select:
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
        _eraseAt(worldPoint);
        break;

      case WhiteboardTool.shape:
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
          updatePan(screenDelta);
        }
        break;

      case WhiteboardTool.text:
      case WhiteboardTool.stickyNote:
      case WhiteboardTool.image:
        break;
    }

    _lastDragWorld = worldPoint;
  }

  void onPointerUp() {
    if (state.currentDrawing != null) {
      _pushUndo();
      final updated = List<BoardObject>.from(state.objects)
        ..add(state.currentDrawing!);
      state = state.copyWith(objects: updated, clearCurrentDrawing: true);
      _repository.saveObjects(state.roomId, updated);
    } else if (_isMovingObject) {
      _pushUndo();
      _repository.saveObjects(state.roomId, state.objects);
    }

    _isMovingObject = false;
    _dragStartWorld = null;
    _lastDragWorld = null;
  }

  void _eraseAt(Offset worldPoint) {
    final toRemove = <BoardObject>[];
    for (final obj in state.objects) {
      if (obj.containsPoint(worldPoint, hitSlop: 12.0)) {
        toRemove.add(obj);
      }
    }

    if (toRemove.isNotEmpty) {
      _pushUndo();
      final updated = state.objects
          .where((o) => !toRemove.contains(o))
          .toList();
      state = state.copyWith(
        objects: updated,
        clearSelectedObjectId: toRemove.any(
          (o) => o.id == state.selectedObjectId,
        ),
      );
      _repository.saveObjects(state.roomId, updated);
    }
  }

  // Nesne Aksiyonları (Sabitleme & Silme)
  void deleteSelectedObject() {
    if (state.selectedObjectId == null) return;
    _pushUndo();
    final updated = state.objects
        .where((o) => o.id != state.selectedObjectId)
        .toList();
    state = state.copyWith(objects: updated, clearSelectedObjectId: true);
    _repository.saveObjects(state.roomId, updated);
  }

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

  void clearCanvas() {
    _pushUndo();
    state = state.copyWith(
      objects: [],
      clearSelectedObjectId: true,
      clearCurrentDrawing: true,
    );
    _repository.clearObjects(state.roomId);
  }

  // SVG Serileştirici (Dışa Aktarma)
  String exportSvg() {
    if (state.objects.isEmpty) {
      return '<svg xmlns="http://www.w3.org/2000/svg" width="800" height="600" viewBox="0 0 800 600"></svg>';
    }

    // Tüm nesnelerin kapladığı sınır kutusunu bul
    Rect totalBounds = state.objects.first.getBounds();
    for (final obj in state.objects) {
      totalBounds = totalBounds.expandToInclude(obj.getBounds());
    }
    totalBounds = totalBounds.inflate(40); // Kenar boşluğu

    final minX = totalBounds.left;
    final minY = totalBounds.top;
    final width = totalBounds.width;
    final height = totalBounds.height;

    final buffer = StringBuffer();
    buffer.writeln(
      '<svg xmlns="http://www.w3.org/2000/svg" '
      'width="${width.toInt()}" height="${height.toInt()}" '
      'viewBox="$minX $minY $width $height">',
    );
    buffer.writeln('  <!-- BoardConnect Whiteboard Export -->');
    buffer.writeln('  <defs>');
    buffer.writeln(
      '    <marker id="arrowhead" markerWidth="10" markerHeight="7" '
      'refX="9" refY="3.5" orient="auto">'
      '<polygon points="0 0, 10 3.5, 0 7" fill="#F59E0B" />'
      '</marker>',
    );
    buffer.writeln('  </defs>');

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

  String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  String _escapeXml(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }
}

/// Aile bazlı Whiteboard Provider (oda ID'sine göre)
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
