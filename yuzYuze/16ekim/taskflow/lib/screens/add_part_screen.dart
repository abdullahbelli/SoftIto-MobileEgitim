import 'package:flutter/material.dart';

import '../models/part_model.dart';

class AddPartScreen extends StatefulWidget {
  final ValueChanged<PartModel> onPartAdded;
  final bool Function(String code) partCodeExists;

  const AddPartScreen({
    super.key,
    required this.onPartAdded,
    required this.partCodeExists,
  });

  @override
  State<AddPartScreen> createState() => _AddPartScreenState();
}

class _AddPartScreenState extends State<AddPartScreen> {
  final _formKey = GlobalKey<FormState>();

  // TextEditingController:
  // Form kutularındaki metinleri yönetir.
  final _name = TextEditingController();
  final _code = TextEditingController();
  final _brand = TextEditingController();
  final _price = TextEditingController();
  final _stock = TextEditingController();

  String _category = "Motor";

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _brand.dispose();
    _price.dispose();
    _stock.dispose();
    super.dispose();
  }

  // Yeni parçayı kaydet.
  void _savePart() {
    if (!_formKey.currentState!.validate()) return;

    final price = double.parse(_price.text.trim().replaceAll(',', '.'));

    final stock = int.parse(_stock.text.trim());

    final part = PartModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: _name.text.trim(),
      partCode: _code.text.trim(),
      brand: _brand.text.trim(),
      category: _category,
      price: price,
      stock: stock,
    );

    // Yeni parçayı main.dart içindeki ortak listeye ekle.
    widget.onPartAdded(part);

    // Formu temizle.
    _name.clear();
    _code.clear();
    _brand.clear();
    _price.clear();
    _stock.clear();

    setState(() {
      _category = "Motor";
    });

    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Parça envantere eklendi!"),
        backgroundColor: Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sayfanın üst bilgilendirme alanı.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.add_box_outlined,
                    color: Color(0xFFF97316),
                    size: 38,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Yeni Stok Kaydı",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Envantere yeni bir yedek parça ekleyin.",
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // BÖLÜM 1 - ÜRÜN BİLGİLERİ
            _section("01", "Ürün Bilgileri", [
              _field(
                "Parça Adı",
                _name,
                Icons.build_outlined,
                "Örn: Yağ Filtresi",
              ),
              const SizedBox(height: 14),
              _field(
                "Parça Kodu",
                _code,
                Icons.qr_code,
                "Örn: YF-001",
                extraValidator: (text) {
                  if (widget.partCodeExists(text)) {
                    return "Bu parça kodu zaten kayıtlı";
                  }
                  return null;
                },
              ),
            ]),

            const SizedBox(height: 16),

            // BÖLÜM 2 - ARAÇ BİLGİLERİ
            _section("02", "Araç ve Kategori", [
              _field(
                "Araç Markası",
                _brand,
                Icons.directions_car_outlined,
                "Örn: Hyundai",
              ),

              const SizedBox(height: 14),

              // Kategori seçimi.
              DropdownButtonFormField<String>(
                initialValue: _category,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: "Parça Kategorisi",
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: ["Motor", "Fren", "Filtre", "Elektrik", "Diğer"].map((
                  item,
                ) {
                  return DropdownMenuItem(value: item, child: Text(item));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _category = value);
                  }
                },
              ),
            ]),

            const SizedBox(height: 16),

            // BÖLÜM 3 - FİYAT VE STOK
            _section("03", "Fiyat ve Stok", [
              _field(
                "Birim Fiyat (TL)",
                _price,
                Icons.payments_outlined,
                "Örn: 450",
                keyboard: const TextInputType.numberWithOptions(decimal: true),
                extraValidator: (text) {
                  final value = double.tryParse(text.replaceAll(',', '.'));
                  if (value == null || !value.isFinite || value <= 0) {
                    return "Geçerli bir fiyat girin";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 14),

              _field(
                "Stok Miktarı",
                _stock,
                Icons.inventory_2_outlined,
                "Örn: 25",
                keyboard: TextInputType.number,
                extraValidator: (text) {
                  final value = int.tryParse(text);
                  if (value == null || value < 0) {
                    return "Geçerli bir stok adedi girin";
                  }
                  return null;
                },
              ),
            ]),

            const SizedBox(height: 24),

            // Kayıt butonu.
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _savePart,
                icon: const Icon(Icons.save_outlined),
                label: const Text(
                  "ENVANTERE EKLE",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF97316),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // Tekrar kullanılabilir numaralı form bölümü.
  Widget _section(String number, String title, List<Widget> fields) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEDD5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  number,
                  style: const TextStyle(
                    color: Color(0xFFEA580C),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ...fields:
          // Liste içindeki bütün form elemanlarını ekler.
          ...fields,
        ],
      ),
    );
  }

  // Tekrar kullanılabilir form alanı.
  Widget _field(
    String label,
    TextEditingController controller,
    IconData icon,
    String hint, {
    TextInputType keyboard = TextInputType.text,
    String? Function(String)? extraValidator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
      validator: (value) {
        final text = value?.trim() ?? "";

        if (text.isEmpty) {
          return "$label boş bırakılamaz";
        }

        if (extraValidator != null) {
          return extraValidator(text);
        }

        return null;
      },
    );
  }
}
