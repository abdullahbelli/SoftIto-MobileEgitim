/// BoardConnect hata yönetimi sınıfı
/// Dart dilindeki standart 'Exception' arayüzünü (interface) uygular (implements).
/// Uygulama içinde fırlatılan özel iş mantığı (business logic) hatalarını temsil eder.
class AppException implements Exception {
  // Kullanıcıya veya log ekranına gösterilecek açıklayıcı hata mesajı.
  final String message;
  // Opsiyonel hata kodu (Örn: 'AUTH_01', 'ROOM_NOT_FOUND' gibi hata sınıflandırması için).
  final String? code;

  // Değişmez (immutable) yapıcı metot (constructor).
  const AppException(this.message, {this.code});

  @override // Üst sınıftan gelen toString metodunu yeniden tanımlar.
  // Hata nesnesi string'e dönüştürüldüğünde doğrudan hata mesajını döndürür.
  String toString() => message;
}
