import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/guest_login_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/rooms/presentation/screens/rooms_screen.dart';
import '../../features/whiteboard/presentation/screens/whiteboard_screen.dart';

/// BoardConnect yönlendirme (Routing) yapılandırması
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      final hasUser = authState.value != null;
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/guest-login' ||
          state.matchedLocation == '/otp-verification' ||
          state.matchedLocation == '/forgot-password' ||
          state.matchedLocation == '/reset-password';

      if (isLoading) return null;

      // Kullanıcı oturum açmışsa ve auth sayfalarındaysa odalara yönlendir
      if (hasUser && isAuthRoute) {
        return '/rooms';
      }

      // Kullanıcı oturum açmamışsa ve korumalı rotalara erişmek istiyorsa login'e yönlendir
      if (!hasUser && !isAuthRoute) {
        return '/login';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/guest-login',
        builder: (context, state) => const GuestLoginScreen(),
      ),
      GoRoute(
        path: '/otp-verification',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          return OtpVerificationScreen(registrationData: data);
        },
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          return ResetPasswordScreen(
            email: data['email'] ?? '',
            code: data['code'] ?? '',
          );
        },
      ),
      GoRoute(path: '/rooms', builder: (context, state) => const RoomsScreen()),
      GoRoute(
        path: '/whiteboard/:roomId',
        builder: (context, state) {
          final roomId = state.pathParameters['roomId'] ?? 'room_demo_default';
          final extra = state.extra as Map<String, dynamic>?;
          final roomName = extra?['roomName'] as String? ?? 'Beyaz Tahta Odası';
          return WhiteboardScreen(roomId: roomId, roomName: roomName);
        },
      ),
    ],
  );
});
