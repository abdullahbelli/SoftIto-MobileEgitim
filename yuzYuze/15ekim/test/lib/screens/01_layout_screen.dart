import 'package:flutter/material.dart';

class LayoutStylingScreen extends StatefulWidget {
  const LayoutStylingScreen({super.key});

  @override
  State<LayoutStylingScreen> createState() => _LayoutStylingScreenState();
}

class _LayoutStylingScreenState extends State<LayoutStylingScreen> {
  // State: Ekrandaki değişebilen verileri tutar.
  bool _isBalancedVisible = true;
  String _lastAction = "Hazır - Butonlara Tıklayabilirsiniz";

  // setState: Veriyi günceller ve ekranın yeniden çizilmesini sağlar.
  void _updateAction(String action) {
    setState(() {
      _lastAction = action;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // İçerik ekranı aşarsa kaydırma yapılmasını sağlar.
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 32),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Son İşlem: $_lastAction',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  fontStyle: FontStyle.italic,
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
  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0x1F6366F1),
                  border: Border.all(color: const Color(0xFF6366F1), width: 2),
                ),
                child: const Icon(
                  Icons.person,
                  size: 32,
                  color: Color(0xFF6366F1),
                ),
              ),

              // Profil fotoğrafının sağ altındaki online rozeti
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),

          // Expanded: Row içinde kalan yatay alanı kaplar.
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Merhaba, Abdullah 👋",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  "Tekrar hoş geldin!",
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () {
              _updateAction("Bildirimler açıldı");
            },
            icon: const Icon(Icons.notifications_outlined),
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
  Widget _buildWalletCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF4338CA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Toplam Bakiyem",
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isBalancedVisible = !_isBalancedVisible;
                    _lastAction = _isBalancedVisible
                        ? "Bakiye gösterildi"
                        : "Bakiye gizlendi";
                  });
                },
                icon: Icon(
                  _isBalancedVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Koşullu gösterim: State değerine göre içerik değişir.
          Text(
            _isBalancedVisible ? "₺ 24.850,75" : "₺ ••••••",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          const Row(
            children: [
              Icon(Icons.trending_up, color: Color(0xFF86EFAC)),
              SizedBox(width: 8),
              Text(
                "Bu ay +%12,5 artış",
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
  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Hızlı İşlemler",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.add,
                  title: "Para Ekle",
                  color: Colors.green,
                  onTap: () => _updateAction("Para Ekle tıklandı"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.send,
                  title: "Transfer",
                  color: Colors.blue,
                  onTap: () => _updateAction("Transfer tıklandı"),
                ),
              ),
              const SizedBox(width: 12),
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

  // Tekrar kullanılabilir buton widget'ı
  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 4),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
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
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "İstatistikler",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildStatisticCard(
                  title: "Aylık Gelir",
                  value: "₺ 18.450",
                  icon: Icons.arrow_downward,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
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

  Widget _buildStatisticCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF2563EB), size: 28),
          const SizedBox(width: 12),

          Flexible(
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
                GestureDetector(
                  onTap: () {
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
