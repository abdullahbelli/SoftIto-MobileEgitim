import 'package:flutter/material.dart'; // flutter arayüz bileşenleri

// Değişen verileri olan ekran widget'ını tanımlar.
class LayoutStylingScreen extends StatefulWidget {
  // değişen verileri olan ekran widgetını tanımlar
  const LayoutStylingScreen({
    super.key,
  }); //ekran constructorı (ekran oluşturulurken çalışır)
  //super.key widgetın flutter tarafından tanınmasını ve widget ağacında doğru şekilde takip edilmesini sağlar

  @override // üst sınıftan gelen bir metodun yeniden tanımlandığını belirtir.
  State<LayoutStylingScreen> createState() => _LayoutStylingScreenState(); //ekranın state nesnesini oluşturu (değişen veilere göre ekranın yeniden çizilmsi sağlanabilir)
}

// State: Ekrandaki değişebilen verileri tutar.
// setState: Veriyi günceller ve ekranın yeniden çizilmesini sağlar
class _LayoutStylingScreenState extends State<LayoutStylingScreen> {
  //ekranın durmu ve arayüz yönetilir
  bool _isBalancedVisible = true; // Bakiyenin görünürlük durumunu tutar
  String _lastAction =
      "Hazır - Butonlara Tıklayabilirsiniz"; // Son yapılan işlemi saklar

  void _updateAction(String action) {
    // Son işlem bilgisini günceller
    // Durumun değiştiğini fluttera bildirir
    setState(() {
      _lastAction = action; // Yeni işlem açıklamasını kaydeder
    });
  }

  @override
  // Ekranın arayüzünü oluşturur.
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // İçerik ekranı aşarsa kaydırma yapılmasını sağlar.

      physics: const BouncingScrollPhysics(), // kaydırmaya esneme efekti ekler

      padding: const EdgeInsets.only(
        bottom: 32,
      ), // alttan 32 birim boşluk bırakır
      // Elemanları dikey sıralar.
      child: Column(
        // Elemanları sola hizalar. (başlangı sol üst köşe) end yazarsa nesne yoksa sağ üst köşe)
        crossAxisAlignment: CrossAxisAlignment.start,
        // Gösterilecek widgetların listesi.
        children: [
          // 1. Profil ve çevrimiçi rozeti
          _buildProfileHeader(),

          // 2. Cüzdan ve bakiye kartı
          _buildWalletCard(),

          // 3. Hızlı işlem butonları
          _buildQuickActions(),

          // 4. Flex kullanılarak oluşturulan istatistikler
          _buildFlexStatistics(),

          // 5. Bildirim banner'ı
          _buildNotificationBanner(),

          // 6. Son işlem bilgisi
          // İçeriği ortalar.
          Center(
            // İç boşluk
            child: Padding(
              padding: const EdgeInsets.all(16.0), // Her yönden 16 birim boşluk
              child: Text(
                'Son İşlem: $_lastAction', // Son işlemi ekrana yazdırır

                textAlign: TextAlign.center, // Metni ortalar
                // Metnin görünümü
                style: const TextStyle(
                  fontSize: 13, // Yazı boyutu
                  color: Color(0xFF64748B), // Yazı rengi
                  fontStyle: FontStyle.italic, // italik yazı
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // 1. PROFİL BAŞLIĞI
  // Row: Elemanları yatay olarak sıralar.
  // Stack: Elemanları üst üste yerleştirir.
  // Positioned: Stack içindeki konumu belirler.
  // =====================================================

  // Profil başlığını oluşturan metot
  Widget _buildProfileHeader() {
    // Profil bölümüne boşluk ekler
    return Padding(
      // Sol, üst, sağ ve alt boşlukları belirler
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      // Elemanları yatay sıralar
      child: Row(
        children: [
          // Profil ikonu ile rozeti üst üste yerleştirir
          Stack(
            clipBehavior: Clip.none, // Dışarı taşan elemanları kesmez
            children: [
              Container(
                // Profil ikonu için kutu oluşturur
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  // Kutunun tasarımı
                  // Kutuyu yuvarlak yapar
                  shape: BoxShape.circle,
                  color: const Color(0x1F6366F1),
                  border: Border.all(color: const Color(0xFF6366F1), width: 2),
                ),
                // Kullanıcı ikonu
                child: const Icon(
                  Icons.person,
                  size: 32,
                  color: Color(0xFF6366F1),
                ),
              ),

              // Profil fotoğrafının sağ altındaki online rozeti
              // Rozeti belirli bir konuma yerleştirir
              Positioned(
                // Sağ kenara hizalar
                right: 0,
                // Alt kenara hizalar
                bottom: 0,
                // Çevrimiçi rozeti oluşturur
                child: Container(
                  width: 16,
                  height: 16,
                  // Rozetin görünümü
                  decoration: BoxDecoration(
                    color: Colors.green,
                    // Yuvarlak yapar
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                ),
              ),
            ],
          ),

          // Yatay boşluk bırakır.
          const SizedBox(width: 12),

          // Expanded: Row içinde kalan yatay alanı kaplar.
          const Expanded(
            // Metinleri dikey sıralar
            child: Column(
              // Metinleri sola hizalar
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Merhaba, Abdullah 👋",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                // Dikey boşluk bırakır.
                SizedBox(height: 4),
                Text(
                  "Tekrar hoş geldin!",
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),

          // Bildirim butonu
          IconButton(
            // Butona basılınca çalışır
            onPressed: () {
              // Son işlem bilgisini günceller
              _updateAction("Bildirimler açıldı");
            },
            // Bildirim ikonu
            icon: const Icon(Icons.notifications_outlined),
            // Butonun açıklama metni
            tooltip: "Bildirimler",
          ),
        ],
      ),
    );
  }

  // =====================================================
  // 2. CÜZDAN KARTI
  // Container: Boyut, padding ve dekorasyon sağlar.
  // BoxDecoration: Renk, kenarlık ve köşe yuvarlama.
  // =====================================================

  // Cüzdan kartını oluşturan metot
  Widget _buildWalletCard() {
    // Cüzdan kartı için kutu
    return Container(
      // Kullanılabilir genişliği kaplar
      width: double.infinity,
      // Dış boşluklar
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      // İç boşluk
      padding: const EdgeInsets.all(24),
      // Kartın tasarımı
      decoration: BoxDecoration(
        // Renk geçişi
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF4338CA)],
          begin: Alignment.topLeft,
          end: Alignment
              .bottomRight, //renk geçisi sol üstten başlar sağ altta biter
        ),
        // Kartın köşelerini yuvarlar
        borderRadius: BorderRadius.circular(20),
        // Kartın gölgelerini tanımlar.
        boxShadow: [
          BoxShadow(
            // Gölge rengi ve saydamlığı
            color: const Color(0xFF6366F1).withValues(alpha: 0.25),
            // Gölgenin bulanıklığı
            blurRadius: 16,
            // Gölgeyi aşağı kaydırır
            offset: const Offset(0, 8),
          ),
        ],
      ),
      // Kart içeriğini dikey sıralar
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık ve görünürlük butonunu yatay sıralar
          Row(
            // Elemanları iki uca yerleştirir
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Toplam Bakiyem",

                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
              // Bakiye gizleme/gösterme butonu
              IconButton(
                // Butona basıldığında çalışır
                onPressed: () {
                  // Durumu günceller
                  setState(() {
                    // true değerini false, false değerini true yapar
                    _isBalancedVisible = !_isBalancedVisible;
                    // Duruma göre işlem mesajını belirler
                    _lastAction = _isBalancedVisible
                        ? "Bakiye gösterildi"
                        : "Bakiye gizlendi";
                  });
                },
                // Görünürlük ikonu
                icon: Icon(
                  // Duruma göre farklı ikon
                  _isBalancedVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,

                  color: Colors.white,
                ),
              ),
            ],
          ),

          // Dikey boşluk
          const SizedBox(height: 12),

          // Koşullu gösterim: State değerine göre içerik değişir
          Text(
            // true ise bakiye, false ise yıldızlar gösterilir
            _isBalancedVisible ? "₺ 24.850,75" : "₺ ••••••",

            style: const TextStyle(
              color: Colors.white,

              fontSize: 32,

              fontWeight: FontWeight.bold,
            ),
          ),

          // Dikey boşluk bırakır.
          const SizedBox(height: 20),

          // Artış bilgisini yatay gösterir.
          const Row(
            children: [
              // Yükseliş ikonu.
              Icon(Icons.trending_up, color: Color(0xFF86EFAC)),
              // Yatay boşluk.
              SizedBox(width: 8),
              // Aylık artış metni.
              Text(
                "Bu ay +%12,5 artış",
                // Metnin görünümü.
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =====================================================
  // 3. HIZLI İŞLEM BUTONLARI
  // Row: Yatay yerleşim.
  // Expanded: Butonların eşit alan kaplamasını sağlar.
  // InkWell: Dokunma/tıklama olayını yakalar.
  // =====================================================

  // Hızlı işlem bölümünü oluşturur
  Widget _buildQuickActions() {
    // İç boşluk
    return Padding(
      // Sağdan ve soldan 20 birim boşluk
      padding: const EdgeInsets.symmetric(horizontal: 20),
      // Elemanları dikey sıralar
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Hızlı İşlemler",

            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          // Dikey boşluk
          const SizedBox(height: 16),

          // Butonları yatay sıralar
          Row(
            children: [
              // İlk butonun kullanılabilir alanı paylaşmasını sağlar
              Expanded(
                // Para ekleme butonu
                child: _buildActionButton(
                  icon: Icons.add,

                  title: "Para Ekle",

                  color: Colors.green,
                  // Tıklanınca son işlem bilgisini günceller
                  onTap: () => _updateAction("Para Ekle tıklandı"),
                ),
              ),
              // Butonlar arasına boşluk
              const SizedBox(width: 12),
              // İkinci butonun alanı paylaşmasını sağlar
              Expanded(
                child: _buildActionButton(
                  icon: Icons.send,

                  title: "Transfer",

                  color: Colors.blue,

                  onTap: () => _updateAction("Transfer tıklandı"),
                ),
              ),
              // Yatay boşluk
              const SizedBox(width: 12),
              // Üçüncü butonun alanı paylaşmasını sağlar
              Expanded(
                child: _buildActionButton(
                  icon: Icons.history,

                  title: "Geçmiş",

                  color: Colors.orange,

                  onTap: () => _updateAction("Geçmiş tıklandı"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Tekrar kullanılabilir buton widgetı
  // Parametre alarak ortak bir buton oluşturu
  Widget _buildActionButton({
    required IconData icon,

    required String title,

    required Color color,

    required VoidCallback onTap, //zorunlu alanlar
  }) {
    // Material görünümünü sağlar
    return Material(
      // Arka planı şeffaf yapar
      color: Colors.transparent,
      // Tıklanabilir alan oluşturur
      child: InkWell(
        // Tıklama fonksiyonunu bağlar
        onTap: onTap,
        // Dokunma efektinin köşelerini yuvarlar
        borderRadius: BorderRadius.circular(16),
        // Butonun kutusunu oluşturur
        child: Container(
          // İç boşluklar
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 4),
          // Kutunun görünümü
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E8F0)),

            borderRadius: BorderRadius.circular(16),
          ),
          // İkon ve başlığı dikey sıralar
          child: Column(
            children: [
              // Parametreden gelen ikon
              Icon(icon, color: color, size: 28),
              // Dikey boşluk
              const SizedBox(height: 10),

              Text(
                title,
                // Metni ortalar.
                textAlign: TextAlign.center,

                style: const TextStyle(
                  fontSize: 12,
                  // Yarı kalın yaz
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================
  // 4. FLEX İSTATİSTİKLER
  // Expanded(flex: n) ile oranlı alan paylaşımı.
  // Burada 2:1 oranı kullanılıyor.
  // =====================================================

  Widget _buildFlexStatistics() {
    //iç boşluk
    return Padding(
      padding: const EdgeInsets.all(20),
      // Elemanları dikey sıralar.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "İstatistikler",

            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          // Dikey boşluk
          const SizedBox(height: 16),

          // İstatistik kartlarını yatay sıralar
          Row(
            children: [
              // İlk kartın daha fazla alan kaplamasını sağlar
              Expanded(
                // Kalan alanın 2 payını alır
                flex: 2,
                // Gelir kartını oluşturur
                child: _buildStatisticCard(
                  title: "Aylık Gelir",
                  value: "₺ 18.450",
                  icon: Icons.arrow_downward,
                  color: Colors.green,
                ),
              ),
              // Kartlar arasında boşluk
              const SizedBox(width: 12),
              // İkinci kartın alanı paylaşmasını sağlar
              Expanded(
                // Kalan alanın 1 payını alır
                flex: 1,
                // Gider kartını oluşturur
                child: _buildStatisticCard(
                  title: "Gider",
                  value: "₺ 6.250",
                  icon: Icons.arrow_upward,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Tekrar kullanılabilir istatistik kartı
  Widget _buildStatisticCard({
    //zorunlu alanlar
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    // Kart için kutu
    return Container(
      // İç boşluk
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),

        borderRadius: BorderRadius.circular(16),

        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ), // Saydam kenarlık
      ),
      // Elemanları dikey sıralar
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),

          const SizedBox(height: 12),

          Text(
            title,

            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          // Dikey boşluk
          const SizedBox(height: 6),
          // Metnin taşmasını önlemek için küçültebilir
          FittedBox(
            fit: BoxFit.scaleDown, // Gerektiğinde içeriği küçültür

            alignment: Alignment.centerLeft, // İçeriği sola hizalar.

            child: Text(
              value,

              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // 5. BİLDİRİM BANNER'I
  // Flexible: İçeriğin kullanılabilir alana uyum sağlaması.
  // =====================================================

  Widget _buildNotificationBanner() {
    // Bildirim kutusunu oluşturur
    return Container(
      // Dış boşluklar
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      // İç boşluk
      padding: const EdgeInsets.all(16),
      // Kutunun tasarımı
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      // Elemanları yatay sıralar
      child: Row(
        children: [
          // Bilgi ikonunu gösterir
          const Icon(Icons.info_outline, color: Color(0xFF2563EB), size: 28),
          // Yatay boşluk
          const SizedBox(width: 12),

          // İçeriğin mevcut genişliğe uyum sağlamasına yardımcı olur
          Flexible(
            // Bildirim içeriğini dikey sıralar
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Yeni Özellik!",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D4ED8),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Artık harcamalarını daha kolay takip edebilirsin.",
                  style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
                ),
                const SizedBox(height: 8),
                // Dokunma hareketlerini algılar
                GestureDetector(
                  // Metne tıklanınca çalışır
                  onTap: () {
                    // Son işlem bilgisini günceller
                    _updateAction("Yeni özellik incelendi");
                  },
                  child: const Text(
                    "Detayları Gör →",
                    style: TextStyle(
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
