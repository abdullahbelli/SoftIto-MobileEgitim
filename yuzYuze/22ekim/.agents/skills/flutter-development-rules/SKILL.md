---
name: flutter-development-rules
description: Ritmia üzerinde her Flutter/Dart kodlama görevi, hata düzeltme, refactor, dosya düzeni, yorum ve test sırasında uygulanan genel mühendislik ve çalışma kuralları.
---

# Flutter General Development Skill

## Başlamadan önce
1. Kök `project.md` dosyasını, bu skill'i ve `flutter-mvc-architecture` ile tasarım skill'lerini oku.
2. Var olan dosyaları ve bağımlılıkları incele; zaten çalışan davranışı bozma.
3. Yapılacak işi ekranlar, MVC modelleri, View–Controller veri akışı ve test maddeleriyle sınırlı bir küçük plan halinde düşün.
4. Backend yoksa sahte davranışı **demo** etiketi olmadan gerçekmiş gibi gösterme.

## Kod kalitesi
- Dart null safety, `const` mümkün oldukça, anlamlı değişken/fonksiyon adları, düşük karmaşıklık, kısa widget'lar.
- `setState` yalnız lokal geçici UI durumunda; kalıcı/iş durumu için Provider + ChangeNotifier tabanlı MVC Controller. Karmaşık iş kuralları bağımsız Service sınıflarında; veri saklama Repository içinde.
- Hata/boş/yükleme ve form validation unutulmaz. Snackbar'lar gereksiz tekrarlamaz.
- Doğrudan renk/sayı/ekran metni tekrarları üretme; tasarım token'ları ve l10n/strings kullan.
- Gereksiz dependency ekleme; paket seçimini ve amacını `pubspec.yaml` yanında kısaca açıkla.
- Ağ, platform, izin veya backend gerektiren özelliği sessizce çalışıyor varsayma.

## Yorum yazım standardı
- Kodların ne yaptığını öğrenmeyi kolaylaştıracak **kısa, doğal Türkçe** yorumlar kullan.
- Karmaşık hesap, özel tarih/lig kuralı, karar gerekçesi, widget durumu, veri akışı ve önemli public method'larda açıklama yaz.
- `final x = 1; // x'e 1 atar` gibi her satırı tekrar eden yorumlar yazma. Yorum **neden** ve **nasıl** bilgisi katsın; okunabilir kodun yerine geçmesin.
- Çok uzun dosya veya gereksiz yorumla UI yapısını boğma.

## Git ve dosya disiplini
- `.gitignore` içinde `.dart_tool/`, `build/`, `.idea/`, hassas `.env` değerleri ve üretilen geçici dosyaları dışla; gerekli örnek konfigurasyonları `.env.example` içinde sun.
- Mevcut kullanıcı dosyalarını izinsiz silme, toplu yeniden isimlendirme yapma, veri kaybına yol açabilecek komut çalıştırma.
- Her ana kilometre taşında mantıklı commit öner; ortamda kullanıcının açık talebi yoksa otomatik `push`, `reset --hard`, `force push` yapma.
- `project.md` tamamlanan modüllere/kararlara göre güncellensin. Skill dosyalarını sadece kalıcı kural değişirse güncelle.

## Adım adım geliştirme sırası
1. Flutter iskeleti, tasarım token'ları, routing, tema ayarları.
2. Splash + demo giriş/kayıt ekranları ve auth state (gerçek auth için repository sözleşmesi hazır).
3. Alışkanlıklarım boş durum, animasyonlu FAB, CRUD bottom sheet, yerel veri saklama.
4. Plan/tamamlama ve streak servis hesapları, alışkanlık kartları.
5. Takvim, gün raporu ve alışkanlık filtreleri.
6. Rozet motoru/görseller ve profil.
7. Opt-in ve açık etiketli demo liderlik ekranı, lig kurallarının testleri.
8. Responsive, erişilebilirlik, hata senaryoları, temel testler.
9. Ayrı bir sonraki aşama: gerçek backend/auth, sunucu puanlama, lig geçişleri, senkronizasyon.

## Tamamlanma ölçütü
- `dart format .`, `flutter analyze`, `flutter test` çalıştır; hata varsa belirt ve mümkünse düzelt.
- Ekranlar arasında gezinme, form doğrulaması, boş durum, modal klavye açılması, tema kalıcılığı, çıkış/geri akışı kontrol edilir.
- Her değişiklik sonrası kısa rapor: değişen dosyalar, kullanıcı açısından görünen sonuç, test sonucu, kalan iş.
