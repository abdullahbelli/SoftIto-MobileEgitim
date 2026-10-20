import 'package:flutter/material.dart';

import '../../features/vehicles/models/vehicle.dart';
import '../constants/app_constants.dart';
import '../utils/formatters.dart';
import 'fuel_type_badge.dart';
import 'vehicle_type_badge.dart';

/// Rotiva araç kartı bileşeni.
/// Müşteri listelerinde ve ana sayfada araç bilgilerini, fiyatını ve özelliklerini gösterir.
class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final double? rating;
  final int reviewCount;
  final VoidCallback onTap;
  final VoidCallback? onRentTap;
  final Widget? trailingAction;

  const VehicleCard({
    super.key,
    required this.vehicle,
    this.rating,
    this.reviewCount = 0,
    required this.onTap,
    this.onRentTap,
    this.trailingAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst Görsel / Rozet Alanı
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF2C3440), const Color(0xFF1F242C)]
                      : [const Color(0xFFE3EDF8), const Color(0xFFD3E3F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  // Ortadaki Araç Temsili İkonu
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getCategoryIcon(vehicle.category),
                          size: 64,
                          color: theme.colorScheme.primary.withOpacity(0.85),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${vehicle.brand} ${vehicle.model}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurfaceVariant
                                .withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Sol Üst: Renkli Araç Tipi Rozeti (Madde 5)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: VehicleTypeBadge(
                      category: vehicle.category,
                      isCompact: true,
                    ),
                  ),

                  // Sağ Üst: Yıl veya Pasif Rozeti
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!vehicle.isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              color: Colors.red.shade700,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Pasif',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${vehicle.year}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Sol Alt: Lokasyon
                  Positioned(
                    bottom: 10,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            vehicle.location,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Araç Bilgileri ve Fiyat Alanı
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vehicle.displayName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            // Puan ve Yorum Gösterimi
                            Row(
                              children: [
                                if (rating != null) ...[
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 16,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    rating!.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '($reviewCount yorum)',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ] else ...[
                                  Icon(
                                    Icons.star_outline_rounded,
                                    size: 16,
                                    color: theme.colorScheme.outline,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    'Puan yok',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Fiyat Kutusu
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            RotivaFormatters.formatCurrency(vehicle.dailyRate),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          Text(
                            '/ gün',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 10),

                  // Özellik İkonları (Yakıt, Vites, Yaş ve Ehliyet Şartı)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FuelTypeBadge(
                        fuelType: vehicle.fuelType,
                        isCompact: true,
                      ),
                      _buildSpecPill(
                        icon: Icons.settings_outlined,
                        label: vehicle.transmission.displayName,
                        context: context,
                      ),
                      _buildSpecPill(
                        icon: Icons.person_outline,
                        label: '${vehicle.minimumAge}+ Yaş',
                        context: context,
                      ),
                      _buildSpecPill(
                        icon: Icons.badge_outlined,
                        label: '${vehicle.minimumLicenseYears}+ Yıl',
                        context: context,
                      ),
                    ],
                  ),

                  if (trailingAction != null) ...[
                    const SizedBox(height: 12),
                    trailingAction!,
                  ] else if (onRentTap != null) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: vehicle.isActive ? onRentTap : null,
                        child: Text(
                          vehicle.isActive ? 'Kirala' : 'Şu Anda Müsait Değil',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecPill({
    required IconData icon,
    required String label,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.primary),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(VehicleCategory category) {
    switch (category) {
      case VehicleCategory.sedan:
        return Icons.directions_car;
      case VehicleCategory.suv:
        return Icons.directions_car_filled;
      case VehicleCategory.hatchback:
        return Icons.directions_car_outlined;
      case VehicleCategory.stationWagon:
        return Icons.airport_shuttle_outlined;
      case VehicleCategory.commercial:
        return Icons.local_shipping_outlined;
      case VehicleCategory.coupe:
        return Icons.speed;
      case VehicleCategory.luxury:
        return Icons.workspace_premium;
    }
  }
}
