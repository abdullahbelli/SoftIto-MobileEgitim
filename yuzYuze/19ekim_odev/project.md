# Dijital Günlüğüm – Flutter Dijital Günlük Uygulaması

Bu doküman, Flutter projesinde geliştirme yapacak olan Antigravity yapay zekâ ajanı ve yazılım geliştiriciler için hazırlanmıştır. Projede geliştirilen tüm özellikler burada belirtilen gereksinimlere uygun olmalıdır.

## 1. Proje Özeti ve Teknolojiler

- **Uygulama adı:** Dijital Günlüğüm
- **Proje amacı:** Kullanıcının takvim üzerinden istediği tarihi seçerek o güne ait günlük yazabilmesini, mevcut günlüklerini okuyabilmesini, düzenleyebilmesini ve silebilmesini sağlamak.
- **Framework:** Flutter
- **Programlama dili:** Dart
- **Hedef platform:** Öncelikle Chrome (Web), ardından Android ve iOS.
- **Flutter SDK:** Bilgisayarda kurulu mevcut kararlı Flutter sürümü.
- **Tasarım dili:** Material 3
- **Tema:** Aydınlık ve karanlık tema desteği.
- **State yönetimi:** ValueNotifier ve ValueListenableBuilder.
- **Veri saklama:** Web ortamında çalışabilen kalıcı yerel depolama.
- **Dil:** Türkçe.

Uygulama basit, anlaşılır ve kullanımı kolay olmalıdır. Gereksiz özellikler ve karmaşık mimariler kullanılmamalıdır.

---

## 2. Uygulamanın Temel Özellikleri

### 2.1. Takvim Ekranı (Calendar)

Uygulama açıldığında kullanıcıyı takvim ekranı karşılamalıdır.

- Takvim varsayılan olarak içinde bulunulan ayı göstermelidir.
- Kullanıcı önceki ve sonraki aylara geçebilmelidir.
- Takvimdeki günler seçilebilir olmalıdır.
- Bugünün tarihi diğer günlerden farklı gösterilmelidir.
- Günlük yazılmış günlerde küçük bir nokta veya işaret bulunmalıdır.
- Kullanıcı bir güne tıkladığında o tarihe ait günlük sayfası açılmalıdır.
- Takvim Türkçe ay ve gün isimlerini göstermelidir.
- Haftanın ilk günü pazartesi olmalıdır.

### 2.2. Günlük Ekranı (Diary)

Kullanıcı takvimden bir tarih seçtiğinde günlük ekranı açılmalıdır.

- Ekranın üst kısmında seçilen tarih gösterilmelidir.
- Seçilen tarihte günlük varsa mevcut kayıt görüntülenmelidir.
- Günlük bulunmuyorsa "Bu güne ait henüz bir günlük yazılmamış." mesajı gösterilmelidir.
- Kullanıcı günlük için başlık ve açıklama yazabilmelidir.
- Yeni günlük kaydedilebilmelidir.
- Mevcut günlük düzenlenebilmelidir.
- Günlük silinebilmelidir.
- Silme işleminden önce kullanıcıdan onay alınmalıdır.
- Başlık ve günlük içeriği tamamen boş bırakılarak kayıt oluşturulması engellenmelidir.
- Aynı tarihe ait yalnızca bir günlük kaydı tutulmalıdır.
- Kaydetme, güncelleme ve silme işlemlerinden sonra takvimdeki günlük işaretleri güncellenmelidir.

### 2.3. Aydınlık ve Karanlık Tema

Uygulamada iki farklı görünüm bulunmalıdır.

**Aydınlık Tema (Light Mode)**

- Açık renkli arka plan.
- Beyaz veya açık tonlarda kartlar.
- Mor/lila vurgular.
- Okunabilir koyu renkli metinler.

**Karanlık Tema (Dark Mode)**

- Koyu gri veya lacivert tonlarında arka plan.
- Koyu renkli kartlar.
- Mor/lila vurgular.
- Okunabilir açık renkli metinler.

**Tema Kuralları**

- Kullanıcı uygulama üzerinden tema değiştirebilmelidir.
- Tema değiştirme işlemi uygulama yeniden başlatılmadan gerçekleşmelidir.
- Seçilen tema tercihi kalıcı olarak saklanmalıdır.
- Tema yönetiminde ValueNotifier kullanılmalıdır.
- Renk ve yazı stilleri merkezi tema dosyalarından yönetilmelidir.

### 2.4. Veri Saklama

- Günlük kayıtları uygulama kapatıldığında kaybolmamalıdır.
- Chrome üzerinde veriler kalıcı olarak tutulmalıdır.
- Aynı tarayıcı profiliyle uygulama yeniden açıldığında kayıtlar yüklenmelidir.
- Günlük kayıtları tarih bilgisiyle ilişkilendirilmelidir.
- Kullanıcı herhangi bir tarihin kaydını güncelleyebilmeli veya silebilmelidir.
- Uygulama için sunucu, kullanıcı hesabı veya internet bağlantısı zorunlu olmamalıdır.
- Tarayıcı verilerinin temizlenmesi durumunda yerel kayıtların silinebileceği kabul edilmelidir.

---

## 3. Mimari Yapı – Özellik Bazlı

Kodlar kesinlikle tek dosyada toplanmamalıdır.

Her özellik kendi klasöründe geliştirilmelidir.

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

- `main.dart` yalnızca uygulamanın başlangıç yapılandırmasını içermelidir.
- `core/` klasöründe ortak servisler ve tema dosyaları bulunmalıdır.
- `features/` klasöründe uygulamanın ekranları ve işlevleri yer almalıdır.
- Controller, Model, View ve Widget dosyaları birbirinden ayrılmalıdır.
- Ayrıntılı mimari kurallar `SKILL.md` dosyasında tanımlanacaktır.
- Gereksiz sınıflar veya kullanılmayan dosyalar oluşturulmamalıdır.

---

## 4. Tasarım ve Kullanıcı Deneyimi

- Arayüz sade, modern ve anlaşılır olmalıdır.
- Material 3 tasarım bileşenleri kullanılmalıdır.
- Mobil ekranlara uyumlu responsive tasarım hazırlanmalıdır.
- Chrome üzerinde geniş ekranlarda içerik ortalanmalı ve uygun maksimum genişlik kullanılmalıdır.
- Takvim günleri rahatlıkla seçilebilmelidir.
- Butonlar ve metin alanları yeterli boşluklara sahip olmalıdır.
- Kullanıcı yaptığı işlemlerin sonucunu görebilmelidir.
- Günlük yazma ekranında dikkat dağıtan gereksiz bileşenler bulunmamalıdır.
- Aydınlık ve karanlık temalarda okunabilirlik korunmalıdır.

---

## 5. Kırmızı Çizgiler ve Proje Sınırları

1. Sayfa düzeyinde state yönetimi için ValueNotifier kullanılacaktır.
2. Gereksiz büyük StatefulWidget yapılarından kaçınılacaktır.
3. Her özellik kendi feature klasöründe geliştirilecektir.
4. Widget, controller ve model sorumlulukları ayrılacaktır.
5. Mümkün olan tüm widget'larda const kullanılacaktır.
6. Gereksiz üçüncü taraf paketler eklenmeyecektir.
7. Backend, kullanıcı girişi ve bulut senkronizasyonu geliştirilmeyecektir.
8. Takvim ve günlük işlemleri hatasız çalışmalıdır.
9. Uygulama Chrome üzerinde çalışabilmelidir.
10. Mevcut ödev klasörü dışındaki dosyalar değiştirilmemelidir.

---

## 6. Geliştirme Süreci

Antigravity ajanı geliştirme işlemlerini aşağıdaki sırayla gerçekleştirmelidir.

1. `project.md` dosyasını incele.
2. `.agents/skills/SKILL.md` dosyasındaki mimari kuralları oku.
3. Gerekli yardımcı örnek ve referans dosyalarını incele.
4. Flutter projesini mevcut `19ekim_odev` klasöründe oluştur.
5. Tema altyapısını hazırla.
6. Takvim ekranını geliştir.
7. Günlük modelini ve controller yapısını oluştur.
8. Günlük ekleme, düzenleme ve silme özelliklerini geliştir.
9. Kalıcı veri saklama işlemlerini tamamla.
10. Widget ve birim testlerini hazırla.
11. Analiz ve test komutlarını çalıştır.
12. Uygulamayı Chrome üzerinde çalıştır.

### Süreç Takibi

Ajan, geliştirme işlemlerini takip etmek için proje kökünde `PROGRESS.md` dosyası oluşturmalıdır.

Bu dosyada tamamlanan işlemler, kalan görevler, hatalar ve test sonuçları bulunmalıdır.

Her önemli geliştirme aşamasından sonra bu dosya güncellenmelidir.

---

## 7. Test ve Doğrulama

Projenin çalıştığı aşağıdaki komutlarla doğrulanmalıdır.

**Paketleri yükleme:**

```bash
flutter pub get
```

**Statik kod analizi:**

```bash
flutter analyze
```

Hedef sıfır hata ve sıfır uyarıdır.

**Birim ve Widget testleri:**

```bash
flutter test
```

**Chrome üzerinde çalıştırma:**

```bash
flutter run -d chrome
```

Aşağıdaki senaryolar kontrol edilmelidir:

- Takvimden farklı tarihler seçilebilmesi.
- Seçilen tarihin günlük ekranının açılması.
- Yeni günlük oluşturulması.
- Mevcut günlük içeriğinin düzenlenmesi.
- Günlük silinmesi.
- Kayıtların uygulama yeniden açıldığında korunması.
- Aydınlık ve karanlık tema arasında geçiş yapılması.
- Tema tercihinin yeniden açılışta korunması.

---

## 8. Ajanın Çıktı ve Yanıt Standartları

- Geliştirme süreci Türkçe açıklanmalıdır.
- Yapılan önemli değişiklikler kısa ve anlaşılır şekilde bildirilmelidir.
- Dosyalar oluşturulmadan önce mevcut proje yapısı kontrol edilmelidir.
- Diğer ödev klasörlerine müdahale edilmemelidir.
- Hata oluştuğunda önce hata analiz edilmeli, ardından çözüm uygulanmalıdır.
- Test edilmemiş özellikler çalışıyor olarak raporlanmamalıdır.
- Gereksiz uzun kod çıktıları yerine değiştirilen dosyalar ve işlemler özetlenmelidir.

## 9. Tamamlanma Kriterleri

Proje aşağıdaki şartların tamamı karşılandığında bitmiş kabul edilir:

- Takvim ekranı çalışıyor.
- Tarih seçildiğinde ilgili günlük ekranı açılıyor.
- Günlük oluşturma, düzenleme ve silme işlemleri çalışıyor.
- Günlükler yerel depolamada kalıcı olarak saklanıyor.
- Açık ve koyu tema düzgün çalışıyor.
- Tema tercihi saklanıyor.
- Flutter analiz ve test kontrolleri başarılı.
- Uygulama Chrome üzerinde çalıştırılmış.
- `PROGRESS.md` güncel ve tamamlanma durumu raporlanmış.
