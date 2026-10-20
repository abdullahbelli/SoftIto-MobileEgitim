// Flutter Material tasarım bileşenlerini içeri aktarıyoruz.
import 'package:flutter/material.dart';

// Sabitler, form doğrulayıcılar, ortak diyaloglar, logo ve veri kapsamını içeri aktarıyoruz.
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/rotiva_app_bar.dart';
import '../../../core/widgets/rotiva_logo.dart';
import '../../../core/widgets/rotiva_scope.dart';
import '../../admin/view/admin_shell_screen.dart';

/// Yönetici giriş ekranı (Müşteri girişinden ayrı özel arayüz).
/// Yöneticilerin araç CRUD ve filo istatistikleri paneline erişmesini sağlar.
class AdminLoginScreen extends StatefulWidget {
  // Statik const constructor tanımlıyoruz.
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  // Form doğrulama durumunu takip etmek için GlobalKey
  final _formKey = GlobalKey<FormState>();
  // Yönetici e-posta ve şifre denetleyicileri (Demo kolaylığı için hazır doldurulur)
  final _emailController = TextEditingController(text: 'admin@rotiva.com');
  final _passwordController = TextEditingController(text: 'admin');
  // Şifrenin gizli mi açık mı görüntüleneceğini tutan bayrak
  bool _obscurePassword = true;
  // Giriş butonuna tıklandığında dönen çark animasyonunu kontrol eden durum bayrağı
  bool _isLoading = false;

  @override
  void dispose() {
    // Bellek sızıntılarını önlemek için controller nesnelerini dispose ediyoruz.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Yönetici giriş işlemini yürüten asenkron metot
  Future<void> _handleAdminLogin() async {
    // Form alanlarının geçerliliğini denetliyoruz.
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final repository = RotivaScope.of(context).repository;
    // Yalnızca admin rolündeki kullanıcıların girişine izin veriyoruz.
    final success = await repository.login(
      _emailController.text,
      _passwordController.text,
      expectedRole: UserRole.admin,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      // Giriş başarılıysa bildirim gösterip yönetici kabuğuna (AdminShellScreen) yönlendiriyoruz.
      RotivaDialogs.showSnackBar(
        context,
        'Yönetici girişi başarılı. Panel açılıyor...',
        isSuccess: true,
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AdminShellScreen()),
        (route) => false, // Geri tuşuyla giriş ekranına dönüşü engelliyoruz.
      );
    } else {
      // Yetkisiz giriş uyarısı gösteriyoruz.
      RotivaDialogs.showSnackBar(
        context,
        'Yetkisiz giriş. Lütfen yönetici bilgilerinizi kontrol ediniz.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const RotivaAppBar(titleText: 'Yönetici Girişi'),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            // Büyük ekranlarda formun aşırı yayılmasını engelleyen BoxConstraints
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Rotiva Logo Bileşeni
                    const Center(child: RotivaLogo(size: 72)),
                    const SizedBox(height: 16),
                    Text(
                      'Yönetim Paneli Girişi',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Demo Uyarı Bandı (PROJECT.md Madde 48 gereği)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.amber.shade800,
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            color: Colors.amber.shade900,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'DEMO YÖNETİCİ: Bu alan eğitim amaçlıdır. Araç ekleme, düzenleme ve kiralama yönetimi simüle edilir.',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.amber.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Hızlı Doldurma Çipi (Eğitim testi kolaylığı sağlar)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ActionChip(
                        avatar: const Icon(Icons.flash_on, size: 16),
                        label: const Text(
                          'Demo Yöneticiyi Doldur (admin@rotiva.com)',
                        ),
                        onPressed: () {
                          setState(() {
                            _emailController.text = 'admin@rotiva.com';
                            _passwordController.text = 'admin';
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Yönetici E-posta Giriş Alanı
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Yönetici E-posta',
                        prefixIcon: Icon(Icons.admin_panel_settings_outlined),
                      ),
                      validator: RotivaValidators.validateEmail,
                    ),
                    const SizedBox(height: 16),

                    // Yönetici Şifre Giriş Alanı
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleAdminLogin(),
                      decoration: InputDecoration(
                        labelText: 'Yönetici Parolası',
                        prefixIcon: const Icon(Icons.password_outlined),
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
                      validator: RotivaValidators.validateRequired,
                    ),
                    const SizedBox(height: 24),

                    // Yönetim Paneline Giriş Butonu
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.secondary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _isLoading ? null : _handleAdminLogin,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Yönetim Paneline Giriş Yap'),
                    ),
                    const SizedBox(height: 16),

                    // Müşteri Ekranına Geri Dön Butonu
                    TextButton.icon(
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Müşteri Ekranına Dön'),
                      onPressed: () => Navigator.of(context).pop(),
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
