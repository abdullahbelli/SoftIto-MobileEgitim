---
name: boardconnect-general
description: BoardConnect Flutter projesinde genel geliştirme kuralları, iş planı, değişiklik güvenliği, kod kalitesi, test ve project.md güncellemeleri için kullanılır.
---

# BoardConnect — Genel Geliştirme Skill'i

## Ne zaman kullanılır?
BoardConnect üzerinde **her geliştirme görevinden önce** bu dosyayı ve proje kökündeki `project.md` dosyasını oku. Tasarım veya mimari görevlerinde ilgili ek skill ile birlikte kullan.

## Tek doğruluk kaynağı
- Proje adı: **BoardConnect**.
- Gereksinimler için kökteki `project.md` önceliklidir; skill dosyaları uygulama biçimini belirler. Çelişki varsa yeni özellik uydurmak yerine belgedeki gereksinimi koru, uyumsuzluğu bildir.
- Kullanıcı istemeden kapsam dışı büyük özellikler ekleme veya mevcut ekranları yeniden yazma.
- Tasarımlar Stitch referanslarına dayanmalı; görseller verilmemişse varmış gibi davranma.

## Zorunlu çalışma sırası
1. `project.md`, ilgili skill'ler ve hedef dosyaları oku; klasör yapısını incele.
2. Görevi küçük, test edilebilir parçalara ayır; dokunulacak dosyaları ve beklenen davranışı belirle.
3. İlgili mevcut kodu koruyarak uygula. Aynı sorunu çözen ikinci bir servis, model veya ekran oluşturma.
4. Kod biçimlendirmesini, analizini ve ilgili testleri çalıştır; çalıştırılamayanları belirt.
5. Ekranlarda dar mobil, dikey/yatay, tablet ve geniş masaüstü taşmalarını kontrol et.
6. Tamamlanan değişiklikleri, yeni kararları ve açık işleri `project.md` değişiklik geçmişine işle.
7. Kullanıcıya yapılanlar, etkilenen dosyalar, doğrulama sonuçları ve eksik kalanları kısa şekilde bildir.

## Flutter kuralları
- Dart null safety, tutarlı isimlendirme ve küçük bileşenler kullan.
- `main.dart` yalnızca başlatma/bağlama işlerini yönetsin. UI, veri modeli, repository ve servisleri ayır.
- State yönetiminde planlanan Riverpod yaklaşımına uy; alternatif kütüphaneyi gerekçesiz ekleme.
- Sayfa yönlendirmesinde tek bir routing düzeni kullan.
- Kullanıcıya görünen metinler Türkçe ve tutarlı olsun. Tekrarlanan metinleri merkezi tanımlamayı değerlendir.
- Bekleme, boş veri, hata, yeniden deneme ve bağlantı kesilmesi durumlarını tasarla.
- Yapılan değişiklikler mümkün olduğunca küçük ve geriye uyumlu olsun.
- Öğrenmeyi kolaylaştıracak kısa ve **anlamlı** Türkçe yorumlar yaz; her trivial satıra yorum zorlamasıyla okunabilirliği bozma.

## Değişmeyecek ürün kuralları
- Sonsuz pan/zoom tuvali, serbest çizim, silgi, şekiller, metin, post-it ve görseller.
- PNG/SVG dışa aktarma ve paylaşım (oda kodu veya bağlantı).
- Kayıtlı kullanıcı ve misafir katılımı; misafirlerin tuval araçlarına erişimi.
- Kullanıcı başına renk ve canlı konum/isim etiketi.
- Post-it, şekil ve metinde seçince görünen sil/sabitle kontrolleri.
- Aydınlık/karanlık mod, başlangıçta sarı vurgu ve değiştirilebilir tema.
- BoardConnect adı/logo ve sabit üst çubuk.

## Kontrol listesi
- [ ] Var olan akışlar bozulmadı.
- [ ] Flutter analyzer hatası yok (çalıştırılabildiyse).
- [ ] Gerçek kullanıcıya ait gizli anahtar kaynak kodda yok.
- [ ] Kullanıcı eylemleri görsel geri bildirim veriyor.
- [ ] Ekran boyutları/klavye/dokunma/fare hesaba katıldı.
- [ ] `project.md` güncellendi.
