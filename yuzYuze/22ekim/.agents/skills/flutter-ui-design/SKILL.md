---
name: flutter-ui-design
description: Ritmia Flutter uygulamasının Material 3 tasarım dili, light/dark tema, ekranları, boş durumları, animasyonları ve erişilebilirliğini uygularken kullan.
---

# Flutter UI/UX Design Skill

## Kaynak ve hedef
Önce kökteki `project.md` dosyasını oku. UI sadece estetik değil; tam ekran akışını, kartların durumlarını, form validasyonunu, erişilebilirliği ve mobil tepkiselliği kapsar. Bütün ekranlar **aynı tasarım sistemini** kullansın.

## Tasarım sistemi
- Uygulama adı **Ritmia**. Logo halka+filiz/kıvılcım fikrinden türetilmiş, splash/auth/topbar boyutlarında anlaşılır tek bir vektörel sembol.
- Flutter `ThemeData(useMaterial3: true)` ve `ColorScheme` üzerinden tema kur. Inline sabit renk yazma; `Theme.of(context).colorScheme` veya semantik tema uzantıları kullan.
- Light: pudra/pembe + beyaz; dark: mürdüm/gece eriği + koral vurgular. Kullanıcı ayardan tema modu ve onaylı paletten accent değiştirebilir. Renkler erişilebilir kontrastı bozuyorsa öncelik okunabilirlikte.
- Spacing: 4, 8, 12, 16, 24, 32; radius kart 20–24, input 14–16. Tek bir typography scale ve ikon seti.
- Görünür dokunma alanları en az 48x48. `SafeArea` kullan, `MediaQuery.textScaler` ile uzun metinleri dene.

## Ekran sözleşmeleri
### Auth
- Splash → Giriş → Kayıt; logo kimliği aynı. Formlar klavye açıkken kaydırılabilir, parola göster/gizle, anlaşılır hata ve loading göstergesi.
- Backend yokken açıkça **Demo oturum** bilgisi ver; gerçek hesap koruması varmış gibi bir dil kullanma.

### Alışkanlıklarım
- TopBar: logo yatay ortada; sağda alev ve genel streak sayısı. `AppBar.centerTitle` ile sağ aksiyonların merkezlemeyi bozmamasını kontrol et.
- Boş durum: “Henüz bir alışkanlık eklemediniz.” + teşvik; FAB yalnız `+`. Boş durumda kısa süreli, düşük genlikli dikey sıçrama. Animasyon sürekli dikkat dağıtan hızda olmasın; ekran okuyucu ve reduce-motion davranışına saygı göster.
- Kart: isim, tutarlı kategori ikonu/görseli, progres bar ve `x/hedef`, planlı seri, motive edici mikro metin, sağ üstte kalem ikonu. Tamamlama/ilerleme kontrolünü ayırt edilebilir yap. Çok uzun isim taşmaz.
- Düzenle ve ekle aynı bottom sheet form widget'ını paylaşır. `isScrollControlled: true`, `SafeArea`, klavye inset, drag handle, kapat/iptal/kaydet aksiyonları.

### Takvim
- Ay başlığı, gezinme, gün grid'i, legend. Renk oranına ek olarak günün `x/y` değeri veya erişilebilir açıklaması bulunmalı. Günü seçmek rapor açar. Gelecek gün ve plan olmayan gün nötr.
- Genel görünüm + alışkanlık detayından filtreli görünüm; aynı takvim bileşenini tekrar kullan.

### Liderlik
- Katılım öncesi davet ekranı; açık `Katıl` ve `Şimdilik değil` aksiyonları; zorlama yok.
- Lig seviyesi, hafta aralığı, 15 kişilik grup kapasitesi, terfi/düşüş bölgeleri, ilk 3 madalya, skorlar. Mevcut kullanıcı satırı belirgin; eşitlik ve boş grup durumları görselleştirilir.
- Gerçek servis yokken **Demo lig — örnek veriler** etiketi her sahte skor görünümünde yer alır.

### Profil ve rozetler
- Avatar baş harfi/foto alanı, kullanıcı bilgileri, istatistikler, rozetler, profili düzenle, tema/rengini değiştir, katılım kontrolü, çıkış yap.
- Rozet görselleri: aynı dış altıgen/yuvarlak kontur, çizgi kalınlığı ve gradient dili; İlk Kıvılcım, Sağlam Ritim, Ritmin Ustası ile altın/gümüş/bronz lig ayrı sembolleri. Kilitli rozet gri, kazanılmışta tarih ve bağlam.

## Etkileşim ve kalite
- Loading skeleton/indicator, empty, offline/demo, error, success geri bildirimi tasarla.
- Animasyonlarda 180–350 ms, yaygın geçiş kuralları. `Hero` ancak gerçekten yerindeyse; performansı bozan sürekli gölgelerden kaçın.
- Semantics etiketleri, yüksek kontrast, ekran okuyucu, haptik geri bildirimler (opsiyonel), metin büyüklüğü ve responsive uyum.
- Widget'ları küçük ve tekrar kullanılabilir böl; domain kurallarını widget `build` içinde hesaplama.

## Çıktı kontrolü
1. Açık/koyu/rengin değişimi bütün sayfalarda tutarlı mı?
2. 320dp ve 430dp genişliklerde klavye/overflow hatası var mı?
3. Modal form açılıp güvenle kapanabiliyor mu?
4. İlerleme, tamamlanma, boş durum ve demo durumu anlaşılır mı?
5. Logo ve rozetler birbirine ait aynı görsel aile gibi mi?
