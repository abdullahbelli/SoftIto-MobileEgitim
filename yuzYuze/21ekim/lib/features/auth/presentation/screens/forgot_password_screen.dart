import 'dart:async'; // Zamanlayıcı (Timer) işlemleri için Dart zaman kütüphanesini içe aktarır.

import 'package:flutter/material.dart'; // Flutter Material Design arayüz bileşenlerini içe aktarır.
import 'package:flutter/services.dart'; // Klavyeye kısıtlama koymak için (FilteringTextInputFormatter) içe aktarır.
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod durum yönetimi ConsumerStatefulWidget desteğini sağlar.
import 'package:go_router/go_router.dart'; // Sayfalar arası geçiş ve geri dönme (context.pop, context.push) için içe aktarır.

import '../../../../core/config/app_constants.dart'; // Uygulama geneli sabitleri (OTP süresi vb.) içe aktarır.
import '../../../../core/widgets/app_logo.dart'; // Uygulama logosu bileşenini içe aktarır.
import '../controllers/auth_controller.dart'; // Kimlik doğrulama controller'ını içe aktarır.

/// Şifremi Unuttum Ekranı
/// 'ConsumerStatefulWidget', Riverpod sağlayıcılarına erişebilen ve kendi yerel durumunu (state) tutabilen bir widget türüdür.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override // Widget'a ait durum nesnesini üretir.
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

/// Şifremi unuttum ekranının durum yönetimi sınıfı
class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController =
      TextEditingController(); // E-posta metin giriş kutusu denetleyicisi.
  final _codeController =
      TextEditingController(); // 6 haneli kod metin giriş kutusu denetleyicisi.
  bool _codeSent =
      false; // Kodun e-postaya gönderilip gönderilmediğini takip eden bayrak.
  Timer? _timer; // 90 saniyelik geri sayımı çalıştıran periyodik zamanlayıcı.
  int _remainingSeconds =
      AppConstants.otpDurationSeconds; // Kalan saniye sayacı (90 saniye).
  bool _isLoading = false; // Arka planda istek sürerken butonları pasifleştiren ve çark döndüren bayrak.

  @override // Widget bellekten silindiğinde çalışan temizlik metodu (Lifecycle: dispose).
  void dispose() {
    _timer?.cancel(); // Aktif zamanlayıcı varsa bellek sızıntısını önlemek için durdurur.
    _emailController.dispose(); // Metin denetleyicisini serbest bırakır.
    _codeController.dispose(); // Kod denetleyicisini serbest bırakır.
    super.dispose(); // Üst sınıfın dispose metodunu çağırır.
  }

  // 90 saniyelik geri sayım sayacını başlatan yardımcı metot.
  void _startCountdown() {
    _timer?.cancel(); // Varsa önceki zamanlayıcıyı iptal eder.
    setState(() {
      _remainingSeconds =
          AppConstants.otpDurationSeconds; // Süreyi 90 saniyeye sıfırlar.
    });
    // Her 1 saniyede bir tetiklenen periyodik zamanlayıcı başlatır.
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted)
        return; // Widget ekrandan kaldırıldıysa işlem yapmaz (hata önleme).
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--; // Her saniyede sayacı 1 azaltır ve arayüzü günceller.
        });
      } else {
        timer.cancel(); // Süre sıfıra ulaştığında sayacı durdurur.
      }
    });
  }

  // Kalan süreyi 'dakika:saniye' (örneğin 01:30) biçiminde metne dönüştüren getter.
  String get _formattedTime {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(
      2,
      '0',
    ); // Tam bölme ile dakikayı alır ve 2 basamağa tamamlar.
    final seconds = (_remainingSeconds % 60).toString().padLeft(
      2,
      '0',
    ); // Mod alma ile kalan saniyeyi alır ve 2 basamağa tamamlar.
    return '$minutes:$seconds';
  }

  // E-postaya 6 haneli kod gönderme butonuna tıklandığında çalışan fonksiyon.
  Future<void> _handleSendCode() async {
    final email = _emailController.text
        .trim(); // E-posta metnini alır ve boşlukları kırpar.
    // Temel e-posta biçim kontrolü.
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen geçerli bir e-posta adresi girin.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true); // Yükleme durumunu başlatır.
    try {
      // Riverpod üzerinden authController'a kod gönderme isteği atar.
      await ref
          .read(authControllerProvider.notifier)
          .sendPasswordResetOtp(email);
      setState(() {
        _codeSent = true; // Kod gönderildi durumuna geçirerek kod giriş alanını gösterir.
      });
      _startCountdown(); // 90 saniyelik sayacı başlatır.
      if (mounted) {
        // Kullanıcıya kodun gönderildiğini bildiren bilgilendirme çubuğu (SnackBar) gösterir.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '6 haneli şifre sıfırlama kodu gönderildi (Demo: 123456).',
            ),
            behavior: SnackBarBehavior
                .floating, // Ekranın altında yüzen modern bildirim.
          ),
        );
      }
    } catch (e) {
      // Hata oluşursa kullanıcıya kırmızı bildirimle iletir.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      // İşlem başarılı da olsa hatalı da olsa yükleniyor durumunu kapatır.
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Girilen 6 haneli kodu doğrulayan ve yeni şifre ekranına yönlendiren fonksiyon.
  Future<void> _handleVerifyCode() async {
    final code = _codeController.text.trim();
    if (code.length != 6) return; // 6 hane tamamlanmadıysa işlem yapmaz.

    final email = _emailController.text.trim();
    setState(() => _isLoading = true);
    try {
      // Kodu doğrular.
      final isValid = await ref
          .read(authControllerProvider.notifier)
          .verifyOtp(email, code);

      // Kod doğruysa ve sayfa hâlâ ekrandaysa yeni şifre ekranına e-posta ve kod ile yönlendirir.
      if (isValid && mounted) {
        context.push('/reset-password', extra: {'email': email, 'code': code});
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
        setState(() => _isLoading = false);
      }
    }
  }

  @override // Ekran arayüzünün inşa edildiği yer.
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Aktif temayı alır.
    final isDark = theme.brightness == Brightness.dark; // Koyu mod kontrolü.
    final isCodeComplete =
        _codeController.text.trim().length ==
        6; // 6 hanenin tam girilip girilmediği.

    return Scaffold(
      // Üst uygulama çubuğu: Ortalanmış logo içerir.
      appBar: AppBar(title: const AppLogo(size: 30), centerTitle: true),
      body: SafeArea(
        // Cihazın çentik ve alt navigasyon çubuklarından güvenli alanda çalışmasını sağlar.
        child: Center(
          // Ekranın tam ortasına yerleştirir.
          child: SingleChildScrollView(
            // Küçük ekranlarda ve klavye açıldığında taşmayı önlemek için kaydırılabilir yapar.
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              // Masaüstü ve geniş ekranlarda kartın aşırı yayılmasını önler (maksimum 440 piksel).
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
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min, // İçeriği kadar dikey yer kaplar.
                    crossAxisAlignment: CrossAxisAlignment
                        .stretch, // İçindeki butonları tam genişliğe yayar.
                    children: [
                      // Kilit sıfırlama ikonu yuvarlak kutusu.
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
                          Icons.lock_reset_rounded,
                          size: 32,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Ekran başlığı.
                      Text(
                        'Şifremi Unuttum',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      // Açıklama metni.
                      Text(
                        'Hesabınıza bağlı e-posta adresinizi girerek 6 haneli sıfırlama kodu talep edin.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),

                      // E-posta metin giriş alanı
                      TextField(
                        controller: _emailController,
                        enabled: !_codeSent, // Kod gönderildikten sonra e-posta kutusu kilitlenir.
                        keyboardType: TextInputType
                            .emailAddress, // E-posta klavyesi açar.
                        decoration: const InputDecoration(
                          labelText: 'E-posta Adresi',
                          prefixIcon: Icon(Icons.mail_outline_rounded),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Kod henüz gönderilmediyse 'Doğrulama Kodu Gönder' butonunu gösterir.
                      if (!_codeSent) ...[
                        ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : _handleSendCode, // Yükleniyorsa buton pasif.
                          child: _isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.black,
                                  ),
                                )
                              : const Text('Doğrulama Kodu Gönder'),
                        ),
                      ] else ...[
                        // Kod gönderildikten sonra açılan 6 haneli kod giriş alanı.
                        TextField(
                          controller: _codeController,
                          keyboardType:
                              TextInputType.number, // Sayısal klavye açar.
                          textAlign:
                              TextAlign.center, // Kodu ortalayarak yazar.
                          maxLength:
                              6, // En fazla 6 karakter girilmesine izin verir.
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly, // Harf ve simge girişini engelleyip sadece rakam alır.
                          ],
                          style: const TextStyle(
                            fontSize: 26,
                            letterSpacing: 10, // Rakamların arasını ferah göstermek için harf aralığı verir.
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            labelText: '6 Haneli Kod',
                            counterText:
                                '', // Alt kısımdaki '0/6' sayacını gizler.
                            hintText: '000000',
                            hintStyle: TextStyle(
                              color: Colors.grey.withValues(alpha: 0.4),
                              letterSpacing: 10,
                            ),
                          ),
                          onChanged: (_) => setState(() {}), // Her harf girildiğinde butonu aktifleştirmek için yeniden çizer.
                        ),
                        const SizedBox(height: 12),

                        // Kalan süreyi gösteren sayaç satırı.
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 18,
                              color: _remainingSeconds > 0
                                  ? theme.colorScheme.primary
                                  : Colors.redAccent,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Kalan Süre: $_formattedTime',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _remainingSeconds > 0
                                    ? theme.colorScheme.primary
                                    : Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Süre bittiğinde (0 olduğunda) tekrar kod gönderme bağlantısı belirir.
                        if (_remainingSeconds == 0)
                          TextButton.icon(
                            onPressed: _handleSendCode,
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Tekrar Kod Gönder'),
                          ),
                        const SizedBox(height: 16),

                        // 6 hane tamamlanmadan ve yükleme sürerken pasif olan onay butonu.
                        ElevatedButton(
                          onPressed: (isCodeComplete && !_isLoading)
                              ? _handleVerifyCode
                              : null,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.black,
                                  ),
                                )
                              : const Text('Kodu Doğrula ve Devam Et'),
                        ),
                      ],
                      const SizedBox(height: 16),

                      // Giriş ekranına geri dönüş bağlantı butonu.
                      TextButton(
                        onPressed: () =>
                            context.pop(), // Önceki sayfaya geri döner.
                        child: const Text('Giriş Ekranına Dön'),
                      ),
                    ],
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
