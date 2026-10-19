---
name: flutter-diary-feature-scaffold
description: Dijital Günlük Flutter uygulamasında takvim, günlük ve tema özelliklerini modüler olarak geliştirir. ValueNotifier ile reaktif state yönetimi, immutable modeller, temiz UI katmanı ve birim test standartlarını uygular.
---

# Flutter Dijital Günlük Feature Scaffold

Bu yetenek, Dijital Günlüğüm uygulamasında yeni bir ekran veya özellik geliştirirken modüler mimari, reaktif state yönetimi ve temiz kod kurallarına uyulmasını sağlar.

Antigravity ajanı, proje geliştirme sürecinde bu dosyada belirtilen kuralları uygulamak zorundadır.

Uygulamanın fonksiyonel gereksinimleri `project.md` dosyasında tanımlanmıştır.

## 1. Temel Kurallar

### 1.1. Dosya Ayrımı

Kodlar kesinlikle tek dosyada toplanmayacaktır.

Her özellik için gerekli olan Model, Controller, View ve Widget dosyaları birbirinden ayrılmalıdır.

- **Model:** Uygulamanın veri yapısını tanımlar.
- **Controller:** İş mantığını ve state değişikliklerini yönetir.
- **View:** Kullanıcıya gösterilen ana ekranı oluşturur.
- **Widget:** Ekranlarda tekrar kullanılabilecek küçük arayüz bileşenlerini içerir.

### 1.2. State Yönetimi

- State yönetimi için `ValueNotifier` kullanılmalıdır.
- Arayüz güncellemeleri `ValueListenableBuilder` ile yapılmalıdır.
- Sayfa düzeyinde ağır `setState` kullanımından kaçınılmalıdır.
- Basit yerel animasyonlar için `StatefulWidget` kullanılabilir.
- Controller içerisinde iş mantığı bulunmalı, UI kodu bulunmamalıdır.
- Kullanılmayan controller ve notifier nesneleri uygun zamanda `dispose()` ile temizlenmelidir.

### 1.3. Const Kullanımı

Mümkün olan tüm widget'larda `const` kullanılmalıdır.

Bu sayede gereksiz widget oluşturma işlemleri azaltılır ve kodun okunabilirliği artırılır.

### 1.4. Immutable Model

Model sınıfları mümkün olduğunca immutable olmalıdır.

- Alanlar `final` olarak tanımlanmalıdır.
- Uygun modellerde `const` constructor kullanılmalıdır.
- Veri güncellemek için `copyWith()` kullanılmalıdır.
- Veriyi JSON formatına çevirmek için `toJson()` kullanılmalıdır.
- JSON verisini modele çevirmek için `fromJson()` kullanılmalıdır.

## 2. Klasör Yapısı

Yeni bir özellik geliştirilirken aşağıdaki yapı kullanılmalıdır.

```text
lib/
  core/
    constants/
      app_colors.dart
    theme/
      app_theme.dart
      theme_controller.dart
    services/
      diary_storage_service.dart

  features/
    calendar/
      controllers/
        calendar_controller.dart
      models/
        calendar_model.dart
      view/
        calendar_view.dart
      widgets/
        calendar_day_card.dart

    diary/
      controllers/
        diary_controller.dart
      models/
        diary_model.dart
      view/
        diary_view.dart
      widgets/
        diary_card.dart

  main.dart
```

Yeni feature oluşturulurken aynı klasörleme standardı kullanılmalıdır.

İşlevsiz veya kullanılmayan dosyalar yalnızca klasör yapısını doldurmak amacıyla oluşturulmamalıdır.

## 3. Adım Adım Uygulama Akışı

### Adım 1: Model Oluşturma

`features/diary/models/diary_model.dart` dosyasında günlük verisini temsil eden model oluşturulmalıdır.

```dart
class DiaryModel {
  final DateTime date;
  final String title;
  final String content;

  const DiaryModel({
    required this.date,
    required this.title,
    required this.content,
  });

  DiaryModel copyWith({
    DateTime? date,
    String? title,
    String? content,
  }) {
    return DiaryModel(
      date: date ?? this.date,
      title: title ?? this.title,
      content: content ?? this.content,
    );
  }

  factory DiaryModel.fromJson(Map<String, dynamic> json) {
    return DiaryModel(
      date: DateTime.parse(json['date'] as String),
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'title': title,
      'content': content,
    };
  }
}
```

Modeldeki tarih bilgisi bir günlük kaydının hangi güne ait olduğunu belirlemek için kullanılır.

Aynı tarihin farklı saatleri ayrı günlük olarak değerlendirilmemelidir.

### Adım 2: Controller Oluşturma

`features/diary/controllers/diary_controller.dart` dosyasında günlük state yönetimi hazırlanmalıdır.

Aşağıdaki örnek basit bir state yönetimi iskeletidir.

```dart
import 'package:flutter/foundation.dart';
import '../models/diary_model.dart';

class DiaryController {
  final ValueNotifier<DiaryModel?> selectedDiary =
      ValueNotifier<DiaryModel?>(null);

  void selectDiary(DiaryModel? diary) {
    selectedDiary.value = diary;
  }

  void updateDiary(String title, String content) {
    final currentDiary = selectedDiary.value;

    if (currentDiary == null) return;

    selectedDiary.value = currentDiary.copyWith(
      title: title,
      content: content,
    );
  }

  void dispose() {
    selectedDiary.dispose();
  }
}
```

Bu örnek yalnızca controller yapısını göstermektedir.

Gerçek uygulamada günlük kayıtlarının eklenmesi, silinmesi ve kalıcı olarak saklanması için storage servisi ile bağlantı kurulmalıdır.

Controller, veri saklama işlemlerini doğrudan UI içerisinde gerçekleştirmemelidir.

### Adım 3: View Oluşturma

`features/diary/view/diary_view.dart` dosyasında günlük ekranı oluşturulmalıdır.

View katmanının görevi kullanıcıya arayüzü göstermek ve kullanıcı etkileşimlerini controller'a iletmektir.

```dart
import 'package:flutter/material.dart';
import '../controllers/diary_controller.dart';

class DiaryView extends StatelessWidget {
  final DiaryController controller;

  const DiaryView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Günlüğüm'),
      ),
      body: ValueListenableBuilder(
        valueListenable: controller.selectedDiary,
        builder: (context, diary, _) {
          if (diary == null) {
            return const Center(
              child: Text('Henüz günlük yazılmamış.'),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                diary.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(diary.content),
            ],
          );
        },
      ),
    );
  }
}
```

Controller, View içerisinde gereksiz yere yeniden oluşturulmamalıdır.

Controller'ın yaşam döngüsü, onu oluşturan üst widget veya uygun bir bağımlılık yönetimi katmanı tarafından yönetilmelidir.

### Adım 4: Widget Oluşturma

`features/diary/widgets/diary_card.dart` dosyasında günlük önizleme kartı oluşturulmalıdır.

```dart
import 'package:flutter/material.dart';

class DiaryCard extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onTap;

  const DiaryCard({
    super.key,
    required this.title,
    required this.content,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(
          content,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
```

Widget mümkün olduğunca küçük, anlaşılır ve tekrar kullanılabilir olmalıdır.

## 4. Takvim Modülü Kuralları

Takvim ekranı `features/calendar/` klasöründe geliştirilmelidir.

- Takvimde ay değiştirme işlemi controller tarafından yönetilmelidir.
- Seçilen tarih `ValueNotifier<DateTime>` ile tutulmalıdır.
- Bugünün tarihi diğer tarihlerden farklı gösterilmelidir.
- Günlük kaydı bulunan tarihler işaretlenmelidir.
- Tarihe tıklanınca ilgili günlük ekranına geçilmelidir.
- Takvimde gösterilen tarihler, yıl ve ay geçişlerinde doğru hesaplanmalıdır.
- Takvim günleri ve ay isimleri Türkçe gösterilmelidir.

Takvim hesaplamaları mümkün olduğunca UI katmanından ayrılmalıdır.

## 5. Tema Yönetimi

Uygulama aydınlık ve karanlık tema desteğine sahip olmalıdır.

Tema dosyaları `core/theme/` altında bulunmalıdır.

### Tema Controller

Tema durumu `ValueNotifier<ThemeMode>` ile yönetilmelidir.

```dart
import 'package:flutter/material.dart';

class ThemeController {
  final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  void toggleTheme() {
    themeMode.value =
        themeMode.value == ThemeMode.light
            ? ThemeMode.dark
            : ThemeMode.light;
  }

  void dispose() {
    themeMode.dispose();
  }
}
```

Bu kod tema değişiminin temel mantığını göstermektedir.

Gerçek uygulamada kullanıcının tema tercihi kalıcı depolama ile saklanmalı ve uygulama başlatılırken yüklenmelidir.

### Tema Kuralları

- Açık ve koyu tema renkleri merkezi olarak tanımlanmalıdır.
- Widget içerisinde gereksiz sabit renk kullanılmamalıdır.
- `Theme.of(context)` üzerinden tema değerlerine erişilmelidir.
- Tema değiştirildiğinde bütün ekranlar yeni temaya uyum sağlamalıdır.
- Kullanıcının tema tercihi uygulama yeniden açıldığında korunmalıdır.

## 6. Veri Saklama Kuralları

Günlük kayıtları kalıcı olarak saklanmalıdır.

- Veri saklama işlemleri `DiaryStorageService` üzerinden gerçekleştirilmelidir.
- Controller ile storage katmanı birbirinden ayrılmalıdır.
- JSON dönüşümleri model içerisinde yapılmalıdır.
- Kayıtlar tarih bilgisi kullanılarak yönetilmelidir.
- Aynı güne ait birden fazla günlük oluşturulmamalıdır.
- Kaydetme ve silme işlemlerinden sonra ilgili notifier değerleri güncellenmelidir.
- Veri okuma ve yazma işlemlerinde oluşabilecek hatalar ele alınmalıdır.
- Chrome üzerinde desteklenen yerel depolama yöntemi kullanılmalıdır.

## 7. Clean Architecture ve Kod Kalitesi

### Separation of Concerns

Her dosya belirli bir sorumluluğa sahip olmalıdır.

- Model veri yapısını tanımlar.
- Controller iş mantığını yönetir.
- View ekranı oluşturur.
- Widget tekrar kullanılabilir UI bileşenlerini içerir.
- Service kalıcı veri işlemlerini gerçekleştirir.

### Reusability

Widget ve controller yapıları mümkün olduğunca tekrar kullanılabilir olmalıdır.

### Testability

İş mantığı, kullanıcı arayüzünden bağımsız olarak test edilebilir olmalıdır.

Controller testlerinde gerçek yerel depolama yerine gerektiğinde sahte servis kullanılabilir.

## 8. Kırmızı Çizgiler

1. Bütün kodlar tek bir `main.dart` dosyasına yazılmayacaktır.
2. Sayfa düzeyinde ağır `setState` kullanılmayacaktır.
3. State yönetiminde `ValueNotifier` esas alınacaktır.
4. Mümkün olan tüm widget'larda `const` kullanılacaktır.
5. Model sınıfları immutable olacaktır.
6. Büyük `build` metotlarından kaçınılacaktır.
7. **40 satırı aşan build metotları** uygun widget'lara ayrılacaktır.
8. UI içerisine veri saklama veya karmaşık iş mantığı yazılmayacaktır.
9. Renkler ve stiller merkezi tema dosyalarından yönetilecektir.
10. Onay alınmadan ağır state management paketleri eklenmeyecektir.
11. Gereksiz paket ve mimari karmaşıklık oluşturulmayacaktır.
12. Başka ödev klasörlerindeki kodlar değiştirilmemelidir.

## 9. Test ve Doğrulama

Her önemli kod değişikliğinden sonra uygun kontroller yapılmalıdır.

### Statik Kod Analizi

```bash
flutter analyze
```

Hedef sıfır hata ve sıfır uyarıdır.

### Birim ve Widget Testleri

```bash
flutter test
```

Özellikle aşağıdaki işlemler test edilmelidir:

- Modelin JSON dönüşümleri.
- `copyWith()` metodunun çalışması.
- Günlük oluşturma.
- Günlük güncelleme.
- Günlük silme.
- Aynı tarihe ait tek kayıt tutulması.
- Takvimde tarih seçimi.
- Tema değiştirme işlemi.

### Chrome Üzerinde Çalıştırma

```bash
flutter run -d chrome
```

Uygulama çalıştırıldıktan sonra temel kullanıcı işlemleri kontrol edilmelidir.

## 10. Yetenek Bileşenleri ve Referans Dosyaları

Bu yetenek aşağıdaki yardımcı dosyalarla desteklenmektedir.

**Örnek Ekran Uygulaması**

`examples/sample_screen.dart`

Immutable model, ValueNotifier controller, StatelessWidget ve modüler widget kullanımını gösterir.

**Reaktif State Yönetimi Kılavuzu**

`references/state_flow.md`

ValueNotifier, ValueListenableBuilder, controller yaşam döngüsü ve state akışını açıklar.

**Otomatik Feature Oluşturma Scripti**

`script/generate_feature.sh`

Yeni feature klasörlerini ve temel dosya iskeletini oluşturmaya yardımcı olur.

Bu referans dosyaları kullanılmadan önce mevcut olup olmadıkları kontrol edilmelidir.

## 11. Kullanım Örnekleri

### Yeni Bir Özellik Oluşturma

Örneğin uygulamaya `mood_tracker` özelliği eklenecekse:

```text
lib/features/mood_tracker/
  controllers/
    mood_tracker_controller.dart
  models/
    mood_tracker_model.dart
  view/
    mood_tracker_view.dart
  widgets/
    mood_tracker_card.dart
```

Bu yapıda her katmanın sorumluluğu ayrı tutulmalıdır.

### Mevcut Özelliği Güncelleme

Mevcut bir ekranda küçük değişiklik yapılacaksa gereksiz yeni dosyalar oluşturulmamalıdır.

Değişiklik, ilgili feature içerisinde gerçekleştirilmelidir.

## 12. Ajanın Çıktı Standartları

- Yapılan işlemler Türkçe açıklanmalıdır.
- Önemli dosya değişiklikleri kullanıcıya bildirilmelidir.
- Büyük dosyaların tamamı gereksiz yere tekrar gösterilmemelidir.
- Oluşturulan dosyaların proje içindeki yolları belirtilmelidir.
- Kod değişikliklerinden sonra analiz ve test sonuçları raporlanmalıdır.
- Başarısız testler gizlenmemelidir.
- Tamamlanan işlemler `PROGRESS.md` dosyasına yazılmalıdır.

## SSS

### Bu skill ne zaman kullanılmalıdır?

Yeni bir Flutter ekranı veya özellik modülü geliştirilirken kullanılmalıdır.

### State yönetimi için hangi yöntem kullanılmalıdır?

Basit ve reaktif durum yönetimi için `ValueNotifier` ve `ValueListenableBuilder` kullanılmalıdır.

### StatefulWidget tamamen yasak mı?

Hayır. Controller yaşam döngüsünü yönetmek, animasyon veya yerel UI durumları için kullanılabilir. Ancak sayfa düzeyindeki iş mantığı controller içerisinde tutulmalıdır.

### Yeni paket eklenebilir mi?

Evet. Proje gereksinimi için gerçekten gerekli olan hafif paketler kullanılabilir. Ağır state yönetimi paketleri kullanıcı onayı olmadan eklenmemelidir.

### Tema nasıl yönetilmelidir?

Tema durumu `ThemeController` üzerinden yönetilmeli ve kullanıcı tercihi kalıcı olarak saklanmalıdır.

### Uygulamanın tamamlandığı nasıl doğrulanır?

`flutter analyze`, `flutter test` ve `flutter run -d chrome` komutlarıyla doğrulanır. Sonuçlar `PROGRESS.md` dosyasında raporlanır.
