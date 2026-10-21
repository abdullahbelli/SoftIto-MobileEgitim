import 'package:flutter/material.dart'; // Testlerde kullanılan temel Material Design renk ve geometri sınıflarını (Offset, Rect, Colors vb.) içe aktarır.
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod durum yönetimi test sağlayıcılarını (ProviderScope) içe aktarır.
import 'package:flutter_test/flutter_test.dart'; // Flutter birim ve widget test kütüphanesini (test, testWidgets, expect vb.) içe aktarır.
import 'package:shared_preferences/shared_preferences.dart'; // Test ortamında sahte kalıcı veri depolama (mock SharedPreferences) sağlamak için içe aktarır.
import 'package:boardconnect/app/app.dart'; // Test edilecek ana uygulama widget'ını (BoardConnectApp) içe aktarır.
import 'package:boardconnect/app/theme/theme_provider.dart'; // SharedPreferences sağlayıcısını override etmek için tema sağlayıcı dosyasını içe aktarır.
import 'package:boardconnect/features/auth/data/mock_auth_repository.dart'; // Kimlik doğrulama testlerinde kullanılan sahte auth deposunu içe aktarır.
import 'package:boardconnect/features/rooms/data/local_room_repository.dart'; // Odalarla ilgili testlerde kullanılan yerel oda deposunu içe aktarır.
import 'package:boardconnect/features/whiteboard/data/local_whiteboard_repository.dart'; // Tuval nesnelerini kaydeden yerel tuval deposunu içe aktarır.
import 'package:boardconnect/features/whiteboard/domain/board_object.dart'; // Test edilecek tuval nesnesi veri modellerini (StrokeObject, ShapeObject vb.) içe aktarır.
import 'package:boardconnect/features/whiteboard/domain/canvas_theme.dart'; // Tuval arka plan desen enum modelini içe aktarır.
import 'package:boardconnect/features/whiteboard/presentation/controllers/whiteboard_controller.dart'; // Tuval iş mantığı ve SVG dışa aktarma denetleyicisini içe aktarır.

void main() {
  // Tüm birim ve widget testlerinin çalıştırıldığı ana giriş fonksiyonudur.
  TestWidgetsFlutterBinding.ensureInitialized(); // Test ortamında Flutter widget bağlayıcısının (binding) başlatıldığından emin olur.

  group('BoardConnect Model & Logic Tests', () {
    // Veri modelleri ve matematiksel mantık hesaplamalarını gruplayan test kümesidir.
    test('StrokeObject bounds and movedBy calculation', () {
      // Serbest çizim sınır alanı ve konum kaydırma mantığını test eder.
      final stroke = StrokeObject(
        // Test için örnek bir serbest çizim (stroke) nesnesi oluşturur.
        id: 'stroke_1', // Çizimin benzersiz kimliği.
        createdBy: 'user_1', // Çizen kullanıcının kimliği.
        createdAt: DateTime.now(), // Oluşturulma zamanı.
        points: const [
          Offset(10, 10),
          Offset(50, 50),
        ], // Çizginin başlangıç ve bitiş koordinat noktaları.
        color: Colors.black, // Çizgi rengi.
        strokeWidth: 4.0, // Çizgi kalınlığı.
      );

      final bounds = stroke.getBounds(); // Çizginin kalınlığı dahil kapladığı dikdörtgen sınırları (Rect) hesaplar.
      expect(
        bounds.left,
        6.0,
      ); // Sol sınırın (10 - 4 = 6) doğru hesaplandığını doğrular.
      expect(
        bounds.top,
        6.0,
      ); // Üst sınırın (10 - 4 = 6) doğru hesaplandığını doğrular.
      expect(
        bounds.right,
        54.0,
      ); // Sağ sınırın (50 + 4 = 54) doğru hesaplandığını doğrular.
      expect(
        bounds.bottom,
        54.0,
      ); // Alt sınırın (50 + 4 = 54) doğru hesaplandığını doğrular.

      // movedBy
      final moved = stroke.movedBy(
        const Offset(20, 30),
      ); // Çizimi X ekseninde 20, Y ekseninde 30 birim öteler.
      expect(
        moved.points.first,
        const Offset(30, 40),
      ); // İlk noktanın (10+20, 10+30 = 30, 40) olduğunu kontrol eder.
      expect(
        moved.points.last,
        const Offset(70, 80),
      ); // Son noktanın (50+20, 50+30 = 70, 80) olduğunu kontrol eder.
    });

    test('ShapeObject pin behavior', () {
      // Şekil nesnesinin sabitlenme (pin) ve hareket kısıtlama mantığını test eder.
      final shape = ShapeObject(
        // Test amaçlı örnek bir dikdörtgen şekil nesnesi oluşturur.
        id: 'shape_1', // Şeklin benzersiz kimliği.
        type: 'rectangle', // Geometrik şekil türü.
        createdBy: 'user_1', // Oluşturan kullanıcı.
        createdAt: DateTime.now(), // Oluşturulma tarihi.
        bounds: const Rect.fromLTWH(
          0,
          0,
          100,
          100,
        ), // Başlangıç sınır koordinatları (0, 0, 100, 100).
        strokeColor: Colors.amber, // Kenarlık rengi.
        isPinned: true, // Şekli tuvale kilitlenmiş/sabitlenmiş olarak ayarlar.
      );

      // Pinned object should NOT move
      final attemptedMove = shape.movedBy(
        const Offset(50, 50),
      ); // Sabitlenmiş şekli hareket ettirmeyi dener.
      expect(attemptedMove.bounds.left, 0.0); // Sabitli nesnenin sol konumunun değişmediğini (0.0 kaldığını) doğrular.
      expect(attemptedMove.bounds.top, 0.0); // Sabitli nesnenin üst konumunun değişmediğini (0.0 kaldığını) doğrular.

      // Unpin object
      final unpinned = shape.withPinned(
        false,
      ); // Nesnenin sabitliğini kaldırarak kilidini açar.
      expect(
        unpinned.isPinned,
        false,
      ); // Kilidin başarıyla açıldığını kontrol eder.
      final validMove = unpinned.movedBy(
        const Offset(50, 50),
      ); // Kilitsiz nesneyi 50 birim hareket ettirir.
      expect(
        validMove.bounds.left,
        50.0,
      ); // Yeni sol koordinatın 50.0 olduğunu doğrular.
      expect(
        validMove.bounds.top,
        50.0,
      ); // Yeni üst koordinatın 50.0 olduğunu doğrular.
    });

    test('CanvasBackgroundPattern labels and icons', () {
      // Tuval arka plan desenlerinin Türkçe başlıklarını doğrular.
      expect(
        CanvasBackgroundPattern.grid.label,
        'Kareli',
      ); // Grid deseninin 'Kareli' etiketine sahip olduğunu denetler.
      expect(
        CanvasBackgroundPattern.plain.label,
        'Düz',
      ); // Plain deseninin 'Düz' etiketine sahip olduğunu denetler.
      expect(
        CanvasBackgroundPattern.ruled.label,
        'Çizgili',
      ); // Ruled deseninin 'Çizgili' etiketine sahip olduğunu denetler.
      expect(
        CanvasBackgroundPattern.dots.label,
        'Kâğıt / Noktalı',
      ); // Dots deseninin 'Kâğıt / Noktalı' etiketine sahip olduğunu denetler.
    });

    test('StickyNoteObject text copy and bounds', () {
      // Yapışkan not nesnesinin metin güncelleme ve kopyalama işlevini test eder.
      final note = StickyNoteObject(
        // Örnek bir yapışkan not nesnesi oluşturur.
        id: 'note_1', // Notun kimliği.
        createdBy: 'user_1', // Oluşturan kullanıcı.
        createdAt: DateTime.now(), // Tarih damgası.
        bounds: const Rect.fromLTWH(
          50,
          50,
          150,
          150,
        ), // Boyutları 150x150 olan sınır kutusu.
        text: 'İlk Not', // İlk metin içeriği.
        authorName: 'Test Kullanıcı', // Not yazarının adı.
      );

      expect(note.bounds.width, 150); // Genişliğin 150 birim olduğunu doğrular.
      expect(
        note.text,
        'İlk Not',
      ); // Metin içeriğinin doğruluğunu kontrol eder.

      final updated = note.copyWithText(
        'Güncel Not',
      ); // Notun metnini güncelleyen kopyasını üretir.
      expect(
        updated.text,
        'Güncel Not',
      ); // Yeni metnin 'Güncel Not' olduğunu doğrular.
      expect(
        updated.id,
        note.id,
      ); // Nesne kimliğinin değişmeden korunduğunu doğrular.
    });
  });

  group('Mock Repository Tests', () {
    // Veri depoları (Auth, Room, Whiteboard) için yazılmış testleri gruplar.
    test('MockAuthRepository login & OTP verification', () async {
      // Kullanıcı girişi ve OTP doğrulama akışını test eden asenkron test.
      SharedPreferences.setMockInitialValues(
        {},
      ); // Bellekte çalışacak sahte boş SharedPreferences başlatır.
      final prefs = await SharedPreferences.getInstance(); // SharedPreferences örneğini asenkron alır.
      final authRepo = MockAuthRepository(
        prefs,
      ); // Sahte auth deposunu başlatır.

      // Varsayılan demo kullanıcısı ile giriş
      final user = await authRepo.login(
        // Demo hesap bilgileriyle giriş yapar.
        'demo@boardconnect.com', // E-posta.
        'Password123*', // Şifre.
      );
      expect(
        user.email,
        'demo@boardconnect.com',
      ); // Kullanıcı e-postasının eşleştiğini doğrular.
      expect(
        user.username,
        'boardmaster',
      ); // Kullanıcı adının 'boardmaster' olduğunu kontrol eder.

      // 6 haneli OTP doğrulama
      final validOtp = await authRepo.verifyOtp(
        user.email,
        '123456',
      ); // Doğru OTP kodunu (123456) test eder.
      expect(validOtp, true); // Doğrulamanın başarılı (true) döndüğünü onaylar.

      // Misafir girişi
      final guest = await authRepo.guestLogin(
        // Misafir kullanıcı girişi fonksiyonunu çağırır.
        name: 'Misafir Test', // Misafir adı.
        roomCode: 'BC-TEST', // Katılacağı oda kodu.
      );
      expect(guest.isGuest, true); // Misafir bayrağının true olduğunu doğrular.
      expect(
        guest.username,
        'Misafir Test',
      ); // Misafir adının korunduğunu denetler.
    });

    test('LocalRoomRepository create & get rooms', () async {
      // Oda oluşturma, listeleme ve silme döngüsünü test eden metot.
      SharedPreferences.setMockInitialValues(
        {},
      ); // Test ortamı için sahte depolamayı sıfırlar.
      final prefs =
          await SharedPreferences.getInstance(); // Tercih nesnesine erişir.
      final roomRepo = LocalRoomRepository(
        prefs,
      ); // Yerel oda deposunu oluşturur.

      final initialRooms = await roomRepo
          .getRooms(); // Başlangıçtaki varsayılan odaları getirir.
      expect(
        initialRooms.isNotEmpty,
        true,
      ); // Başlangıçta en az 1 demo odası bulunduğunu doğrular.

      final newRoom = await roomRepo.createRoom(
        // Yeni bir oda oluşturur.
        name: 'Yeni Test Odası', // Oda adı.
        maxParticipants: 12, // Maksimum katılımcı sayısı.
        ownerId: 'user_1', // Oda sahibi ID'si.
        ownerName: 'Ali Demir', // Oda sahibi adı.
      );
      expect(
        newRoom.name,
        'Yeni Test Odası',
      ); // Oda adının doğruluğunu onaylar.
      expect(
        newRoom.joinCode.startsWith('BC-'),
        true,
      ); // Oda davet kodunun 'BC-' önekiyle başladığını denetler.

      final found = await roomRepo.getRoomByCode(
        newRoom.joinCode,
      ); // Davet koduyla odayı arar.
      expect(
        found?.id,
        newRoom.id,
      ); // Bulunan odanın kimliğinin eşleştiğini doğrular.

      await roomRepo.deleteRoom(newRoom.id); // Oluşturulan odayı siler.
      final afterDelete = await roomRepo.getRoomById(
        newRoom.id,
      ); // Silinen odayı tekrar sorgular.
      expect(afterDelete, null); // Odanın artık bulunamadığını (null) doğrular.
    });

    test('WhiteboardController SVG Export generation', () async {
      // Tuval nesnelerinden SVG çıktısı üretilmesini test eder.
      SharedPreferences.setMockInitialValues(
        {},
      ); // Sahte yerel depolamayı başlatır.
      final prefs =
          await SharedPreferences.getInstance(); // Tercih örneğini alır.
      final wbRepo = LocalWhiteboardRepository(
        prefs,
      ); // Yerel tuval deposunu hazırlar.

      final controller = WhiteboardController(
        // Test amaçlı WhiteboardController örneği oluşturur.
        repository: wbRepo, // Tuval deposu.
        roomId: 'test_room', // Test odası kimliği.
        currentUserId: 'user_1', // Test kullanıcısı kimliği.
        currentUserName: 'Test User', // Test kullanıcısı adı.
      );

      // Şekil ekle
      controller.setActiveShapeType(
        'rectangle',
      ); // Aktif şekli dikdörtgen yapar.
      controller.onPointerDown(
        const Offset(10, 10),
      ); // Çizimi (10, 10) noktasında başlatır.
      controller.onPointerMove(
        const Offset(100, 80),
      ); // Dikdörtgeni (100, 80) noktasına kadar çeker.
      controller.onPointerUp(); // Çizimi tamamlar ve şekil nesnesini oluşturur.

      final svg = controller
          .exportSvg(); // SVG formatında metin çıktısını üretir.
      expect(
        svg.contains('<svg'),
        true,
      ); // SVG başlangıç etiketinin var olduğunu doğrular.
      expect(
        svg.contains('</svg>'),
        true,
      ); // SVG kapanış etiketinin var olduğunu doğrular.
      expect(
        svg.contains('<rect'),
        true,
      ); // Dikdörtgen vektör etiketinin SVG içeriğinde yer aldığını doğrular.
    });
  });

  group('BoardConnect App Widget Smoke Test', () {
    // Uygulama arayüzünün ilk render duman (smoke) testini gruplar.
    testWidgets('App renders login screen initially', (
      // İlk açılışta giriş ekranının çizildiğini test eden widget testi.
      WidgetTester tester, // Widget test ortamını yöneten simülatör nesnesi.
    ) async {
      SharedPreferences.setMockInitialValues(
        {},
      ); // Sahte SharedPreferences başlatır.
      final prefs = await SharedPreferences.getInstance(); // SharedPreferences örneğini alır.

      await tester.pumpWidget(
        // Uygulama ağacını sanal test ortamında render eder.
        ProviderScope(
          // Riverpod sağlayıcı kapsamı.
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ], // SharedPreferences sağlayıcısını sahte nesneyle değiştirir.
          child: const BoardConnectApp(), // Ana uygulama widget'ı.
        ),
      );

      await tester.pumpAndSettle(); // Animasyonların ve rotaların tamamlanıp ekranın oturmasını bekler.

      // BoardConnect başlığı ve Giriş Yap butonu bulunmalı
      expect(
        find.text('Hoş Geldiniz'),
        findsOneWidget,
      ); // Ekranda 'Hoş Geldiniz' başlığının tam 1 tane olduğunu doğrular.
      expect(
        find.text('Giriş Yap'),
        findsOneWidget,
      ); // Ekranda 'Giriş Yap' butonunun tam 1 tane olduğunu doğrular.
      expect(
        find.text('Misafir Olarak Odaya Katıl'),
        findsOneWidget,
      ); // Ekranda misafir girişi butonunun var olduğunu doğrular.
    });
  });
}
