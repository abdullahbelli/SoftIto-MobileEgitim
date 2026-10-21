import 'dart:async'; // Zamanlayıcı (Timer) işlemleri için Dart asenkron kütüphanesini içe aktarır.

import 'package:flutter/material.dart'; // Flutter Material Design arayüz bileşenlerini içe aktarır.
import 'package:flutter/services.dart'; // Metin girişini sadece rakamla sınırlamak için içe aktarır.
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod durum yönetimi ConsumerStatefulWidget desteğini sağlar.
import 'package:go_router/go_router.dart'; // go_router sayfa yönlendirmelerini (context.go, context.pop) sağlar.

import '../../../../core/config/app_constants.dart'; // Uygulama sabitlerini (90 saniyelik OTP süresi vb.) içe aktarır.
import '../../../../core/widgets/app_logo.dart'; // BoardConnect logo bileşenini içe aktarır.
import '../controllers/auth_controller.dart'; // Kimlik doğrulama controller'ını içe aktarır.

/// E-posta Doğrulama Kodu Ekranı (6 Haneli, 90 Saniyelik OTP)
/// Proje gereksinimlerine göre:
/// 1. Kod yalnızca rakamlardan oluşur.
/// 2. Kod tam olarak 6 hanelidir.
/// 3. Geçerlilik süresi 90 saniyedir.
/// 4. Sayaç formatı dakika:saniye (01:30) biçimindedir.
/// 5. Kod girilmeden Onayla butonu pasiftir.
class OtpVerificationScreen extends ConsumerStatefulWidget {
  // Önceki kayıt ekranından gelen kullanıcı bilgilerini (ad, soyad, e-posta, şifre) taşıyan harita.
  final Map<String, dynamic> registrationData;

  const OtpVerificationScreen({super.key, required this.registrationData});

  @override // Widget'ın durum yönetim nesnesini oluşturur.
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

/// OTP doğrulama ekranı durum yönetimi sınıfı
class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  // 6 haneli kodun girildiği metin kutusu denetleyicisi.
  final _codeController = TextEditingController();
  // 90 saniyelik geri sayımı saniye saniye işleten zamanlayıcı nesnesi.
  Timer? _timer;
  // Kalan saniye sayacı (başlangıç: AppConstants.otpDurationSeconds = 90 saniye).
  int _remainingSeconds = AppConstants.otpDurationSeconds;
  // İşlem devam ederken butonları kilitleyip çark gösteren yükleme bayrağı.
  bool _isLoading = false;

  @override // Widget ağaca ilk eklendiğinde çalışan başlatıcı metot (Lifecycle: initState).
  void initState() {
    super.initState();
    _startCountdown(); // Sayfa açılır açılmaz 90 saniyelik geri sayımı başlatır.
  }

  // Geri sayım sayacını kurup işleten yardımcı fonksiyon.
  void _startCountdown() {
    _timer?.cancel(); // Varsa önceki sayacı durdurur.
    setState(() {
      _remainingSeconds = AppConstants.otpDurationSeconds; // Süreyi 90'a kurar.
    });
    // Her 1 saniyede bir tetiklenen periyodik zamanlayıcı kurar.
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return; // Sayfa kapatıldıysa işlemi sonlandırır.
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--; // Süreyi 1 saniye azaltır ve ekranı yeniler.
        });
      } else {
        timer.cancel(); // 0'a ulaşınca sayacı durdurur.
      }
    });
  }

  @override // Sayfadan çıkıldığında bellek temizliği yapar (Lifecycle: dispose).
  void dispose() {
    _timer
        ?.cancel(); // Zamanlayıcıyı sonlandırarak bellek sızıntısını engeller.
    _codeController.dispose(); // Metin kutusu denetleyicisini serbest bırakır.
    super.dispose();
  }

  // Kalan süreyi 'dakika:saniye' (örneğin '01:30') biçiminde metne dönüştüren hesaplayıcı.
  String get _formattedTime {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(
      2,
      '0',
    ); // Tam bölme ile dakikayı 2 basamağa tamamlar.
    final seconds = (_remainingSeconds % 60).toString().padLeft(
      2,
      '0',
    ); // Kalan saniyeyi 2 basamağa tamamlar.
    return '$minutes:$seconds';
  }

  // Kullanıcı 'Onayla' butonuna bastığında çalışan doğrulama ve kayıt tamamlama fonksiyonu.
  Future<void> _handleConfirm() async {
    final code = _codeController.text.trim();
    if (code.length != 6) return; // Kod 6 hane değilse işlem yapmaz.

    setState(() => _isLoading = true); // Yüklenme modunu açar.
    final email =
        widget.registrationData['email'] as String? ??
        ''; // E-posta adresini alır.

    try {
      // Girilen 6 haneli kodu doğrulaması için controller'a gönderir.
      final isValid = await ref
          .read(authControllerProvider.notifier)
          .verifyOtp(email, code);

      if (isValid) {
        // Kod doğruysa, bekletilen kayıt verileriyle asıl kullanıcı kaydını tamamlar.
        await ref
            .read(authControllerProvider.notifier)
            .register(
              email: email,
              password: widget.registrationData['password'] as String? ?? '',
              username: widget.registrationData['username'] as String? ?? '',
              firstName: widget.registrationData['firstName'] as String? ?? '',
              lastName: widget.registrationData['lastName'] as String? ?? '',
            );

        if (mounted) {
          // Başarılı kayıt bildirimini ekranda yeşil SnackBar olarak gösterir.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'E-posta başarıyla doğrulandı ve hesabınız oluşturuldu!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          context.go(
            '/rooms',
          ); // Kullanıcıyı doğrudan odalar sayfasına götürür.
        }
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
        setState(() => _isLoading = false); // Yükleme modunu kapatır.
      }
    }
  }

  // 90 saniye bittiğinde kullanıcının tekrar kod istemesini sağlayan fonksiyon.
  Future<void> _handleResend() async {
    final email = widget.registrationData['email'] as String? ?? '';
    // Tekrar kod gönderme isteğini iletir.
    await ref.read(authControllerProvider.notifier).sendVerificationOtp(email);
    _startCountdown(); // 90 saniyelik sayacı baştan başlatır.
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yeni doğrulama kodu gönderildi (Demo: 123456).'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override // Ekran arayüzünü inşa eden build fonksiyonu.
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Tema bilgilerini çeker.
    final isDark = theme.brightness == Brightness.dark; // Koyu tema kontrolü.
    final email =
        widget.registrationData['email'] as String? ?? 'eposta@alanadi.com';
    // Kod tam 6 haneli olduğunda onay butonunun aktif olması için denetim yapar.
    final isCodeComplete = _codeController.text.trim().length == 6;

    return Scaffold(
      appBar: AppBar(title: const AppLogo(size: 30), centerTitle: true),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // E-posta doğrulama rozet ikonu
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
                          Icons.mark_email_read_outlined,
                          size: 30,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Başlık
                      Text(
                        'E-posta Doğrulama Kodu',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      // Kodun hangi e-postaya gittiğini bildiren açıklama metni
                      Text(
                        '$email adresine gönderilen 6 haneli doğrulama kodunu girin.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Demo İpucu Bilgilendirmesi (Geliştirici ve test kullanıcısı rehberi)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.amber.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              size: 20,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Demo modu: Kod "123456" veya herhangi 6 haneli sayıdır.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.amber.shade200
                                      : Colors.amber.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 6 Haneli Kod Girişi Metin Alanı
                      TextField(
                        controller: _codeController,
                        keyboardType:
                            TextInputType.number, // Sadece sayısal tuş takımı.
                        textAlign:
                            TextAlign.center, // Kod karakterlerini ortalar.
                        maxLength: 6, // 6 haneden fazla girişe izin vermez.
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly, // Yalnızca 0-9 arası rakamlara izin verir.
                        ],
                        style: const TextStyle(
                          fontSize: 28,
                          letterSpacing: 12, // Rakam kutucukları hissi veren geniş harf aralığı.
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          counterText: '', // Karakter sayacını gizler.
                          hintText: '000000',
                          hintStyle: TextStyle(
                            color: Colors.grey.withValues(alpha: 0.4),
                            letterSpacing: 12,
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {}); // Her rakam girildiğinde butonu aktif etmek için ekranı yeniden çizer.
                        },
                      ),
                      const SizedBox(height: 16),

                      // 90 Saniyelik Sayaç Alanı (dakika:saniye formatı Örn: 01:30)
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
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: _remainingSeconds > 0
                                  ? theme.colorScheme.primary
                                  : Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Süre bittiğinde (0 saniye) beliren 'Tekrar Kod Gönder' butonu
                      if (_remainingSeconds == 0)
                        TextButton.icon(
                          onPressed: _handleResend,
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Tekrar Kod Gönder'),
                        ),
                      const SizedBox(height: 18),

                      // Onayla Butonu (Kural gereği 6 hane tamamlanmadan pasiftir)
                      ElevatedButton(
                        onPressed: (isCodeComplete && !_isLoading)
                            ? _handleConfirm
                            : null, // Şartlar sağlanmadığında null verilerek buton kilitlenir.
                        child: _isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.black,
                                ),
                              )
                            : const Text('Onayla'),
                      ),
                      const SizedBox(height: 12),

                      // Bilgileri Değiştir (Geri Dön) Butonu
                      TextButton(
                        onPressed: () => context.pop(),
                        child: const Text('Bilgileri Değiştir'),
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
