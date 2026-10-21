import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod durum yönetimi kütüphanesini içe aktarır.
import 'package:go_router/go_router.dart'; // Flutter için bildirimsel URL tabanlı sayfa yönlendirme (routing) kütüphanesini içe aktarır.

import '../../features/auth/presentation/controllers/auth_controller.dart'; // Kullanıcı oturum durumunu yöneten controller'ı içe aktarır.
import '../../features/auth/presentation/screens/forgot_password_screen.dart'; // Şifremi unuttum sayfasını içe aktarır.
import '../../features/auth/presentation/screens/guest_login_screen.dart'; // Misafir girişi sayfasını içe aktarır.
import '../../features/auth/presentation/screens/login_screen.dart'; // Giriş yap sayfasını içe aktarır.
import '../../features/auth/presentation/screens/otp_verification_screen.dart'; // E-posta OTP kod doğrulama sayfasını içe aktarır.
import '../../features/auth/presentation/screens/register_screen.dart'; // Kayıt ol sayfasını içe aktarır.
import '../../features/auth/presentation/screens/reset_password_screen.dart'; // Yeni şifre belirleme sayfasını içe aktarır.
import '../../features/rooms/presentation/screens/rooms_screen.dart'; // Çalışma odaları listeleme sayfasını içe aktarır.
import '../../features/whiteboard/presentation/screens/whiteboard_screen.dart'; // Çizim tuvali (Whiteboard) sayfasını içe aktarır.

/// BoardConnect yönlendirme (Routing) yapılandırması
/// Provider, GoRouter nesnesini bağımlılık olarak uygulamanın geneline sunar.
final appRouterProvider = Provider<GoRouter>((ref) {
  // authControllerProvider'ı dinleyerek kullanıcının giriş yapıp yapmadığını anlık takip eder.
  final authState = ref.watch(authControllerProvider);

  // Uygulamanın GoRouter yapılandırma nesnesini döndürür.
  return GoRouter(
    initialLocation:
        '/login', // Uygulama ilk açıldığında varsayılan olarak gidilecek rota.
    // Kullanıcının rotalara erişim yetkisini kontrol eden ve gerekirse yönlendiren fonksiyon.
    redirect: (context, state) {
      final isLoading =
          authState.isLoading; // Oturum işlemi sürüyor mu kontrol eder.
      final hasUser =
          authState.value !=
          null; // Oturum açmış aktif bir kullanıcı var mı kontrol eder.
      // Mevcut gidilmek istenen sayfanın bir kimlik doğrulama sayfası olup olmadığını belirler.
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/guest-login' ||
          state.matchedLocation == '/otp-verification' ||
          state.matchedLocation == '/forgot-password' ||
          state.matchedLocation == '/reset-password';

      // Oturum durumu henüz yükleniyorsa yönlendirme yapmadan bekle (null döner).
      if (isLoading) return null;

      // Kullanıcı oturum açmışsa ve auth sayfalarındaysa odalara yönlendir
      if (hasUser && isAuthRoute) {
        return '/rooms'; // Zaten giriş yapmış kullanıcıyı doğrudan odalar sayfasına gönderir.
      }

      // Kullanıcı oturum açmamışsa ve korumalı rotalara erişmek istiyorsa login'e yönlendir
      if (!hasUser && !isAuthRoute) {
        return '/login'; // Giriş yapmamış kullanıcıyı güvenlik gereği giriş sayfasına geri gönderir.
      }

      return null; // Herhangi bir yönlendirme gerekmiyorsa rotanın olağan akışına devam etmesini sağlar.
    },
    // Uygulama rotalarının (sayfa adreslerinin) tanımlandığı liste.
    routes: [
      // '/login' adresi için LoginScreen widget'ını ekrana çizer.
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      // '/register' adresi için RegisterScreen widget'ını ekrana çizer.
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      // '/guest-login' adresi için GuestLoginScreen widget'ını ekrana çizer.
      GoRoute(
        path: '/guest-login',
        builder: (context, state) => const GuestLoginScreen(),
      ),
      // '/otp-verification' adresi için doğrulama ekranını ve gelen ekstra verileri aktarır.
      GoRoute(
        path: '/otp-verification',
        builder: (context, state) {
          // Sayfa geçişinde aktarılan ek verileri (e-posta vb.) Map olarak alır.
          final data = state.extra as Map<String, dynamic>? ?? {};
          return OtpVerificationScreen(
            registrationData: data,
          ); // Alınan veriyi ekrana iletir.
        },
      ),
      // '/forgot-password' adresi için ForgotPasswordScreen widget'ını ekrana çizer.
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      // '/reset-password' adresi için yeni şifre oluşturma ekranını hazırlar.
      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          // Önceki sayfadan gönderilen e-posta ve doğrulama kodunu alır.
          final data = state.extra as Map<String, dynamic>? ?? {};
          return ResetPasswordScreen(
            email:
                data['email'] ??
                '', // E-posta adresini sayfaya parametre olarak aktarır.
            code:
                data['code'] ?? '', // Doğrulanan 6 haneli kodu sayfaya iletir.
          );
        },
      ),
      // '/rooms' adresi için çalışma odalarının listelendiği RoomsScreen widget'ını ekrana çizer.
      GoRoute(path: '/rooms', builder: (context, state) => const RoomsScreen()),
      // '/whiteboard/:roomId' adresi dinamik oda kimliği parametresi alarak tuvali açar.
      GoRoute(
        path: '/whiteboard/:roomId',
        builder: (context, state) {
          // URL yolundaki dinamik :roomId parametresini okur, yoksa varsayılan değer verir.
          final roomId = state.pathParameters['roomId'] ?? 'room_demo_default';
          // Geçiş sırasında gönderilen opsiyonel oda detaylarını okur.
          final extra = state.extra as Map<String, dynamic>?;
          final roomName = extra?['roomName'] as String? ?? 'Beyaz Tahta Odası';
          // Beyaz tahta ekranını ilgili oda kimliği ve başlığıyla oluşturur.
          return WhiteboardScreen(roomId: roomId, roomName: roomName);
        },
      ),
    ],
  );
});
