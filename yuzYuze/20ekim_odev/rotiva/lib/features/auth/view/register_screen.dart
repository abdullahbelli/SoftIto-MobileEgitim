import 'package:flutter/material.dart';

import '../../../core/constants/demo_texts.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/rotiva_app_bar.dart';
import '../../../core/widgets/rotiva_logo.dart';
import '../../../core/widgets/rotiva_scope.dart';
import '../../home/view/customer_shell_screen.dart';
import 'customer_login_screen.dart';

/// Yeni müşteri kayıt ekranı.
/// KVKK ve Açık Rıza onaylarını diyaloglarla inceleme ve doğrulama zorunluluğu içerir.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _kvkkAccepted = false;
  bool _consentAccepted = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showKvkkDialog() {
    RotivaDialogs.showScrollableContentDialog(
      context: context,
      title: DemoTexts.kvkkTitle,
      content: DemoTexts.kvkkContent,
    );
  }

  void _showConsentDialog() {
    RotivaDialogs.showScrollableContentDialog(
      context: context,
      title: DemoTexts.acikRizaTitle,
      content: DemoTexts.acikRizaContent,
    );
  }

  Future<void> _handleRegister() async {
    // 1. Form doğrulaması
    if (!_formKey.currentState!.validate()) return;

    // 2. Zorunlu onay kontrolleri
    if (!_kvkkAccepted || !_consentAccepted) {
      RotivaDialogs.showSnackBar(
        context,
        'Lütfen kayıt işlemini tamamlamak için KVKK ve Açık Rıza metinlerini onaylayınız.',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    final repository = RotivaScope.of(context).repository;
    final success = await repository.register(
      fullName: _fullNameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      RotivaDialogs.showSnackBar(
        context,
        'Kaydınız başarıyla oluşturuldu! Hoş geldiniz.',
        isSuccess: true,
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const CustomerShellScreen()),
        (route) => false,
      );
    } else {
      RotivaDialogs.showSnackBar(
        context,
        'Bu e-posta adresi ile zaten bir hesap bulunmaktadır.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const RotivaAppBar(titleText: 'Yeni Müşteri Kaydı'),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: RotivaLogo(size: 64)),
                    const SizedBox(height: 12),
                    Text(
                      'Rotiva Ailesine Katılın',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Dakikalar içinde hesabınızı oluşturun, güvenle kiralayın',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Ad Soyad
                    TextFormField(
                      controller: _fullNameController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Ad Soyad',
                        hintText: 'Adınız ve Soyadınız',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (v) =>
                          RotivaValidators.validateRequired(v, 'Ad Soyad'),
                    ),
                    const SizedBox(height: 14),

                    // E-posta
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'E-posta Adresi',
                        hintText: 'ornek@rotiva.com',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: RotivaValidators.validateEmail,
                    ),
                    const SizedBox(height: 14),

                    // Telefon
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Telefon Numarası',
                        hintText: '0532 123 45 67',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: RotivaValidators.validatePhone,
                    ),
                    const SizedBox(height: 14),

                    // Şifre
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Şifre',
                        hintText: 'En az 6 karakter',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(
                              () => _obscurePassword = !_obscurePassword,
                            );
                          },
                        ),
                      ),
                      validator: (v) => RotivaValidators.validatePassword(v, 6),
                    ),
                    const SizedBox(height: 14),

                    // Şifre Tekrar
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: 'Şifre Tekrarı',
                        hintText: 'Şifrenizi yeniden giriniz',
                        prefixIcon: const Icon(Icons.lock_reset_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(
                              () => _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                            );
                          },
                        ),
                      ),
                      validator: (v) =>
                          RotivaValidators.validateConfirmPassword(
                            v,
                            _passwordController.text,
                          ),
                    ),
                    const SizedBox(height: 18),

                    // KVKK Aydınlatma Onay Kutusu
                    Card(
                      elevation: 0,
                      color: theme.colorScheme.surfaceContainerHighest
                          .withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: _kvkkAccepted
                              ? theme.colorScheme.primary
                              : Colors.transparent,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: _kvkkAccepted,
                              onChanged: (val) {
                                setState(() => _kvkkAccepted = val ?? false);
                              },
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(
                                    () => _kvkkAccepted = !_kvkkAccepted,
                                  );
                                },
                                child: const Text(
                                  'KVKK Aydınlatma Metnini okudum ve anladım.',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: _showKvkkDialog,
                              child: const Text('İncele'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Açık Rıza Onay Kutusu
                    Card(
                      elevation: 0,
                      color: theme.colorScheme.surfaceContainerHighest
                          .withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: _consentAccepted
                              ? theme.colorScheme.primary
                              : Colors.transparent,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: _consentAccepted,
                              onChanged: (val) {
                                setState(() => _consentAccepted = val ?? false);
                              },
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(
                                    () => _consentAccepted = !_consentAccepted,
                                  );
                                },
                                child: const Text(
                                  'Açık Rıza Metnini kabul ediyorum (Eğitim Demosu).',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: _showConsentDialog,
                              child: const Text('İncele'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Kayıt Ol Butonu
                    FilledButton(
                      onPressed:
                          (_isLoading || !_kvkkAccepted || !_consentAccepted)
                          ? null
                          : _handleRegister,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Kayıt Ol ve Giriş Yap'),
                    ),
                    const SizedBox(height: 16),

                    // Zaten hesabı olanlar için giriş linki
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Zaten bir hesabınız var mı? ',
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const CustomerLoginScreen(),
                              ),
                            );
                          },
                          child: const Text('Giriş Yap'),
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
    );
  }
}
