# SKILL.md — Filizora Projesi Genel Ajan Yönergeleri

Bu dosya, Filizora projesinde çalışan yapay zekâ ajanının uyması gereken genel kuralları ve geliştirme protokolünü tanımlar.

---

## 1. Temel İş Akışı ve Zorunlu Adımlar

Bir göreve başlamadan önce ve geliştirme sürecinde yapay zekâ ajanı aşağıdaki adımları sırasıyla uygulamakla yükümlüdür:

1. **Önce `PROJECT.md` Dosyasını Oku:** Proje kapsamı, temel 4 özellik, renk paleti ve genel kurallar için daima ilk başvuru kaynağı kök dizindeki `PROJECT.md` dosyasıdır.
2. **Mevcut Kodu ve Dosyaları İncele:** Göreve başlamadan önce ilgili dosya ve klasörleri mutlaka kontrol et. Dosyaları incelemeden üzerlerine yazma; mevcut çalışan kodları, testleri ve varlıkları koru.
3. **Uzmanlık Skill'lerini Oku:**
   - **Mimari ve Kod Organizasyonu Görevlerinde:** Mutlaka `.agents/skills/architecture/SKILL.md` dosyasını oku ve kurallara uy.
   - **Görsel Tasarım, UI/UX ve Tema Görevlerinde:** Mutlaka `.agents/skills/design/SKILL.md` dosyasını oku ve kurallara uy.
   - **Her İki Alanı Kapsayan Görevlerde:** İki skill dosyasını da (`architecture/SKILL.md` ve `design/SKILL.md`) birlikte oku ve uygula.
4. **Kapsamı Kesinlikle Koru:** Kullanıcının açıkça istemediği yeni özellik, sayfa, harici kütüphane veya modül ekleme.
5. **Değişikliklerden Sonra Testleri ve Analizi Çalıştır:** Yapılan her değişiklik sonrasında `filizora/` klasöründe analiz ve testleri çalıştırarak doğrula.

---

## 2. Kapsam ve 4 Ana Özellik Kuralı

Uygulama yalnızca aşağıdaki 4 ana özelliği ve kayıt/onay akışını kapsar:

1. **Mentor–Menti Eşleşmesi (`features/mentor_matching`)**
2. **Girişimci Topluluğu (`features/entrepreneur_community`)**
3. **Destek Programları (`features/support_programs`)**
4. **Girişim Süreci Takibi (`features/venture_tracking`)**

Kayıt akışında "İş fikrim var" / "İş fikrim yok" seçimi yapılır. Kayıt sonrasında hesap yönetici onayı bekleme durumuna alınır ve kullanıcı onaylanana kadar ana özelliklere erişemez.

---

## 3. Kodlama ve Tasarım Standartları Özeti

- **Mimari:** Özellik bazlı yapı (`core/` ve `features/<feature_name>/`).
- **Katmanlar:** Controller, model, view, widget net olarak ayrılmalıdır.
- **State Yönetimi:** Sayfa seviyesinde ağır `setState` kullanılmaz; `ValueNotifier` / `ChangeNotifier` tercih edilir.
- **Tasarım:** Material 3 açık ve koyu tema desteklenir.
- **Renkler:** 5 sabit marka rengi (`#005F85`, `#3A8B8E`, `#FF7720`, `#FAA82C`, `#DE2C2C`) `AppColors` sınıfı üzerinden kullanılır.
- **Logo:** `AppLogo` bileşeni (`assets/images/filizora_logo.png`) kullanılır.
- **Build Metotları:** 40 satırı aşan metotlar alt widget'lara bölünür.

---

## 4. Zorunlu Doğrulama Komutları

Değişikliklerin ardından komutları `filizora/` dizininde çalıştır:

```bash
flutter pub get
dart analyze # veya flutter analyze
flutter test
```

- Komutları gerçekten çalıştırmadan başarılı olduklarını söyleme.
- Analiz hatalarını ve test kırılmalarını mutlaka çöz.
- Emülatör/cihaz bulunmaması gibi engelleri açıkça bildir.

---

## 5. Yanıt ve Raporlama Biçimi

Görev tamamlandığında kısa, Türkçe ve net bir sonuç raporu sun:
- Klasör yeniden adlandırma durumu.
- Oluşturulan, taşınan ve değiştirilen dosyaların yolları.
- `PROJECT.md` ve skill dosyalarının durumu.
- Logo, marka ve renk paleti entegrasyonu.
- Gerçekleştirilen analiz ve test sonuçları.
- Varsa engeller veya kullanıcıdan beklenen kararlar.
