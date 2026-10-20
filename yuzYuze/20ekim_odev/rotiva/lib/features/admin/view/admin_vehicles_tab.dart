import 'package:flutter/material.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/fuel_type_badge.dart';
import '../../../core/widgets/rotiva_scope.dart';
import '../../../core/widgets/vehicle_type_badge.dart';
import '../../vehicles/models/vehicle.dart';
import 'admin_vehicle_form_screen.dart';

/// Yönetici Araç Yönetimi (CRUD) Sekmesi.
/// Filodaki tüm araçları listeler, yeni araç ekleme, düzenleme, pasife alma ve aktif kiralama korumalı silme sağlar.
class AdminVehiclesTab extends StatelessWidget {
  const AdminVehiclesTab({super.key});

  void _openVehicleForm(BuildContext context, [Vehicle? vehicle]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AdminVehicleFormScreen(vehicle: vehicle),
      ),
    );
  }

  Future<void> _handleDelete(BuildContext context, Vehicle vehicle) async {
    final repository = RotivaScope.of(context).repository;

    // 1. Aktif kiralama kontrolü (PROJECT.md Madde 101 gereği)
    if (!repository.canDeleteVehicle(vehicle.id)) {
      RotivaDialogs.showScrollableContentDialog(
        context: context,
        title: 'Araç Silinemez (Aktif Kiralama Koruması)',
        content:
            '${vehicle.displayName} aracına ait onaylanmış veya aktif devam eden kiralama rezervasyonu bulunmaktadır.\n\n'
            'Geçmiş kiralama kayıtlarının ve müşteri hesaplarının tutarlılığını korumak için aktif kiralaması olan araçlar sistemden doğrudan silinemez.\n\n'
            'Bunun yerine araç listesindeki anahtarı kullanarak aracı "Pasife" alabilir ve yeni kiralamalara kapatabilirsiniz.',
      );
      return;
    }

    // 2. Silme Onayı
    final confirmed = await RotivaDialogs.showConfirmationDialog(
      context: context,
      title: 'Aracı Sil',
      message:
          '${vehicle.displayName} (${vehicle.year}) filodan tamamen silinecektir. Bu işlem geri alınamaz. Onaylıyor musunuz?',
      confirmText: 'Aracı Sil',
      isDestructive: true,
    );

    if (confirmed && context.mounted) {
      final success = await repository.deleteVehicle(vehicle.id);
      if (context.mounted) {
        if (success) {
          RotivaDialogs.showSnackBar(
            context,
            'Araç filodan başarıyla silindi.',
            isSuccess: true,
          );
        } else {
          RotivaDialogs.showSnackBar(
            context,
            'Araç silinemedi. Lütfen aktif kiralamaları kontrol ediniz.',
            isError: true,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final repository = RotivaScope.of(context).repository;
    final vehicles = repository.vehicles;

    return Scaffold(
      body: vehicles.isEmpty
          ? const Center(child: Text('Filoda kayıtlı araç bulunmuyor.'))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
              itemCount: vehicles.length,
              itemBuilder: (context, index) {
                final vehicle = vehicles[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: vehicle.isActive
                                  ? theme.colorScheme.primary.withOpacity(0.12)
                                  : Colors.red.withOpacity(0.12),
                              child: Icon(
                                Icons.directions_car,
                                color: vehicle.isActive
                                    ? theme.colorScheme.primary
                                    : Colors.red,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          vehicle.displayName,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: vehicle.isActive
                                              ? Colors.green.withOpacity(0.15)
                                              : Colors.red.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          vehicle.isActive ? 'Aktif' : 'Pasif',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: vehicle.isActive
                                                ? Colors.green.shade800
                                                : Colors.red.shade800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
                                      VehicleTypeBadge(
                                        category: vehicle.category,
                                        isCompact: true,
                                      ),
                                      FuelTypeBadge(
                                        fuelType: vehicle.fuelType,
                                        isCompact: true,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${vehicle.year} • ${vehicle.location} • ${vehicle.transmission.displayName} • Min: ${vehicle.minimumAge} Yaş / ${vehicle.minimumLicenseYears} Yıl Ehliyet',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Divider(height: 1),
                        const SizedBox(height: 8),

                        // Fiyat ve Eylemler
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${RotivaFormatters.formatCurrency(vehicle.dailyRate)} / gün',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Pasif/Aktif Geçişi
                                Switch(
                                  value: vehicle.isActive,
                                  onChanged: (val) {
                                    repository.toggleVehicleStatus(
                                      vehicle.id,
                                      val,
                                    );
                                  },
                                ),
                                IconButton(
                                  tooltip: 'Düzenle',
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 20,
                                  ),
                                  onPressed: () =>
                                      _openVehicleForm(context, vehicle),
                                ),
                                IconButton(
                                  tooltip: 'Sil',
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                    color: Colors.red,
                                  ),
                                  onPressed: () =>
                                      _handleDelete(context, vehicle),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Yeni Araç Ekle'),
        onPressed: () => _openVehicleForm(context),
      ),
    );
  }
}
