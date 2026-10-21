import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:boardconnect/app/app.dart';
import 'package:boardconnect/app/theme/theme_provider.dart';
import 'package:boardconnect/features/auth/data/mock_auth_repository.dart';
import 'package:boardconnect/features/rooms/data/local_room_repository.dart';
import 'package:boardconnect/features/whiteboard/data/local_whiteboard_repository.dart';
import 'package:boardconnect/features/whiteboard/domain/board_object.dart';
import 'package:boardconnect/features/whiteboard/domain/canvas_theme.dart';
import 'package:boardconnect/features/whiteboard/presentation/controllers/whiteboard_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BoardConnect Model & Logic Tests', () {
    test('StrokeObject bounds and movedBy calculation', () {
      final stroke = StrokeObject(
        id: 'stroke_1',
        createdBy: 'user_1',
        createdAt: DateTime.now(),
        points: const [Offset(10, 10), Offset(50, 50)],
        color: Colors.black,
        strokeWidth: 4.0,
      );

      final bounds = stroke.getBounds();
      expect(bounds.left, 6.0);
      expect(bounds.top, 6.0);
      expect(bounds.right, 54.0);
      expect(bounds.bottom, 54.0);

      // movedBy
      final moved = stroke.movedBy(const Offset(20, 30));
      expect(moved.points.first, const Offset(30, 40));
      expect(moved.points.last, const Offset(70, 80));
    });

    test('ShapeObject pin behavior', () {
      final shape = ShapeObject(
        id: 'shape_1',
        type: 'rectangle',
        createdBy: 'user_1',
        createdAt: DateTime.now(),
        bounds: const Rect.fromLTWH(0, 0, 100, 100),
        strokeColor: Colors.amber,
        isPinned: true,
      );

      // Pinned object should NOT move
      final attemptedMove = shape.movedBy(const Offset(50, 50));
      expect(attemptedMove.bounds.left, 0.0);
      expect(attemptedMove.bounds.top, 0.0);

      // Unpin object
      final unpinned = shape.withPinned(false);
      expect(unpinned.isPinned, false);
      final validMove = unpinned.movedBy(const Offset(50, 50));
      expect(validMove.bounds.left, 50.0);
      expect(validMove.bounds.top, 50.0);
    });

    test('CanvasBackgroundPattern labels and icons', () {
      expect(CanvasBackgroundPattern.grid.label, 'Kareli');
      expect(CanvasBackgroundPattern.plain.label, 'Düz');
      expect(CanvasBackgroundPattern.ruled.label, 'Çizgili');
      expect(CanvasBackgroundPattern.dots.label, 'Kâğıt / Noktalı');
    });

    test('StickyNoteObject text copy and bounds', () {
      final note = StickyNoteObject(
        id: 'note_1',
        createdBy: 'user_1',
        createdAt: DateTime.now(),
        bounds: const Rect.fromLTWH(50, 50, 150, 150),
        text: 'İlk Not',
        authorName: 'Test Kullanıcı',
      );

      expect(note.bounds.width, 150);
      expect(note.text, 'İlk Not');

      final updated = note.copyWithText('Güncel Not');
      expect(updated.text, 'Güncel Not');
      expect(updated.id, note.id);
    });
  });

  group('Mock Repository Tests', () {
    test('MockAuthRepository login & OTP verification', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final authRepo = MockAuthRepository(prefs);

      // Varsayılan demo kullanıcısı ile giriş
      final user = await authRepo.login(
        'demo@boardconnect.com',
        'Password123*',
      );
      expect(user.email, 'demo@boardconnect.com');
      expect(user.username, 'boardmaster');

      // 6 haneli OTP doğrulama
      final validOtp = await authRepo.verifyOtp(user.email, '123456');
      expect(validOtp, true);

      // Misafir girişi
      final guest = await authRepo.guestLogin(
        name: 'Misafir Test',
        roomCode: 'BC-TEST',
      );
      expect(guest.isGuest, true);
      expect(guest.username, 'Misafir Test');
    });

    test('LocalRoomRepository create & get rooms', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final roomRepo = LocalRoomRepository(prefs);

      final initialRooms = await roomRepo.getRooms();
      expect(initialRooms.isNotEmpty, true);

      final newRoom = await roomRepo.createRoom(
        name: 'Yeni Test Odası',
        maxParticipants: 12,
        ownerId: 'user_1',
        ownerName: 'Ali Demir',
      );
      expect(newRoom.name, 'Yeni Test Odası');
      expect(newRoom.joinCode.startsWith('BC-'), true);

      final found = await roomRepo.getRoomByCode(newRoom.joinCode);
      expect(found?.id, newRoom.id);

      await roomRepo.deleteRoom(newRoom.id);
      final afterDelete = await roomRepo.getRoomById(newRoom.id);
      expect(afterDelete, null);
    });

    test('WhiteboardController SVG Export generation', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final wbRepo = LocalWhiteboardRepository(prefs);

      final controller = WhiteboardController(
        repository: wbRepo,
        roomId: 'test_room',
        currentUserId: 'user_1',
        currentUserName: 'Test User',
      );

      // Şekil ekle
      controller.setActiveShapeType('rectangle');
      controller.onPointerDown(const Offset(10, 10));
      controller.onPointerMove(const Offset(100, 80));
      controller.onPointerUp();

      final svg = controller.exportSvg();
      expect(svg.contains('<svg'), true);
      expect(svg.contains('</svg>'), true);
      expect(svg.contains('<rect'), true);
    });
  });

  group('BoardConnect App Widget Smoke Test', () {
    testWidgets('App renders login screen initially', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const BoardConnectApp(),
        ),
      );

      await tester.pumpAndSettle();

      // BoardConnect başlığı ve Giriş Yap butonu bulunmalı
      expect(find.text('Hoş Geldiniz'), findsOneWidget);
      expect(find.text('Giriş Yap'), findsOneWidget);
      expect(find.text('Misafir Olarak Odaya Katıl'), findsOneWidget);
    });
  });
}
