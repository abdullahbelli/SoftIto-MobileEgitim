import 'dart:ui' as ui; // Düşük seviyeli grafik motoru, görüntü kodlayıcı (PNG) ve piksel verileri için ui kütüphanesini içe aktarır.

import 'package:flutter/gestures.dart'; // Fare tekerleği (PointerScrollEvent) ve işaretçi sinyallerini işlemek için gerekli jest kütüphanesini içe aktarır.
import 'package:flutter/material.dart'; // Material Design bileşenlerini ve görsel yapı taşlarını içe aktarır.
import 'package:flutter/rendering.dart'; // RenderRepaintBoundary gibi alt seviye görsel render nesnelerini kullanmak için içe aktarır.
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod durum yönetimi bileşenlerini (ConsumerStatefulWidget, ref) içe aktarır.
import 'package:go_router/go_router.dart'; // Sayfalar arası bildirimsel yönlendirme (context.go) için GoRouter paketini içe aktarır.

import '../../../../core/utils/download_helper.dart'; // PNG ve SVG dosyalarını platforma uygun şekilde indiren yardımcı sınıfı içe aktarır.
import '../../../../core/widgets/app_logo.dart'; // Uygulama logosunu ve ikonunu gösteren widget'ı içe aktarır.
import '../../../rooms/presentation/controllers/rooms_controller.dart'; // Oda bilgilerine erişmek için odalar repository sağlayıcısını içe aktarır.
import '../../../rooms/presentation/widgets/share_room_dialog.dart'; // Odayı paylaşma ve davet bağlantısı oluşturma diyaloğunu içe aktarır.
import '../../domain/canvas_theme.dart'; // Tuval arka plan desenlerini (grid, kareli vb.) ve temalarını tanımlayan enum'ı içe aktarır.
import '../../domain/participant.dart'; // Odadaki katılımcıların modelini (ad, imleç rengi vb.) içe aktarır.
import '../controllers/whiteboard_controller.dart'; // Tuval durumunu yöneten Riverpod denetleyicisini ve araç türlerini içe aktarır.
import '../widgets/canvas_background_painter.dart'; // Tuvalin arka plan desenini çizen CustomPainter sınıfını içe aktarır.
import '../widgets/canvas_painter.dart'; // Tuvaldeki nesneleri ve canlı çizimleri ekrana çizen CustomPainter sınıfını içe aktarır.
import '../widgets/object_action_overlay.dart'; // Seçili nesnenin üzerinde beliren aksiyon kutucuğunu (sil, sabitle vb.) içe aktarır.
import '../widgets/text_edit_dialog.dart'; // Metin ve yapışkan not ekleme/düzenleme iletişim kutusunu içe aktarır.
import '../widgets/whiteboard_toolbar.dart'; // Ekranın altındaki çizim araç çubuğu widget'ını içe aktarır.

/// Sonsuz Tuval (Whiteboard) Ekranı
class WhiteboardScreen extends ConsumerStatefulWidget {
  // Sonsuz çizim tuvalini yöneten durumlu (stateful) ve Riverpod destekli ekran widget'ıdır.
  final String roomId; // Üzerinde çalışılan odanın benzersiz kimlik bilgisi.
  final String roomName; // Üst başlık çubuğunda gösterilecek odanın adı.

  const WhiteboardScreen({
    // WhiteboardScreen oluşturucu fonksiyonu.
    super.key, // Üst sınıfa iletilen benzersiz widget anahtarı.
    required this.roomId, // Odanın kimliğini zorunlu parametre olarak alır.
    this.roomName =
        'Ortak Çalışma Odası', // Belirtilmezse varsayılan oda adını atar.
  });

  @override // State nesnesini oluşturan metodu yeniden tanımlar.
  ConsumerState<WhiteboardScreen> createState() => _WhiteboardScreenState(); // Ekrana ait state nesnesini örneklendirir.
}

class _WhiteboardScreenState extends ConsumerState<WhiteboardScreen> {
  // WhiteboardScreen ekranının yaşam döngüsünü ve arayüz durumunu yöneten sınıftır.
  final GlobalKey _repaintBoundaryKey = GlobalKey(); // Tuvalin ekran görüntüsünü (PNG export) alabilmek için RepaintBoundary'ye bağlanan anahtar.
  bool _hasShownJoinNotification = false; // Katılımcı giriş bildiriminin birden fazla kez tetiklenmesini önleyen kontrol bayrağı.

  @override // Widget ilk kez ekrana oluşturulduğunda çalışan yaşam döngüsü metodudur.
  void initState() {
    // Başlangıç durumlarını hazırlar.
    super.initState(); // Üst sınıfın initState metodunu çağırır.
    _triggerDemoJoinNotification(); // Katılımcı giriş simülasyon bildirimini zamanlar.
  }

  void _triggerDemoJoinNotification() {
    // Diğer bir katılımcının odaya giriş yaptığını simüle eden ve SnackBar gösteren fonksiyondur.
    // Katılımcı giriş snackbar simülasyonu
    Future.delayed(const Duration(seconds: 2), () {
      // 2 saniyelik gecikmenin ardından çalışır.
      if (mounted && !_hasShownJoinNotification) {
        // Widget hala ekrandaysa ve daha önce gösterilmediyse devam eder.
        _hasShownJoinNotification =
            true; // Bildirimin tekrar gösterilmemesi için bayrağı aktif eder.
        ScaffoldMessenger.of(context).showSnackBar(
          // Ekranda bilgilendirici bir SnackBar mesajı açar.
          SnackBar(
            // SnackBar widget bileşeni.
            content: Row(
              // Bildirim içeriğini yatay eksende sıralar.
              children: [
                // Satır elemanları listesi.
                Container(
                  // Katılımcının temsil rengini gösteren minik daire.
                  width: 10, // Dairenin genişliği.
                  height: 10, // Dairenin yüksekliği.
                  decoration: const BoxDecoration(
                    // Dairenin dekorasyon özellikleri.
                    color: Color(
                      0xFF06B6D4,
                    ), // Selin'in simüle edilen rengi (Cyan).
                    shape: BoxShape.circle, // Şeklini yuvarlak yapar.
                  ),
                ),
                const SizedBox(
                  width: 8,
                ), // Renk ile yazı arasına boşluk bırakır.
                const Text(
                  'Selin Yılmaz giriş yaptı',
                ), // Katılımcının giriş yaptığı bilgisini veren metin.
              ],
            ),
            behavior: SnackBarBehavior.floating, // Bildirimi ekranın altından havada yüzen kart şeklinde gösterir.
            duration: const Duration(
              seconds: 3,
            ), // Bildirimin ekranda kalma süresini 3 saniye olarak belirler.
          ),
        );
      }
    });
  }

  Future<void> _exportPng(WhiteboardController controller) async {
    // Tuvali piksel formatında (PNG) dışa aktarıp indiren asenkron fonksiyondur.
    try {
      // Olası çizim veya indirme hatalarını yakalamak için try-catch bloğu.
      final boundary = // RepaintBoundary render nesnesini global anahtar üzerinden bulur.
          _repaintBoundaryKey.currentContext
                  ?.findRenderObject() // Render ağacındaki nesneye erişir.
              as RenderRepaintBoundary?; // RenderRepaintBoundary tipine dönüştürür.
      if (boundary == null)
        return; // Render nesnesi bulunamadıysa işlemi sonlandırır.

      final image = await boundary.toImage(pixelRatio: 2.0); // Tuvalin görüntüsünü 2 kat piksel yoğunluğunda yüksek çözünürlükle yakalar.
      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      ); // Görüntüyü PNG formatında bayt dizisine dönüştürür.
      if (byteData == null)
        return; // Bayt verisi üretilemediyse işlemi durdurur.

      final bytes = byteData.buffer.asUint8List(); // Bayt verisini 8-bitlik tamsayı listesine (Uint8List) çevirir.
      final filename = // İndirilecek dosya adını oda ID'si ve zaman damgasıyla benzersiz olarak oluşturur.
          'boardconnect_${widget.roomId}_${DateTime.now().millisecondsSinceEpoch}.png';

      DownloadHelper.downloadBytes(
        bytes,
        filename,
        'image/png',
      ); // Platforma uygun yöntemle PNG dosyasını kullanıcıya indirir.

      if (mounted) {
        // Widget hala aktifse başarı mesajı gösterir.
        ScaffoldMessenger.of(context).showSnackBar(
          // Başarı SnackBar'ı görüntüler.
          const SnackBar(
            // Başarı SnackBar widget'ı.
            content: Text(
              'PNG görseli başarıyla indirildi!',
            ), // Başarı mesajı metni.
            backgroundColor: Colors.green, // Arka planı yeşil yapar.
            behavior: SnackBarBehavior.floating, // Yüzen kart biçimi.
          ),
        );
      }
    } catch (e) {
      // Hata oluşması durumunda yakalar.
      if (mounted) {
        // Widget ekrandaysa hata SnackBar'ı gösterir.
        ScaffoldMessenger.of(context).showSnackBar(
          // Hata bildirimini görüntüler.
          SnackBar(
            // Hata SnackBar widget'ı.
            content: Text(
              'PNG dışa aktarılırken hata: $e',
            ), // Hata detayını gösterir.
            backgroundColor:
                Colors.redAccent, // Hata rengini kırmızı tonunda ayarlar.
          ),
        );
      }
    }
  }

  void _exportSvg(WhiteboardController controller) {
    // Tuvaldeki vektörel çizimleri SVG formatında dışa aktarıp indiren metottur.
    try {
      // Hataları yakalamak için try-catch bloğu.
      final svgString = controller.exportSvg(); // Denetleyiciden tuvalin XML tabanlı SVG metin çıktısını alır.
      final filename = // İndirilecek dosya adını benzersiz zaman damgası ile oluşturur.
          'boardconnect_${widget.roomId}_${DateTime.now().millisecondsSinceEpoch}.svg';

      DownloadHelper.downloadText(
        svgString,
        filename,
        'image/svg+xml',
      ); // SVG metnini dosya olarak kullanıcıya indirir.

      if (mounted) {
        // Sayfa aktifse başarı bildirimini ekranda gösterir.
        ScaffoldMessenger.of(context).showSnackBar(
          // Başarı SnackBar'ı açar.
          const SnackBar(
            // SnackBar bileşeni.
            content: Text(
              'SVG vektör dosyası başarıyla indirildi!',
            ), // Başarı metni.
            backgroundColor: Colors.green, // Yeşil başarı arka planı.
            behavior: SnackBarBehavior.floating, // Yüzen kart stili.
          ),
        );
      }
    } catch (e) {
      // Hata durumunda çalışır.
      if (mounted) {
        // Sayfa ekrandaysa hata mesajı gösterir.
        ScaffoldMessenger.of(context).showSnackBar(
          // Hata SnackBar'ı görüntüler.
          SnackBar(
            // SnackBar bileşeni.
            content: Text(
              'SVG dışa aktarılırken hata: $e',
            ), // Hata içeriğini yazdırır.
            backgroundColor: Colors.redAccent, // Kırmızı hata rengi.
          ),
        );
      }
    }
  }

  void _confirmClearCanvas(WhiteboardController controller) {
    // Tuvali tamamen temizlemeden önce kullanıcıdan onay isteyen iletişim kutusunu açar.
    showDialog(
      // Ekrana onay diyalog penceresi açar.
      context: context, // Diyaloğun açılacağı widget context'i.
      builder: (ctx) => AlertDialog(
        // Onay AlertDialog widget'ını inşa eder.
        title: const Row(
          // Başlık satırı.
          children: [
            // Başlık elemanları.
            Icon(
              Icons.cleaning_services_rounded,
              color: Colors.redAccent,
            ), // Temizlik ikonu.
            SizedBox(width: 8), // İkon ile başlık arasına boşluk koyar.
            Text('Tuvali Temizle'), // İletişim kutusunun başlığı.
          ],
        ),
        content: const Text(
          // Kullanıcıyı uyaran açıklama metni.
          'Bu odadaki tüm çizim ve nesneleri silmek istediğinize emin misiniz?',
        ),
        actions: [
          // Aksiyon butonları listesi.
          TextButton(
            // İşlemi iptal etme butonu.
            onPressed: () => Navigator.pop(ctx), // Diyalog penceresini kapatır.
            child: const Text('Vazgeç'), // Buton üzerindeki yazı.
          ),
          ElevatedButton(
            // Silmeyi onaylama butonu.
            style: ElevatedButton.styleFrom(
              // Buton stil ayarları.
              backgroundColor:
                  Colors.redAccent, // Dikkat çekici kırmızı arka plan.
              foregroundColor: Colors.white, // Beyaz yazı rengi.
            ),
            onPressed: () {
              // Onay butonuna basıldığında.
              Navigator.pop(ctx); // Diyalog penceresini kapatır.
              controller.clearCanvas(); // Denetleyici üzerinden tuvaldeki tüm nesneleri siler.
            },
            child: const Text('Evet, Temizle'), // Onay butonu yazısı.
          ),
        ],
      ),
    );
  }

  void _openStickyNoteDialog(
    // Tuvalin ortasına yeni bir yapışkan not (Post-it) eklemek için diyalog açan metottur.
    BuildContext context, // Widget context'i.
    WhiteboardController controller, // Tuval denetleyicisi nesnesi.
  ) {
    final screenSize = MediaQuery.of(context)
        .size; // Cihaz ekranının boyutlarını alır.
    final centerWorld = controller.screenToWorld(
      // Ekranın tam orta noktasını tuvalin dünya koordinatlarına dönüştürür.
      Offset(screenSize.width / 2, screenSize.height / 2),
    );

    showDialog(
      // Metin giriş iletişim kutusunu açar.
      context: context, // Context parametresi.
      builder: (ctx) => TextEditDialog(
        // TextEditDialog bileşenini oluşturur.
        title: 'Yeni Post-it Not Ekle', // Diyalog başlığı.
        showColorPicker:
            true, // Post-it rengi seçebilmek için renk paletini etkinleştirir.
        onSave: (text) {
          // Not kaydedildiğinde çalışan geri çağırma fonksiyonu.
          if (text.isNotEmpty) {
            // Metin boş değilse ekleme yapar.
            controller.addStickyNote(
              // Belirlenen dünya koordinatına sarı yapışkan not nesnesi ekler.
              centerWorld, // Notun tuval üzerindeki konumu.
              text, // Notun metin içeriği.
              const Color(0xFFFEF08A), // Varsayılan sıcak pastel sarı rengi.
            );
          }
        },
      ),
    );
  }

  void _openTextDialog(BuildContext context, WhiteboardController controller) {
    // Tuvale serbest metin nesnesi eklemek için diyalog açan fonksiyondur.
    final screenSize = MediaQuery.of(context).size; // Ekran boyutlarını alır.
    final centerWorld = controller.screenToWorld(
      // Ekran merkezini tuvalin dünya koordinatlarına dönüştürür.
      Offset(screenSize.width / 2, screenSize.height / 2),
    );

    showDialog(
      // Diyalog penceresini ekrana getirir.
      context: context, // Context parametresi.
      builder: (ctx) => TextEditDialog(
        // Metin giriş diyaloğu.
        title: 'Tuvale Metin Ekle', // Diyalog başlığı.
        onSave: (text) {
          // Metin kaydedildiğinde tetiklenir.
          if (text.isNotEmpty) {
            // Metin boş değilse.
            controller.addText(
              centerWorld,
              text,
            ); // Tuvalin merkezine yeni metin nesnesini ekler.
          }
        },
      ),
    );
  }

  void _openImageDialog(BuildContext context, WhiteboardController controller) {
    // Tuvale görsel/etiket kartı eklemek için diyalog açan fonksiyondur.
    final screenSize = MediaQuery.of(context)
        .size; // Ekran genişlik ve yükseklik değerlerini alır.
    final centerWorld = controller.screenToWorld(
      // Ekran merkezini tuval dünya koordinatına çevirir.
      Offset(screenSize.width / 2, screenSize.height / 2),
    );

    final textController = TextEditingController(
      text: 'Proje Mimari Şeması',
    ); // Görsel başlığı için varsayılan metin denetleyicisi.
    showDialog(
      // Görsel ekleme iletişim kutusunu açar.
      context: context, // Context parametresi.
      builder: (ctx) => AlertDialog(
        // AlertDialog penceresi.
        title: const Text('Görsel Ekle'), // Başlık metni.
        content: Column(
          // İçerik sütun düzeni.
          mainAxisSize:
              MainAxisSize.min, // Sütun yüksekliğini içeriğe göre daraltır.
          crossAxisAlignment:
              CrossAxisAlignment.start, // Elemanları sola yaslar.
          children: [
            // Sütun bileşenleri.
            const Text(
              // Açıklama yönerge metni.
              'Tuvale yerleştirilecek görsel için bir etiket belirleyin:',
              style: TextStyle(fontSize: 13), // Yazı tipi boyutu.
            ),
            const SizedBox(height: 12), // Boşluk.
            TextField(
              // Görsel başlığını girmek için metin alanı.
              controller:
                  textController, // Metin kutusunu denetleyiciye bağlar.
              decoration: const InputDecoration(
                // Giriş kutusunun görsel süslemesi.
                labelText: 'Görsel Başlığı / Etiketi', // Etiket yazısı.
              ),
            ),
          ],
        ),
        actions: [
          // İşlem butonları.
          TextButton(
            // Vazgeçme butonu.
            onPressed: () => Navigator.pop(ctx), // Pencereyi kapatır.
            child: const Text('Vazgeç'), // Buton metni.
          ),
          ElevatedButton(
            // Görseli ekleme butonu.
            onPressed: () {
              // Tıklandığında.
              Navigator.pop(ctx); // Pencereyi kapatır.
              controller.addImage(
                centerWorld,
                textController.text.trim(),
              ); // Belirtilen dünya konumuna görsel nesnesini ekler.
            },
            child: const Text('Ekle'), // Buton metni.
          ),
        ],
      ),
    );
  }

  @override // Widget'ın arayüzünü inşa eden ana metottur.
  Widget build(BuildContext context) {
    // Yapı ağacını döndürür.
    final theme = Theme.of(context); // Aktif tema verilerine erişir.
    final isDark =
        theme.brightness ==
        Brightness.dark; // Koyu temanın aktif olup olmadığını sorgular.
    final state = ref.watch(
      whiteboardControllerProvider(widget.roomId),
    ); // Bu odaya ait tuval durumunu canlı olarak izler.
    final controller = ref.read(
      // Tuval üzerinde işlem yapmak için denetleyici örneğini okur.
      whiteboardControllerProvider(widget.roomId).notifier,
    );

    return Scaffold(
      // Ekranın temel iskeletini oluşturur.
      appBar: AppBar(
        // Ekranın üst uygulama çubuğu.
        leading: IconButton(
          // Sol taraftaki geri dönüş ikonu butonu.
          icon: const Icon(
            Icons.arrow_back_rounded,
          ), // Yuvarlatılmış geri oku ikonu.
          tooltip: 'Odalar Listesine Dön', // Uzun basıldığında veya fare üstüne geldiğinde görünen ipucu.
          onPressed: () =>
              context.go('/rooms'), // Odalar sayfasına yönlendirir.
        ),
        titleSpacing: 0, // Başlık ile sol buton arasındaki boşluğu sıfırlar.
        title: Row(
          // Başlık alanındaki elemanları yatayda dizer.
          children: [
            // Başlık satırı elemanları.
            const AppLogo(
              size: 28,
              compact: true,
            ), // Kompakt boyutlu uygulama logosu.
            const SizedBox(width: 8), // Logo ile oda adı arasına boşluk koyar.
            ConstrainedBox(
              // Oda adının taşmasını engelleyen genişlik kısıtı.
              constraints: const BoxConstraints(
                maxWidth: 220,
              ), // En fazla 220 piksel genişlik sınırı.
              child: Text(
                // Oda adını gösteren metin.
                widget.roomName, // Odanın adı.
                style: const TextStyle(
                  // Yazı stili.
                  fontSize: 15, // Yazı boyutu.
                  fontWeight: FontWeight.bold, // Kalın yazı tipi.
                ),
                maxLines: 1, // Tek satırda tutar.
                overflow: TextOverflow
                    .ellipsis, // Sığmayan kısmı üç nokta (...) ile kırpar.
              ),
            ),
          ],
        ),
        actions: [
          // Sağ taraftaki işlem butonları listesi.
          // Katılımcı Avatarları ve "+N" rozeti
          _buildParticipantsArea(
            context,
            state.participants,
          ), // Katılımcı avatarlarını inşa eder.
          const SizedBox(width: 8), // Boşluk.
          // Davet Butonu
          OutlinedButton.icon(
            // Kenarlıklı davet butonu.
            style: OutlinedButton.styleFrom(
              // Buton görsel stili.
              minimumSize: const Size(80, 36), // Butonun minimum boyutları.
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ), // Yatay iç boşluk.
              side: BorderSide(
                // Kenarlık çizgisi özellikleri.
                color: theme.colorScheme.primary.withValues(
                  alpha: 0.5,
                ), // Yarı saydam birincil renk kenarlık.
              ),
            ),
            icon: const Icon(
              Icons.person_add_alt_1_rounded,
              size: 16,
            ), // Kişi ekleme ikonu.
            label: const Text(
              'Davet',
              style: TextStyle(fontSize: 12),
            ), // Buton metni.
            onPressed: () async {
              // Davet butonuna tıklandığında.
              final room =
                  await ref // Odanın güncel modelini depodan asenkron çeker.
                      .read(roomsRepositoryProvider)
                      .getRoomById(widget.roomId);
              if (room != null && context.mounted) {
                // Oda bulunduysa ve ekran aktifse.
                showDialog(
                  // Paylaşım iletişim kutusunu açar.
                  context: context, // Context parametresi.
                  builder: (ctx) => ShareRoomDialog(
                    room: room,
                  ), // Paylaşım diyaloğunu görüntüler.
                );
              }
            },
          ),
          const SizedBox(width: 8), // Boşluk.
          // Tuval Arka Plan Deseni Menüsü
          PopupMenuButton<CanvasBackgroundPattern>(
            // Arka plan deseni seçim açılır menüsü.
            tooltip: 'Tuval Arka Planı', // Buton ipucu metni.
            icon: Icon(
              state.pattern.icon,
              size: 20,
            ), // Seçili desenin ikonunu gösterir.
            itemBuilder: (ctx) => CanvasBackgroundPattern.values.map((p) {
              // Tüm desen seçeneklerini menü elemanlarına dönüştürür.
              final isSelected =
                  state.pattern ==
                  p; // Bu seçeneğin aktif desen olup olmadığını kontrol eder.
              return PopupMenuItem(
                // Menü öğesi.
                value: p, // Tıklanınca dönecek desen değeri.
                child: Row(
                  // Simge ve metni yan yana yerleştirir.
                  children: [
                    // Satır elemanları.
                    Icon(
                      // Desen ikonu.
                      p.icon,
                      size: 18,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : null, // Seçiliyse birincil renkle vurgular.
                    ),
                    const SizedBox(width: 10), // Boşluk.
                    Text(
                      // Desenin adı.
                      p.label,
                      style: TextStyle(
                        // Metin stili.
                        fontWeight:
                            isSelected // Seçiliyse kalınlaştırır.
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected ? theme.colorScheme.primary : null,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(), // Menü listesine dönüştürür.
            onSelected: (p) => controller.setPattern(
              p,
            ), // Yeni desen seçildiğinde denetleyiciye iletir.
          ),

          // Dışa Aktarma (PNG / SVG) Menüsü
          PopupMenuButton<String>(
            // Tuvali indirme ve temizleme açılır menüsü.
            tooltip: 'Dışa Aktar ve İndir', // İpucu metni.
            icon: const Icon(
              Icons.download_rounded,
              size: 20,
            ), // İndirme simgesi.
            itemBuilder: (ctx) => [
              // Menü seçenekleri listesi.
              const PopupMenuItem(
                // PNG indirme seçeneği.
                value: 'png',
                child: Row(
                  children: [
                    Icon(Icons.image_outlined, size: 18),
                    SizedBox(width: 10),
                    Text('PNG Olarak İndir'),
                  ],
                ),
              ),
              const PopupMenuItem(
                // SVG indirme seçeneği.
                value: 'svg',
                child: Row(
                  children: [
                    Icon(Icons.code_rounded, size: 18),
                    SizedBox(width: 10),
                    Text('SVG Vektör İndir'),
                  ],
                ),
              ),
              const PopupMenuDivider(), // Menü ayırıcı ince çizgi.
              const PopupMenuItem(
                // Tuvali temizleme seçeneği.
                value: 'clear',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_sweep_rounded,
                      size: 18,
                      color: Colors.redAccent,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Tuvali Temizle',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ],
                ),
              ),
            ],
            onSelected: (val) {
              // Bir menü elemanı seçildiğinde çalışır.
              if (val == 'png') {
                // PNG seçildiyse.
                _exportPng(controller); // PNG dışa aktarma işlemini çağırır.
              } else if (val == 'svg') {
                // SVG seçildiyse.
                _exportSvg(controller); // SVG dışa aktarma işlemini çağırır.
              } else if (val == 'clear') {
                // Temizleme seçildiyse.
                _confirmClearCanvas(controller); // Onay diyalogunu açar.
              }
            },
          ),
          const SizedBox(width: 8), // Sağ kenardan boşluk bırakır.
        ],
      ),
      body: Stack(
        // Tuval katmanlarını, araç çubuğunu ve panelleri üst üste bindiren Stack widget'ı.
        children: [
          // Katmanlar listesi.
          // 1. Arka Plan Çizicisi (Grid, Kareli, Çizgili, Kâğıt)
          Positioned.fill(
            // Tüm gövde alanını kaplayan arka plan katmanı.
            child: CustomPaint(
              // Özel tuval çizimi yapan widget.
              painter: CanvasBackgroundPainter(
                // Arka plan desenini çizen ressam sınıfı.
                pattern: state.pattern, // Seçili desen (noktalı, grid vb.).
                pan: state.pan, // Tuval kaydırma ofseti.
                scale: state.scale, // Tuval yakınlaştırma oranı.
                isDark: isDark, // Koyu tema bayrağı.
              ),
            ),
          ),

          // 2. Etkileşimli Sonsuz Çizim Tuvali
          Positioned.fill(
            // Tuvalin tüm alanı kaplamasını sağlar.
            child: Listener(
              // Fare tekerleği gibi işaretçi sinyallerini dinleyen widget.
              onPointerSignal: (pointerSignal) {
                // Bir işaretçi sinyali alındığında çalışır.
                // Fare tekerleğiyle yakınlaştırma / uzaklaştırma (Zoom)
                if (pointerSignal is PointerScrollEvent) {
                  // Gelen sinyal fare tekerleği kaydırması ise.
                  final zoomFactor =
                      pointerSignal.scrollDelta.dy >
                          0 // Tekerleğin aşağı/yukarı hareketine göre çarpan belirler.
                      ? 0.9 // Aşağı kaydırmada uzaklaştırır.
                      : 1.1; // Yukarı kaydırmada yakınlaştırır.
                  controller.updateZoom(
                    // Yakınlaştırma oranını günceller.
                    state.scale * zoomFactor, // Yeni ölçek katsayısı.
                    pointerSignal.position, // Yakınlaştırmanın odak noktası (imleç konumu).
                  );
                }
              },
              child: GestureDetector(
                // Parmak ve fare dokunma/sürükleme hareketlerini algılayan widget.
                behavior: HitTestBehavior.opaque, // Boş alanların da dokunma olaylarını yakalamasını sağlar.
                onScaleStart: (details) {
                  // Dokunma veya ölçekleme hareketi başladığında.
                  if (details.pointerCount >
                          1 || // Birden fazla parmak varsa veya
                      state.activeTool == WhiteboardTool.pan) {
                    // aktif araç kaydırma (pan) aracı ise.
                    // İki parmakla veya Pan aracıyla gezinme
                    return; // Çizim başlatmaz, gezinmeye izin verir.
                  }
                  controller.onPointerDown(
                    details.localFocalPoint,
                  ); // Tek parmakla çizim veya seçim işlemini başlatır.
                },
                onScaleUpdate: (details) {
                  // Dokunma veya sürükleme devam ederken sürekli tetiklenir.
                  if (details.pointerCount > 1) {
                    // İki veya daha fazla parmakla hareket ediliyorsa (pinch to zoom).
                    // İki parmakla yakınlaştırma
                    controller.updateZoom(
                      // Tuval ölçeğini günceller.
                      state.scale * details.scale, // Yeni ölçek.
                      details.localFocalPoint, // İki parmağın odak merkezi.
                    );
                    controller.updatePan(
                      details.focalPointDelta,
                    ); // İki parmakla tuvali kaydırır.
                    return; // Çizim hareketini işletmez.
                  }

                  if (state.activeTool == WhiteboardTool.pan) {
                    // Aktif araç pan (el/kaydırma) aracı ise.
                    controller.updatePan(
                      details.focalPointDelta,
                    ); // Tuvali sürükleme yönünde kaydırır.
                  } else {
                    // Çizim, seçim veya silgi araçları aktif ise.
                    controller.onPointerMove(
                      // İmleç hareketini denetleyiciye iletir.
                      details.localFocalPoint, // Yeni imleç konumu.
                      screenDelta:
                          details.focalPointDelta, // Ekrandaki hareket farkı.
                    );
                  }
                },
                onScaleEnd: (details) {
                  // Dokunma hareketi bittiğinde.
                  controller.onPointerUp(); // Çizimi tamamlar veya sürüklemeyi sonlandırır.
                },
                child: RepaintBoundary(
                  // Çizim alanını yeniden çizilme sınırıyla izole eder ve PNG kopyalamaya izin verir.
                  key: _repaintBoundaryKey, // Görüntü yakalamak için global anahtar.
                  child: CustomPaint(
                    // Tuval nesnelerini ekrana çizen widget.
                    painter: CanvasPainter(
                      // Çizici sınıfı.
                      objects: state.objects, // Tuvaldeki tüm nesneler (çizgiler, şekiller, notlar).
                      currentDrawing: state
                          .currentDrawing, // Şu an aktif çizilmekte olan çizgi.
                      selectedObjectId:
                          state.selectedObjectId, // Seçili nesnenin kimliği.
                      pan: state.pan, // Kaydırma ofseti.
                      scale: state.scale, // Ölçekleme oranı.
                      participants: state
                          .participants, // Canlı katılımcılar ve imleçleri.
                      isDark: isDark, // Koyu tema bayrağı.
                    ),
                    size:
                        Size.infinite, // Tuvalin tüm alana yayılmasını sağlar.
                  ),
                ),
              ),
            ),
          ),

          // 3. Seçili Nesne Aksiyon Kutusu (Raptiye, Sil, Düzenle)
          ObjectActionOverlay(
            state: state,
            controller: controller,
          ), // Seçili nesnenin hemen üstünde beliren işlem butonları.
          // 4. Whiteboard Araç Çubuğu (Toolbar)
          Positioned(
            // Araç çubuğunu ekranın alt tarafında konumlandırır.
            left: 16, // Sol boşluk.
            right: 16, // Sağ boşluk.
            bottom: 20, // Alt kenardan 20 piksel yukarıda yüzer.
            child: Center(
              // Çubuğu yatay eksende ortalar.
              child: WhiteboardToolbar(
                // Alt çizim araç çubuğu widget'ı.
                state: state, // Mevcut tuval durumu.
                controller: controller, // Tuval denetleyicisi.
                onAddStickyNote:
                    () => // Yapışkan not ekle butonuna tıklandığında.
                    _openStickyNoteDialog(
                      context,
                      controller,
                    ), // Post-it diyaloğunu açar.
                onAddText: () => _openTextDialog(
                  context,
                  controller,
                ), // Metin ekleme diyaloğunu açar.
                onAddImage: () => _openImageDialog(
                  context,
                  controller,
                ), // Görsel ekleme diyaloğunu açar.
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsArea(
    // Uygulama çubuğundaki katılımcı avatarlarını inşa eden yardımcı widget fonksiyonu.
    BuildContext context, // Build context parametresi.
    List<WhiteboardParticipant> participants, // Odadaki katılımcı listesi.
  ) {
    if (participants.isEmpty)
      return const SizedBox.shrink(); // Katılımcı yoksa boş alan döner.

    const maxVisible = 3; // Yan yana gösterilecek en fazla avatar sayısı.
    final visibleList = participants
        .take(maxVisible)
        .toList(); // İlk 3 katılımcıyı alır.
    final remaining =
        participants.length - maxVisible; // Kalan katılımcı sayısını hesaplar.

    return Row(
      // Katılımcıları ve sayacı yatay dizer.
      mainAxisSize: MainAxisSize.min, // Genişliği içeriğe göre daraltır.
      children: [
        // Sıra elemanları.
        Row(
          // Görünür avatarlar satırı.
          mainAxisSize: MainAxisSize.min, // Minimum genişlik.
          children: List.generate(visibleList.length, (index) {
            // Her katılımcı için daire avatar oluşturur.
            final p = visibleList[index]; // İlgili sıradaki katılımcı.
            return Container(
              // Avatarı saran dış kutu.
              margin: const EdgeInsets.only(
                right: 4,
              ), // Sağdan 4 piksel boşluk.
              child: CircleAvatar(
                // Yuvarlak avatar bileşeni.
                radius: 14, // Avatar yarıçapı.
                backgroundColor: p.color, // Katılımcının kendine has rengi.
                child: Text(
                  // Katılımcının baş harfi.
                  p.name.isNotEmpty
                      ? p.name[0].toUpperCase()
                      : 'U', // Adın ilk harfini büyük olarak gösterir.
                  style: const TextStyle(
                    // Metin stili.
                    fontSize: 12, // Yazı boyutu.
                    fontWeight: FontWeight.bold, // Kalın yazı tipi.
                    color: Colors.white, // Beyaz renk.
                  ),
                ),
              ),
            );
          }),
        ),
        if (remaining > 0) // Kalan katılımcı sayısı sıfırdan büyükse "+N" rozetini gösterir.
          Container(
            // Rozet kutusu.
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 3,
            ), // İç boşluk.
            decoration: BoxDecoration(
              // Rozet kutusunun arka planı ve köşeleri.
              color: Colors.grey.withValues(
                alpha: 0.2,
              ), // Hafif yarı saydam gri arka plan.
              borderRadius: BorderRadius.circular(10), // Yuvarlatılmış köşeler.
            ),
            child: Text(
              // Kalan katılımcı sayısı metni.
              '+$remaining', // Örneğin "+2" formatında yazar.
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ), // Küçük ve kalın yazı stili.
            ),
          ),
      ],
    );
  }
}
