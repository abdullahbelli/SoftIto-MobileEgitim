import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_logo.dart';
import '../controllers/auth_controller.dart';

/// Giriş Ekranı (Login)
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'demo@boardconnect.com');
  final _passwordController = TextEditingController(text: 'Password123*');
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .login(_emailController.text.trim(), _passwordController.text);
      if (mounted) {
        context.go('/rooms');
      }
    } catch (e) {
      if (mounted) {
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
        setState(() => _isLoading = false);
      }
    }
  }

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
          'Google ile Giriş özelliği gerçek Supabase Auth entegrasyonu aşamasında aktif olacaktır.\n\n'
          'Şimdilik kayıtlı demo hesabını veya misafir girişini kullanarak uygulamayı test edebilirsiniz.\n\n'
          'Demo E-posta: demo@boardconnect.com\n'
          'Demo Şifre: Password123*',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Anladım'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
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
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo & Başlık
                        const Center(
                          child: AppLogo(size: 48, showTagline: true),
                        ),
                        const SizedBox(height: 32),

                        Text(
                          'Hoş Geldiniz',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tuvale ve ortak odalarınıza erişmek için giriş yapın.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),

                        // E-posta Alanı
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'E-posta Adresi',
                            prefixIcon: Icon(Icons.mail_outline_rounded),
                          ),
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

                        // Şifre Alanı
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
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
                            onPressed: () => context.push('/forgot-password'),
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

                        // Ayırıcı çizgi
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
                          onPressed: () => context.push('/guest-login'),
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

                        // Kayıt Ol Bağlantısı
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
                            GestureDetector(
                              onTap: () => context.push('/register'),
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
