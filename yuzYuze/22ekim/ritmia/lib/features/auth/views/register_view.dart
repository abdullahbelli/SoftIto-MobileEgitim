import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/ritmia_logo.dart';
import '../controllers/auth_controller.dart';

/// Kayıt Ekranı (Register View)
/// İsim, soyisim, e-posta, kullanıcı adı ve şifre ile yeni hesap oluşturur.
class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authController = context.read<AuthController>();
    final success = await authController.register(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      context.go('/habits');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authController = context.watch<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hesap Oluştur'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(
                  child: RitmiaLogo(size: 60),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Ritmine katılmak için ilk adımını at!',
                    style: TextStyle(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Ad ve Soyad
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _firstNameController,
                        label: 'Ad',
                        hint: 'Örn: Aylin',
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Ad giriniz';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        controller: _lastNameController,
                        label: 'Soyad',
                        hint: 'Örn: Yılmaz',
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Soyad giriniz';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // E-posta
                CustomTextField(
                  controller: _emailController,
                  label: 'E-posta',
                  hint: 'ornek@ritmia.app',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'E-posta giriniz';
                    if (!val.contains('@') || !val.contains('.')) {
                      return 'Geçerli bir e-posta adresi giriniz';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Kullanıcı Adı
                CustomTextField(
                  controller: _usernameController,
                  label: 'Kullanıcı Adı',
                  hint: '3-20 karakter (örn: aylin_ritm)',
                  prefixIcon: Icons.alternate_email_rounded,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Kullanıcı adı giriniz';
                    if (val.trim().length < 3 || val.trim().length > 20) {
                      return 'Kullanıcı adı 3-20 karakter arasında olmalı';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Şifre
                CustomTextField(
                  controller: _passwordController,
                  label: 'Şifre',
                  hint: 'En az 8 karakter',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (val) {
                    if (val == null || val.length < 8) {
                      return 'Şifre en az 8 karakter olmalıdır';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Şifre Tekrarı
                CustomTextField(
                  controller: _passwordConfirmController,
                  label: 'Şifre Tekrarı',
                  hint: 'Şifrenizi tekrar giriniz',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: _obscureConfirm,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirm = !_obscureConfirm;
                      });
                    },
                  ),
                  validator: (val) {
                    if (val != _passwordController.text) {
                      return 'Şifreler eşleşmiyor';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                if (authController.errorMessage != null) ...[
                  Text(
                    authController.errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                ],

                const SizedBox(height: 16),

                // Kayıt Ol Butonu
                CustomButton(
                  text: 'Kayıt Ol',
                  isLoading: authController.isLoading,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: 16),

                // Giriş Yap Linki
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Zaten bir hesabın var mı? ',
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Text(
                        'Giriş Yap',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
