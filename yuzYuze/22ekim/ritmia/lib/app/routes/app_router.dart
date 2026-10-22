import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../../features/auth/views/login_view.dart';
import '../../features/auth/views/register_view.dart';
import '../../features/calendar/views/calendar_view.dart';
import '../../features/habits/views/my_habits_view.dart';
import '../../features/leaderboard/views/leaderboard_view.dart';
import '../../features/profile/views/profile_view.dart';

/// Ritmia yönlendirme ve alt gezinme çubuğu (ShellRoute) konfigürasyonu.
abstract final class AppRouter {
  static GoRouter createRouter(AuthController authController) {
    return GoRouter(
      initialLocation: authController.isAuthenticated ? '/habits' : '/login',
      refreshListenable: authController,
      redirect: (context, state) {
        final isLoggedIn = authController.isAuthenticated;
        final isAuthRoute = state.uri.toString() == '/login' || state.uri.toString() == '/register';

        if (!isLoggedIn && !isAuthRoute) {
          return '/login';
        }
        if (isLoggedIn && isAuthRoute) {
          return '/habits';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginView(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterView(),
        ),
        ShellRoute(
          builder: (context, state, child) {
            return _ScaffoldWithNavBar(child: child);
          },
          routes: [
            GoRoute(
              path: '/habits',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: MyHabitsView(),
              ),
            ),
            GoRoute(
              path: '/calendar',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: CalendarView(),
              ),
            ),
            GoRoute(
              path: '/leaderboard',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: LeaderboardView(),
              ),
            ),
            GoRoute(
              path: '/profile',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ProfileView(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 4 sekmeli alt navigasyon çubuğu barındıran iskelet widget
class _ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;

  const _ScaffoldWithNavBar({required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/habits')) return 0;
    if (location.startsWith('/calendar')) return 1;
    if (location.startsWith('/leaderboard')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/habits');
        break;
      case 1:
        context.go('/calendar');
        break;
      case 2:
        context.go('/leaderboard');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (idx) => _onItemTapped(idx, context),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.track_changes_outlined),
            selectedIcon: Icon(Icons.track_changes_rounded),
            label: 'Alışkanlıklar',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'Takvim',
          ),
          NavigationDestination(
            icon: Icon(Icons.leaderboard_outlined),
            selectedIcon: Icon(Icons.leaderboard_rounded),
            label: 'Liderlik',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
