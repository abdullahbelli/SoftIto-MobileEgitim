import 'package:flutter/material.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/admin/view/admin_dashboard_view.dart';
import 'features/authentication/controller/auth_controller.dart';
import 'features/authentication/models/user_account.dart';
import 'features/authentication/view/pending_approval_view.dart';
import 'features/authentication/view/register_view.dart';
import 'features/entrepreneur_community/controller/community_controller.dart';
import 'features/entrepreneur_community/view/entrepreneur_community_view.dart';
import 'features/investor/view/investor_dashboard_view.dart';
import 'features/mentor_matching/controller/mentor_matching_controller.dart';
import 'features/mentor_matching/view/mentor_matching_view.dart';
import 'features/support_programs/controller/support_programs_controller.dart';
import 'features/support_programs/view/support_programs_view.dart';
import 'features/venture_tracking/controller/venture_tracking_controller.dart';
import 'features/venture_tracking/view/venture_tracking_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final themeController = ThemeController();
  final authController = AuthController();
  final mentorController = MentorMatchingController();

  runApp(FilizoraApp(
    themeController: themeController,
    authController: authController,
    mentorController: mentorController,
  ));
}

/// Filizora Ana Uygulama Kökü
typedef GirisimcilikPlatformuApp = FilizoraApp;

class FilizoraApp extends StatelessWidget {
  final ThemeController? themeController;
  final AuthController? authController;
  final MentorMatchingController? mentorController;

  const FilizoraApp({
    super.key,
    this.themeController,
    this.authController,
    this.mentorController,
  });

  @override
  Widget build(BuildContext context) {
    final tController = themeController ?? ThemeController();
    final aController = authController ?? AuthController();
    final mController = mentorController ?? MentorMatchingController();

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: tController.themeMode,
      builder: (context, currentThemeMode, _) {
        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentThemeMode,
          home: AppRootRouter(
            themeController: tController,
            authController: aController,
            mentorController: mController,
          ),
        );
      },
    );
  }
}

/// Çoklu Rol ve Onay Durumuna Göre Ekran Yönlendiricisi
class AppRootRouter extends StatelessWidget {
  final ThemeController themeController;
  final AuthController authController;
  final MentorMatchingController mentorController;

  const AppRootRouter({
    super.key,
    required this.themeController,
    required this.authController,
    required this.mentorController,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserAccount?>(
      valueListenable: authController.currentUser,
      builder: (context, user, _) {
        // 1. Henüz oturum açılmamışsa çoklu rol kayıt & giriş ekranı
        if (user == null) {
          return RegisterView(
            authController: authController,
            themeController: themeController,
          );
        }

        // 2. Yönetici (Admin) Rolü: Başvuru ve Giriş Onaylama Paneli
        if (user.isAdmin) {
          return AdminDashboardView(
            authController: authController,
            themeController: themeController,
          );
        }

        // 3. Yatırımcı / Mentor Rolü: Bekleyen Eşleşme Talepleri ve İnceleme Paneli
        if (user.isInvestor) {
          return InvestorDashboardView(
            mentorController: mentorController,
            authController: authController,
            themeController: themeController,
          );
        }

        // 4. Girişimci Rolü: Henüz yönetici onayı bekliyorsa bekleme ekranı
        if (user.approvalStatus != ApprovalStatus.approved) {
          return PendingApprovalView(
            authController: authController,
            themeController: themeController,
          );
        }

        // 5. Onaylı Girişimci: 4 temel özellikli ana kabuk
        return PlatformMainShell(
          themeController: themeController,
          authController: authController,
          mentorController: mentorController,
        );
      },
    );
  }
}

/// Onaylı Girişimciler İçin 4 Temel Özelliği Barındıran Ana Kabuk
class PlatformMainShell extends StatefulWidget {
  final ThemeController themeController;
  final AuthController authController;
  final MentorMatchingController? mentorController;

  const PlatformMainShell({
    super.key,
    required this.themeController,
    required this.authController,
    this.mentorController,
  });

  @override
  State<PlatformMainShell> createState() => _PlatformMainShellState();
}

class _PlatformMainShellState extends State<PlatformMainShell> {
  int _currentIndex = 0;

  late final MentorMatchingController _mentorController;
  late final CommunityController _communityController;
  late final SupportProgramsController _supportController;
  late final VentureTrackingController _ventureController;

  @override
  void initState() {
    super.initState();
    _mentorController = widget.mentorController ?? MentorMatchingController();
    _communityController = CommunityController();
    _supportController = SupportProgramsController();
    _ventureController = VentureTrackingController();
  }

  @override
  void dispose() {
    if (widget.mentorController == null) {
      _mentorController.dispose();
    }
    _communityController.dispose();
    _supportController.dispose();
    _ventureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      MentorMatchingView(
        controller: _mentorController,
        themeController: widget.themeController,
        authController: widget.authController,
      ),
      EntrepreneurCommunityView(
        controller: _communityController,
        themeController: widget.themeController,
      ),
      SupportProgramsView(
        controller: _supportController,
        themeController: widget.themeController,
      ),
      VentureTrackingView(
        controller: _ventureController,
        themeController: widget.themeController,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.people_outline_rounded),
            selectedIcon: Icon(Icons.people_rounded),
            label: 'Mentorluk',
          ),
          NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            selectedIcon: Icon(Icons.forum_rounded),
            label: 'Topluluk',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_outlined),
            selectedIcon: Icon(Icons.account_balance_rounded),
            label: 'Destekler',
          ),
          NavigationDestination(
            icon: Icon(Icons.rocket_launch_outlined),
            selectedIcon: Icon(Icons.rocket_launch_rounded),
            label: 'Süreç Takibi',
          ),
        ],
      ),
    );
  }
}
