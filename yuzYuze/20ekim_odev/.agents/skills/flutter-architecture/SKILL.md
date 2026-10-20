---
name: rotiva-flutter-architecture
description: Backend olmadan feature-based Flutter mimarisi, uygulama durumu, modeller ve yerel veri katmanını yönetir.
---
# Flutter Mimari Skill

## Esaslar
- 19 Ekim örneğine benzer `lib/core` + `lib/features/<feature>/{controllers,models,view,widgets}`.
- `lib/data/mock` seed; `lib/data/repositories` yerel CRUD sağlar.
- Başlangıç seviyesine uygun `ChangeNotifier` veya `ValueNotifier` + `ListenableBuilder`/`ValueListenableBuilder` tercih et. Tek veri kaynağı ile ekranlar tutarlı kalsın.
- `main.dart` bootstrap; `app.dart` tema/MaterialApp/nav. Sayfa sınıfını route konfigürasyonuyla şişirme.
- `core/theme`: iki ayrı `ColorScheme` ve theme state.
- `core/widgets`: tekrar kullanılan parçalar (empty state, section heading, dialog, vehicle card vb.).

## Veri akışı
`View → Controller/Notifier → InMemoryRepository → models`; güncellemede notifier ekranlara haber verir. `RentalPricing` gibi saf kurallar ayrıca test edilebilir.

## Model tasarımı
- `final` alanlı immutable modeller, named constructor, `copyWith`.
- JSON saklanıyorsa tutarlı `toJson/fromJson`, enum parse fallback ve DateTime ISO8601.
- Kimlikler UUID paketi gerekmiyorsa timestamp+artımlı sayaç ile çakışmasız örnek ID üretilebilir.
- Değerler doğrudan widget içinde değiştirilemez.

## Kalıcılık
- Öncelik: deterministik demo seed + uygulama oturumu süresince hafıza.
- Kullanıcı kapatıp açınca durum korunsun istenirse sadece uygun demo bilgiler (tema, mock araç/kiralama/yorum) `shared_preferences` JSON olarak saklanabilir.
- Gerçek parola, kart verisi, hassas kimlik bilgisi saklama; bu uygulama güvenli auth altyapısı değildir.
- Eski bozuk JSON için güvenli fallback ve seed'i tekrar yükleme stratejisi sun.

## Navigasyon
- Müşteri: Home, Vehicles, My Rentals, Profile.
- Admin: Dashboard, Customers, Vehicles, Rentals.
- `Navigator`/Material routes yeterli; router paketi ancak gerçek ihtiyaç varsa.
- Geri tuşu, diyalog kapanması, başarı ekranından geçmişe dönüş doğru çalışsın.

## Sadelik
- Devasa tek `main.dart` yasak.
- Tek ekran için 10 ayrı soyut katman oluşturma.
- Repository interface ancak test için gerçekten yararlıysa.
- `flutter analyze` uyarılarını saklama; `ignore_for_file` ile sorun maskeleme.
