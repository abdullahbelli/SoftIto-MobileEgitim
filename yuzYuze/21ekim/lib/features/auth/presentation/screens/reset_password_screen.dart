import 'package:flutter/material.dart'; // Flutter Material Design kütüphanesini içe aktarır.
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod durum yönetimi ConsumerStatefulWidget desteğini sağlar.
import 'package:go_router/go_router.dart'; // Sayfa yönlendirme (context.go) kütüphanesini içe aktarır.

import '../../../../core/widgets/app_logo.dart'; // BoardConnect logosu bileşeni.
import '../controllers/auth_controller.dart'; // Kimlik doğrulama denetleyicisi.

/// Yeni Şifre Oluşturma Ekranı
/// Kullanıcı doğrulama kodunu girdikten sonra yeni şifresini ve şifre tekrarını bu ekranda belirler.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  // Şifresi sıfırlanacak hedef e-posta adresi.
  final String email;
  // Önceki sayfada başarıyla doğrulanan 6 haneli OTP kodu.
  final String code;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.code,
  });

  @override // Ekran durum sınıfını üretir.
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

/// Yeni şifre ekranının durum yönetimi sınıfı
class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>(); // Form doğrulama anahtarı.
  final _passwordController =
      TextEditingController(); // Yeni şifre metin denetleyicisi.
  final _confirmPasswordController =
      TextEditingController(); // Yeni şifre tekrarı metin denetleyicisi.
  bool _obscurePassword =
      true; // Şifrenin gizli mi açık mı olduğunu takip eder.
  bool _isLoading = false; // İşlem sürerken çark gösteren yükleme bayrağı.

  @override // Ekrandan çıkıldığında denetleyicileri serbest bırakır.
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Şifreyi Onayla butonuna basıldığında çalışan şifre sıfırlama fonksiyonu
  Future<void> _handleReset() async {
    // Şifre uzunluğu ve şifrelerin eşleşmesi kurallarını denetler.
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true); // Yüklenme durumunu başlatır.
    try {
      // AuthController üzerinden yeni şifreyi kaydeder.
      await ref
          .read(authControllerProvider.notifier)
          .resetPassword(
            email: widget.email,
            code: widget.code,
            newPassword: _passwordController.text,
          );

      if (mounted) {
        // Başarı mesajı gösterir.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Şifreniz başarıyla güncellendi! Yeni şifrenizle giriş yapabilirsiniz.',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Kullanıcıyı yeni şifresiyle giriş yapabilmesi için doğrudan giriş sayfasına yönlendirir.
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false); // Yüklenme durumunu kapatır.
      }
    }
  }

  @override // Ekran arayüzünü oluşturur.
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Temayı okur.
    final isDark = theme.brightness == Brightness.dark; // Koyu mod kontrolü.

    return Scaffold(
      appBar: AppBar(title: const AppLogo(size: 30), centerTitle: true),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 440,
              ), // Kart genişliğini sınırlar.
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
                        // Anahtar ikonu yuvarlak kutusu
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.15,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.vpn_key_rounded,
                            size: 30,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Başlık
                        Text(
                          'Yeni Şifre Belirleyin',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),

                        // Açıklama
                        Text(
                          'Hesabınız için güçlü ve benzersiz yeni bir şifre girin.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),

                        // Yeni Şifre Giriş Alanı
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword, // Şifreyi maskele.
                          decoration: InputDecoration(
                            labelText: 'Yeni Şifre',
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
                              return 'Lütfen yeni bir şifre girin.';
                            }
                            if (val.length < 6) {
                              return 'Şifre en az 6 karakter olmalıdır.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Yeni Şifre Tekrar Giriş Alanı
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscurePassword,
                          decoration: const InputDecoration(
                            labelText: 'Yeni Şifre (Tekrar)',
                            prefixIcon: Icon(Icons.lock_clock_outlined),
                          ),
                          // İki şifrenin birbirini tutup tutmadığını kontrol eden doğrulayıcı.
                          validator: (val) {
                            if (val != _passwordController.text) {
                              return 'Girdiğiniz şifreler eşleşmiyor.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Şifre kuralları bilgilendirme kutucuğu
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Şifre Kuralları:',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '• En az 6 karakter uzunluğunda olmalıdır.\n'
                                '• Güvenlik için rakam ve özel işaret içermesi önerilir.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? Colors.white60
                                      : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Şifreyi Onayla Butonu
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleReset,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.black,
                                  ),
                                )
                              : const Text('Şifreyi Onayla'),
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
