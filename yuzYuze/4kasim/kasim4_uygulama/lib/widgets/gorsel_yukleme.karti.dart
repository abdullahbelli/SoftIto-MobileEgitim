// cihazdaki dosya ve platform işlemlerini kullanmayı sağlar
import 'dart:io';

// flutter material tasarım widgetlarını kullanmayı sağlar
import 'package:flutter/material.dart';

// macos üzerinde kameraya erişmeyi ve fotoğraf çekmeyi sağlar
import 'package:camera_macos/camera_macos.dart';

// görsel seçme, kamera ve buluta yükleme arayüzünü oluşturan widget
class GorselYuklemeKarti extends StatefulWidget {
  // seçilen görsel dosyasını tutar ve null olabilir
  final File? secilenDosya;

  // buluta yüklenen görselin url adresini tutar
  final String? yuklenenUrl;

  // dosyanın yüklenme oranını tutar
  final double yuklemeOrani;

  // yükleme işleminin devam edip etmediğini tutar
  final bool yukleniyorMu;

  // galeri butonuna basıldığında çalışacak parametresiz callback
  final VoidCallback onGaleridenSec;

  // kamera butonuna basıldığında çalışacak parametresiz callback
  final VoidCallback onKameradanCek;

  // buluta yükleme butonuna basıldığında çalışacak callback
  final VoidCallback onBulutaYukle;

  // macOS kamera: Çekilen fotoğrafı üst ekrana aktarmak için.
  final ValueChanged<File>? onFotografCekildi;

  // widgetın kurucu metodu
  const GorselYuklemeKarti({
    // widgetın kimliğini üst sınıfa iletir
    super.key,

    // seçilen dosya bilgisini zorunlu parametre olarak alır
    required this.secilenDosya,

    // yüklenen dosyanın url bilgisini zorunlu parametre olarak alır
    required this.yuklenenUrl,

    // dosyanın yükleme oranını zorunlu parametre olarak alır
    required this.yuklemeOrani,

    // yükleme durumunu zorunlu parametre olarak alır
    required this.yukleniyorMu,

    // galeri seçme işlemini gerçekleştirecek fonksiyonu alır
    required this.onGaleridenSec,

    // kamera açma işlemini gerçekleştirecek fonksiyonu alır
    required this.onKameradanCek,

    // buluta yükleme işlemini gerçekleştirecek fonksiyonu alır
    required this.onBulutaYukle,

    // macos kamerasından çekilen fotoğrafı aktaracak isteğe bağlı fonksiyonu alır
    this.onFotografCekildi,
  });

  // widgetın durumunu yönetecek state sınıfını oluşturur
  @override
  State<GorselYuklemeKarti> createState() => _GorselYuklemeKartiState();
}

// görsel yükleme kartının değişebilen durumlarını yöneten state sınıfı
class _GorselYuklemeKartiState extends State<GorselYuklemeKarti> {
  // macOS kamera: Kamera durumunu ve kontrolcüsünü tutar.
  // kameranın açık olup olmadığını tutar
  bool _kameraAcikMi = false;

  // fotoğraf çekme işleminin devam edip etmediğini tutar
  bool _fotografCekiliyorMu = false;

  // macos kamerasını yönetmek için kullanılan controller nesnesini tutar
  CameraMacOSController? _kameraController;

  // macOS kamera: Kamerayı açar veya fotoğraf çeker.
  Future<void> _kameraButonunaBas() async {
    // cihaz macos değilse normal kamera seçme işlemini çalıştırır
    if (!Platform.isMacOS) {
      // üst widgettan gelen kamera callback fonksiyonunu çağırır
      widget.onKameradanCek();

      // macos işlemlerine devam etmeden metottan çıkar
      return;
    }

    // macos kamerası henüz açık değilse önizlemeyi açar
    if (!_kameraAcikMi) {
      // kamera durumunu değiştirerek ekranı yeniden oluşturur
      setState(() {
        // kamera önizlemesini aktif hale getirir
        _kameraAcikMi = true;

        // önceki kamera controller bilgisini sıfırlar
        _kameraController = null;
      });

      // kamera açıldıktan sonra fotoğraf çekme işlemine geçmeden çıkar
      return;
    }

    // kamera hazır değilse veya fotoğraf çekiliyorsa işlemi engeller
    if (_kameraController == null || _fotografCekiliyorMu) {
      return;
    }

    // fotoğraf çekme işleminin başladığını belirtir
    setState(() => _fotografCekiliyorMu = true);

    // fotoğraf çekme sırasında oluşabilecek hataları yakalar
    try {
      // kamera controller üzerinden fotoğraf çeker
      final fotograf = await _kameraController!.takePicture();

      // çekilen fotoğrafın byte verilerini alır
      final bytes = fotograf?.bytes;

      // fotoğraf verisi yoksa veya boşsa hata oluşturur
      if (bytes == null || bytes.isEmpty) {
        throw Exception('Fotoğraf alınamadı.');
      }

      // macOS kamera: Firebase'in kullanacağı geçici dosyayı oluşturur.
      // çekilen fotoğraf için geçici klasörde benzersiz dosya yolu oluşturur
      final dosya = File(
        // sistemin geçici klasör yolunu kullanır
        '${Directory.systemTemp.path}/'
        // mevcut zamanın milisaniye değerini dosya adına ekler
        'kamera_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      // fotoğrafın byte verilerini oluşturulan dosyaya kaydeder
      await dosya.writeAsBytes(bytes);

      // widget ekrandan kaldırılmışsa işlemi sonlandırır
      if (!mounted) return;

      // fotoğraf çekildikten sonra kamera önizlemesini kapatır
      setState(() {
        // kameranın kapalı olduğunu belirtir
        _kameraAcikMi = false;

        // kamera controller referansını temizler
        _kameraController = null;
      });

      // Çekilen görseli mevcut ekranın dosya değişkenine aktarır.
      // callback tanımlanmışsa çekilen dosyayı üst ekrana gönderir
      widget.onFotografCekildi?.call(dosya);

      // fotoğraf çekme sırasında oluşan hatayı yakalar
    } catch (e) {
      // widget hala ekrandaysa hata mesajını gösterir
      if (mounted) {
        // kullanıcıya snackbar üzerinden kamera hatasını bildirir
        ScaffoldMessenger.of(context).showSnackBar(
          // hata bilgisini içeren snackbar oluşturur
          SnackBar(content: Text('Kamera hatası: $e')),
        );
      }

      // işlem başarılı veya hatalı olsa da sonunda çalışır
    } finally {
      // widget hala ekrandaysa fotoğraf çekme durumunu sıfırlar
      if (mounted) {
        // fotoğraf çekme işleminin tamamlandığını belirtir
        setState(() => _fotografCekiliyorMu = false);
      }
    }
  }

  // macOS kamera: Galeri seçildiğinde kamera önizlemesini kapatır.
  void _galeriButonunaBas() {
    // kamera açıksa önce kamera önizlemesini kapatır
    if (_kameraAcikMi) {
      // kamera durumunu değiştirerek ekranı günceller
      setState(() {
        // kamera önizlemesini kapatır
        _kameraAcikMi = false;

        // kamera controller referansını temizler
        _kameraController = null;
      });
    }

    // üst widgettan gelen galeriden görsel seçme fonksiyonunu çalıştırır
    widget.onGaleridenSec();
  }

  // widgetın kullanıcı arayüzünü oluşturan metot
  @override
  Widget build(BuildContext context) {
    // içeriği kart şeklinde gösterir
    return Card(
      // kartın gölgesini kaldırır
      elevation: 0,

      // kartın köşelerini ve kenarlığını belirler
      shape: RoundedRectangleBorder(
        // kartın köşelerini 16 piksel yuvarlar
        borderRadius: BorderRadius.circular(16),

        // kartın kenarlarına açık gri çizgi ekler
        side: BorderSide(color: Colors.grey.shade300),
      ),

      // kartın içeriğine boşluk ekler
      child: Padding(
        // kartın tüm kenarlarından 16 piksel boşluk bırakır
        padding: const EdgeInsets.all(16),

        // kartın içindeki widgetları dikey olarak sıralar
        child: Column(
          // çocuk widgetları yatay eksende mümkün olan genişliğe yayar
          crossAxisAlignment: CrossAxisAlignment.stretch,

          // sütun içerisinde gösterilecek widgetları tanımlar
          children: [
            // kartın başlık ve simge bölümünü yatay olarak oluşturur
            const Row(
              // satır içerisindeki widgetları tanımlar
              children: [
                // buluta yükleme simgesini ve rengini belirler
                Icon(Icons.cloud_upload_outlined, color: Color(0xff0047ff)),

                // simge ile başlık arasında 8 piksel boşluk bırakır
                SizedBox(width: 8),

                // kartın başlık metnini gösterir
                Text(
                  'Firebase Medya Yükleyici',

                  // başlığın yazı stilini belirler
                  style: TextStyle(
                    // başlık yazısının boyutunu 16 yapar
                    fontSize: 16,

                    // başlık yazısını kalın yapar
                    fontWeight: FontWeight.bold,

                    // başlık rengini argb değerleriyle belirler
                    color: Color.fromARGB(211, 148, 177, 30),
                  ),
                ),
              ],
            ),

            // başlık ile görsel alanı arasında 14 piksel boşluk bırakır
            const SizedBox(height: 14),

            // kamera önizlemesi veya seçilen görsel için alan oluşturur
            Container(
              // görsel alanının yüksekliğini 180 piksel yapar
              height: 180,

              // görsel alanının arka plan ve kenarlık özelliklerini belirler
              decoration: BoxDecoration(
                // arka plan rengini argb değerleriyle belirler
                color: Color.fromARGB(209, 170, 29, 188),

                // köşeleri 12 piksel yuvarlar
                borderRadius: BorderRadius.circular(12),

                // görsel alanına açık gri kenarlık ekler
                border: Border.all(color: Colors.grey.shade300),
              ),

              // görsel içeriğini alanın ortasına hizalar
              alignment: Alignment.center,

              // macOS kamera: Kamera açıksa bu alanda canlı görüntü gösterilir.
              // kamera açık ve cihaz macos ise canlı kamera önizlemesini gösterir
              child: _kameraAcikMi && Platform.isMacOS
                  ? ClipRRect(
                      // kamera görüntüsünün köşelerini 12 piksel yuvarlar
                      borderRadius: BorderRadius.circular(12),

                      // kamera görüntüsünü kullanılabilir alana yayar
                      child: SizedBox.expand(
                        // macos kamera önizlemesini oluşturur
                        child: CameraMacOSView(
                          // kamera görüntüsünü alanı kaplayacak şekilde ölçeklendirir
                          fit: BoxFit.cover,

                          // kamerayı fotoğraf çekme modunda kullanır
                          cameraMode: CameraMacOSMode.photo,

                          // kamera başlatıldığında controller bilgisini alır
                          onCameraInizialized: (controller) {
                            // widget hala ekrandaysa kamera controllerını kaydeder
                            if (mounted) {
                              setState(() {
                                // başlatılan kamera controllerını değişkene atar
                                _kameraController = controller;
                              });
                            }
                          },
                        ),
                      ),
                    )
                  // kamera açık değilse seçilmiş bir dosya olup olmadığını kontrol eder
                  : widget.secilenDosya != null
                  ? ClipRRect(
                      // seçilen görselin köşelerini yuvarlar
                      borderRadius: BorderRadius.circular(12),

                      // cihazdan seçilen görseli dosya üzerinden gösterir
                      child: Image.file(
                        // null olmadığını bildiğimiz dosyayı görsel olarak kullanır
                        widget.secilenDosya!,

                        // görseli alanı kaplayacak şekilde ölçeklendirir
                        fit: BoxFit.cover,

                        // görselin genişliğini kullanılabilir maksimum değere ayarlar
                        width: double.infinity,

                        // görselin yüksekliğini kullanılabilir maksimum değere ayarlar
                        height: double.infinity,
                      ),
                    )
                  // seçilen dosya yoksa yüklenmiş görselin url bilgisini kontrol eder
                  : (widget.yuklenenUrl != null
                        ? ClipRRect(
                            // internetten gelen görselin köşelerini yuvarlar
                            borderRadius: BorderRadius.circular(12),

                            // url adresindeki görseli internetten yükleyerek gösterir
                            child: Image.network(
                              // null olmadığını bildiğimiz görsel url adresini kullanır
                              widget.yuklenenUrl!,

                              // görseli alanı kaplayacak şekilde ölçeklendirir
                              fit: BoxFit.cover,

                              // görselin genişliğini maksimum değere ayarlar
                              width: double.infinity,

                              // görselin yüksekliğini maksimum değere ayarlar
                              height: double.infinity,
                            ),
                          )
                        // seçilen veya yüklenen görsel yoksa bilgilendirme alanı oluşturur
                        : Column(
                            // içerikleri dikey eksende ortalar
                            mainAxisAlignment: MainAxisAlignment.center,

                            // bilgilendirme alanındaki widgetları tanımlar
                            children: [
                              // görsel seçilmediğini belirten simgeyi oluşturur
                              Icon(
                                // görsel simgesini kullanır
                                Icons.image_outlined,

                                // simgenin boyutunu 48 piksel yapar
                                size: 48,

                                // simge rengini açık gri yapar
                                color: Colors.grey.shade500,
                              ),

                              // simge ile açıklama arasında 8 piksel boşluk bırakır
                              const SizedBox(height: 8),

                              // kullanıcıya henüz görsel seçilmediğini bildirir
                              Text(
                                'Henüz bir görsel seçilmedi',

                                // açıklama metninin rengini gri yapar
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          )),
            ),

            // yükleme işlemi devam ediyorsa ilerleme göstergelerini listeye ekler
            if (widget.yukleniyorMu) ...[
              //... ne işe yarıyor ???
              // üç nokta spread operatörüdür ve listedeki elemanları başka bir listeye açar
              // if koşulu doğru olduğunda köşeli parantez içindeki widgetları children listesine ekler

              // görsel alanı ile ilerleme çubuğu arasında boşluk bırakır
              const SizedBox(height: 12),

              // görselin yüklenme ilerlemesini gösteren çubuk oluşturur
              LinearProgressIndicator(
                // yükleme oranını 0 ile 1 arasında ilerleme çubuğuna aktarır
                value: widget.yuklemeOrani,

                // ilerleme çubuğunun boş kısmının rengini belirler
                backgroundColor: Colors.grey.shade200,

                // ilerleme çubuğunun dolu kısmının rengini belirler
                color: const Color.fromARGB(255, 19, 13, 13),

                // ilerleme çubuğunun yüksekliğini 6 piksel yapar
                minHeight: 6,

                // ilerleme çubuğunun köşelerini 4 piksel yuvarlar
                borderRadius: BorderRadius.circular(4),
              ),

              // ilerleme çubuğu ile yüzde metni arasında boşluk bırakır
              const SizedBox(height: 4),

              // yükleme yüzdesini metin olarak gösterir
              Text(
                // oranı 100 ile çarpar ve ondalık basamak olmadan yüzdeye dönüştürür
                'Yükleniyor: %${(widget.yuklemeOrani * 100).toStringAsFixed(0)}',

                // yükleme yüzdesini sağa hizalar
                textAlign: TextAlign.end,

                // yüzde metninin görünüm özelliklerini belirler
                style: const TextStyle(
                  // yazı boyutunu 12 piksel yapar
                  fontSize: 12,

                  // yüzde metnini kalın yapar
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],

            // ilerleme alanı ile butonlar arasında 14 piksel boşluk bırakır
            const SizedBox(height: 14),

            // galeri ve kamera butonlarını yatay olarak sıralar
            Row(
              // satır içerisinde gösterilecek widgetları tanımlar
              children: [
                // galeri butonunun kullanılabilir yatay alanı doldurmasını sağlar
                Expanded(
                  // kenarlıklı ve simgeli galeri butonu oluşturur
                  child: OutlinedButton.icon(
                    // yükleme devam ediyorsa butonu pasif hale getirir
                    onPressed: widget.yukleniyorMu ? null : _galeriButonunaBas,

                    // buton üzerinde gösterilecek metni belirler
                    label: const Text('Galeri'),

                    // butonda fotoğraf galerisi simgesini gösterir
                    icon: const Icon(Icons.photo_library_outlined),
                  ),
                ),

                // iki buton arasında 8 piksel boşluk bırakır
                const SizedBox(width: 8),

                // kamera butonunun kullanılabilir yatay alanı doldurmasını sağlar
                Expanded(
                  // kenarlıklı ve simgeli kamera butonu oluşturur
                  child: OutlinedButton.icon(
                    // yükleme, fotoğraf çekme veya kamera hazırlanma durumunda butonu kapatır
                    onPressed:
                        widget.yukleniyorMu ||
                            _fotografCekiliyorMu ||
                            (_kameraAcikMi && _kameraController == null)
                        ? null
                        : _kameraButonunaBas,

                    // kamera açıkken fotoğraf çek, diğer durumlarda kamera metnini gösterir
                    label: Text(
                      // macos kamerası açıksa fotoğraf çekme metnini seçer
                      _kameraAcikMi && Platform.isMacOS
                          ? 'Fotoğraf Çek'
                          : 'Kamera',
                    ),

                    // kamera simgesini gösterir
                    icon: Icon(Icons.camera_alt_outlined),
                  ),
                ),
              ],
            ),

            // macOS kamera: Önizlemeyi kapatmak için.
            // kamera açık ve cihaz macos ise kapatma butonunu gösterir
            if (_kameraAcikMi && Platform.isMacOS) ...[
              // kamera butonları ile kapatma butonu arasında boşluk bırakır
              const SizedBox(height: 8),

              // kamera önizlemesini kapatmak için metin butonu oluşturur
              TextButton(
                // butona basıldığında kamera durumunu günceller
                onPressed: () {
                  // ekranı yeniden oluşturmak için state değişkenlerini günceller
                  setState(() {
                    // kamera önizlemesini kapatır
                    _kameraAcikMi = false;

                    // kamera controller referansını temizler
                    _kameraController = null;
                  });
                },

                // kapatma butonunun üzerindeki metni belirler
                child: const Text('Kamerayı Kapat'),
              ),
            ],

            // görsel seçilmişse buluta yükleme butonunu gösterir
            if (widget.secilenDosya != null) ...[
              // buton ile üstündeki alan arasında boşluk bırakır
              const SizedBox(height: 8),

              // simgeli ve dolgulu buluta yükleme butonu oluşturur
              FilledButton.icon(
                // yükleme devam ediyorsa butonu pasif hale getirir
                onPressed: widget.yukleniyorMu ? null : widget.onBulutaYukle,

                // yükleme butonunun üzerindeki metni belirler
                label: const Text('Buluta yükle'),

                // yükleme butonunun görünüm özelliklerini belirler
                style: FilledButton.styleFrom(
                  // butonun arka plan rengini argb değerleriyle belirler
                  backgroundColor: const Color.fromARGB(239, 217, 127, 0),
                ),

                // buluta yükleme simgesini gösterir
                icon: const Icon(Icons.cloud_upload),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// soru: if (kosul) ...[] yapısındaki üç nokta ne işe yarar
// üç nokta dart dilinde spread operatörüdür
// bir listenin elemanlarını başka bir listenin içerisine ayrı ayrı ekler
// if koşulu doğruysa köşeli parantez içindeki widgetlar children listesine eklenir
// koşul yanlışsa bu widgetlar listeye eklenmez
// örnek olarak yükleme devam ediyorsa progress indicator ve yüzde metni gösterilir
// böylece görünmesi gerekmeyen widgetlar için ayrıca boş bir widget oluşturmaya gerek kalmaz

// soru: widget.secilenDosya ile _kameraAcikMi arasındaki fark nedir
// widget.secilenDosya üst widgettan constructor aracılığıyla gelen dosya bilgisidir
// _kameraAcikMi ise bu state sınıfının kendi içerisinde tuttuğu durum değişkenidir
// üst widgettan gelen değerlere widget üzerinden erişilir
// state sınıfının kendi değişkenlerine doğrudan erişilebilir

// soru: voidcallback ile valuechanged arasındaki fark nedir
// voidcallback parametre almayan ve değer döndürmeyen fonksiyon türüdür
// valuechanged ise bir parametre alır ve değer döndürmez
// valuechanged<File> çekilen dosyayı üst widgeta göndermek için kullanılır

// soru: mounted neden kullanılır
// mounted widgetın hala widget ağacında bulunup bulunmadığını belirtir
// async işlemler sırasında widget ekrandan kaldırılmış olabilir
// mounted kontrolü kaldırılmış bir widget üzerinde setState çağrılmasını önlemek için kullanılır
