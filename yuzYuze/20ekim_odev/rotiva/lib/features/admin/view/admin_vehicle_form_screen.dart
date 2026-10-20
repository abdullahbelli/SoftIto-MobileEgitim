import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/rotiva_app_bar.dart';
import '../../../core/widgets/rotiva_scope.dart';
import '../../vehicles/models/vehicle.dart';

/// Yönetici araç ekleme ve düzenleme formu ekranı.
class AdminVehicleFormScreen extends StatefulWidget {
  final Vehicle? vehicle;

  const AdminVehicleFormScreen({super.key, this.vehicle});

  @override
  State<AdminVehicleFormScreen> createState() => _AdminVehicleFormScreenState();
}

class _AdminVehicleFormScreenState extends State<AdminVehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _yearController;
  late TextEditingController _dailyRateController;
  late TextEditingController _hourlyRateController;
  late TextEditingController _minAgeController;
  late TextEditingController _minLicenseYearsController;
  late TextEditingController _dailyKmLimitController;
  late TextEditingController _additionalDailyKmController;
  late TextEditingController _additionalKmPriceController;
  late TextEditingController _addressDeliveryFeeController;

  late VehicleCategory _category;
  late FuelType _fuelType;
  late TransmissionType _transmission;
  late String _selectedCity;
  late String _selectedDistrict;
  late bool _isActive;

  bool get isEditing => widget.vehicle != null;

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;

    _brandController = TextEditingController(text: v?.brand ?? '');
    _modelController = TextEditingController(text: v?.model ?? '');
    _yearController = TextEditingController(
      text: v != null ? '${v.year}' : '2024',
    );
    _dailyRateController = TextEditingController(
      text: v != null ? '${v.dailyRate}' : '1200',
    );
    _hourlyRateController = TextEditingController(
      text: v != null ? '${v.hourlyRate}' : '120',
    );
    _minAgeController = TextEditingController(
      text: v != null ? '${v.minimumAge}' : '21',
    );
    _minLicenseYearsController = TextEditingController(
      text: v != null ? '${v.minimumLicenseYears}' : '1',
    );
    _dailyKmLimitController = TextEditingController(
      text: v != null ? '${v.dailyKmLimit}' : '300',
    );
    _additionalDailyKmController = TextEditingController(
      text: v != null ? '${v.additionalDailyKm}' : '150',
    );
    _additionalKmPriceController = TextEditingController(
      text: v != null ? '${v.additionalKmDailyPrice}' : '200',
    );
    _addressDeliveryFeeController = TextEditingController(
      text: v != null ? '${v.addressDeliveryFee}' : '400',
    );

    _category = v?.category ?? VehicleCategory.sedan;
    _fuelType = v?.fuelType ?? FuelType.gasoline;
    _transmission = v?.transmission ?? TransmissionType.automatic;
    _selectedCity = v?.city ?? 'İstanbul';
    _selectedDistrict = v?.district ?? 'Kadıköy';
    _isActive = v?.isActive ?? true;
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _dailyRateController.dispose();
    _hourlyRateController.dispose();
    _minAgeController.dispose();
    _minLicenseYearsController.dispose();
    _dailyKmLimitController.dispose();
    _additionalDailyKmController.dispose();
    _additionalKmPriceController.dispose();
    _addressDeliveryFeeController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final repository = RotivaScope.of(context).repository;

    final vehicleData = Vehicle(
      id: widget.vehicle?.id ?? 'veh_${DateTime.now().millisecondsSinceEpoch}',
      brand: _brandController.text.trim(),
      model: _modelController.text.trim(),
      year: int.parse(_yearController.text.trim()),
      category: _category,
      fuelType: _fuelType,
      transmission: _transmission,
      city: _selectedCity,
      district: _selectedDistrict,
      imagePath: widget.vehicle?.imagePath ?? '',
      hourlyRate: double.parse(_hourlyRateController.text.replaceAll(',', '.')),
      dailyRate: double.parse(_dailyRateController.text.replaceAll(',', '.')),
      minimumAge: int.parse(_minAgeController.text.trim()),
      minimumLicenseYears: int.parse(_minLicenseYearsController.text.trim()),
      dailyKmLimit: int.parse(_dailyKmLimitController.text.trim()),
      additionalDailyKm: int.parse(_additionalDailyKmController.text.trim()),
      additionalKmDailyPrice: double.parse(
        _additionalKmPriceController.text.replaceAll(',', '.'),
      ),
      addressDeliveryFee: double.parse(
        _addressDeliveryFeeController.text.replaceAll(',', '.'),
      ),
      isActive: _isActive,
    );

    if (isEditing) {
      await repository.updateVehicle(vehicleData);
      if (mounted) {
        RotivaDialogs.showSnackBar(
          context,
          'Araç bilgileri güncellendi.',
          isSuccess: true,
        );
      }
    } else {
      await repository.addVehicle(vehicleData);
      if (mounted) {
        RotivaDialogs.showSnackBar(
          context,
          'Yeni araç filoya eklendi.',
          isSuccess: true,
        );
      }
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final districts = AppConstants.turkeyCities[_selectedCity] ?? [];

    return Scaffold(
      appBar: RotivaAppBar(
        titleText: isEditing ? 'Aracı Düzenle' : 'Yeni Araç Ekle',
        actions: [
          FilledButton.tonal(
            onPressed: _handleSave,
            child: const Text('KAYDET'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Marka ve Model
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _brandController,
                      decoration: const InputDecoration(
                        labelText: 'Marka (Örn: Renault)',
                      ),
                      validator: (v) =>
                          RotivaValidators.validateRequired(v, 'Marka'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _modelController,
                      decoration: const InputDecoration(
                        labelText: 'Model (Örn: Megane)',
                      ),
                      validator: (v) =>
                          RotivaValidators.validateRequired(v, 'Model'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Yıl ve Kategori
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _yearController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Model Yılı',
                      ),
                      validator: (v) =>
                          RotivaValidators.validatePositiveInteger(
                            v,
                            'Model Yılı',
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<VehicleCategory>(
                      value: _category,
                      decoration: const InputDecoration(labelText: 'Kategori'),
                      items: VehicleCategory.values.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(cat.displayName),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _category = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Yakıt ve Vites
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<FuelType>(
                      value: _fuelType,
                      decoration: const InputDecoration(
                        labelText: 'Yakıt Türü',
                      ),
                      items: FuelType.values.map((f) {
                        return DropdownMenuItem(
                          value: f,
                          child: Text(f.displayName),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _fuelType = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<TransmissionType>(
                      value: _transmission,
                      decoration: const InputDecoration(
                        labelText: 'Vites Türü',
                      ),
                      items: TransmissionType.values.map((t) {
                        return DropdownMenuItem(
                          value: t,
                          child: Text(t.displayName),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _transmission = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Şehir ve İlçe
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCity,
                      decoration: const InputDecoration(labelText: 'Şehir'),
                      items: AppConstants.turkeyCities.keys.map((c) {
                        return DropdownMenuItem(value: c, child: Text(c));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedCity = val;
                            _selectedDistrict =
                                AppConstants.turkeyCities[val]?.first ?? '';
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: districts.contains(_selectedDistrict)
                          ? _selectedDistrict
                          : (districts.isNotEmpty ? districts.first : null),
                      decoration: const InputDecoration(labelText: 'İlçe'),
                      items: districts.map((d) {
                        return DropdownMenuItem(value: d, child: Text(d));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedDistrict = val);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),

              // Ücretler
              const Text(
                'Fiyatlandırma Ayarları',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dailyRateController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Günlük Ücret (₺)',
                        suffixText: '₺',
                      ),
                      validator: (v) => RotivaValidators.validatePositiveNumber(
                        v,
                        'Günlük Ücret',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _hourlyRateController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Saatlik Bilgi Ücreti (₺)',
                        suffixText: '₺',
                      ),
                      validator: (v) => RotivaValidators.validatePositiveNumber(
                        v,
                        'Saatlik Ücret',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _addressDeliveryFeeController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Adrese Teslim Ücreti (₺)',
                        suffixText: '₺',
                      ),
                      validator: (v) => RotivaValidators.validatePositiveNumber(
                        v,
                        'Adrese Teslim Ücreti',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _additionalKmPriceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Ek KM Günlük Fiyatı (₺)',
                        suffixText: '₺',
                      ),
                      validator: (v) => RotivaValidators.validatePositiveNumber(
                        v,
                        'Ek KM Fiyatı',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),

              // Sürücü ve KM Kuralları
              const Text(
                'Sürücü ve KM Sınırları',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minAgeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Min. Sürücü Yaşı',
                      ),
                      validator: (v) =>
                          RotivaValidators.validatePositiveInteger(
                            v,
                            'Yaş Sınırı',
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _minLicenseYearsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Min. Ehliyet Yılı',
                      ),
                      validator: (v) =>
                          RotivaValidators.validatePositiveInteger(
                            v,
                            'Ehliyet Yılı',
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dailyKmLimitController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Standart Günlük KM',
                      ),
                      validator: (v) =>
                          RotivaValidators.validatePositiveInteger(
                            v,
                            'Standart KM',
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _additionalDailyKmController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Ek Paketteki Günlük KM',
                      ),
                      validator: (v) =>
                          RotivaValidators.validatePositiveInteger(v, 'Ek KM'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Aktiflik Durumu
              SwitchListTile(
                title: const Text('Araç Kiralama İçin Aktif'),
                subtitle: const Text(
                  'Pasif araçlar müşteri arama listelerinde görünmez.',
                ),
                value: _isActive,
                onChanged: (val) => setState(() => _isActive = val),
              ),
              const SizedBox(height: 24),

              // Kaydet Butonu
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  icon: const Icon(Icons.save),
                  label: Text(
                    isEditing ? 'Değişiklikleri Kaydet' : 'Aracı Filoya Ekle',
                  ),
                  onPressed: _handleSave,
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
