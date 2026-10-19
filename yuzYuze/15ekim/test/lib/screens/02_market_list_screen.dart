import 'package:flutter/material.dart';

import '../models/asset_model.dart';
import '../models/transaction_model.dart';

class MarketGridListScreen extends StatelessWidget {
  const MarketGridListScreen({super.key});

  // Kripto varlıkların örnek verileri
  static const List<Asset> assets = [
    Asset(
      symbol: 'BTC',
      name: 'Bitcoin',
      price: 67420.00,
      change24h: 4.20,
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

  // İşlem geçmişi
  static const List<TransactionItem> transactions = [
    TransactionItem(
      id: 'tx_1',
      title: 'Apple Store',
      category: 'Teknoloji',
      date: 'Bugün 14:20',
      amount: 64500,
      icon: Icons.laptop_mac,
      isExpanse: true,
    ),
    TransactionItem(
      id: 'tx_2',
      title: 'Kodusta Danışmanlık Hakediş',
      category: 'Kurumsal Gelir',
      date: 'Dün 09:00',
      amount: 125000.00,
      icon: Icons.account_balance,
      isExpanse: false,
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

  @override
  Widget build(BuildContext context) {
    // SingleChildScrollView:
    // Sayfadaki tüm içeriği kaydırılabilir yapar.
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ekran başlığı
          _buildHeader(),

          const SizedBox(height: 24),

          // Kripto varlıklar bölümü
          _buildSectionTitle(
            title: "Piyasa Takibi",
            subtitle: "Kripto varlıkların güncel durumu",
          ),

          const SizedBox(height: 16),

          // GridView ile kart görünümü
          _buildAssetGrid(),

          const SizedBox(height: 32),

          // İşlem geçmişi başlığı
          _buildSectionTitle(
            title: "Son İşlemler",
            subtitle: "Hesap hareketlerin",
          ),

          const SizedBox(height: 16),

          // ListView ile işlem listesi
          _buildTransactionList(),

          const SizedBox(height: 24),

          // Gelir gider özeti
          _buildSummaryCard(),

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
    return Row(
      children: [
        const Expanded(
          child: Column(
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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.bar_chart, color: Color(0xFF6366F1)),
        ),
      ],
    );
  }

  // Tekrar kullanılabilir bölüm başlığı
  Widget _buildSectionTitle({required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
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
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),

      itemCount: assets.length,

      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 190,
      ),

      itemBuilder: (context, index) {
        // Listedeki sıradaki varlığı alır.
        final asset = assets[index];

        return _buildAssetCard(asset);
      },
    );
  }

  // =====================================================
  // 3. KRİPTO VARLIK KARTI
  // =====================================================
  Widget _buildAssetCard(Asset asset) {
    // Pozitif veya negatif fiyat değişimini kontrol eder.
    final bool isPositive = asset.change24h >= 0;

    final Color changeColor = isPositive ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.all(14),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kripto simgesi ve sembolü
          Row(
            children: [
              CircleAvatar(
                radius: 19,
                backgroundColor: const Color(0xFFEEF2FF),
                child: Text(
                  asset.symbol.substring(0, 1),
                  style: const TextStyle(
                    color: Color(0xFF6366F1),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),

          const SizedBox(height: 6),

          // Fiyat bilgisi
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              "\$${asset.price.toStringAsFixed(2)}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),

          const SizedBox(height: 10),

          // Günlük fiyat değişimi
          Row(
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                color: changeColor,
                size: 18,
              ),

              const SizedBox(width: 4),

              Text(
                "${isPositive ? '+' : ''}${asset.change24h.toStringAsFixed(2)}%",
                style: TextStyle(
                  color: changeColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const Spacer(),

          Text(
            "Bakiye: ${asset.balance}",
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
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),

      itemCount: transactions.length,

      separatorBuilder: (context, index) {
        return const SizedBox(height: 12);
      },

      itemBuilder: (context, index) {
        final transaction = transactions[index];

        return _buildTransactionItem(transaction);
      },
    );
  }

  // =====================================================
  // 5. İŞLEM LİSTESİ ELEMANI
  // =====================================================
  Widget _buildTransactionItem(TransactionItem transaction) {
    // Gider ise kırmızı, gelir ise yeşil.
    final bool isExpense = transaction.isExpanse;

    final Color amountColor = isExpense ? Colors.red : Colors.green;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),

      child: Row(
        children: [
          // İşlem kategorisi ikonu
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isExpense
                  ? const Color(0xFFFEF2F2)
                  : const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(transaction.icon, color: amountColor),
          ),

          const SizedBox(width: 12),

          // İşlem açıklamaları
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
            "${isExpense ? '-' : '+'}₺${transaction.amount.toStringAsFixed(2)}",
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
    // Toplam geliri hesapla.
    final double totalIncome = transactions
        .where((item) => !item.isExpanse)
        .fold<double>(0.0, (sum, item) => sum + item.amount);

    // Toplam gideri hesapla.
    final double totalExpense = transactions
        .where((item) => item.isExpanse)
        .fold<double>(0.0, (sum, item) => sum + item.amount);

    // Net bakiye
    final double netBalance = totalIncome - totalExpense;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
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
            children: [
              Expanded(
                child: _buildSummaryValue(
                  "Toplam Gelir",
                  totalIncome,
                  Colors.greenAccent,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _buildSummaryValue(
                  "Toplam Gider",
                  totalExpense,
                  Colors.redAccent,
                ),
              ),
            ],
          ),

          const Divider(color: Colors.white24, height: 32),

          const Text(
            "Net İşlem Bakiyesi",
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),

          const SizedBox(height: 8),

          Text(
            "₺${netBalance.toStringAsFixed(2)}",
            style: TextStyle(
              color: netBalance >= 0 ? Colors.greenAccent : Colors.redAccent,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Tekrar kullanılabilir özet alanı
  Widget _buildSummaryValue(String title, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),

        const SizedBox(height: 8),

        FittedBox(
          fit: BoxFit.scaleDown,
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
