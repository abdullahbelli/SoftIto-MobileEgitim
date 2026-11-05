import 'package:flutter/material.dart'; // material tasarım widgetlarını kullanmak için
import 'package:flutter/widgets.dart'; // flutter temel widgetlarını kullanmak için
import 'package:kasim4_uygulama/models/bildirim_modeli.dart'; // bildirim verilerini tutan modeli projeye dahil eder

class BildirimListesiKarti extends StatelessWidget {
  // durumu kendi içinde değişmeyen bildirim kartı widgetı
  final List<BildirimModeli>
  bildirimler; // gelen bildirimleri liste olarak tutar
  final String? token; // null olabilen fcm cihaz tokenını tutar
  final bool konuyaAboneMi; // kullanıcının konuya abone olup olmadığını tutar
  final ValueChanged<bool> onAboneDegisti; // abonelik durumu değişince bool değerini üst widgeta ileten callback

  const BildirimListesiKarti({
    // widgetın kurucu metodu
    super.key, // widgetın kimliğini üst sınıfa iletir
    required this.bildirimler, // bildirim listesinin gönderilmesini zorunlu yapar
    required this.token, // token parametresinin gönderilmesini zorunlu yapar ancak null olabilir
    required this.konuyaAboneMi, // abonelik bilgisinin gönderilmesini zorunlu yapar
    required this.onAboneDegisti, // abonelik değiştiğinde çalışacak fonksiyonu zorunlu yapar
  });
  @override // üst sınıftaki build metodunu ezerek yeniden tanımlar
  Widget build(BuildContext context) {
    // widgetın arayüzünü oluşturan metot
    return Card(
      // içeriği kart şeklinde gösterir
      elevation: 0, // kartın gölge yüksekliğini sıfırlar
      shape: RoundedRectangleBorder(
        // kartın kenarlık ve köşe şeklini belirler
        borderRadius: BorderRadius.circular(
          16,
        ), // kartın köşelerini 16 piksel yuvarlar
        side: BorderSide(
          // kenarlık için gri rengin 300 tonunu kullanır
          color: Colors.grey.shade300,
        ), // kartın kenarlarına açık gri çizgi ekler
      ),
      child: Padding(
        // kartın içeriğine boşluk ekler
        padding: const EdgeInsets.all(
          16,
        ), // tüm kenarlardan 16 piksel iç boşluk bırakır
        child: Column(
          // widgetları dikey olarak sıralar
          crossAxisAlignment: CrossAxisAlignment
              .stretch, // çocukları yatay eksende mümkün olan genişliğe yayar
          // sütun içerisinde gösterilecek widgetları tanımlar
          children: [
            // bildirim başlığı ve abonelik anahtarını yatay olarak sıralar
            Row(
              // widgetları yatay olarak sıralar
              children: [
                const Icon(
                  // bildirim simgesi oluşturur
                  Icons.notifications_active_outlined, // aktif bildirim simgesini seçer
                  color: Color(0xFF006C4A), // simgenin rengini belirler
                ),
                const SizedBox(width: 8), // 8 piksel yatay boşluk bırakır
                const Expanded(
                  // kalan yatay alanı kaplamasını sağlar
                  child: Text(
                    // başlık metnini gösterir
                    'fcm bildirim Merkezi', // kartın başlığı
                    style: TextStyle(
                      // metnin görünüm özelliklerini belirler
                      fontSize: 16, // yazı boyutunu 16 yapar
                      fontWeight: FontWeight.bold, // yazıyı kalın yapar
                      color: Color(
                        // metnin rengini hexadecimal değerle belirler
                        0xFFF172A,
                      ), // metin rengini hex koduyla belirler
                    ),
                  ),
                ),
                Switch(
                  // abonelik durumunu açıp kapatan anahtar
                  value:
                      konuyaAboneMi, // switch durumunu bool değişkeninden alır
                  onChanged: onAboneDegisti, // switch değiştiğinde callback fonksiyonunu çalıştırır
                  activeColor: const Color.fromARGB(
                    // rengin alfa değerini belirler
                    15,
                    // kırmızı renk bileşenini belirler
                    160,
                    // yeşil renk bileşenini belirler
                    40,
                    // mavi renk bileşenini belirler
                    50,
                  ), // açık durumdaki switch rengini argb ile belirler
                ),
              ],
            ),
            Text(
              // abonelik durumuna göre bilgi metni gösterir
              konuyaAboneMi ? 'tüm sınıf yayını aktif' : 'Yayın kapalı', // ternary operatörüyle koşula göre metin seçer
              style: TextStyle(
                // metnin stil özelliklerini belirler
                fontSize: 12, // yazı boyutunu 12 yapar
                color:
                    konuyaAboneMi // abonelik durumuna göre renk seçer
                    ? const Color.fromARGB(
                        // rengin alfa değerini belirler
                        15,
                        // kırmızı renk bileşenini belirler
                        24,
                        // yeşil renk bileşenini belirler
                        59,
                        // mavi renk bileşenini belirler
                        17,
                      ) // aboneyse bu rengi kullanır
                    : Colors.grey.shade600, // abone değilse gri renk kullanır
                fontWeight: FontWeight.w600, // yazıya yarı kalın görünüm verir
              ),
            ),
            const SizedBox(height: 12), // 12 piksel dikey boşluk bırakır
            Container(
              // token bilgisini göstermek için kutu oluşturur
              padding: const EdgeInsets.all(
                10,
              ), // tüm kenarlardan 10 piksel iç boşluk bırakır
              decoration: BoxDecoration(
                // kutunun arka plan ve köşe özelliklerini belirler
                color: const Color(
                  0xFF0F172A,
                ), // kutunun arka plan rengini belirler
                borderRadius: BorderRadius.circular(
                  8,
                ), // kutunun köşelerini 8 piksel yuvarlar
              ),
              child: Column(
                // içerikleri dikey sıralar
                crossAxisAlignment:
                    CrossAxisAlignment.start, // içerikleri sola hizalar
                children: [
                  const Text(
                    // token başlığını gösterir
                    "Cihazın FCM TOKENİ", // başlık metni
                    style: TextStyle(
                      // başlığın görünümünü belirler
                      color: Colors.blue, //burdaa neden shade kabul etmedi ???  const verdiğimiz için
                      fontSize: 11, // yazı boyutunu 11 yapar
                    ),
                  ),
                  const SizedBox(height: 2), // 2 piksel dikey boşluk bırakır
                  SelectableText(
                    // kullanıcının seçip kopyalayabileceği metin oluşturur
                    token ?? 'token alınıyor', // token null ise varsayılan metni gösterir
                    style: const TextStyle(
                      // token metninin görünümünü belirler
                      color: Color(
                        0xFF388888,
                      ), // token metninin rengini belirler
                      fontSize: 11, // yazı boyutunu 11 yapar
                      fontFamily: 'monospace', // tüm karakterleri eşit genişlikte gösteren yazı tipini kullanır
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14), // 14 piksel dikey boşluk bırakır
            Text(
              // gelen bildirim sayısını gösteren başlık
              'Gelen Bildirimler (${bildirimler.length})', // string interpolation ile bildirim sayısını metne ekler
              style: const TextStyle(
                // başlığın stilini belirler
                fontWeight: FontWeight.bold, // yazıyı kalın yapar
                fontSize: 14, // yazı boyutunu 14 yapar
                color: Color.fromARGB(
                  // rengin saydamlık değerini belirler
                  15,
                  // kırmızı renk bileşenini belirler
                  28,
                  // yeşil renk bileşenini belirler
                  167,
                  // mavi renk bileşenini belirler
                  247,
                ), // metnin rengini ve saydamlığını argb ile belirler
              ),
            ),
            const SizedBox(height: 8), // 8 piksel dikey boşluk bırakır
            bildirimler
                    .isEmpty // bildirim listesinin boş olup olmadığını kontrol eder
                ? Container(
                    // liste boşsa bilgilendirme kutusu oluşturur
                    padding: const EdgeInsets.all(
                      24,
                    ), // tüm kenarlardan 24 piksel iç boşluk bırakır
                    alignment:
                        Alignment.center, // içeriği kutunun ortasına hizalar
                    child: Text(
                      // boş liste mesajını gösterir
                      'Henüz gelen bildirim yok', // kullanıcıya gösterilecek bilgilendirme metni
                      textAlign: TextAlign.center, // metni ortalar
                      style: TextStyle(
                        // metnin görünümünü belirler
                        fontSize: 12, // yazı boyutunu 12 yapar
                        color:
                            Colors.grey.shade500, // metne açık gri renk verir
                      ),
                    ),
                  )
                : ListView.separated(
                    // liste doluysa aralarına ayırıcı koyarak elemanları listeler
                    shrinkWrap:
                        true, // listenin yüksekliğini içeriğine göre ayarlar
                    physics: const NeverScrollableScrollPhysics(), // listenin kendi içinde kaydırılmasını engeller
                    itemCount: bildirimler.length, // oluşturulacak liste elemanı sayısını belirler
                    separatorBuilder: (_, _) => const Divider(height: 1), // elemanların arasına 1 piksel yüksekliğinde ayırıcı ekler
                    itemBuilder: (context, index) {
                      // her bildirim için liste elemanı oluşturan fonksiyon

                      // index değerine karşılık gelen bildirimi listeden alır
                      final b = bildirimler[index];

                      // her bildirimi liste satırı olarak gösterir
                      return ListTile(
                        // liste elemanının varsayılan iç boşluklarını kaldırır
                        contentPadding: EdgeInsets.zero,

                        // liste elemanının sol tarafında dairesel simge gösterir
                        leading: const CircleAvatar(
                          // dairesel alanın arka plan rengini belirler
                          backgroundColor: Color.fromARGB(0, 123, 238, 230),

                          // dairesel alanın içerisinde bildirim simgesi oluşturur
                          child: Icon(
                            // okunmamış e-posta simgesini kullanır
                            Icons.mark_email_unread_outlined,

                            // simgenin rengini argb değeriyle belirler
                            color: Color.fromARGB(0, 113, 25, 25),

                            // simgenin boyutunu 20 piksel yapar
                            size: 20,
                          ),
                        ),

                        // bildirim başlığını gösterir
                        title: Text(
                          // bildirim modelindeki başlık bilgisini kullanır
                          b.baslik,

                          // başlık metninin görünüm özelliklerini belirler
                          style: const TextStyle(
                            // başlık yazısını kalın yapar
                            fontWeight: FontWeight.bold,

                            // başlık yazısının boyutunu 14 yapar
                            fontSize: 14,
                          ),
                        ),

                        // bildirim modelindeki içerik bilgisini alt başlık olarak gösterir
                        subtitle: Text(b.icerik),

                        // liste elemanının sağ tarafında bildirim saatini gösterir
                        trailing: Text(
                          // bildirim tarihinden saat ve dakika bilgilerini alarak iki haneli biçimde gösterir
                          '${b.tarih.hour.toString().padLeft(2, '0')} : ${b.tarih.minute.toString().padLeft(2, '0')}',

                          // saat metninin görünüm özelliklerini belirler
                          style: TextStyle(
                            // saat metninin boyutunu 11 yapar
                            fontSize: 11,

                            // saat metninin rengini gri rengin 500 tonuyla belirler
                            color: Colors.grey.shade500, //uygulama çalışırken güncelleme yapılacağı için const kullanmıyorum aterial kütüphanesinin sözleşmelernde uyma konusu da var ??
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
//Colors. hazır renk paletini kullanır, Color() ise renk değerini kendimiz belirlememizi sağlar.

// soru 1: colors.blue.shade500 neden const Text içerisinde kullanılamıyor
// const ile oluşturulan widgetların değerleri derleme zamanında sabit olmalıdır
// shade500 çalışma zamanında değerlendirildiği için const içerisinde kullanılamaz
// çözüm olarak Text ve TextStyle üzerindeki const kaldırılabilir
// Colors.blue gibi sabit renkler ise const içerisinde kullanılabilir

// soru 2: colors.grey.shade500 kullanırken neden const TextStyle yazamıyoruz
// shade500 derleme zamanı sabiti olmadığı için const TextStyle ile kullanılamaz
// bunun sebebi uygulamanın çalışırken güncellenmesi veya setState kullanılması değildir
// const yalnızca derleme zamanında belirlenebilen değerleri kabul eder
// Colors.grey doğrudan kullanılabilir ancak Colors.grey.shade500 için const kaldırılmalıdır
