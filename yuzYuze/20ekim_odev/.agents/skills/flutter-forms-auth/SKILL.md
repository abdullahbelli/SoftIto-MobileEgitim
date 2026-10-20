---
name: rotiva-flutter-forms-auth
description: Flutter form validatorları, demo müşteri/yönetici oturumu, kayıt ve sözleşme diyalogları.
---
# Formlar, Giriş ve Diyaloglar Skill

## Form temel yaklaşımı
- `Form` + `GlobalKey<FormState>`; `AutovalidateMode.onUserInteraction` uygundur.
- Controller oluşturulan ekranda `dispose` edilmeli; `mounted` kontrolü yapılmalı.
- `TextInputType.emailAddress`, `phone`, `number`; `obscureText` + görünürlük butonu.
- Validasyonlar ayrı fonksiyonlar: `validateRequired`, `validateEmail`, `validatePhone`, `validatePassword`, `validateConfirmPassword`, pozitif sayı, ücret, tarih, seçili il/ilçe.
- Kullanıcı hatasını alanın yanında anlat; genel başarısızlık `SnackBar` veya uygun dialog.

## Kayıt
1. Ad soyad, e-posta, telefon, parola, parola tekrarı.
2. KVKK **aydınlatma metni** dialogu ve **açık rıza metni** dialogu ayrı.
3. İki onay checkbox'ı, kullanıcı işaretlemedikçe demo gereği kayıt tamamlanmaz.
4. E-posta tekrar kaydını engelle; başarılı kayıt sonrası müşteri ekranına yönlendir/oturum aç.
5. **Hukuki sınır:** Aydınlatmayı okuma teyidi ve açık rıza aynı şey değildir; gerçek hayatta açık rıza her durumda hizmet koşulu yapılamaz. Demo metinler hukuki tavsiye değildir; canlı ürüne taşınırken uzman incelemesi gerekir.

## Giriş ve rol
- Ayrı `CustomerLoginScreen` ve `AdminLoginScreen`; kullanıcı rolüne göre yönlendirme.
- Demo hesaplar README'de; canlı güvenlik iddiası yok.
- Gerçek kişisel veri ve parola saklama gerektiren üretim çözümü tasarlama.
- Çıkış butonuna basınca oturumu kapat ve Welcome'a geri dön.

## Dialog standartları
- KVKK, açık rıza ve kiralama sözleşmesi: scrollable `AlertDialog`, "Kapat".
- Silme: "Vazgeç" / "Sil" ile açık teyit; işlem geri alınamıyorsa uyar.
- Kiralama sözleşmesi: kullanıcı `okudum ve kabul ediyorum` kutusunu işaretlemeden ilerlemesin.
- Başarı: rezervasyon kodu, araç adı, toplam ve gitmek istenen ekran.

## Kişisel veri minimizasyonu
- Demo için TCKN, belge fotoğrafı, kart numarası, CVV, gerçek IBAN, açık adres geçmişi gibi gereksiz hassas veri toplama.
- Adrese teslim alanı yalnız mock kiralama için kullanılır; mümkünse seed/sahte örnek kullan.
- Aydınlatma/açık rıza için gerçek şirket/iletişim/veri işleme vaadi uydurma.
