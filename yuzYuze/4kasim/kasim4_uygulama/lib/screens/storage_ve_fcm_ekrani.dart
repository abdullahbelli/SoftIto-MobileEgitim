// dosya işlemleri için kullanılan dart kütüphanesi
import 'dart:io';

import 'package:flutter/material.dart';

import '../models/bildirim_modeli.dart';
import '../services/fcm_bildirim_servisi.dart';
import '../services/storage_servisi.dart';
import '../widgets/bildirim_listesi_karti.dart';
import '../widgets/gorsel_yukleme.karti.dart';

// görsel yükleme ve fcm bildirim işlemlerini yöneten durum bilgisi tutabilen ekran
class StorageVeFcmEkrani extends StatefulWidget {
  // widget oluşturucusu ve isteğe bağlı key parametresi
  const StorageVeFcmEkrani({super.key});

  // ekranın durumunu yönetecek state sınıfını oluşturur
  @override
  State<StorageVeFcmEkrani> createState() => _StorageVeFcmEkraniState();
}

// ekranın değişkenlerini, işlemlerini ve arayüzünü yöneten state sınıfı
class _StorageVeFcmEkraniState extends State<StorageVeFcmEkrani> {
  // firebase storage işlemlerini gerçekleştirmek için servis nesnesi oluşturur
  final StorageServisi _storageServisi = StorageServisi();

  // firebase cloud messaging işlemleri için servis nesnesi oluşturur
  final FcmBildirimServisi _fcmBildirimServisi = FcmBildirimServisi();

  // kullanıcının seçtiği görsel dosyasını tutar, başlangıçta null olabilir
  File? _secilenDosya;

  // buluta yüklenen görselin url adresini tutar
  String? _yuklenenUrl;

  // görselin yüklenme oranını 0 ile 1 arasında tutar
  double _yuklemeOrani = 0.0;

  // görsel yükleme işleminin devam edip etmediğini tutar
  bool _yukleniyorMu = false;

  // cihazın firebase cloud messaging token bilgisini tutar
  String? _fcmToken;

  // kullanıcının bildirim konusuna abone olup olmadığını tutar
  bool _konuyaAboneMi = false;

  // gelen bildirimleri BildirimModeli nesneleri olarak saklayan boş liste
  final List<BildirimModeli> _bildirimler = [];

  // ekran ilk oluşturulduğunda bir kez çalıştırılan yaşam döngüsü metodu
  @override
  void initState() {
    // üst sınıfın initState metodunu çalıştırır
    super.initState();

    // fcm servisini başlatmak için ilgili metodu çağırır
    _fcmKur();
  }

  // fcm servisini başlatır, mesajları dinler ve cihaz tokenini alır
  Future<void> _fcmKur() async {
    // fcm servisini başlatır ve tamamlanmasını bekler
    await _fcmBildirimServisi.baslat(
      // yeni mesaj geldiğinde çalıştırılacak callback fonksiyonu
      onMesajGeldi: (message) {
        // bildirim listesi değiştiği için ekranı yeniden oluşturur
        setState(() {
          // yeni bildirimi listenin belirtilen konumuna ekler
          _bildirimler.insert(
            // bildirimi listenin ilk sırasına ekler
            0,

            // gelen mesajın bilgileriyle yeni bildirim modeli oluşturur
            BildirimModeli(
              // mesaj kimliği varsa onu kullanır, yoksa mevcut tarihten kimlik üretir
              id: message.messageId ?? DateTime.now().toIso8601String(),

              // bildirim başlığını alır, başlık yoksa varsayılan metni kullanır
              baslik: message.notification?.title ?? 'Yeni Bildiirim',

              // bildirim içeriğini alır, içerik yoksa boş metin kullanır
              icerik: message.notification?.body ?? '',

              // bildirimin alındığı anın tarih ve saat bilgisini kaydeder
              tarih: DateTime.now(),
            ),
          );
        });
      },
    );

    // cihazın fcm token bilgisini asenkron olarak alır
    final token = await _fcmBildirimServisi.tokenAl();

    // alınan token bilgisini değişkene kaydeder ve ekranı günceller
    setState(() => _fcmToken = token);
  }

  // kamera veya galeriden görsel seçilmesini sağlayan asenkron metot
  Future<void> _gorselSec({required bool kameradan}) async {
    // kameradan parametresi true ise kamerayı, false ise galeriyi kullanır
    final dosya = await _storageServisi.gorselSec(kameradan: kameradan);

    // kullanıcı bir dosya seçmişse işlemleri gerçekleştirir
    if (dosya != null) {
      // seçilen dosya bilgilerini güncelleyerek ekranı yeniler
      setState(() {
        // seçilen dosyayı değişkene kaydeder
        _secilenDosya = dosya;

        // önceki yüklenen görsele ait url bilgisini sıfırlar
        _yuklenenUrl = null;

        // yeni görsel için yükleme oranını sıfırlar
        _yuklemeOrani = 0.0;
      });
    }
  }

  // macOS kamerasından çekilen fotoğrafı seçilen dosya olarak kaydeder.
  void _macosFotografSecildi(File dosya) {
    // fotoğraf bilgilerini güncelleyerek ekranı yeniden oluşturur
    setState(() {
      // kameradan gelen dosyayı seçilen dosya olarak kaydeder
      _secilenDosya = dosya;

      // önceki görselin url bilgisini temizler
      _yuklenenUrl = null;

      // yükleme ilerleme oranını sıfırlar
      _yuklemeOrani = 0.0;
    });
  }

  // seçilen görseli firebase storage üzerine yükleyen asenkron metot
  Future<void> _bulutaYukle() async {
    // dosya seçilmemişse yükleme işlemini başlatmadan metottan çıkar
    if (_secilenDosya == null) return;

    // yükleme işleminin başladığını belirtir ve ekranı günceller
    setState(() => _yukleniyorMu = true);

    // yükleme sırasında oluşabilecek hataları yakalamak için try bloğu
    try {
      // mevcut zamanın milisaniye değerini kullanarak dosya adı oluşturur
      final dosyaAdi = 'profil_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // seçilen dosyanın firebase storage üzerine yüklenmesini başlatır
      final task = _storageServisi.yuklemeBaslat(
        // null olmadığını bildiğimiz seçilen dosyayı servise gönderir
        dosya: _secilenDosya!,

        // yükleme işleminde kullanılacak dosya adını servise gönderir
        dosyaAdi: dosyaAdi,
      );

      // yükleme sırasında oluşan ilerleme olaylarını dinler
      task.snapshotEvents.listen((snapshot) {
        // toplam dosya boyutu sıfırdan büyükse ilerlemeyi hesaplar
        if (snapshot.totalBytes > 0) {
          // yükleme oranı değiştiğinde ekranı günceller
          setState(() {
            // yüklenen byte miktarını toplam byte miktarına bölerek oranı hesaplar
            _yuklemeOrani = snapshot.bytesTransferred / snapshot.totalBytes;
          });
        }
      });

      // yükleme işleminin tamamlanmasını bekler ve sonucunu kaydeder
      final tamamlanan = await task;

      // yüklenen dosyanın referansını kullanarak indirme url adresini alır
      final url = await _storageServisi.urlGetir(tamamlanan.ref);

      // yükleme tamamlandığında ekran durumunu günceller
      setState(() {
        // firebase storage üzerinden alınan url adresini kaydeder
        _yuklenenUrl = url;

        // yükleme işleminin tamamlandığını belirtir
        _yukleniyorMu = false;
      });

      // widget hala ekranda bulunuyorsa bildirim mesajını gösterir
      if (mounted) {
        // ekranın ScaffoldMessenger nesnesi üzerinden snackbar gösterir
        ScaffoldMessenger.of(context).showSnackBar(
          // başarılı yükleme mesajını içeren snackbar oluşturur
          const SnackBar(
            // snackbar içinde gösterilecek metin widgetı
            content: Text('Görsel buluta başarıyla yüklendi'),

            // snackbar arka plan rengini argb değerleriyle belirler
            backgroundColor: Color.fromARGB(0, 253, 1, 186),
          ),
        );
      }

      // yükleme sırasında oluşan hatayı e değişkeniyle yakalar
    } catch (e) {
      // hata oluştuğunda yükleme durumunu pasif hale getirir
      setState(() => _yukleniyorMu = false);

      // widget hala ekranda bulunuyorsa hata mesajını gösterir
      if (mounted) {
        // hata bilgisini kullanıcıya snackbar ile gösterir
        ScaffoldMessenger.of(context).showSnackBar(
          // hata mesajını içeren snackbar oluşturur
          SnackBar(
            // hata bilgisini metin olarak ekranda gösterir
            content: Text('Yükleme hatası : $e'),

            // hata snackbarının arka plan rengini argb değerleriyle belirler
            backgroundColor: const Color.fromARGB(0, 17, 208, 0),
          ),
        );
      }
    }
  }

  // kullanıcının bildirim konusuna abonelik durumunu değiştiren metot
  Future<void> _aboneDegistir(bool deger) async {
    // gelen bool değerini abonelik değişkenine kaydeder ve ekranı günceller
    setState(() => _konuyaAboneMi = deger);

    // deger true ise kullanıcıyı bildirim konusuna abone eder
    if (deger) {
      // kullanıcıyı tum_sinif isimli fcm konusuna abone eder
      await _fcmBildirimServisi.konuyaAboneOl('tum_sinif');

      // deger false ise kullanıcıyı bildirim konusundan çıkarır
    } else {
      // kullanıcının tum_sinif konusundaki aboneliğini kaldırır
      await _fcmBildirimServisi.konudanAyril('tum_sinif');
    }
  }

  // ekranın kullanıcı arayüzünü oluşturan build metodu
  @override
  Widget build(BuildContext context) {
    // ekranın temel sayfa yapısını oluşturur
    return Scaffold(
      // sayfanın arka plan rengini belirler
      backgroundColor: const Color(0XFFF8FAFC),

      // ekranın üst uygulama çubuğunu oluşturur
      appBar: AppBar(
        // uygulama çubuğunda başlık ve açıklamayı alt alta gösterir
        title: const Column(
          // metinleri yatay eksende sola hizalar
          crossAxisAlignment: CrossAxisAlignment.start,

          // sütun içerisinde gösterilecek widgetları tanımlar
          children: [
            // uygulamanın ana başlığını gösterir
            Text(
              'SoftIto Storage ve Fcm Çalışması',

              // başlık metninin boyutunu ve kalınlığını belirler
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),

            // ana başlığın altında açıklama metnini gösterir
            Text(
              'Bulut Yükleme ve Push Bildirimleri',

              // açıklama metninin boyutunu ve rengini belirler
              style: TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),

        // uygulama çubuğunun arka plan rengini belirler
        backgroundColor: const Color(0xFff0F172A),

        // uygulama çubuğundaki ön plan öğelerinin rengini beyaz yapar
        foregroundColor: Colors.white,
      ),

      // ekranın ana içerik alanını oluşturur
      body: SingleChildScrollView(
        // içerik taşarsa ekranın dikey olarak kaydırılmasını sağlar

        // içeriğin etrafına her yönden 16 piksel boşluk bırakır
        padding: const EdgeInsets.all(16),

        // ana içeriği dikey olarak sıralayan sütun oluşturur
        child: Column(
          // sütun içerisinde gösterilecek widgetları tanımlar
          children: [
            // görsel seçme ve buluta yükleme işlemlerini gösteren kart
            GorselYuklemeKarti(
              // seçilen görsel dosyasını karta gönderir
              secilenDosya: _secilenDosya,

              // yüklenen görselin url adresini karta gönderir
              yuklenenUrl: _yuklenenUrl,

              // görselin yüklenme oranını karta gönderir
              yuklemeOrani: _yuklemeOrani,

              // yükleme işleminin devam edip etmediğini karta bildirir
              yukleniyorMu: _yukleniyorMu,

              // galeri butonuna basıldığında kameradan false parametresiyle görsel seçer
              onGaleridenSec: () => _gorselSec(kameradan: false),

              // kamera butonuna basıldığında kameradan true parametresiyle görsel seçer
              onKameradanCek: () => _gorselSec(kameradan: true),

              // buluta yükleme butonuna basıldığında ilgili metodu çalıştırır
              onBulutaYukle: _bulutaYukle,

              // macos kamerasından fotoğraf çekildiğinde ilgili metodu çalıştırır
              onFotografCekildi: _macosFotografSecildi,
            ),

            // görsel kartı ile bildirim kartı arasında 16 piksel boşluk bırakır
            const SizedBox(height: 16),

            // gelen bildirimleri ve fcm bilgilerini gösteren kart
            BildirimListesiKarti(
              // gelen bildirimlerin bulunduğu listeyi karta gönderir
              bildirimler: _bildirimler,

              // cihazın fcm token bilgisini karta gönderir
              token: _fcmToken,

              // kullanıcının bildirim konusuna abonelik durumunu karta gönderir
              konuyaAboneMi: _konuyaAboneMi,

              // abonelik durumu değiştiğinde ilgili metodu çalıştırır
              onAboneDegisti: _aboneDegistir,
            ),
          ],
        ),
      ),
    );
  }
}
