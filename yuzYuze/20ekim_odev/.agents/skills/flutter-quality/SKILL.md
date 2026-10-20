---
name: rotiva-flutter-quality
description: Flutter analiz/test standardı, edge-case denetimleri, temel erişilebilirlik ve teslime hazırlık.
---
# Kalite ve Test Skill

## Her feature ve kod değişikliği sonrası
- `dart format .`
- `flutter analyze`
- İlgili `flutter test` dosyaları.
- Uygun ortamda `flutter run -d chrome`; Android emülatörde de görsel test.
- Çalıştırılamayan komutu başarılıymış gibi bildirme.
- **Zorunlu PROJECT.md Güncellemesi:** Projede herhangi bir kod değişikliği, layout düzeltmesi veya yeni özellik eklendiğinde `yuzYuze/20ekim_odev/PROJECT.md` dosyası da güncellenmeli; yapılan gerçek değişiklikler belgelenmelidir.

## Kalıcı Türkçe Kod Açıklama (Yorumlama) Standardı
Bu proje SoftIto Flutter eğitimi kapsamında geliştirilmektedir. Projeye eklenecek veya değiştirilecek **bütün Dart kodlarında** başlangıç seviyesindeki bir öğrencinin satır satır okuyarak Flutter mantığını kavrayabileceği Türkçe açıklama standardı uygulanacaktır:
- `import`, `class`, `enum`, `final`, `const`, `late`, `required`, `?` (nullable) yapılarının amacı belirtilmelidir.
- `initState`, `dispose`, `setState`, `build`, `Scaffold`, `AppBar`, `Column`, `Row`, `Expanded`, `Wrap` gibi temel widget ve yaşam döngüsü metotları açıklanmalıdır.
- Model, Repository, InheritedWidget (RotivaScope), SharedPreferences kalıcılığı ve fiyat/ceza hesaplama kuralları yorumlanmalıdır.
- Açıklamalar kısa, doğal ve eğitici Türkçe `//` yorumları biçiminde olmalıdır; anlamsız kapanış parantezlerine yorum eklenmemelidir.
- Kodun çalışma mantığı açıklanmalı, sadece kod birebir tekrar edilmemelidir.

## Unit test
- Form validator: boş/geçersiz e-posta, kısa şifre, uyumsuz parola, telefon.
- Tarih ve çakışma: geçmiş, sıfır gün, ardışık kiralama, çakışma.
- Fiyat: normal, ek km, şube nakit indirimi, adrese teslim, yasak ödeme.
- Yaş/ehliyet: sınır günü ve yetersiz süre.
- Repository: ekle, düzenle, pasif yap, aktif kiralamalı araç silme engeli.

## Widget test
- KVKK ve açık rıza onayları olmadan kayıt yapılamaz.
- Dialog aç/kapat; tema değiştirme.
- Filtreleme sonucunun değişmesi ve boş durum.
- Adrese teslim seçilince nakit opsiyonunun kapatılması.
- Kiralama sözleşmesi kabul edilmeden ödeme geçişinin engellenmesi.

## Elle senaryo kontrolü
- Demo müşteri girişi → araç ara → filtre → detay → tarih → km → sözleşme → ödeme simülasyonu → Kiralamalarım.
- Demo yönetici girişi → araç ekle/düzenle/pasif yap/sil teyidi → müşteri ve kiralama kontrolü.
- Light/dark tema; klavye/scroll/geri gitme; 360px dar ekran.
- Boş araç/yorum/kiralama listesi; eksik resim; uzun metinler ve büyük font.
- Yönetici dashboard ve kiralama kartlarında `BOTTOM OVERFLOWED` ve nested scaffold çakışması olmamalıdır.

## Çıktı
README'de kurulum ve çalıştırma komutları, demo hesap açıklaması, özellikler, mimari, temalar, bilinen DEMO sınırlamaları ve test bilgileri bulunsun.
