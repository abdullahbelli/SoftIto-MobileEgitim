import 'package:flutter/material.dart'; // Flutter Material arayüz bileşenlerini içe aktarır.
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod durum yönetimi ConsumerStatefulWidget desteğini sağlar.
import 'package:go_router/go_router.dart'; // go_router sayfa yönlendirmelerini (context.go, context.push) sağlar.

import '../../../../core/widgets/app_logo.dart'; // BoardConnect logosu bileşeni.
import '../controllers/auth_controller.dart'; // Kullanıcı oturum yönetimini sağlayan controller.

/// Giriş Ekranı (Login)
/// Kullanıcıların e-posta ve şifreyle sisteme giriş yaptığı, misafir veya kayıt ekranlarına yönlendiği ana ekrandır.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override // Widget'ın durum nesnesini üretir.
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

/// Giriş ekranı durum yönetimi sınıfı
class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Form alanlarının topluca doğrulanmasını sağlayan Form anahtarı.
  final _formKey = GlobalKey<FormState>();
  // Kolay test yapabilmek için varsayılan demo e-posta atanmış metin denetleyicisi.
  final _emailController = TextEditingController(text: 'demo@boardconnect.com');
  // Varsayılan demo şifre atanmış metin denetleyicisi.
  final _passwordController = TextEditingController(text: 'Password123*');
  // Şifrenin gizli (yıldızlı) mi yoksa görünür mü olduğunu denetleyen bayrak.
  bool _obscurePassword = true;
  // Giriş isteği sunucuya/depoya gönderildiğinde çark gösteren yükleme bayrağı.
  bool _isLoading = false;

  @override // Ekrandan çıkıldığında denetleyicileri bellekten temizler.
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Giriş Yap butonuna tıklandığında çalışan oturum açma fonksiyonu
  Future<void> _handleLogin() async {
    // Form alanlarının kurallara uygunluğunu kontrol eder, hata varsa durur.
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true); // Yüklenme durumunu başlatır.
    try {
      // Riverpod AuthController üzerinden giriş işlemini çağırır.
      await ref
          .read(authControllerProvider.notifier)
          .login(_emailController.text.trim(), _passwordController.text);
      if (mounted) {
        context.go(
          '/rooms',
        ); // Giriş başarılıysa kullanıcıyı odalar listesine yönlendirir.
      }
    } catch (e) {
      if (mounted) {
        // Hata durumunda (yanlış şifre vb.) kullanıcıya uyarı SnackBar'ı gösterir.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false); // Yüklenme durumunu kapatır.
      }
    }
  }

  /// Google ile Giriş butonuna tıklandığında bilgilendirici bir diyalog penceresi açar.
  void _showGoogleNotice() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.amber), // Bilgi ikonu.
            SizedBox(width: 8),
            Text('Supabase Entegrasyonu'),
          ],
        ),
        content: const Text(
          'Google ile Giriş özelliği gerçek Supabase Auth entegrasyonu aşamasında aktif olacaktır.\n\n'
          'Şimdilik kayıtlı demo hesabını veya misafir girişini kullanarak uygulamayı test edebilirsiniz.\n\n'
          'Demo E-posta: demo@boardconnect.com\n'
          'Demo Şifre: Password123*',
        ),
        actions: [
          // Diyaloğu kapatma butonu.
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Anladım'),
          ),
        ],
      ),
    );
  }

  @override // Arayüz widget ağacını oluşturur.
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Aktif temayı alır.
    final isDark = theme.brightness == Brightness.dark; // Koyu mod kontrolü.

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            // Ekran boyutuna göre dikeyde kaydırılabilir alan.
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 440,
              ), // Kart genişliğini 440 pikselle sınırlar.
              child: Card(
                elevation: isDark ? 2 : 0,
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.grey.withValues(alpha: 0.2),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 40,
                  ),
                  child: Form(
                    key: _formKey, // Form doğrulama anahtarını bağlar.
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo & Tanıtım sloganı
                        const Center(
                          child: AppLogo(size: 48, showTagline: true),
                        ),
                        const SizedBox(height: 32),

                        // Hoş geldiniz başlığı
                        Text(
                          'Hoş Geldiniz',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        // Alt açıklama metni
                        Text(
                          'Tuvale ve ortak odalarınıza erişmek için giriş yapın.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),

                        // E-posta Metin Giriş Alanı
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'E-posta Adresi',
                            prefixIcon: Icon(Icons.mail_outline_rounded),
                          ),
                          // E-posta format geçerlilik denetleyicisi.
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Lütfen e-posta adresinizi girin.';
                            }
                            if (!value.contains('@') || !value.contains('.')) {
                              return 'Geçerli bir e-posta adresi girin.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Şifre Giriş Alanı
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword, // Şifreyi gizleme/gösterme durumu.
                          decoration: InputDecoration(
                            labelText: 'Şifre',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            // Şifreyi görünür kılan göz ikonu butonu.
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword; // Görünürlüğü tersine çevirir.
                                });
                              },
                            ),
                          ),
                          // En az 6 karakterlik şifre uzunluğu denetimi.
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen şifrenizi girin.';
                            }
                            if (value.length < 6) {
                              return 'Şifre en az 6 karakter olmalıdır.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),

                        // Şifremi Unuttum Bağlantısı
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => context.push(
                              '/forgot-password',
                            ), // Şifremi unuttum sayfasına geçer.
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Şifremi Unuttum',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Giriş Yap Butonu
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.black,
                                  ),
                                )
                              : const Text('Giriş Yap'),
                        ),
                        const SizedBox(height: 14),

                        // Google ile Giriş Butonu
                        OutlinedButton.icon(
                          onPressed: _showGoogleNotice,
                          icon: const Icon(
                            Icons.g_mobiledata_rounded,
                            size: 26,
                          ),
                          label: const Text('Google ile Devam Et'),
                        ),
                        const SizedBox(height: 20),

                        // "veya" Yazılı Çizgi Ayırıcı
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.grey.withValues(alpha: 0.3),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                'veya',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.black45,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.grey.withValues(alpha: 0.3),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Misafir Girişi Butonu
                        OutlinedButton.icon(
                          onPressed: () => context.push(
                            '/guest-login',
                          ), // Misafir giriş sayfasına gider.
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.5,
                              ),
                              width: 1.5,
                            ),
                          ),
                          icon: Icon(
                            Icons.person_outline_rounded,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          label: const Text('Misafir Olarak Odaya Katıl'),
                        ),
                        const SizedBox(height: 28),

                        // Kayıt Ol Bağlantı Satırı
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Hesabınız yok mu?',
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                            const SizedBox(width: 6),
                            // Tıklanabilir metin için GestureDetector kullanılır.
                            GestureDetector(
                              onTap: () => context.push(
                                '/register',
                              ), // Kayıt ol ekranına geçer.
                              child: Text(
                                'Kayıt Ol',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
