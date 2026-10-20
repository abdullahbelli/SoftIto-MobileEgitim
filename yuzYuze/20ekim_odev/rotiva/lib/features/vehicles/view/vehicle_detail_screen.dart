// Flutter Material tasarım kütüphanesini içeri aktarıyoruz.
import 'package:flutter/material.dart';

// Formatlayıcılar, rozetler, AppBar, veri kapsamı ve kiralama form ekranını içeri aktarıyoruz.
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/fuel_type_badge.dart';
import '../../../core/widgets/rotiva_app_bar.dart';
import '../../../core/widgets/rotiva_scope.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/vehicle_type_badge.dart';
import '../../rentals/view/rental_form_screen.dart';
import '../models/vehicle.dart';

/// Araç detay sayfası.
/// Aracın tüm teknik özelliklerini, sürücü şartlarını, km sınırını, yorumları ve kiralama aksiyonunu sunar.
class VehicleDetailScreen extends StatelessWidget {
  final Vehicle vehicle; // Detayları gösterilecek araç modeli
  final DateTimeRange? preselectedDateRange; // Ana sayfada önceden seçilmiş tarih aralığı (opsiyonel)

  // Statik const constructor tanımlıyoruz.
  const VehicleDetailScreen({
    super.key,
    required this.vehicle,
    this.preselectedDateRange,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark =
        theme.brightness == Brightness.dark; // Tema karanlık mı aydınlık mı?
    final repository = RotivaScope.of(context).repository;

    // Araca ait müşteri yorumlarını ve ortalama puanı depodan alıyoruz.
    final reviews = repository.getReviewsForVehicle(vehicle.id);
    final rating = repository.getAverageRatingForVehicle(vehicle.id);

    return Scaffold(
      appBar: RotivaAppBar(titleText: vehicle.displayName),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst Görsel / Hero Banner Alanı
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                // Temaya göre uyumlu açık veya koyu degradeli arka plan
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF2C3440), const Color(0xFF1B2028)]
                      : [const Color(0xFFE3EDF8), const Color(0xFFC7DBF2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  // Ortalanmış Araç İkonu ve Marka/Model Başlığı
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.directions_car,
                          size: 80,
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.9,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${vehicle.brand} ${vehicle.model} • ${vehicle.year}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Sol Alt Köşe Kasa Kategori Rozeti (Sedan, SUV vb.)
                  Positioned(
                    bottom: 12,
                    left: 16,
                    child: VehicleTypeBadge(category: vehicle.category),
                  ),
                  // Sağ Alt Köşe Yakıt Türü Rozeti (Benzin, Dizel vb.)
                  Positioned(
                    bottom: 12,
                    right: 16,
                    child: FuelTypeBadge(fuelType: vehicle.fuelType),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Başlık, Lokasyon ve Fiyat Alanı
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Araç Adı ve Bulunduğu Şehir/İlçe
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vehicle.displayName,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: Colors.redAccent,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  vehicle.location,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Günlük Standart ve Saatlik Bilgilendirme Ücretleri
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            RotivaFormatters.formatCurrency(vehicle.dailyRate),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const Text(
                            '/ gün',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Saatlik: ${RotivaFormatters.formatCurrency(vehicle.hourlyRate)}*',
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Yıldız Değerlendirmesi ve Yorum Sayısı Satırı
                  Row(
                    children: [
                      if (rating != null) ...[
                        const Icon(
                          Icons.star_rounded,
                          size: 20,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '(${reviews.length} müşteri yorumu)',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ] else ...[
                        Icon(
                          Icons.star_outline_rounded,
                          size: 18,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Henüz değerlendirme yok',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Temel Araç Özellikleri Izgarası (Responsive LayoutBuilder ile dar ekran uyumlu)
                  const SectionHeader(
                    title: 'Araç Özellikleri',
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // Genişlik 340px üzerindeyse 2 sütuna bölüyoruz; daha darsa tek sütun yapıyoruz.
                      final cardWidth = constraints.maxWidth > 340
                          ? (constraints.maxWidth - 12) / 2
                          : constraints.maxWidth;

                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildSpecCard(
                            icon: Icons.local_gas_station_outlined,
                            title: 'Yakıt Türü',
                            value: vehicle.fuelType.displayName,
                            context: context,
                            width: cardWidth,
                          ),
                          _buildSpecCard(
                            icon: Icons.settings_outlined,
                            title: 'Vites',
                            value: vehicle.transmission.displayName,
                            context: context,
                            width: cardWidth,
                          ),
                          _buildSpecCard(
                            icon: Icons.speed,
                            title: 'Günlük KM Sınırı',
                            value: '${vehicle.dailyKmLimit} km / gün',
                            context: context,
                            width: cardWidth,
                          ),
                          _buildSpecCard(
                            icon: Icons.add_road,
                            title: 'Ek KM Paketi',
                            value:
                                '+${vehicle.additionalDailyKm} km (${RotivaFormatters.formatCurrency(vehicle.additionalKmDailyPrice)}/gün)',
                            context: context,
                            width: cardWidth,
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Sürücü ve Teslimat Koşulları Kartı
                  const SectionHeader(
                    title: 'Kiralama ve Sürücü Koşulları',
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 0,
                    color: theme.colorScheme.surfaceContainerHighest
                        .withOpacity(0.5),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          _buildConditionRow(
                            icon: Icons.badge_outlined,
                            title: 'Minimum Sürücü Yaşı',
                            value: '${vehicle.minimumAge} Yaş ve Üzeri',
                            context: context,
                          ),
                          const Divider(height: 16),
                          _buildConditionRow(
                            icon: Icons.credit_card_outlined,
                            title: 'Minimum Ehliyet Süresi',
                            value:
                                '${vehicle.minimumLicenseYears} Yıl ve Üzeri',
                            context: context,
                          ),
                          const Divider(height: 16),
                          _buildConditionRow(
                            icon: Icons.delivery_dining_outlined,
                            title: 'Adrese Teslimat Bedeli',
                            value: RotivaFormatters.formatCurrency(
                              vehicle.addressDeliveryFee,
                            ),
                            context: context,
                          ),
                          const Divider(height: 16),
                          _buildConditionRow(
                            icon: Icons.percent,
                            title: 'Şubede Nakit İndirimi',
                            value: '%10 İndirim Fırsatı',
                            context: context,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Müşteri Değerlendirmeleri ve Yorumları Bölümü
                  SectionHeader(
                    title: 'Müşteri Değerlendirmeleri (${reviews.length})',
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 12),
                  if (reviews.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Bu araç için henüz kullanıcı değerlendirmesi bulunmamaktadır. Kiralamanız tamamlandıktan sonra ilk yorumu siz bırakabilirsiniz!',
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  else
                    ...reviews.map(
                      (r) => Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 0,
                        color: theme.colorScheme.surfaceContainerHighest
                            .withOpacity(0.4),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    r.customerName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  // Yıldız İkonları
                                  Row(
                                    children: List.generate(
                                      5,
                                      (i) => Icon(
                                        i < r.stars
                                            ? Icons.star_rounded
                                            : Icons.star_border_rounded,
                                        size: 16,
                                        color: Colors.amber,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                r.comment,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),
                  // Demo ve Yasal Bilgilendirme Notu
                  Text(
                    '*Saatlik ücret bilgilendirme amaçlıdır; Rotiva yalnızca günlük kiralama sözleşmesi yapmaktadır.',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(
                    height: 80,
                  ), // Alttaki sabit kiralama butonu için boşluk
                ],
              ),
            ),
          ],
        ),
      ),
      // Ekranın Altında Sabit Duran Hızlı Fiyat ve Kiralama Butonu
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      RotivaFormatters.formatCurrency(vehicle.dailyRate),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      'Günlük standart tarife',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                icon: const Icon(Icons.car_rental),
                label: const Text('Hemen Kirala'),
                onPressed: () {
                  // Kiralama rezervasyon formuna geçiş yapıyoruz.
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => RentalFormScreen(
                        vehicle: vehicle,
                        initialDateRange: preselectedDateRange,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Teknik özellik kartını oluşturan yardımcı metot
  Widget _buildSpecCard({
    required IconData icon,
    required String title,
    required String value,
    required BuildContext context,
    double? width,
  }) {
    final theme = Theme.of(context);
    return Container(
      width: width ?? 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  /// Kiralama koşulları satırını oluşturan yardımcı metot
  Widget _buildConditionRow({
    required IconData icon,
    required String title,
    required String value,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
