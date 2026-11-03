import 'package:flutter/material.dart'; // Flutter'ın Material Design bileşenlerini kullanmayı sağlar

class HataliVeDogruRow extends StatelessWidget {
  // Hatalı ve doğru Row kullanımını gösteren ekran
  const HataliVeDogruRow({
    super.key,
  }); // Widget'ın oluşturulmasını ve flutter tarafından takip edilmesini sağlar

  @override // Üst sınıftaki build metodunu yeniden tanımlar
  Widget build(BuildContext context) {
    // Ekranın arayüz bileşenleri
    return Scaffold(
      // Ekranın temel yapısı
      appBar: AppBar(
        // Ekranın üst kısmındaki uygulama çubuğu
        title: const Text("Row ve Layout"), // Üst menüde gösterilecek başlık
      ),
      body: Padding(
        // Ekran içeriğinin etrafına boşluk ekler (iç boşluk) (16 birim (yüzde))
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // Ekrandaki bileşenleri dikey sıralar
          crossAxisAlignment: CrossAxisAlignment
              .start, // Bileşenleri yatay eksende sola hizalar
          children: [
            // HATALI YAPI
            const Text(
              // Hatalı Row yapısının başlığı
              'Hatalı Yapı: A overflowed by *** pixels (sarı siyah şerit)',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 8), // Başlık ile örnek arasına dikey boşluk

            Container(
              // Hatalı Row örneğinin arka plan kutusunu oluşturur
              color: Colors.amber.shade100,
              child: Row(
                // Elemanları yatay sıralar ancak metne genişlik sınırı koymaz
                children: [
                  const Icon(
                    // Uyarı ikonu
                    Icons.warning,
                    color: Colors.red,
                  ),
                  const SizedBox(
                    width: 8,
                  ), // İkon ile metin arasına yatay boşluk
                  const Text(
                    // Uzun metinlerde Row taşmasına neden olabilecek sınırsız metin alanını oluşturur
                    'Kısa metin (hata vermez ama uzarsa Render Patlar)',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32), // boşluk
            // DOĞRU YAPI
            const Text(
              // Doğru Row kullanımı
              'Doğru Yapı: Flexible ve Expanded ile sınırlandırılmıştır.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 8), // boşluk ekler

            Container(
              // Doğru Row yapısını göstermek için kutu oluşturur
              padding: const EdgeInsets.all(12), // i. boşluk ekler
              decoration: BoxDecoration(
                // Kutunun arka planını ve kenarlıklarını düzenler
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(
                  8,
                ), // Kutunun köşelerini yuvarlar
                border: Border.all(
                  // Kutunun çevresine kenarlık
                  color: Colors.green,
                ),
              ),
              child: Row(
                // İkon ile metin alanını yatay yerleştirir
                children: [
                  const CircleAvatar(
                    // Dairesel ikon alanı
                    backgroundColor: Colors.green,
                    child: Icon(
                      // Dairenin içine ikon yerleştirir
                      Icons.check, // Onay işareti
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(width: 12), // yatay boşluk ekler

                  Expanded(
                    // Metin alanını kalan genişlikle sınırlandırarak taşmayı önler
                    child: Column(
                      // Başlık ve açıklama metnini alt alta yerleştirir
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // Metinleri sola hizalar
                      children: const [
                        Text(
                          // Doğru yapı örneğinin başlığını gösterir
                          'Softİto 4. Dönem Mobil Standartı',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4), // boşluk ekler
                        Text(
                          // Uzun metnin mevcut genişliğe göre alt satıra geçmesini sağlar
                          'Bu metin ne kadar uzun olursa olsun '
                          'telefonun ekranının genişliğinde alt satıra '
                          'geçer ve asla sarı siyah taşma hatası üretmez.',
                          style: TextStyle(color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
