---
name: boardconnect-design
description: BoardConnect Stitch tasarımlarını Flutter Material 3 responsive arayüzüne dönüştürme, erişilebilirlik, tema, auth ekranları, oda listeleri ve whiteboard toolbar etkileşimleri için kullanılır.
---

# BoardConnect — Tasarım / UI-UX Skill'i

## Kullanım
Yeni ekran, widget, tema, animasyon, responsive düzen veya Stitch tasarımının Flutter'a aktarımı gerektiğinde bu skill'i uygula. Önce `project.md` ve `boardconnect-general` oku.

## Tasarım dili
- Kimlik: **BoardConnect**. Başlangıç paleti sıcak sarı/amber tonları + nötr yüzeyler; kullanıcı vurgu rengini değiştirebilmeli.
- Light/Dark `ThemeData` ayrı; aynı bileşenlerde `ColorScheme` token'larını kullan. Sabit hex kodlarını widget'lara dağıtma.
- Material 3, dengeli boşluk, uygun kontrast ve belirgin odak/hover/pressed/disabled durumları.
- Kullanıcının karanlık mod tercihi ile tuval arka plan desenini **ayrı ayarlar** olarak ele al.
- Başlıktaki logo/BoardConnect adı uygulamanın bütün ana ekranlarında görünür.
- Stitch tasarımı varsa referans al; ekran boyutuna körü körüne piksel kopyalama.

## Responsive / giriş biçimleri
- Mobil: dikey tek sütun akışı, dokunmaya uygun hedefler, sanal klavye açıldığında form taşması olmamalı.
- Tablet: alanı uygun paylaşan iki panelli tasarım düşünülebilir.
- Masaüstü/Web: geniş panel, klavye ve fare etkileşimleri; mouse wheel, hover ve imleç durumu.
- Dar ve geniş ekranlarda gerçek sınırlandırma/scroll kullan; `RenderFlex overflow` bırakma.
- Bottom sheet oda oluştur/katıl için kullanılmalı; masaüstünde adapte edilmiş modal mümkün, ama aynı alanlar/akış korunmalı.

## Ekran akışları
### Giriş / kayıt
- Logo, e-posta, şifre, Giriş Yap, Google ile Giriş, Şifremi Unuttum, Kayıt Ol, Misafir.
- Misafir: isim + oda kodu + Odaya Gir; misafir tuvale girdikten sonra bütün temel araçları kullanabilmeli.
- Kayıt: isim, soyisim, kullanıcı adı, e-posta, şifre, Google ile devam et.
- E-posta onay kodu: **yalnızca 6 rakam**, **01:30** ile başlayan **90 saniyelik** geri sayım, süre sonunda Tekrar Gönder; 6 rakam yoksa Onayla disabled.
- Şifre sıfırlama: e-posta ve kod gönderimi, 6 rakam/90 saniye sayacı, kod doğrulama, yeni şifre + tekrar ve kurallar, başarıda girişe dönüş.
- Sayaç ve kod gerçek sunucu doğrulamasına bağlı; yalnızca görsel sayaç güvenlik kontrolü sayılmaz.

### Çalışmalar / odalar
- Oluşturulan ve katılınan odalar kartlarla listelenir; boş/erişilemeyen oda durumları açıkça gösterilir.
- `+` Oda Oluştur, Odaya Katıl; oda adı/kapasite ve kod alanları bottom sheet.
- Yetkili kişi için oda silme: yanlış silmeyi önleyen onay diyaloğu.

### Tuval
- **Sonsuz** koordinatlı tuval; pan + zoom araç seçimiyle çatışmamalı.
- Her zaman görünen üst bar: BoardConnect ve oda adı; sağda Davet ve katılımcı avatarları **aynı bölgeyi paylaşır**. İlk açılışta Davet görünür; katılımcılar geldikçe avatarlar ve Davet birlikte kalır. Fazla kişi +N ve açılır liste.
- Katılımcı eklenince `kullanıcı_adı giriş yaptı`, ayrılınca `kullanıcı_adı ayrıldı` Snackbar; tekrar bağlantıda spam önle.
- Araçlar: kalem, silgi, şekiller, metin, post-it, resim, paylaş, dışa aktar/indir. Geniş ekranda sabit erişilebilir toolbar; dar/dikey ekranda alttaki toolbar kullanılmazken kademeli saydamlaşıp gizlenir, aynı bölgede erişilebilir görünür tetikleyici bırakır.
- Şekiller açılır seçim; seçilen şekil +/aktif durumuyla anlaşılır ve sürükleme ile boyutlandırılır.
- Nesne seçimi: post-it/şekil/metnin sağ üstünde çöp kutusu ve raptiye göster; raptiyenin simgesi **sabit/sabit değil** durumuna göre değişsin. Sabitlenen nesnede taşıma/boyut değişimini engelle, ancak gerekli yetkili işlemleri açık tut; ayrıntıları `project.md` kararıyla eşle.
- Farklı kullanıcılar tutarlı ayırt edilebilir renklerle; kendi çalışma noktasına yakın, kullanıcı adı yazan kontrastlı etiketle gösterilsin. Etiket tuval içeriğini gereksiz kapatmasın; zoom/pan dönüşümlerini doğru takip etsin.
- Tuval görünümü: boş, kareli, çizgili, kağıt. Arka plan kullanıcı seçimi dışında çizim nesnesi olarak saklanmaz.

## Kullanılabilirlik ve erişilebilirlik
- İkonlara tooltip/semantik etiket ekle; yalnız renk kullanarak durum anlatma.
- Form hata mesajları alan yanında; işlemlerde spinner, butonda loading/disabled durumu.
- Dokunma hedefleri ve metin kontrastını erişilebilir tut; aşırı küçük ikonlardan kaçın.
- Kaydediliyor/bağlantı koptu gibi durumlarda kullanıcıyı bilgilendir.
- Uygun odak sırası, klavye gezinmesi ve Esc gibi beklenen masaüstü davranışlarını düşün.

## Teslim kontrolü
Ekranı bitirince light/dark, mobile portrait, tablet, desktop, form keyboard, text scale, uzun oda adı, çok katılımcı, toolbar gizleme/gösterme, panel/modal taşması durumlarını gözden geçir.
