const

1. Ne işe yarar ? : İçine girilen değerleri derleme zamanında tek bir kere yazılarak değişişmez olarak üretir.
2. Neden Kullanılır ? : Bir widget const olarak tanımlanırsa setState olduğunda flutter bu widget'ı yeniden üretmez. CPU ve pil tasarrufu sağlar.

final

1. Ne işe yarar ? : Çalışma zamanında değeri bir kez atanan ve sonrasında referansı asla değiştirilmeyen değişkenler.
   **const ve final farkı : const derlenirken bilinmek zorunda(const pi =3.14) final ise çalışma anında belirlenebilir (final saat= DateTime.now()). ---Model sınıflaırnda alanlarında alanlar her zaman final olmalıdır.---**

late

1. Ne işe yarar ? : Değişken tanımlandığı anda değil , ilk kullanıldığında veya initState anında başlatılacağı zaman kulanılır.

required

1. Ne işe yarar ? : İismlendirilmiş parametrelerde o parametrenin(değişkenin) zorunlu olduğunu belirtmek için kullanılır.

@override

1. Ne işe yarar ? : Alt sınıfın üst sınıftan devraldığı metodu ezdiğini belirtir.
2. Faydası : Eğer üst metod adını yanlış yazarsanız (ÖRN: Build metodu için build yazmak gerekirken buildS yazarsanız) derleyici @override sayesinde anında hata verir ve düzeltmenizi sağlar.

Null-aware operatöreleri ( ? ?? ! )
?. - place?.title -> eğer place null ise hata vermez direkt null olarak döner.
?? - if null : final id = state.userId ?? 10; -> Sol taraf null ise sağdaki (harcode olan değer) otomatiik olarak atanır.
! (null / force) : final id = state.userId! -> Bu kod derleyiciye bana güven bu değer o anda kesinlikle null değil der. Eğer null ise uygulama anında çöker. (ÇOK DİKKATLİ KULLANILMALI)

Spread operatörü(...)

1. Ne işe yarar? : Bir listenin elemanlarını tek tek çıkartıp bulunduğu üst listenin içine ekler. Column veya ListView içinde dinamik widget dizini oluşturmak için kullanılan en temiz ve modern yöntemdir.
   ...listAdi.map((e) => \_buildCard(e))

initState()
Ne zaman çalışır : Widget ağaca fiziksel olarak ilk başladığında yalnızca bir kere çalışır.
Ne yapılır : ScrollController başlatmaları ve ilk API istekleri burada kurulur.
Kural : İçinde doğrudan BuildContext ile Navigator çağrılmaz. Çünkü widget ağaca tam oturmamaıştır.

didChangeDependencies()
Ne zaman çalışır: initState()'ten heme sonra ve widget dinlediği bir (Örn: Theme.of(context)) değiştiğinde otomatik tetikler.
Ne yapar: BuildContext güvenli bir şekilde erişerek tema veya ekran boyutu bağımlılıklarıı ile ilgili ilk yüklemeler burada yapılır.

build(BuildContext context)
Ne zaman çalışır: Sayfa ilk açıldığında ,setState() çağrıldığında veya üst widgetyeni bir inşa ağaç boyama geldiğinde saniyesinde defalardca çalışır.
Kural: build() metodu tamamen saf olmalıdır. Asla içinde setState() api isteği ya da controller başlatma yapılmamalıdır. Sadece UI döndürmelidir.

dispose()
Ne zaman çalışır: widget hafızadan atılmadan hemen önce son bir kez çalışır.
Ne yapılır: \_controller.dispose() stream dinleyicilerin iptalleri burada yapılır. super .dispose() un mutlaka son satıra yazılması gerekir.

setState((){})

1. arka planda ne yapar: State'in bağlı olduğu StatefulElement nesnesine "ben değiştim, build et" sinyali yolar.
2. nerede kullanılır: Sayfa genelini çizdirmez. Sadece onu dinleyen küçük ValueListenableBuilder'a sinyal gönderilir.

ValueNotifier<T>

1. Arka planda ne iş yapar: ChangeNotifier sınıfından türer. Belleğinde tek bir nesne referansı tutar. (T \_value)
2. Tetikleme : Değer atandığında (set value(T value)) ,eğer yeni değer eski değere eşit değilse (\_value!=newValue) , kayıtolı olan fonksiyonu çağrılır. (addListener(){ })

InheritedNotifier<T>

1. Ne yapar: Widget ağacında alttaki childların, aradaki onlarca widgeti baypas ederek, üst widgetın verisine(stateine) doğrudan erişmesini sağlayan soyut bir widgettir.

Material 3 Tasarım Dili Renk algoritması ve temalar
primary: Ana marka rengi
onpRİMARY: Ana rengin üstüne yazılacak yazı rengi (okunabilirlik açısından)
primaryContainer: Ana rengin pastel arkaplan tonu
onPrimaryContainer: Ana rengin yumuşak pastel arkaplan tonunun üsütne yazılacak yazı (okunabilirlik açısından)
surface: Sayfa arka plan tuvali
onSurface: Sayfa üstündeki ana metin rengi
outlineVarient: İnce sınır ve ayrım çizgilerinin rengi

ThemeMode.system :
color: Colors.balck.withOpacity(1 - 255 arasında tam sayı girilmeli)**Bu kullanım güncelde istenmiyor**

color:Colors.black.withValues(alpha : 186/255) // double sayı olarak girilmelidir**Güncel ve doğru kullanım budur**

Arayüz Düzen ve Liste Bileşenleri

Expanded ve Flexible
Expanded: Kalan bol alanın TAMAMINI kaplamaya zorlar.
Flexible: Kalan bol alanı kendi "flex" (esneklik) değerine göre paylaşıma zorlar. (flex:1,flex:2)
Flex: yan yana iki expanded varsa birine flex2 diğerine flex 1 verir bu sayede ekran boyutuna göre otomatik olarak ayarlar.

Stack ve Positioned
Ne yapar: Widgetları z ekseninde üst üste bindirir.
Positioned: Yalnızca bir stack içinde çalışır.
top:10, right:10 vererek bir resmin sağ üst köşesine bildirim rozeti eklemenizi sağlar.

ListView.buuilder.
Klasik ListView(children:[...],) içindeki örenke vermek gerekirse 10.000 elemanın tamamını daha sayfa açılmadan belleğe yükler ve doğal olarak telefon donar.
ListView.builder ise geri Dönüşümlü Görünüm alanı mantığını kullanarak ekranda sadece o an eğer 5 kart görünecek ise sadece 5 kartıram belleğe yüler. Kullanıcı aşağıya kaydıka yukarıda kalanlar bellekten düşürülüp kalanlar belleğe taze olarak yeni olarak üretilir.

shinkWrap: true
Bir ListView bakşa bir dikey kaydırıcının (singleChildScrollView) içine konursa VerticalViewport hatası verir.
shirkWrap:true verilerek bu çözülebilir ancak: ListView'ın sonsuza kadırma(sonsuz scroll) özelliğini kaybeder.
**Sadece 3 5 elemanınınz varsa bunu kullanmalısınız**

Inkwell ve GestureDetector
GestureDetector: Tıklama çift tıklama sürükleme olaylarını yakalar ama görsel ihiçbir tepki VERMEZ.
Inkwell : Tıklandığı an parmağın altından dışa doğru yayılan bir su dalgası efekti verir.

Önemli Kural : Inkwell'in arkasından mutlaka bir material widget olmak zorundadır. Aksi takdirde su dalgası arkadaki tuvali göremediği iiçin hiçbir şekilde görünmez.

Form Mimarisi
GlobalKey<FormState>
Widget içindeki Form düğümüne doğrudan dışarıdan erişilemiyor. bu yüzden Widgetin en üstüne koyduğumuz globalKey değişkeni sayesinde formun Vliadate (geçerli) durumunu ve içindeki değerleri (Değişkenleri) dışarıdan okuyoruz.

\_formKey.currentState?.validate() çağrıldığında o formun altındaki tüm TextFormField validator bloklarını sırasıyla çalıştırır.

validator : (String ? value)

fonksiyonda bir hata bulursa geriye strign olarak hata metni dönderiri. Bu metin otomatik kırmızı renkte ve inputun altında belirir.
Eğer veri geçerliyse null döner. Flutter için bu alanda hata yok demektir. Null gelmesi.

Animasyon Motoru

AnimatorContainer: Genişlik yükseklik padding margin border renk ve gölge oynatır.
AnimatedOpacity: Görünürlüğü 0.0 ile 1.0 arasında yumuşakça soldurur.
AnimatedScale:Widget merkezinden dışarıya doğru büyütüp küçültür.
AnimatedAlign: Widget kutunun içinde sağdan sola yukarıdan aşağıya karşı konumunu değiştirir.

Curves
İvmeenme Karakterleri

Curves.linear : Sabit hız (robotik hareketler)
Curves.easeInout : Yavaş Başlar ortada hızlanır yavaşça durur.
Curves.bounceOut : Hedefe çarptığında top gibi 2 3 kez yaylanarak seker.
Curves.elasticOut : Lastik gibi ileri geri filtreleyerek yerine oturur.

Gorouter

Alt taraftaki menü : ShellRoute
Sayfanın geri kalanı : gorouter

context.go('/profil'): Route yönlendirmesidir. Rota tablosunda hiyerarşiyi takip eder sayfayı temzileyebilir.

context.push('/profil/5') Stack yönlendirmedir. Kullanıcı nereden gelirse gelsinmevcutsafanın tepeie yeni bir katan ekler ve dönüş safası için bir geri ok butonu ekler.

context.pop() sayfanın e ğstteki yığınını kapatır.

state.pathParameters["id"]: Gorouter içinde tanımladığımız /:id yapılarına erişmek içi kullanılır.

/profil?user=berat
state.uri.queryParameters["user"] : Opsiyoel filtrelemme ya da arama zamanlarındaulanılır.

Cihaz içi Yerel Depolamma mimarileri

SharedPreferences:
Küçük kullanıcı ayarları (Tema, dil, bildirim ayarları vb.)
Düşük güvenilirlik.
Okuma yazma hıları : Okuma hızı orta / yzma hızı yavaş

FlutterSecureStorage:
Şifre Token vb. saklamak için.
En yüksek güvence
Orta

Hive/Isar: Yüksek performasnı nesne depolama
Orta (isteğe bağlı olarak şifreleme açılabilir.)
Aşırı hızlı
