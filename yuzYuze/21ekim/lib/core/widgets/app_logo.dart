import 'package:flutter/material.dart'; // Flutter Material Design bileşenlerini içe aktarır.

/// BoardConnect logo ve başlık bileşeni
/// 'StatelessWidget' durum barındırmayan (sabit) bir widget yapısıdır; verilen parametrelere göre ekrana çizilir.
class AppLogo extends StatelessWidget {
  final double size; // Logonun ikon boyutu (varsayılan: 36)
  final bool showTagline; // Alt slogan metninin gösterilip gösterilmeyeceğini belirleyen bayrak
  final bool compact; // Yalnızca logonun ikon halinin (metinsiz) gösterilip gösterilmeyeceğini belirleyen bayrak

  // Kurucu fonksiyon (Constructor): opsiyonel parametrelerle varsayılan değerler tanımlanır.
  const AppLogo({
    super.key, // Widget anahtarı
    this.size = 36, // Varsayılan ikon boyutu
    this.showTagline = false, // Varsayılan olarak alt slogan gizlidir
    this.compact = false, // Varsayılan olarak tam logo ve yazı gösterilir
  });

  @override // StatelessWidget sınıfının build fonksiyonunu yeniden tanımlar.
  Widget build(BuildContext context) {
    // Arayüzün inşa edildiği ana metot.
    final theme = Theme.of(
      context,
    ); // Mevcut widget ağacından aktif ThemeData nesnesini okur.
    final isDark =
        theme.brightness ==
        Brightness.dark; // Koyu temanın aktif olup olmadığını kontrol eder.

    // Logonun kare/yuvarlatılmış simge kısmını oluşturan Container widget'ı.
    final logoIcon = Container(
      width: size, // Genişlik
      height: size, // Yükseklik
      decoration: BoxDecoration(
        // Çapraz geçişli zarif bir degrade (gradient) boyama tanımlar.
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary, // Temanın birincil sarı/vurgu rengi.
            theme.colorScheme.primaryContainer, // Açık tonlu ikincil kap rengi.
          ],
          begin: Alignment.topLeft, // Degradenin başlangıç yönü (sol üst).
          end: Alignment.bottomRight, // Degradenin bitiş yönü (sağ alt).
        ),
        borderRadius: BorderRadius.circular(
          size * 0.28,
        ), // Boyuta orantılı yuvarlak köşeler.
        boxShadow: [
          // Logonun arkasına hafif renkli bir derinlik gölgesi ekler.
          BoxShadow(
            color: theme.colorScheme.primary.withValues(
              alpha: 0.35,
            ), // %35 saydam birincil renk gölgesi.
            blurRadius: size * 0.3, // Gölgenin bulanıklık yarıçapı.
            offset: Offset(
              0,
              size * 0.1,
            ), // Gölgenin aşağıya doğru kayma miktarı.
          ),
        ],
      ),
      child: Center(
        // İkonu kutunun tam ortasına yerleştirir.
        child: Icon(
          Icons.dashboard_customize_rounded, // Beyaz tahtayı ve panelleri simgeleyen modern bir simge.
          size: size * 0.58, // Boyutla orantılı simge büyüklüğü.
          color: theme.colorScheme.onPrimary, // Sarı üzerindeki kontrast yazı/simge rengi (siyah veya koyu renk).
        ),
      ),
    );

    // Eğer kompakt mod seçilmişse yalnızca ikonu döndürür.
    if (compact) {
      return logoIcon;
    }

    // İkon ile yanındaki başlık ve slogan metinlerini yatay olarak dizer.
    return Row(
      mainAxisSize:
          MainAxisSize.min, // Sadece içeriği kadar genişlik kaplamasını sağlar.
      crossAxisAlignment:
          CrossAxisAlignment.center, // Elemanları dikey eksende dikey ortalar.
      children: [
        logoIcon, // Soldaki logo ikonu.
        SizedBox(
          width: size * 0.25,
        ), // İkon ile metin arasına boyuta oranlı yatay boşluk bırakır.
        Flexible(
          // Taşmaları önlemek için metin sütununu esnek yapar.
          child: Column(
            mainAxisSize:
                MainAxisSize.min, // Dikeyde yalnızca içeriği kadar yer kaplar.
            crossAxisAlignment:
                CrossAxisAlignment.start, // Metinleri sola hizalar.
            children: [
              // Farklı renk ve stillerdeki metin parçalarını birleştirmek için Text.rich kullanılır.
              Text.rich(
                TextSpan(
                  text: 'Board', // Başlığın ilk kısmı.
                  style: TextStyle(
                    fontSize: size * 0.52, // Başlık font boyutu.
                    fontWeight: FontWeight.w800, // Ekstra kalın yazı tipi.
                    letterSpacing: -0.5, // Harfler arası hafif sıkılaştırma.
                    color: isDark
                        ? Colors.white
                        : const Color(0xFF1E293B), // Açık/koyu moda göre renk.
                  ),
                  children: [
                    TextSpan(
                      text:
                          'Connect', // Başlığın vurgu rengindeki ikinci kısmı.
                      style: TextStyle(
                        color: theme
                            .colorScheme
                            .primary, // Marka vurgu rengi (sarı).
                        fontWeight:
                            FontWeight.w900, // En kalın yazı tipi ağırlığı.
                      ),
                    ),
                  ],
                ),
                maxLines: 1, // Tek satırda kalmasını sağlar.
                overflow:
                    TextOverflow.ellipsis, // Sığmazsa üç nokta ile kısaltır.
              ),
              // Eğer slogan gösterimi etkinse alt başlık metnini ekler.
              if (showTagline)
                Text(
                  'Sonsuz Ortak Tuval', // Alt açıklama metni.
                  style: TextStyle(
                    fontSize: size * 0.26, // Slogan yazı boyutu.
                    fontWeight: FontWeight.w500, // Orta kalınlıkta yazı.
                    color: isDark
                        ? Colors.white70
                        : Colors.black54, // İkincil soluk metin rengi.
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
