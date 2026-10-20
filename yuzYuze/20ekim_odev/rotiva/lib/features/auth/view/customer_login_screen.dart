import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/rotiva_app_bar.dart';
import '../../../core/widgets/rotiva_logo.dart';
import '../../../core/widgets/rotiva_scope.dart';
import '../../home/view/customer_shell_screen.dart';
import 'register_screen.dart';

/// Müşteri giriş ekranı.
class CustomerLoginScreen extends StatefulWidget {
  const CustomerLoginScreen({super.key});

  @override
  State<CustomerLoginScreen> createState() => _CustomerLoginScreenState();
}

class _CustomerLoginScreenState extends State<CustomerLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _fillDemoAccount(String email) {
    setState(() {
      _emailController.text = email;
      _passwordController.text = '123456';
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final repository = RotivaScope.of(context).repository;
    final success = await repository.login(
      _emailController.text,
      _passwordController.text,
      expectedRole: UserRole.customer,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      RotivaDialogs.showSnackBar(
        context,
        'Giriş başarılı! Hoş geldiniz, ${repository.currentUser?.fullName}',
        isSuccess: true,
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const CustomerShellScreen()),
        (route) => false,
      );
    } else {
      RotivaDialogs.showSnackBar(
        context,
        'Giriş başarısız. E-posta veya şifre hatalı.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const RotivaAppBar(titleText: 'Müşteri Girişi'),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: RotivaLogo(size: 72)),
                    const SizedBox(height: 16),
                    Text(
                      'Hesabınıza Giriş Yapın',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Araç kiralama ve geçmiş işlemlerinizi takip edin',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Demo Hesap Hızlı Seçim Çipleri
                    Text(
                      'Hızlı Demo Seçimi:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        ActionChip(
                          avatar: const Icon(Icons.person, size: 16),
                          label: const Text('Ahmet (31 yaş)'),
                          onPressed: () => _fillDemoAccount('ahmet@rotiva.com'),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.person, size: 16),
                          label: const Text('Ayşe (28 yaş)'),
                          onPressed: () => _fillDemoAccount('ayse@rotiva.com'),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.person, size: 16),
                          label: const Text('Can (22 yaş)'),
                          onPressed: () => _fillDemoAccount('can@rotiva.com'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // E-posta Alanı
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
                    const SizedBox(height: 16),

                    // Şifre Alanı
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleLogin(),
                      decoration: InputDecoration(
                        labelText: 'Şifre',
                        hintText: '••••••',
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
                    const SizedBox(height: 24),

                    // Giriş Butonu
                    FilledButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Giriş Yap'),
                    ),
                    const SizedBox(height: 16),

                    // Kayıt Ol Yönlendirmesi
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Henüz hesabınız yok mu? ',
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: const Text('Kayıt Ol'),
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
