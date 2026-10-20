import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/rotiva_scope.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/status_badge.dart';

/// Yönetici Dashboard (Özet Paneli) sekmesi.
/// Filo durumu, müşteri sayısı, aktif kiralamalar ve ciro gibi temel KPI metriklerini gösterir.
class AdminDashboardTab extends StatelessWidget {
  const AdminDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final repository = RotivaScope.of(context).repository;

    final allVehicles = repository.vehicles;
    final totalVehicles = allVehicles.length;
    final activeVehicles = repository.activeVehicles.length;

    final customers = repository.users.where((u) => u.isCustomer).toList();
    final totalCustomers = customers.length;

    final allRentals = repository.rentals;
    final activeRentals = allRentals
        .where(
          (r) =>
              r.rentalStatus == RentalStatus.active ||
              r.rentalStatus == RentalStatus.approved,
        )
        .toList();

    // Bekleyen nakit ödemeleri
    final pendingCashRentals = allRentals
        .where(
          (r) =>
              r.paymentStatus == PaymentStatus.payAtBranch &&
              r.rentalStatus != RentalStatus.cancelled,
        )
        .toList();
    final pendingCashTotal = pendingCashRentals.fold<double>(
      0.0,
      (sum, r) => sum + r.finalPrice,
    );

    // Tahmini toplam ciro
    final totalRevenue = allRentals
        .where((r) => r.rentalStatus != RentalStatus.cancelled)
        .fold<double>(0.0, (sum, r) => sum + r.finalPrice);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hoş Geldiniz Bannerı
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.15),
                    theme.colorScheme.secondary.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
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

            // KPI Metrik Kartları Grid
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

            // Toplam Ciro Kartı
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
                  Row(
                    children: [
                      Icon(
                        Icons.monetization_on_outlined,
                        size: 32,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Column(
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
                          Text(
                            RotivaFormatters.formatCurrency(totalRevenue),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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

            if (allRentals.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text('Henüz kiralama işlemi bulunmuyor.'),
                ),
              )
            else
              ...allRentals
                  .take(4)
                  .map(
                    (rental) => Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primary
                              .withOpacity(0.12),
                          child: Icon(
                            Icons.car_rental,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        title: Text(
                          '${rental.customerName} • ${rental.vehicleName}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        subtitle: Text(
                          '${rental.reservationCode} • ${rental.rentalDays} Gün • ${rental.paymentMethod.displayName}',
                          style: const TextStyle(fontSize: 11),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
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
                      ),
                    ),
                  ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Icon(icon, size: 20, color: color),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
