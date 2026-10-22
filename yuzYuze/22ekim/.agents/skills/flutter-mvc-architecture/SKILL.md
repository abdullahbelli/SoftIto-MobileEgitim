---
name: flutter-mvc-architecture
description: Ritmia Flutter mobil uygulamasında Model-View-Controller (MVC) klasörlerini, SOLID ilkelerini, Controller, Service ve Repository sorumluluklarını uygularken kullan.
---

# Flutter MVC + SOLID Skill

## Mimari
Flutter projesi **feature-first MVC** mimarisini kullanır. `data/domain/presentation` katmanları oluşturma. Her özellik altında gerektiğinde `models/`, `views/`, `controllers/` bulunur; karmaşık hesaplar `services/`, veri erişimi `repositories/` altındadır.

- **Model:** Veri nesnelerini temsil eder. `Habit`, `HabitDayProgress`, `UserProfile`, `EarnedBadge` gibi. Flutter UI widget'larını bilmez.
- **View:** `StatelessWidget`/`StatefulWidget`, ekran, form, bottom sheet, kart, navigasyon ve animasyon. Controller'daki durumu gösterir, kullanıcı eylemini ona iletir; SQL/iş kuralı içermez.
- **Controller:** `ChangeNotifier` ile ekran durumunu yönetir. Form eylemlerini karşılar, ilgili service/repository çağrılarını koordine eder, yükleme ve hataları bildirir. Controller tüm algoritmaları veya veritabanı kodlarını kendi içine gömmez.
- **Service:** Streak, takvim oranı, rozet eşiği, puan, lig yükselme/düşme gibi hesapları bağımsız/test edilebilir fonksiyonlarla yapar.
- **Repository:** Model kalıcılığı ve veri kaynaklarıyla iletişim; yerel SQLite uygulaması ileride API ile değiştirilebilir. Repository arayüzleri, implementasyonlardan ayrı tutulabilir.

## Bağımlılık akışı
`View → Controller → Service / Repository → veri kaynağı`. Model ortak veri sözleşmelerini sağlar. Service mümkün olduğunca saf Dart kodudur. View doğrudan SQLite'a veya HTTP'ye gitmez. Controller da `BuildContext` tutmaz.

## SOLID ilkeleri
- **S / Single Responsibility:** Her View, Controller, Model, Service ve Repository sınıfı tek bir ana sorumluluk taşısın.
- **O / Open-Closed:** Hedef türleri ve rozet kuralları genişletilirken mevcut kod gereksiz yere değiştirilmesin; gerektiği yerde strateji fonksiyonları kullan.
- **L / Liskov Substitution:** Demo ve gerçek repository uygulamaları aynı sözleşme ve hata davranışını korusun.
- **I / Interface Segregation:** Devasa tek bir repository yerine ihtiyaca göre `HabitRepository`, `ProgressRepository`, `LeaderboardRepository` vb. küçük sözleşmeler kullan.
- **D / Dependency Inversion:** Controller somut SQLite sınıfına bağımlı olmasın, bağımlılıklarını constructor/Provider üzerinden alsın.

## Örnek klasör
```text
features/habits/
  models/
    habit.dart
    habit_day_progress.dart
  views/
    my_habits_view.dart
    widgets/habit_card.dart
    widgets/habit_form_sheet.dart
  controllers/
    habit_controller.dart
  services/
    habit_streak_service.dart
  repositories/
    habit_repository.dart
    sqlite_habit_repository.dart
```

## Uygulama kuralları
- `HabitController extends ChangeNotifier` ekran için `habits`, `isLoading`, `errorMessage` gibi durumları tutabilir. `notifyListeners()` ile View'ları günceller; `Provider`/`ChangeNotifierProvider` ile erişilir.
- Basit buton görünürlüğü/animasyon gibi geçici View durumları için `setState` uygundur; kalıcı alışkanlık durumu Controller'dadır.
- Tarih ve streak planlanan günlerden hesaplanır; tamamlanmamış bugün seriyi gün bitmeden kırmaz. `targetSnapshot` geçmiş hedefleri korur.
- Tamamlanma, puan ve rozet verme işlemleri idempotent olmalıdır. 7/30/365 planlı tamamlanma eşiği ve lig 15 kişi, 5 yükselir/5 düşer kuralı `project.md` ile aynıdır.
- Saat/gece ve haftalık lig sınırlarını sahte zaman girdileriyle test et.
- Demo login/lig açıkça demo olarak işaretlenir; gerçek şifreler düz metin saklanmaz. Gerçek sıralama ve puan güvenliği backend ister.
- Kullanılmayan interface, boş klasör ve gereksiz soyutlama üretme; **MVC'nin derste öğrenilen açıklığını koru**.

## Test
Controller'ı sahte repository/service ile test et; View için widget testleri ve iş kuralları için saf Dart unit testleri yaz. `dart format .`, `flutter analyze`, `flutter test` çalıştır.
