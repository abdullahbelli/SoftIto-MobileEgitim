// Flutter Material tasarım bileşenlerini içeri aktarıyoruz.
import 'package:flutter/material.dart';

// Sabitler, form doğrulayıcılar, ortak diyaloglar ve veri kapsamını içeri aktarıyoruz.
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/rotiva_app_bar.dart';
import '../../../core/widgets/rotiva_scope.dart';
import '../../vehicles/models/vehicle.dart';

/// Yönetici araç ekleme ve düzenleme formu ekranı.
/// Filoya yeni araç ekler veya mevcut aracın teknik ve fiyatlandırma özelliklerini günceller.
class AdminVehicleFormScreen extends StatefulWidget {
  // Düzenleme modunda gönderilen mevcut araç nesnesi (Yeni eklemede null gelir).
  final Vehicle? vehicle;

  const AdminVehicleFormScreen({super.key, this.vehicle});

  @override
  State<AdminVehicleFormScreen> createState() => _AdminVehicleFormScreenState();
}

class _AdminVehicleFormScreenState extends State<AdminVehicleFormScreen> {
  // Formun doğrulama durumunu takip etmek için GlobalKey tanımlıyoruz.
  final _formKey = GlobalKey<FormState>();

  // Metin giriş alanlarının denetleyicileri (Controllers)
  late TextEditingController _brandController; // Marka
  late TextEditingController _modelController; // Model
  late TextEditingController _yearController; // Yıl
  late TextEditingController _dailyRateController; // Günlük ücret
  late TextEditingController _hourlyRateController; // Saatlik ücret
  late TextEditingController _minAgeController; // Minimum sürücü yaşı
  late TextEditingController _minLicenseYearsController; // Minimum ehliyet yılı
  late TextEditingController _dailyKmLimitController; // Günlük standart km
  late TextEditingController _additionalDailyKmController; // Ek paket km
  late TextEditingController _additionalKmPriceController; // Ek km ücreti
  late TextEditingController
  _addressDeliveryFeeController; // Adrese teslim ücreti

  // Seçimli açılır kutu (Dropdown) durum alanları
  late VehicleCategory _category; // Kategori (Sedan, SUV vb.)
  late FuelType _fuelType; // Yakıt türü
  late TransmissionType _transmission; // Vites türü
  late String _selectedCity; // Şehir
  late String _selectedDistrict; // İlçe
  late bool _isActive; // Kiralamaya açık mı?

  // Ekranın düzenleme modunda mı yoksa yeni ekleme modunda mı olduğunu anlatan yardımcı getter
  bool get isEditing => widget.vehicle != null;

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;

    // Eğer düzenleme modundaysa mevcut değerlerle, yeni eklemeyse varsayılanlarla dolduruyoruz.
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
    // Bellek sızıntılarını (memory leak) önlemek için tüm denetleyicileri dispose ediyoruz.
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

  /// Form verilerini kaydeden asenkron fonksiyon.
  Future<void> _handleSave() async {
    // Tüm form alanlarının doğrulama (validation) kurallarından geçtiğini denetliyoruz.
    if (!_formKey.currentState!.validate()) return;

    final repository = RotivaScope.of(context).repository;

    // Form alanlarından yeni/güncellenmiş Vehicle model nesnesini inşa ediyoruz.
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

    // Düzenleme veya yeni ekleme işlemine göre repository metodunu çağırıyoruz.
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

    // İşlem bitince form sayfasını kapatıp listeye geri dönüyoruz.
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Seçili ile ait ilçelerin listesini alıyoruz.
    final districts = AppConstants.turkeyCities[_selectedCity] ?? [];

    return Scaffold(
      appBar: RotivaAppBar(
        titleText: isEditing ? 'Aracı Düzenle' : 'Yeni Araç Ekle',
        actions: [
          // AppBar üzerinde hızlı kaydet butonu
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
              // Marka ve Model Giriş Satırı
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

              // Yıl ve Kategori Seçim Satırı
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

              // Yakıt ve Vites Türü Seçim Satırı
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

              // Şehir ve İlçe Seçim Satırı (Şehir değiştiğinde ilçeler dinamik güncellenir)
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

              // Fiyatlandırma Ayarları Başlığı
              const Text(
                'Fiyatlandırma Ayarları',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              // Günlük ve Saatlik Ücretler
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
              // Adrese Teslimat ve Ek KM Ücretleri
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
              // Yaş ve Ehliyet Şartı
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
              // Standart KM ve Ek KM Paketi
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

              // Araç Aktiflik Durumu Açma/Kapatma Anahtarı
              SwitchListTile(
                title: const Text('Araç Kiralama İçin Aktif'),
                subtitle: const Text(
                  'Pasif araçlar müşteri arama listelerinde görünmez.',
                ),
                value: _isActive,
                onChanged: (val) => setState(() => _isActive = val),
              ),
              const SizedBox(height: 24),

              // Büyük Kaydet Butonu
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
