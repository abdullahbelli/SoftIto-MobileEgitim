// Flutter Material tasarım bileşenlerini içeri aktarıyoruz.
import 'package:flutter/material.dart';

// Formatlayıcılar, diyaloglar, rozetler ve veri kapsamını içeri aktarıyoruz.
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
  // Statik const constructor tanımlıyoruz.
  const AdminVehiclesTab({super.key});

  /// Araç ekleme veya düzenleme form ekranını açan yardımcı metot.
  void _openVehicleForm(BuildContext context, [Vehicle? vehicle]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AdminVehicleFormScreen(vehicle: vehicle),
      ),
    );
  }

  /// Araç silme isteğini ve aktif kiralama korumasını (Madde 101) denetleyen metot.
  Future<void> _handleDelete(BuildContext context, Vehicle vehicle) async {
    final repository = RotivaScope.of(context).repository;

    // 1. Aktif kiralama koruması kontrolü (PROJECT.md Madde 101 gereği)
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

    // 2. Yöneticiden silme onayı istiyoruz (Kırmızı yıkıcı eylem stili)
    final confirmed = await RotivaDialogs.showConfirmationDialog(
      context: context,
      title: 'Aracı Sil',
      message:
          '${vehicle.displayName} (${vehicle.year}) filodan tamamen silinecektir. Bu işlem geri alınamaz. Onaylıyor musunuz?',
      confirmText: 'Aracı Sil',
      isDestructive: true,
    );

    // Onay verildiyse ve sayfa hala ekrandaysa silme işlemini yapıyoruz.
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
    // Tema ve veri deposu referansları
    final theme = Theme.of(context);
    final repository = RotivaScope.of(context).repository;
    final vehicles = repository.vehicles;

    return Scaffold(
      backgroundColor:
          Colors.transparent, // Dış kabuğun arka plan rengini devralır.
      body: SafeArea(
        top: false, // Üst AppBar dış kabuk tarafından yönetilir.
        child: vehicles.isEmpty
            ? const Center(child: Text('Filoda kayıtlı araç bulunmuyor.'))
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  80,
                ), // FAB butonunun altında kalmaması için alttan 80px boşluk
                itemCount: vehicles.length,
                itemBuilder: (context, index) {
                  final vehicle = vehicles[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Araç Simgesi Avatarı (Aktifse tema rengi, pasifse kırmızı)
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: vehicle.isActive
                                    ? theme.colorScheme.primary.withOpacity(
                                        0.12,
                                      )
                                    : Colors.red.withOpacity(0.12),
                                child: Icon(
                                  Icons.directions_car,
                                  color: vehicle.isActive
                                      ? theme.colorScheme.primary
                                      : Colors.red,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Araç Bilgileri Alanı
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            vehicle.displayName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        // Aktif / Pasif Durum Rozeti
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
                                            vehicle.isActive
                                                ? 'Aktif'
                                                : 'Pasif',
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
                                    // Kategori ve Yakıt Rozetleri (Responsive Wrap)
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
                                    // Yıl, Lokasyon, Vites ve Sürücü Koşulları
                                    Text(
                                      '${vehicle.year} • ${vehicle.location} • ${vehicle.transmission.displayName} • Min: ${vehicle.minimumAge} Yaş / ${vehicle.minimumLicenseYears} Yıl Ehliyet',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
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

                          // Fiyat ve Yönetici Eylemleri Satırı
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
                                  // Pasif / Aktif Açma-Kapama Anahtarı (Switch)
                                  Switch(
                                    value: vehicle.isActive,
                                    onChanged: (val) {
                                      repository.toggleVehicleStatus(
                                        vehicle.id,
                                        val,
                                      );
                                    },
                                  ),
                                  // Düzenleme Butonu
                                  IconButton(
                                    tooltip: 'Düzenle',
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 20,
                                    ),
                                    onPressed: () =>
                                        _openVehicleForm(context, vehicle),
                                  ),
                                  // Silme Butonu
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
      ),
      // Yeni Araç Ekleme Yüzen Eylem Butonu (FAB)
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Yeni Araç Ekle'),
        onPressed: () => _openVehicleForm(context),
      ),
    );
  }
}
