import 'package:flutter/material.dart';

import '../models/asset_model.dart';
import '../models/transaction_model.dart'; // bu ekranda kullanıalcak modelleri importları

class MarketGridListScreen extends StatelessWidget {
  // Piyasa ve işlem listesini gösteren durumsuz ekran
  const MarketGridListScreen({
    super.key,
  }); // Ekran widgetının oluşturulmasını ve takip edilmesini sağlar

  // Kripto varlıkların örnek verileri (değiştirilemeyen liste)
  static const List<Asset> assets = [
    Asset(
      symbol: 'BTC',
      name: 'Bitcoin',
      price: 67420.00,
      change24h: 4.20, // Son 24 saatteki yüzdelik fiyat değişimi
      balance: 0.4,
    ),
    Asset(
      symbol: 'ETH',
      name: 'Ethereum',
      price: 3500,
      change24h: -1.80,
      balance: 4.20,
    ),
    Asset(
      symbol: 'SOL',
      name: 'Solana',
      price: 200.00,
      change24h: 0.5,
      balance: 85.00,
    ),
  ];

  // Örnek gelir ve gider işlemleri
  static const List<TransactionItem> transactions = [
    TransactionItem(
      id: 'tx_1',
      title: 'Apple Store',
      category: 'Teknoloji',
      date: 'Bugün 14:20',
      amount: 64500,
      icon: Icons.laptop_mac,
      isExpanse: true, // İşlemin gider olduğunu belirtir
    ),
    TransactionItem(
      id: 'tx_2',
      title: 'Kodusta Danışmanlık Hakediş',
      category: 'Kurumsal Gelir',
      date: 'Dün 09:00',
      amount: 125000.00,
      icon: Icons.account_balance,
      isExpanse: false, // İşlemin gelir olduğunu belirtir
    ),
    TransactionItem(
      id: 'tx_3',
      title: 'Market Alışverişi',
      category: 'Alışveriş',
      date: 'Dün 18:30',
      amount: 2450,
      icon: Icons.shopping_cart,
      isExpanse: true,
    ),
    TransactionItem(
      id: 'tx_4',
      title: 'Restoran',
      category: 'Yeme İçme',
      date: '12 Ekim 20:15',
      amount: 1850,
      icon: Icons.restaurant,
      isExpanse: true,
    ),
  ];

  @override // Üst sınıftaki build metodunu yeniden tanımlar
  Widget build(BuildContext context) {
    // Ekranda gösterilecek widget ağacını oluşturur
    // SingleChildScrollView: Sayfadaki tüm içeriği kaydırılabilir yapar
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(), // Kaydırma sınırında esneme efekti uygular
      padding: const EdgeInsets.all(
        20,
      ), // Ekran içeriğine her yönden boşluk ekler

      child: Column(
        // Bölümleri dikey olarak sıralar
        crossAxisAlignment: CrossAxisAlignment.start, // İçerikleri sola hizalar
        children: [
          _buildHeader(), // Ekran başlığı

          const SizedBox(height: 24), // dikey boşlu
          // Kripto varlıklar bölümü
          _buildSectionTitle(
            title: "Piyasa Takibi",
            subtitle: "Kripto varlıkların güncel durumu",
          ),

          const SizedBox(height: 16),

          _buildAssetGrid(), // GridView ile kart görünümü

          const SizedBox(height: 32),

          // İşlem geçmişi başlığı
          _buildSectionTitle(
            title: "Son İşlemler",
            subtitle: "Hesap hareketlerin",
          ),

          const SizedBox(height: 16),

          _buildTransactionList(), // ListView ile işlem listesi

          const SizedBox(height: 24),

          _buildSummaryCard(), // Gelir gider özeti

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // =====================================================
  // 1. EKRAN BAŞLIĞI
  // Row: Elemanları yatay sıralar.
  // Expanded: Kalan boşluğu doldurur.
  // =====================================================
  Widget _buildHeader() {
    // Ekranın üst başlık alanını oluşturur
    return Row(
      children: [
        const Expanded(
          // Başlık alanının kullanılabilir genişliği doldurmasını sağlar
          child: Column(
            // Başlık ve açıklamayı alt alta yerleştirir
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Piyasalar & İşlemler",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 6),
              Text(
                "Varlıklarını ve işlemlerini takip et",
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),

        Container(
          // Başlığın sağındaki ikon kutusu
          padding: const EdgeInsets.all(12), //iç boşluk
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.bar_chart, color: Color(0xFF6366F1)),
        ),
      ],
    );
  }

  Widget _buildSectionTitle({required String title, required String subtitle}) {
    // Farklı başlık ve alt başlıklarla kullanılabilen bölüm
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title, // Parametre olarak gelen başlık
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle, // Parametre olarak gelen açıklama
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
      ],
    );
  }

  // =====================================================
  // 2. GRIDVIEW
  //
  // GridView.builder:
  // Verilere göre dinamik kartlar oluşturur.
  //
  // shrinkWrap:
  // GridView'ın içeriği kadar yer kaplamasını sağlar.
  //
  // NeverScrollableScrollPhysics:
  // İç içe kaydırma sorununu engeller.
  // =====================================================
  Widget _buildAssetGrid() {
    // Kripto varlıklarını ızgara düzeninde oluşturur
    return GridView.builder(
      // Listedeki her varlık için ayrı kart üretir
      shrinkWrap:
          true, // Izgaranın içerik yüksekliği kadar alan kaplamasını sağlar
      physics: const NeverScrollableScrollPhysics(), // İç içe kaydırmayı önleyerek ana sayfanın kaydırılmasını kullanır

      itemCount: assets
          .length, // Oluşturulacak kart sayısını varlık listesine göre belirler

      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        // Izgaranın sütun ve boşluk düzenini belirler
        crossAxisCount: 2, // Her satırda iki kart
        crossAxisSpacing: 12, // Kartlar arasında yatay boşluk
        mainAxisSpacing: 12, // Kartlar arasında dikey boşluk
        mainAxisExtent: 190, // Kart yüksekliğini sabitler
      ),

      itemBuilder: (context, index) {
        // Her kartın hangi veriden oluşturulacağını belirler
        // Listedeki sıradaki varlığı alır.
        final asset = assets[index];

        return _buildAssetCard(
          asset,
        ); // Seçilen varlık için kart widgetı oluşturur
      },
    );
  }

  // =====================================================
  // 3. KRİPTO VARLIK KARTI
  // =====================================================
  Widget _buildAssetCard(Asset asset) {
    // Verilen kripto varlığının bilgi kartı
    // Pozitif veya negatif fiyat değişimini kontrol eder
    final bool isPositive =
        asset.change24h >=
        0; // Fiyat değişiminin sıfır veya pozitif olup olmadığını kontrol eder

    final Color changeColor = isPositive
        ? Colors.green
        : Colors.red; // Değişim yönüne göre yeşil veya kırmızı renk

    return Container(
      // Kartın dış kutusu
      padding: const EdgeInsets.all(14), // Kartın iç boşluğu
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        // Kart içeriğini dikey sıralar
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 19,
                backgroundColor: const Color(0xFFEEF2FF),
                child: Text(
                  asset.symbol.substring(
                    0,
                    1,
                  ), // Varlık kodunun ilk harfini gösterir
                  style: const TextStyle(
                    color: Color(0xFF6366F1),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                // Kod metninin satırdaki kalan alana yayılmasını sağlar
                child: Text(
                  asset.symbol,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            asset.name,
            maxLines: 1, // Varlık adını tek satırla sınırlar
            overflow:
                TextOverflow.ellipsis, // Uzun isimleri üç noktayla kısaltır
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),

          const SizedBox(height: 6),
          FittedBox(
            // Fiyat metninin kartın genişliğine sığmasını sağlar
            fit: BoxFit.scaleDown, // Metin sığmadığında boyutunu küçültür
            alignment: Alignment.centerLeft,
            child: Text(
              "\$${asset.price.toStringAsFixed(2)}", // Fiyatı virgülden sonra iki basamakla gösterir
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),

          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down, // Fiyat yönüne göre yükseliş veya düşüş ikonu gösterir
                color: changeColor,
                size: 18,
              ),

              const SizedBox(width: 4),

              Text(
                "${isPositive ? '+' : ''}${asset.change24h.toStringAsFixed(2)}%", // Fiyat değişimini yüzde biçiminde gösterir
                style: TextStyle(
                  color: changeColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const Spacer(), // Kalan dikey boşluğu kullanarak bakiyeyi alta iter

          Text(
            "Bakiye: ${asset.balance}", // Kullanıcının varlık miktarını gösterir
            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // 4. LISTVIEW
  //
  // ListView.separated:
  // Liste elemanlarının arasına boşluk veya çizgi ekler.
  //
  // itemBuilder:
  // Her işlem için ayrı bir kart oluşturur.
  // =====================================================
  Widget _buildTransactionList() {
    // İşlem geçmişini ayrı satırlar halinde oluşturur
    return ListView.separated(
      // İşlemleri aralarında boşluk bırakarak listeler
      shrinkWrap: true, // Listeyi içerik yüksekliğiyle sınırlar
      physics: const NeverScrollableScrollPhysics(), // Ana sayfa dışında ayrı kaydırmayı engeller

      itemCount: transactions.length, // Gösterilecek işlem sayısını belirler

      separatorBuilder: (context, index) {
        // İşlemlerin arasına eklenecek alanı oluşturur
        return const SizedBox(height: 12);
      },

      itemBuilder: (context, index) {
        // Her işlem satırını dinamik oluşturur
        final transaction =
            transactions[index]; // Listedeki sıradaki işlemi alır

        return _buildTransactionItem(
          transaction,
        ); // İşlem verisini kart oluşturma metoduna gönderir
      },
    );
  }

  // =====================================================
  // 5. İŞLEM LİSTESİ ELEMANI
  // =====================================================
  Widget _buildTransactionItem(TransactionItem transaction) {
    // Tek bir işlem satırının görünümünü oluşturur
    // Gider ise kırmızı gelir ise yeşil
    final bool isExpense =
        transaction.isExpanse; // İşlemin gider olup olmadığını belirler

    final Color amountColor = isExpense
        ? Colors.red
        : Colors.green; // İşlem türüne göre tutarın rengini seçer

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),

      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color:
                  isExpense // Gider ve gelir için farklı arka plan rengi seçer
                  ? const Color(0xFFFEF2F2)
                  : const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              transaction.icon,
              color: amountColor,
            ), // İşleme ait ikonu uygun renkte gösterir
          ),

          const SizedBox(width: 12),

          // İşlem açıklamaları
          Expanded(
            // Açıklama alanının kalan genişliği kullanmasını sağlar
            child: Column(
              // İşlem bilgilerini alt alta sıralar
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  maxLines: 1,
                  overflow: TextOverflow
                      .ellipsis, // Uzun işlem başlıklarını üç noktayla kısaltır
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  transaction.category,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  transaction.date,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // İşlem tutarı
          Text(
            "${isExpense ? '-' : '+'}₺${transaction.amount.toStringAsFixed(2)}", // Geliri artı gideri eksi işaretiyle gösterir
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // 6. GELİR GİDER ÖZETİ
  //
  // fold:
  // Liste içindeki sayısal verileri toplayabilir.
  // =====================================================
  Widget _buildSummaryCard() {
    // Gelir gider ve net bakiyeyi hesaplayıp gösterir
    final double totalIncome =
        transactions // Yalnızca gelirleri toplayarak toplam geliri hesaplar
            .where(
              (item) => !item.isExpanse,
            ) // Gider olmayan işlemleri filtreler
            .fold<double>(
              0.0,
              (sum, item) => sum + item.amount,
            ); // Filtrelenen işlemlerin tutarlarını toplar

    // Toplam gideri hesapla.
    final double totalExpense =
        transactions // Yalnızca giderleri toplayarak toplam gideri hesaplar
            .where((item) => item.isExpanse) // Gider işlemlerini filtreler
            .fold<double>(
              0.0,
              (sum, item) => sum + item.amount,
            ); // Gider tutarlarını sıfırdan başlayarak toplar

    // Net bakiye
    final double netBalance =
        totalIncome -
        totalExpense; // Toplam gelirden gideri çıkararak net bakiyeyi bulur

    return Container(
      width:
          double.infinity, // Kartın kullanılabilir genişliği kaplamasını sağlar
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        // Özet içeriğini dikey sıralar
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "İşlem Özeti",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            // Gelir ve gider alanlarını yatay yerleştirir
            children: [
              Expanded(
                // Gelir alanına kullanılabilir genişlikten pay verir
                child: _buildSummaryValue(
                  // Gelir tutarını yeşil renkte gösteren alanı oluşturur
                  "Toplam Gelir",
                  totalIncome,
                  Colors.greenAccent,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                // Gider alanına kullanılabilir genişlikten pay verir
                child: _buildSummaryValue(
                  // Gider tutarını kırmızı renkte gösteren alanı oluşturur
                  "Toplam Gider",
                  totalExpense,
                  Colors.redAccent,
                ),
              ),
            ],
          ),

          const Divider(
            color: Colors.white24,
            height: 32,
          ), // Gelir gider toplamlarıyla net bakiye arasına çizgi koyar

          const Text(
            "Net İşlem Bakiyesi",
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),

          const SizedBox(height: 8),

          Text(
            "₺${netBalance.toStringAsFixed(2)}", // Net bakiyeyi iki ondalık basamakla gösterir
            style: TextStyle(
              color: netBalance >= 0 ? Colors.greenAccent : Colors.redAccent, // Net bakiye pozitifse yeşil negatifse kırmızı kullanır
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryValue(String title, double amount, Color color) {
    // Başlık tutar ve renkle tekrar kullanılabilen özet alanını oluşturur
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),

        const SizedBox(height: 8),

        FittedBox(
          // Tutarın alana sığmasını sağlar
          fit: BoxFit.scaleDown, // Gerekli olduğunda tutar metnini küçültür
          alignment: Alignment.centerLeft,
          child: Text(
            "₺${amount.toStringAsFixed(2)}",
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
