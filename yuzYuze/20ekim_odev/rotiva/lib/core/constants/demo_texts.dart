/// Rotiva eğitim projesine ait demo metinleri (KVKK, Açık Rıza, Sözleşme).
/// Bu metinler eğitim amaçlı simülasyondur ve hukuki bağlayıcılığı yoktur.
class DemoTexts {
  static const String kvkkTitle = 'KVKK Aydınlatma Metni (Eğitim Demosu)';
  static const String kvkkContent = '''
ROTİVA ARAÇ KİRALAMA VE TAKİP UYGULAMASI
KİŞİSEL VERİLERİN KORUNMASI KANUNU (KVKK) AYDINLATMA METNİ
(EĞİTİM DEMOSU - GERÇEK HUKUKİ BELGE DEĞİLDİR)

Değerli Kullanıcımız,
Bu uygulama, SoftIto Mobil Geliştirme Eğitimi kapsamında hazırlanmış bir prototiptir. Gerçek bir şirket veya ticari veri işleme faaliyeti bulunmamaktadır.

1. Veri Sorumlusu Simülasyonu:
Demo ortamında veri sorumlusu sıfatı sembolik olarak "Rotiva Araç Kiralama A.Ş." unvanına aittir.

2. İşlenen Kişisel Veriler:
Kayıt formunda girdiğiniz ad, soyad, e-posta adresi, telefon numarası gibi bilgiler yalnızca cihazınızın yerel hafızasında (mock state) geçici olarak tutulur. Hiçbir sunucuya, üçüncü tarafa veya harici veritabanına iletilmez.

3. Verilerin İşlenme Amacı:
Kullanıcı girişini simüle etmek, araç kiralama rezervasyon akışını test etmek ve kiralama geçmişinizi görüntülemenizi sağlamak.

4. Veri Aktarımı:
Verileriniz hiçbir şekilde üçüncü kişilere, reklam ortaklarına veya kamu kurumlarına aktarılmaz.

5. Haklarınız:
KVKK'nın 11. maddesi kapsamındaki haklarınız demo ortamında simüle edilmekte olup, dilediğiniz zaman profil ekranından bilgilerinizi silebilir veya uygulamayı cihazınızdan kaldırarak tüm yerel veriyi temizleyebilirsiniz.
''';

  static const String acikRizaTitle = 'Açık Rıza Metni (Eğitim Demosu)';
  static const String acikRizaContent = '''
ROTİVA AÇIK RIZA BEYANI
(EĞİTİM DEMOSU - GERÇEK HUKUKİ BELGE DEĞİLDİR)

Rotiva Araç Kiralama uygulaması bünyesinde sunulan demo hizmetlerin yürütülebilmesi amacıyla;

1. Ad, soyad, iletişim bilgileri (telefon, e-posta) ve simüle edilmiş sürüş/kiralama tercihlerimin,
2. Yalnızca mobil eğitim projesi simülasyonu kapsamında yerel cihazımda işlenmesini,
3. Test amacıyla oluşturulan araç rezervasyonları ve değerlendirmelerde kullanıcı adımın yerel arayüzde gösterilmesini

Özgür irademle kabul ediyor ve açık rıza veriyorum.
''';

  static const String rentalAgreementTitle =
      'Araç Kiralama Sözleşmesi (Eğitim Demosu)';
  static const String rentalAgreementContent = '''
ROTİVA KİRALAMA SÖZLEŞMESİ ŞARTLARI
(EĞİTİM DEMOSU - GERÇEK HUKUKİ BELGE DEĞİLDİR)

1. TARAFLAR VE AMAÇ
Bu sözleşme, Rotiva Araç Kiralama simülasyonu ile kiralayan kullanıcı arasında, seçilen aracın belirtilen tarih ve şartlarda geçici kullanımına ilişkin esasları belirler.

2. KİRALAMA SÜRESİ VE KİLOMETRE LİMİTİ
- Kiralama süresi başlangıç ve bitiş tarihleri arasındaki takvim gün farkına göre hesaplanır (en az 1 gün).
- Kiralanan aracın standart günlük km limiti veya satın alınan ek km paketi geçerlidir. Aşım durumunda ek km tarifesi yansıtılır.

3. SÜRÜCÜ YAŞI VE EHLİYET ŞARTLARI
- Kiralanacak aracın sınıfına göre belirlenen minimum sürücü yaşı ve minimum ehliyet yılı şartının kiralayan tarafından eksiksiz sağlanması zorunludur.

4. TESLİMAT VE İADE
- Şubeden teslim seçeneğinde araç Rotiva şubesinden teslim alınır ve aynı şubeye iade edilir.
- Adrese teslim seçeneğinde belirlenen teslimat ücreti faturaya eklenir.

5. ÖDEME VE İNDİRİM KOŞULLARI
- Kredi kartı ve Havale/EFT simülasyon ödemeleri anında onaylanır.
- Şubeden teslim + Şubede nakit ödeme seçildiğinde kiralama ve ek km bedeli üzerinden %10 nakit indirimi uygulanır. Adrese teslimatta nakit ödeme kabul edilmez.

6. SİMÜLASYON BEYANI
İşbu sözleşme bir eğitim projesidir; hiçbir hukuki veya cezai sorumluluk doğurmaz. Gerçek bir ödeme veya kiralama taahhüdü içermez.
''';
}
