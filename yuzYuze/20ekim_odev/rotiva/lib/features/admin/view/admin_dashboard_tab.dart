// Flutter Material tasarım bileşenlerini içeri aktarıyoruz.
import 'package:flutter/material.dart';

// Sabitler, formatlayıcılar ve özel widget'ları içeri aktarıyoruz.
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/rotiva_scope.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/status_badge.dart';

/// Yönetici Dashboard (Özet Paneli) sekmesi.
/// Filo durumu, müşteri sayısı, aktif kiralamalar ve ciro gibi temel KPI metriklerini gösterir.
/// Responsive tasarımı sayesinde mobil, tablet ve masaüstü ekranlarda taşma (overflow) yapmaz.
class AdminDashboardTab extends StatelessWidget {
  // Statik ve sabit widget optimizasyonu için const constructor tanımlıyoruz.
  const AdminDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Mevcut tema ve renk şemasına erişiyoruz.
    final theme = Theme.of(context);
    // Veri deposuna (repository) InheritedWidget olan RotivaScope üzerinden erişiyoruz.
    final repository = RotivaScope.of(context).repository;

    // Filodaki tüm araçları ve aktif araç sayısını alıyoruz.
    final allVehicles = repository.vehicles;
    final totalVehicles = allVehicles.length;
    final activeVehicles = repository.activeVehicles.length;

    // Sistemde kayıtlı yalnızca müşteri rolündeki kullanıcıları filtreliyoruz.
    final customers = repository.users.where((u) => u.isCustomer).toList();
    final totalCustomers = customers.length;

    // Tüm kiralama kayıtlarını alıyoruz.
    final allRentals = repository.rentals;
    // Devam eden veya onaylanmış aktif rezervasyonları filtreliyoruz.
    final activeRentals = allRentals
        .where(
          (r) =>
              r.rentalStatus == RentalStatus.active ||
              r.rentalStatus == RentalStatus.approved,
        )
        .toList();

    // Şubede nakit ödenecek bekleyen tutarları hesaplıyoruz (İptal edilenler hariç).
    final pendingCashRentals = allRentals
        .where(
          (r) =>
              r.paymentStatus == PaymentStatus.payAtBranch &&
              r.rentalStatus != RentalStatus.cancelled,
        )
        .toList();
    // fold metoduyla bekleyen nakit kiralama tutarlarını topluyoruz.
    final pendingCashTotal = pendingCashRentals.fold<double>(
      0.0,
      (sum, r) => sum + r.finalPrice,
    );

    // İptal edilmemiş tüm kiralamaların toplam cirosunu hesaplıyoruz.
    final totalRevenue = allRentals
        .where((r) => r.rentalStatus != RentalStatus.cancelled)
        .fold<double>(0.0, (sum, r) => sum + r.finalPrice);

    // Dış kabuktaki (AdminShellScreen) Scaffold ile çakışmayı önlemek için doğrudan SafeArea ve SingleChildScrollView kullanıyoruz.
    return SafeArea(
      top: false, // Üst AppBar ile çakışmayı önlemek için üst safeArea kapalı
      bottom: true, // Alt navigasyon çubuğu için alt safeArea açık
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(
          16,
        ), // Sayfa çevresine 16px iç boşluk veriyoruz.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst Karşılama ve Genel Durum Bannerı
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                // Şık bir degradeli (gradient) arka plan rengi uyguluyoruz.
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.15),
                    theme.colorScheme.secondary.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(
                  16,
                ), // Köşeleri yuvarlatıyoruz.
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Genel Filo ve Kiralama Durumu',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rotiva platformundaki anlık rezervasyon, araç ve müşteri istatistikleri',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // KPI Metrik Kartları 1. Satır: Toplam Müşteri ve Toplam Araç
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Toplam Müşteri',
                    value: '$totalCustomers',
                    icon: Icons.people_outline,
                    color: Colors.blue,
                    context: context,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Toplam Araç',
                    value: '$totalVehicles ($activeVehicles Aktif)',
                    icon: Icons.directions_car_outlined,
                    color: Colors.indigo,
                    context: context,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // KPI Metrik Kartları 2. Satır: Aktif Rezervasyon ve Bekleyen Nakit
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Aktif Rezervasyon',
                    value: '${activeRentals.length}',
                    icon: Icons.assignment_turned_in_outlined,
                    color: Colors.green,
                    context: context,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Bekleyen Nakit',
                    value: RotivaFormatters.formatCurrency(pendingCashTotal),
                    icon: Icons.storefront_outlined,
                    color: Colors.amber.shade800,
                    context: context,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Toplam Kiralama Cirosu Kartı
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.monetization_on_outlined,
                          size: 32,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Toplam Kiralama Cirosu (Demo)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              // Metin dar ekranlarda taşmasın diye FittedBox kullanıyoruz.
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  RotivaFormatters.formatCurrency(totalRevenue),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${allRentals.length} Kiralama',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Son Kiralamalar Başlığı
            const SectionHeader(
              title: 'Son Kiralama Hareketleri',
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: 10),

            // Kiralama listesi boşsa bilgilendirme, doluysa son hareketler kartları
            if (allRentals.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text('Henüz kiralama işlemi bulunmuyor.'),
                ),
              )
            else
              // ListTile trailing alanındaki 2px dikey taşmayı önlemek için esnek Card + Row mimarisi kullanıyoruz.
              ...allRentals
                  .take(4)
                  .map(
                    (rental) => Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Sol Araç Simgesi Avatarı
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: theme.colorScheme.primary
                                  .withOpacity(0.12),
                              child: Icon(
                                Icons.car_rental,
                                size: 20,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Orta Bilgi Alanı: Müşteri Adı, Araç Adı, Rezervasyon Kodu
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${rental.customerName} • ${rental.vehicleName}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                    maxLines: 1, // Uzun isimlerin taşmaması için tek satır
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${rental.reservationCode} • ${rental.rentalDays} Gün • ${rental.paymentMethod.displayName}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Sağ Bilgi Alanı: Tutar ve Durum Rozeti (Sabit kısıtlamasız, esnek yükseklik)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  RotivaFormatters.formatCurrency(
                                    rental.finalPrice,
                                  ),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                StatusBadge.rental(rental.rentalStatus),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// KPI istatistik kartlarını oluşturan yardımcı metot.
  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst satır: Başlık ve ilgili simge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Icon(icon, size: 20, color: color),
              ],
            ),
            const SizedBox(height: 8),
            // Alt satır: Metrik değeri (Dar ekranlarda taşmayı önlemek için FittedBox)
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
