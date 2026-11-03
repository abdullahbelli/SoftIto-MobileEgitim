class Asset {
  // nesen bilgilerini tutan model sınıfı
  final String symbol; //sembol
  final String name; //ad
  final double price; // fiyat
  final double change24h; // 24 saatlik değişim
  final double balance; //sahip olunan varlık

  const Asset({
    // asset nesnesini oluşturan sabit constructor
    required this.symbol, //required: doldurulması zorunlu alanlar.
    required this.name,
    required this.price,
    required this.change24h,
    required this.balance,
  });
}
