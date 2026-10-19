# Fitness su takip uygulamsı

Bu döküman Flutter projesinde geliştrime yapacak olan ajan (Antigravity) yapay zeka ve yazlım geliştiriciler için bağlayıcı bir kılavuzdur. Projede ğretilen her kod satırı buradaki kurallara UYMAK ZORUNDADIR.

## 1.Proje Özeti ve Teknolojiler

- **Uygulama adı:** Susadım (akıllı su egzersiz ve kalori takibi uygulaması)

- **Hedef platform:** iOS ve Android öncelikli ardından Web ve Desktop

- **Flutter SDK Sürümü:** 3.29.0

- **Dart SDK Sürümü:** 3.0.0 -**Tasarım dili:**Material 3, Koyu Tema(gece spor salonu paleti,dark obsidian &neon);

---

## Mimari Yapı : Özellik Bazlı

kodlar ksinlikle tek bir yerde toplanmayacaktır. Her modül kendi feature klasöründe kodlanacaktır.

```
text
lib/
core/
extension'lar
contasnts/app_colors.dart
theme/app_theme.dart

    features/
        water_traker/
            controller/
            models/
            view/
            widget/
        workout/
            controller/
            models/
            view/
            widget/
        competiton/
            controller/
            models/
            view/
            widget/

    main.dart
```

#### Sadece uygulama başlatma ve tema bölümleri

### 2.1 Yarışma & Liderlik Tablosu (Competition Özelliği)
- **Sıralama Metriği:** Meydan Okuma Serisi (Streak) — Hedefleri aralıksız tutturma gün sayısı ve kazanılan rozetler.
- **Tasarım:** Haftalık Lig & Podyum (İlk 3 dereceye özel neon madalyalar), kullanıcının sıralaması ve meydan okuma butonları.
- **Yapı:** `competition` feature klasöründe model, controller, parçalı widget'lar ve ana görünüm.


## 3. Kırmızı Çizgiler Kod Kalite Standartları

1 - **State Yönetim Standartları:**
Sayfa dğzeyinde ağır `setState`KULLANILMAYACAKTIR.
Sadece yerel arayüz durumunu yöneten (örneğin buton animasyonları vb.) StatefulWidget kabul edilir.

2 - **UI ve Performans Kuralları:**
Statik tüm widget'larda `const`zorunludur.
Renk ve metin stilleri kesinlikle tema dosyalarına yazılacaktır.
Büyük buşld methodları yasaktır. 40 satırı geçen build metodları özel widget yazılacatır.

3 - **Yasaklı Paketler:**
Projeye onay almadan harici ağır state paketleri EKLENMEYECEKTİR.
Dart'ın ve Flutter'ın yerel çekirdek apilerini kullanmak esastır.

## 4 Geliştirme ve Analiz ve Test Komutları

Ajan yaptığı harhangi bir kod değişikliklerinden sonra mutlaka alttaki koutların çalıştığını doğrulamalıdır.

- **Statik kod analizi(0 uyarı ve 0 haa şart):**

```bash
flutter analyze
```

- **Birim ve Widget testleri:**

```bash
flutter test
```

- **Projeyi çalıştırma:**

```bash
flutter run
```

## 5 Ajanın çıktı ve Yanıt verme standartları

**Açıklamalar:** Türkçe teknk terimlerin özğnü bozmadan net ve doğrudan olacaktır.

**Değişiklik Sunumları:** Örnek 500 satırlık bir dosyda 3 satır değiştiyse tüm dosyayı baştan sona basma; hedef satırları ve diff yapısını göster.

**Dosya yolları:** Bahsedilen ve üretilen her dosya için mutlaka projeye göre tıklananbilir link ver.

**Doğrulama:** Kod yazdıktan sonra kullanıcıya "Şimdi flutter analiz ile kontrol edebilirsin" şeklinde doğrulama yönergeleri ver.
