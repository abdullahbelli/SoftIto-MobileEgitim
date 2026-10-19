---
name: flutter-feature-scaffold
description: Flutter projelerinde özellik bazlı klasör yapısı oluşturur. ValueNotifier state mimarisini UI ayrımını ve birim test iskeletini standartlara uygun olarak üretir.
---

# Flutter feature scaffold (modler ekran iskeleti)

Bu yetenek, projede yeni bir ekran ya da işlev modğlğ açarken Clean UI ve reaktif State kurallarına tam uyulmasını garanti altına alır.

## Temel Kuralar

1. **Asla tek dosada toplama:**
   UI (`_vier.dart`) State Controller
   (`_controler.dart`) ve model (`_model.dart`) dosyaları ayrı ayrı açılmalıdır.
2. **State Yönetimi:**
   Basit ve reaktif durumlar için `ValueNotifier` kullanılmalıdır.
   Doğrudan devasa StatefulWidgets yazarak işi karmaşıklaştırma.
3. **Const Zorunluluğu:**
   Mümkün olan tüm widgetlarda const olmalıdır.

## Adım Adım Uygulama Akışı

### Adım 1: Klasör yapısı oluşturma

Hedeflenen modül adlarını (örn:`water_tracker`) , `lib/features/<feature_name>/` altında yapıyı kur.

```text
lib/features/<feature_name>
    controllers/
        <feature_name>_controller.dart
    models/
        <feature_name>_model.dart
    view/
        <feature_name>_view.dart
    widgets/
        <feature_name>_card.dart

```

### Adım 2 : Controller Dosyasını Yaz

`controllers/<feature_name>_controller.dart` içinde mantığı `ValueNotifier`tanımlarını oluştur:

```dart
import 'package:flutter/foundation.dart';

class WaterTrackerController {
    final ValueNotifier<int> currentWater = ValueNotifier<int>(0);
    final int dailyGoalWater = 2000; //2litre

    void addWater(){
        currentWater.value +=250;
    }
    void resetWater(){
        currentWater.value = 0;

    }

    void dispose(){
        currentWater.dispose();
    }

}
```

### Adım 3 : Model Dosyası

`models/<feature_name>_model.dart` dosyasını `copyWith`, `fromJson`, `toJson` metotlarını içerek şekilde ìmmutableòlarak tanımla:

```dart
class UserProfile{
    final String name;
    final String email;
    final String profileImage;
    final int level;
    final int coins;

    const UserProfile({
        required this.name,
        required this.email,
        required this.profileImage,
        required this.level,
        required this.coins,
    });

    // Modelden yeni bir kopya olusturur, sadece degisen alani gunceller
    UserProfile copyWith({
        String? name,
        String? email,
        String? profileImage,
        int? level,
        int? coins,
    }) {
        return UserProfile(
            name: name ?? this.name,
            email: email ?? this.email,
            profileImage: profileImage ?? this.profileImage,
            level: level ?? this.level,
            coins: coins ?? this.coins,
        );
    }

    // JSON'dan model olusturma
    factory UserProfile.fromJson(Map<String, dynamic> json) {
        return UserProfile(
            name: json['name'] ?? '',
            email: json['email'] ?? '',
            profileImage: json['profileImage'] ?? '',
            level: json['level'] ?? 0,
            coins: json['coins'] ?? 0,
        );
    }

    // Modelden JSON olusturma
    Map<String, dynamic> toJson() {
        return {
            'name': name,
            'email': email,
            'profileImage': profileImage,
            'level': level,
            'coins': coins,
        };
    }
}
```

### Adım 4: View Dosyası

`view/<feature_name>_view.dart` içinde `StatelessWidget` kullanarak temiz UI katmanı oluştur.

```dart
import 'package:flutter/material.dart';
import '../controllers/<feature_name>_controller.dart';

class <Feature_name>View extends StatelessWidget {
    final <Feature_name>Controller _controller = <Feature_name>Controller();

    <Feature_name>View({Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(title: const Text('Flutter Feature Scaffold')),
            body: ValueListenableBuilder<int>(
                valueListenable: _controller.currentWater,
                builder: (context, currentWater, _) {
                    return Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                Text('Current Water: $currentWater ml',
                                style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                    onPressed: () {
                                        _controller.addWater();
                                    },
                                    child: const Text('Add 250 ml'),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                    onPressed: () {
                                        _controller.resetWater();
                                    },
                                    child: const Text('Reset Water'),
                                ),
                            ],
                        ),
                    );
                },
            ),
        );
    }
}
```

### Adım 5: Widget Oluşturma (Widget)

`widgets/<feature_name>_card.dart` dosyasında `StatelessWidget` kullanılarak UI katmanını oluştur:

```dart
import 'package:flutter/material.dart';

class <Feature_name>Card extends StatelessWidget {
    final String title;
    final String subtitle;
    final IconData icon;
    final int level;
    final int coins;

    const <Feature_name>Card({
        Key? key,
        required this.title,
        required this.subtitle,
        required this.icon,
        required this.level,
        required this.coins,
    }) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return Card(
            child:Column(
                children: [
                    Image.network(icon),
                    Text(title),
                    Text(subtitle),
                    Text('Level: $level'),
                    Text('Coins: $coins'),
                ],
            ),
        );
    }
}
```

### Adım 6: Clean Architecture Kurallarına Uyum

- **Separation of Concerns:** Her dosyanın belirli bir sorumluluğu olduğundan emn ol.
- **Reusability:** Widgetları ve controllerı diğer ekranlarda da kullanılabilecel şekilde tasarla.
- **Testability:** Her dosya için birim test (unit test) iskeletini oluştur.

## 📂 Yetenek Bileşenleri ve Referans Dosyaları

Bu yetenek aşağıdaki yardımcı araç ve referans dökümanlarıyla desteklenmektedir:

1. **Örnek Ekran Uygulaması (Example):**
   - [sample_screen.dart](file:///Users/d1-11/Documents/GitHub/SoftIto-MobileEgitim/yuzYuze/19ekim_3/.agents/skills/examples/sample_screen.dart) — İmmutable model, reaktif controller, parçalı (<40 satır) widget'lar ve `StatelessWidget` görünümü içeren eksiksiz şablon.
2. **Reaktif Durum Akışı Kılavuzu (References):**
   - [state_flow.md](file:///Users/d1-11/Documents/GitHub/SoftIto-MobileEgitim/yuzYuze/19ekim_3/.agents/skills/references/state_flow.md) — `ValueNotifier` mimarisi, yaşam döngüsü, bellek yönetimi ve Mermaid akış diyagramları.
3. **Otomatik İskelet Oluşturucu Script (Script):**
   - [generate_feature.sh](file:///Users/d1-11/Documents/GitHub/SoftIto-MobileEgitim/yuzYuze/19ekim_3/.agents/skills/script/generate_feature.sh) — Yeni bir özellik modülünü tüm katmanları ve birim testleriyle otomatik üreten kabuk betiği.

## Kullanma Örnekleri

### Örnek 1: Basit bir ekran oluşturma

```dart
import 'package:flutter/material.dart';
import '../view/water_tracker_view.dart';

class HomePage extends StatelessWidget {
    const HomePage({Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return WaterTrackerView();
    }
}
```

### Örnek 2: Modüler Widget Kullanımı

```dart
import 'package:flutter/material.dart';
import '../widgets/water_tracker_card.dart';

class HomePage extends StatelessWidget {
    const HomePage({Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return WaterTrackerCard(
            title: 'Water Tracker',
            subtitle: 'Water Tracker',
            icon: Icons.water_drop,
            level: 1,
            coins: 0,
        );
    }
}
```

## Ekstra İpuçları

- **Dependency Injection:** Controller'ları widgetlara inject etmek için GetIt veya Provider kullanabilirsin.
- **Navigation:** Navigasyonu sağlamak için Navigator 2.0 veya go_router kullanabilirsin.
- **Testing:** Her katman için ayrı testler yazarak uygulanın stabilitesi sağlayabilirsin.

### SSS

### Soru: Hangi durularda bu yeteniğini kıllanmalıyı?

**Cevap:** Yeni bir ekran veya işlev modülü oluşturuken bu yeteneği kullanmalısın.

### Soru: Bu yetenek hangi duurmlarda kullanmalıyım?

**Cevap:** Mevcut bir ekranı güncellerken veya kğçük bir hata düzeltmesi yaparken bu yeteneği kullanmamalısın.
