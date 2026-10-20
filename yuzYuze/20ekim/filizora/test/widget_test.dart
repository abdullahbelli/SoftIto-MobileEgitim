import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:filizora/core/theme/theme_controller.dart';
import 'package:filizora/features/authentication/controller/auth_controller.dart';
import 'package:filizora/features/authentication/models/user_account.dart';
import 'package:filizora/features/entrepreneur_community/controller/community_controller.dart';
import 'package:filizora/features/entrepreneur_community/models/community_post.dart';
import 'package:filizora/features/mentor_matching/controller/mentor_matching_controller.dart';
import 'package:filizora/features/mentor_matching/models/mentor.dart';
import 'package:filizora/features/support_programs/controller/support_programs_controller.dart';
import 'package:filizora/features/support_programs/models/support_program.dart';
import 'package:filizora/features/venture_tracking/controller/venture_tracking_controller.dart';
import 'package:filizora/features/venture_tracking/models/venture_stage.dart';
import 'package:filizora/core/widgets/app_logo.dart';
import 'package:filizora/main.dart';

void main() {
  group('Girişimcilik Platformu - Model Testleri', () {
    test('UserAccount ve BusinessIdea serialization testi', () {
      const idea = BusinessIdea(
        title: 'Akıllı Tarım',
        sector: 'AgriTech',
        description: 'Sensörlü sulama çözümü.',
      );

      final user = UserAccount(
        id: 'u1',
        fullName: 'Ahmet Kaya',
        email: 'ahmet@example.com',
        hasIdea: true,
        idea: idea,
        approvalStatus: ApprovalStatus.pendingApproval,
        createdAt: DateTime(2026, 10, 20),
      );

      final json = user.toJson();
      final fromJson = UserAccount.fromJson(json);

      expect(fromJson.fullName, 'Ahmet Kaya');
      expect(fromJson.hasIdea, true);
      expect(fromJson.idea?.title, 'Akıllı Tarım');
      expect(fromJson.approvalStatus, ApprovalStatus.pendingApproval);
      expect(fromJson.isApproved, false);
      expect(fromJson.isPending, true);
    });

    test('Mentor modeli copyWith ve json testi', () {
      const mentor = Mentor(
        id: 'm1',
        name: 'Dr. Selin',
        title: 'Yatırımcı',
        company: 'Ventures',
        expertise: 'Finans',
        rating: 4.9,
        bio: 'Biyografi',
      );

      final updated = mentor.copyWith(isMatched: true);
      expect(updated.isMatched, true);
      expect(updated.name, 'Dr. Selin');

      final json = updated.toJson();
      final fromJson = Mentor.fromJson(json);
      expect(fromJson.isMatched, true);
    });

    test('CommunityPost beğeni ve serialization testi', () {
      final post = CommunityPost(
        id: 'p1',
        authorName: 'Deniz',
        authorTitle: 'Girişimci',
        content: 'Harika bir mentorluk aldık!',
        tag: 'Mentorluk',
        likesCount: 5,
        createdAt: DateTime.now(),
      );

      final liked = post.copyWith(isLiked: true, likesCount: 6);
      expect(liked.likesCount, 6);
      expect(liked.isLiked, true);
    });

    test('SupportProgram ve VentureStage model testi', () {
      const program = SupportProgram(
        id: 'sp1',
        title: 'KOSGEB İleri Girişimci',
        institution: 'KOSGEB',
        amountLimit: '1.000.000 ₺',
        summary: 'Özet',
        category: 'Hibe',
        deadline: 'Sürekli',
        eligibility: 'Uygunluk',
      );
      expect(program.category, 'Hibe');

      const stage = VentureStage(
        id: 's1',
        title: 'MVP',
        description: 'Prototip',
        tasks: [
          VentureTask(id: 't1', title: 'Tasarım', isDone: true),
          VentureTask(id: 't2', title: 'Kodlama', isDone: false),
        ],
      );
      expect(stage.progress, 0.5);
      expect(stage.completedTasksCount, 1);
    });
  });

  group('Girişimcilik Platformu - Controller State Testleri', () {
    test('AuthController kayıt, iş fikri seçimi ve yönetici onay akışı', () async {
      final authController = AuthController();
      expect(authController.isAuthenticated, false);

      // İş fikri seçimi değiştirme
      authController.setHasIdea(false);
      expect(authController.hasIdeaSelection.value, false);

      // Fikirsiz kayıt
      var success = await authController.register(
        fullName: 'Mehmet Öz',
        email: 'mehmet@example.com',
      );
      expect(success, true);
      expect(authController.isAuthenticated, true);
      expect(authController.isPending, true);
      expect(authController.isApproved, false);

      // Yönetici onayı simülasyonu
      authController.simulateAdminApproval();
      expect(authController.isApproved, true);
      expect(authController.isPending, false);

      // Oturumu kapat
      authController.logout();
      expect(authController.isAuthenticated, false);

      authController.dispose();
    });

    test('MentorMatchingController filtreleme ve eşleşme testi', () {
      final controller = MentorMatchingController();
      expect(controller.mentors.value.isNotEmpty, true);

      controller.filterByExpertise('Yatırım & Finans');
      expect(controller.filteredMentors.every((m) => m.expertise == 'Yatırım & Finans'), true);

      final firstId = controller.mentors.value.first.id;
      final initialMatched = controller.mentors.value.first.isMatched;
      controller.toggleMatch(firstId);
      expect(controller.mentors.value.first.isMatched, !initialMatched);

      controller.dispose();
    });

    test('CommunityController paylaşım yapma ve beğenme testi', () {
      final controller = CommunityController();
      final initialCount = controller.posts.value.length;

      controller.addPost(
        authorName: 'Test Kullanıcısı',
        authorTitle: 'Kurucu',
        content: 'Yeni bir dönüm noktasına ulaştık!',
        tag: 'Girişimcilik',
      );

      expect(controller.posts.value.length, initialCount + 1);
      final newPost = controller.posts.value.first;
      expect(newPost.content, 'Yeni bir dönüm noktasına ulaştık!');

      controller.toggleLike(newPost.id);
      expect(controller.posts.value.first.isLiked, true);

      controller.dispose();
    });

    test('SupportProgramsController filtreleme ve kaydetme testi', () {
      final controller = SupportProgramsController();
      final initialSaved = controller.programs.value.first.isSaved;

      controller.toggleSave(controller.programs.value.first.id);
      expect(controller.programs.value.first.isSaved, !initialSaved);

      controller.filterByCategory('Hibe');
      expect(controller.filteredPrograms.every((p) => p.category == 'Hibe'), true);

      controller.dispose();
    });

    test('VentureTrackingController alt görev tamamlama testi', () {
      final controller = VentureTrackingController();
      final stage = controller.stages.value.first;
      final task = stage.tasks.first;
      final initialDone = task.isDone;

      controller.toggleTask(stage.id, task.id);
      final updatedStage = controller.stages.value.firstWhere((s) => s.id == stage.id);
      final updatedTask = updatedStage.tasks.firstWhere((t) => t.id == task.id);
      expect(updatedTask.isDone, !initialDone);

      controller.dispose();
    });
  });

  group('Uçtan Uca Widget & Akış Testleri', () {
    testWidgets('Kayıt -> Onay Bekleme -> Yönetici Onayı -> 4 Ana Sayfa Akışı', (WidgetTester tester) async {
      final authController = AuthController();
      final themeController = ThemeController();

      await tester.pumpWidget(GirisimcilikPlatformuApp(
        authController: authController,
        themeController: themeController,
      ));
      await tester.pumpAndSettle();

      // 1. Adım: Kayıt ekranı görüntülenir
      expect(find.text('Kayıt Ol'), findsOneWidget);
      expect(find.text('Filizora'), findsOneWidget);
      expect(find.byType(AppLogo), findsWidgets);
      expect(find.text('İş Fikri Durumu'), findsOneWidget);
      expect(find.text('İş Fikrim Var'), findsOneWidget);
      expect(find.text('İş Fikrim Yok'), findsOneWidget);

      // "İş Fikrim Yok" butonuna tıkla
      await tester.tap(find.text('İş Fikrim Yok'));
      await tester.pumpAndSettle();

      // "İş Fikrim Yok" seçildiğinde rehber kartının gösterildiğini doğrula
      expect(find.text('İş Fikriniz Yok mu? Hiç Sorun Değil!'), findsOneWidget);

      // Form alanlarını doldur
      await tester.enterText(find.widgetWithText(TextFormField, 'Ad Soyad'), 'Bora Aksoy');
      await tester.enterText(find.widgetWithText(TextFormField, 'E-posta Adresi'), 'bora@test.com');
      await tester.pumpAndSettle();

      // Kaydı Tamamla butonuna kaydır ve bas
      await tester.ensureVisible(find.text('Kaydı Tamamla ve Onaya Gönder'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kaydı Tamamla ve Onaya Gönder'));
      await tester.pumpAndSettle();

      // 2. Adım: Onay Bekleme Ekranı (Ana özellikler kilitli!)
      expect(find.text('Yönetici Onayı Bekleniyor'), findsOneWidget);
      expect(find.text('Ana özellikler kilitli'), findsOneWidget);
      expect(find.text('Simülasyon: Yönetici Onayı Ver (Erişimi Aç)'), findsOneWidget);

      // Ana sayfa sekmelerinin görünmediğini doğrula
      expect(find.text('Mentorluk'), findsNothing);
      expect(find.text('Topluluk'), findsNothing);

      // 3. Adım: Yönetici Onayı Ver (Simülasyon)
      await tester.tap(find.text('Simülasyon: Yönetici Onayı Ver (Erişimi Aç)'));
      await tester.pumpAndSettle();

      // 4. Adım: 4 Ana Sayfa Erişime Açıldı
      expect(find.text('Mentorluk'), findsWidgets);
      expect(find.text('Topluluk'), findsWidgets);
      expect(find.text('Destekler'), findsWidgets);
      expect(find.text('Süreç Takibi'), findsWidgets);

      // Mentor eşleşmesi sayfasındayız
      expect(find.text('Mentor Eşleşmesi'), findsOneWidget);

      // Sekmeler arası geçişi dene: Topluluk sekmesi
      await tester.tap(find.text('Topluluk'));
      await tester.pumpAndSettle();
      expect(find.text('Girişimci Topluluğu'), findsOneWidget);

      // Destekler sekmesi
      await tester.tap(find.text('Destekler'));
      await tester.pumpAndSettle();
      expect(find.text('Destek Programları'), findsOneWidget);
      expect(find.text('Destek Programına Başvuru Yap'), findsWidgets);

      // Süreç Takibi sekmesi
      await tester.tap(find.text('Süreç Takibi'));
      await tester.pumpAndSettle();
      expect(find.text('Girişim Süreci Takibi'), findsOneWidget);
      expect(find.text('Gantt Şeması'), findsOneWidget);

      authController.dispose();
      themeController.dispose();
    });

    testWidgets('Admin Paneli: Bekleyen Başvuruları Listeleme ve Onaylama', (WidgetTester tester) async {
      final authController = AuthController();
      final themeController = ThemeController();

      // Admin olarak doğrudan giriş yap
      authController.loginAsRole(UserRole.admin);

      await tester.pumpWidget(GirisimcilikPlatformuApp(
        authController: authController,
        themeController: themeController,
      ));
      await tester.pumpAndSettle();

      // Yönetici Paneli ekranı görüntülenir
      expect(find.text('Yönetici Paneli (Admin)'), findsOneWidget);
      expect(find.text('Onay Bekleyenler'), findsOneWidget);
      expect(find.text('Tüm Kullanıcılar'), findsOneWidget);

      // Onay bekleyen girişimciler listelenir
      expect(find.text('Başvuruyu Onayla'), findsWidgets);
      expect(find.text('Reddet'), findsWidgets);

      // İlk bekleyen başvuruyu onayla
      await tester.tap(find.text('Başvuruyu Onayla').first);
      await tester.pumpAndSettle();

      // Onaylandı bildirimi görüntülenir
      expect(find.text('Girişimcinin başvurusu onaylandı!'), findsOneWidget);

      // Başvuru reddetmeyi dene
      final initialPendingCount = authController.pendingUsers.length;
      if (initialPendingCount > 0) {
        final rejectButton = find.widgetWithText(OutlinedButton, 'Reddet').first;
        await tester.tap(rejectButton);
        await tester.pumpAndSettle();
        expect(authController.pendingUsers.length, initialPendingCount - 1);
      }

      authController.dispose();
      themeController.dispose();
    });

    testWidgets('Girişimci Mentöre İstek Gönderir -> Yatırımcı Giriş Yapıp Bekleyen İsteği Görür ve Kabul Eder',
        (WidgetTester tester) async {
      final authController = AuthController();
      final themeController = ThemeController();
      final mentorController = MentorMatchingController();

      // 1. Onaylı Girişimci olarak giriş yap
      authController.loginAsRole(UserRole.entrepreneur);

      await tester.pumpWidget(FilizoraApp(
        authController: authController,
        themeController: themeController,
        mentorController: mentorController,
      ));
      await tester.pumpAndSettle();

      // Mentor eşleşmesi sekmesindeyiz
      expect(find.text('Mentor Eşleşmesi'), findsOneWidget);
      expect(find.text('Eşleşme İsteği'), findsWidgets);

      // İlk mentöre eşleşme isteği gönder
      await tester.tap(find.text('Eşleşme İsteği').first);
      await tester.pumpAndSettle();

      // SnackBar bildirimi görüntülenir
      expect(find.textContaining('için eşleşme isteği iletildi'), findsOneWidget);

      // 2. Girişimci çıkış yapar ve Yatırımcı (Dr. Ahmet Yılmaz) giriş yapar
      authController.logout();
      await tester.pumpAndSettle();

      // Kayıt/Giriş ekranında Yatırımcı sekmesine geç veya hızlı demo girişi yap
      await tester.tap(find.text('Yatırımcı').first);
      await tester.pumpAndSettle();

      // Yatırımcı Portalı Girişi Yap butonuna kaydır ve bas
      await tester.ensureVisible(find.text('Yatırımcı Portalı Girişi Yap'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Yatırımcı Portalı Girişi Yap'));
      await tester.pumpAndSettle();

      // 3. Yatırımcı Portalı görüntülenir ve bekleyen istekler listelenir
      expect(find.textContaining('Yatırımcı Portalı'), findsOneWidget);
      expect(find.text('Bekleyen İstekler'), findsOneWidget);
      expect(find.text('Eşleşmeyi Kabul Et'), findsWidgets);

      // Eşleşmeyi kabul et
      final acceptButton = find.widgetWithText(FilledButton, 'Eşleşmeyi Kabul Et').first;
      await tester.ensureVisible(acceptButton);
      await tester.pumpAndSettle();
      await tester.tap(acceptButton);
      await tester.pumpAndSettle();

      expect(mentorController.acceptedRequests.isNotEmpty, true);

      authController.dispose();
      themeController.dispose();
      mentorController.dispose();
    });

    testWidgets('Girişimci Ekranı: Giriş Yap ve Yeni Kayıt Sekmeleri Arası Geçiş ve Giriş Testi',
        (WidgetTester tester) async {
      final authController = AuthController();
      final themeController = ThemeController();

      await tester.pumpWidget(FilizoraApp(
        authController: authController,
        themeController: themeController,
      ));
      await tester.pumpAndSettle();

      // Girişimci ekranındayız
      expect(find.text('Yeni Kayıt Ol'), findsOneWidget);
      expect(find.text('Giriş Yap'), findsOneWidget);

      // "Giriş Yap" sekmesine tıkla
      await tester.tap(find.text('Giriş Yap'));
      await tester.pumpAndSettle();

      // Giriş yap form alanları görüntülenir
      expect(find.text('Kayıtlı E-posta Adresi'), findsOneWidget);
      expect(find.text('Girişimci Girişi Yap'), findsOneWidget);

      // Onaylı girişimci e-postası gir (bora@test.com)
      await tester.enterText(find.widgetWithText(TextFormField, 'Kayıtlı E-posta Adresi'), 'bora@test.com');
      await tester.pumpAndSettle();

      // Girişimci Girişi Yap butonuna kaydır ve bas
      await tester.ensureVisible(find.text('Girişimci Girişi Yap'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Girişimci Girişi Yap'));
      await tester.pumpAndSettle();

      // Onaylı olduğu için doğrudan 4 ana sayfa kabuğuna eriştiğini doğrula
      expect(find.text('Mentorluk'), findsWidgets);
      expect(find.text('Topluluk'), findsWidgets);

      authController.dispose();
      themeController.dispose();
    });
  });
}
