import 'package:flutter/material.dart'; // Flutter Material tasarım kütüphanesini içe aktarır.
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod durum yönetimi ConsumerStatefulWidget desteğini sağlar.
import 'package:go_router/go_router.dart'; // go_router sayfa geçişlerini (context.push, context.pop) sağlar.

import '../../../../core/widgets/app_logo.dart'; // BoardConnect logosu bileşenini içe aktarır.
import '../controllers/auth_controller.dart'; // Kimlik doğrulama controller'ını içe aktarır.

/// Kayıt Ol Ekranı (Register)
/// Kullanıcıdan isim, soyisim, kullanıcı adı, e-posta ve şifre alarak hesap açma akışını başlatır.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override // Ekranın durum sınıfını üretir.
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

/// Kayıt ekranının durum yönetimi sınıfı
class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  // Formun doğruluğunu denetleyen anahtar.
  final _formKey = GlobalKey<FormState>();
  // Kullanıcının adını tutan metin denetleyicisi.
  final _firstNameController = TextEditingController();
  // Kullanıcının soyadını tutan metin denetleyicisi.
  final _lastNameController = TextEditingController();
  // Kullanıcı rumuzunu tutan metin denetleyicisi.
  final _usernameController = TextEditingController();
  // E-posta adresini tutan metin denetleyicisi.
  final _emailController = TextEditingController();
  // Şifreyi tutan metin denetleyicisi.
  final _passwordController = TextEditingController();
  // Şifrenin gizli mi görünür mü olduğunu takip eden bayrak.
  bool _obscurePassword = true;
  // Kayıt işlemi sürerken butonları kilitleyip çark gösteren yükleme bayrağı.
  bool _isLoading = false;

  @override // Bellek sızıntılarını önlemek için tüm denetleyicileri yok eder (dispose).
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Kayıt Ol butonuna basıldığında çalışan fonksiyon
  Future<void> _handleRegister() async {
    // Form alanları kurallara uygun değilse akışı durdurur.
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true); // Yüklenme durumunu başlatır.
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final username = _usernameController.text.trim();
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();

      // Proje akışına göre: E-posta ile kayıt olunduğunda önce 90 saniyelik OTP doğrulama kodu gönderilir.
      await ref
          .read(authControllerProvider.notifier)
          .sendVerificationOtp(email);

      if (mounted) {
        // Doğrulama sayfasına kayıt formundaki verileri 'extra' parametresi olarak aktararak yönlendirir.
        context.push(
          '/otp-verification',
          extra: {
            'email': email,
            'password': password,
            'username': username,
            'firstName': firstName,
            'lastName': lastName,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        // Hata durumunda (zaten kayıtlı e-posta vb.) uyarı SnackBar'ı gösterir.
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

  /// Google ile kayıt butonuna basıldığında açılan bilgilendirme penceresi.
  void _showGoogleNotice() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.amber),
            SizedBox(width: 8),
            Text('Supabase Entegrasyonu'),
          ],
        ),
        content: const Text(
          'Google ile Kayıt özelliği Supabase Auth entegrasyonu tamamlandığında devreye girecektir.\n\n'
          'Formu doldurarak hemen demo hesabı oluşturabilirsiniz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  @override // Arayüzün çizildiği build fonksiyonu.
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Temayı okur.
    final isDark = theme.brightness == Brightness.dark; // Koyu mod kontrolü.

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(), // Giriş ekranına geri döner.
        ),
        title: const AppLogo(size: 32),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 480,
              ), // Maksimum genişlik sınırı.
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
                    vertical: 36,
                  ),
                  child: Form(
                    key: _formKey, // Form doğrulaması için form anahtarını bağlar.
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Başlık
                        Text(
                          'Yeni Hesap Oluştur',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        // Alt başlık
                        Text(
                          'Takımınızla hemen ortak tuvalde buluşun.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),

                        // İsim ve Soyisim Alanları (Yan Yana Row İçinde)
                        Row(
                          children: [
                            // İsim alanı: Expanded ile yatay alanı eşit paylaşır.
                            Expanded(
                              child: TextFormField(
                                controller: _firstNameController,
                                decoration: const InputDecoration(
                                  labelText: 'İsim',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                                validator: (val) =>
                                    val == null || val.trim().isEmpty
                                    ? 'İsim girin'
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Soyisim alanı: Expanded ile diğer yarıyı paylaşır.
                            Expanded(
                              child: TextFormField(
                                controller: _lastNameController,
                                decoration: const InputDecoration(
                                  labelText: 'Soyisim',
                                ),
                                validator: (val) =>
                                    val == null || val.trim().isEmpty
                                    ? 'Soyisim girin'
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Kullanıcı Adı Giriş Alanı
                        TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Kullanıcı Adı',
                            prefixIcon: Icon(Icons.alternate_email_rounded),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Kullanıcı adı girin';
                            }
                            if (val.trim().length < 3) {
                              return 'En az 3 karakter olmalıdır';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // E-posta Giriş Alanı
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'E-posta Adresi',
                            prefixIcon: Icon(Icons.mail_outline_rounded),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'E-posta adresinizi girin';
                            }
                            if (!val.contains('@') || !val.contains('.')) {
                              return 'Geçerli bir e-posta girin';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Şifre Giriş Alanı
                        TextFormField(
                          controller: _passwordController,
                          obscureText:
                              _obscurePassword, // Şifreyi gizle/göster.
                          decoration: InputDecoration(
                            labelText: 'Şifre',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Şifre girin';
                            }
                            if (val.length < 6) {
                              return 'Şifre en az 6 karakter olmalıdır';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Kayıt Ol Butonu
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleRegister,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.black,
                                  ),
                                )
                              : const Text('Kayıt Ol'),
                        ),
                        const SizedBox(height: 14),

                        // Google ile Kayıt Butonu
                        OutlinedButton.icon(
                          onPressed: _showGoogleNotice,
                          icon: const Icon(
                            Icons.g_mobiledata_rounded,
                            size: 26,
                          ),
                          label: const Text('Google ile Devam Et'),
                        ),
                        const SizedBox(height: 24),

                        // Zaten hesabınız var mı? Giriş Yap satırı
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Zaten bir hesabınız var mı?',
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () =>
                                  context.pop(), // Giriş ekranına geri döner.
                              child: Text(
                                'Giriş Yap',
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
