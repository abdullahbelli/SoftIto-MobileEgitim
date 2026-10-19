class PartModel {
  // Her parçanın benzersiz kimlik numarası.
  final String id;

  // Parçanın adı (Örn: Yağ Filtresi).
  final String name;

  // Ürün / OEM parça kodu.
  final String partCode;

  // Uyumlu araç markası.
  final String brand;

  // Parçanın kategorisi.
  final String category;

  // Birim satış fiyatı.
  final double price;

  // Depoda bulunan parça adedi.
  final int stock;

  // Constructor: Yeni bir parça nesnesi oluşturur.
  const PartModel({
    required this.id,
    required this.name,
    required this.partCode,
    required this.brand,
    required this.category,
    required this.price,
    required this.stock,
  });

  // copyWith:
  // Mevcut parçanın bilgilerini koruyarak
  // yalnızca stok miktarını değiştirmemizi sağlar.
  PartModel copyWith({int? stock}) {
    return PartModel(
      id: id,
      name: name,
      partCode: partCode,
      brand: brand,
      category: category,
      price: price,
      stock: stock ?? this.stock,
    );
  }
}
