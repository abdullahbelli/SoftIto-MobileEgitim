import 'dart:io'; // cihazdaki dosyalarla işlem yapmak için kullanılan dart kütüphanesi

import 'package:firebase_storage/firebase_storage.dart'; // firebase üzerinde dosya depolama işlemlerini sağlayan paket

import 'package:image_picker/image_picker.dart'; // galeri veya kameradan görsel seçmeyi sağlayan paket

class StorageServisi {
  // görsel seçme ve firebase depolama işlemlerini yöneten sınıf
  final FirebaseStorage _storage = FirebaseStorage
      .instance; // firebase storage servisinin mevcut örneğini alır
  final ImagePicker _picker =
      ImagePicker(); // görsel seçme işlemleri için nesne oluşturur

  Future<File?> gorselSec({bool kameradan = false}) async {
    // varsayılan olarak galeriden dosya seçen asenkron metot
    final XFile? xFile = await _picker.pickImage(
      // kamerayı veya galeriyi açar ve seçilen görseli bekler
      source: kameradan
          ? ImageSource.camera
          : ImageSource
                .gallery, // true ise kamerayı false ise galeriyi kullanır
      imageQuality: 80, // görsel sıkıştırma kalite değerini 80 olarak belirler
      maxWidth: 1200, // görsel genişliğini en fazla 1200 piksel ile sınırlar
    );
    if (xFile == null) return null; // görsel seçilmezse null döndürür
    return File(xFile.path); // seçilen görselin yolundan file nesnesi oluşturur
  }

  UploadTask yuklemeBaslat({
    // dosya yüklemesini başlatıp uploadtask nesnesi döndüren metot
    required File dosya, // yüklenecek dosyayı zorunlu parametre olarak alır
    required String dosyaAdi, // dosyanın kaydedileceği adı zorunlu olarak alır
    String klasor = 'yuklemeler', // klasör belirtilmezse varsayılan olarak yuklemeler klasörünü kullanır
  }) {
    // firebase storage üzerinde dosyanın kaydedileceği konumu belirler
    final Reference ref = _storage.ref().child(
      // klasör ve dosya adını birleştirerek dosyanın yolunu oluşturur
      '$klasor/$dosyaAdi',
    ); // firebase storage üzerinde dosyanın hedef yolunu oluşturur

    // dosyanın içerik türünü ve özel bilgilerini tutan metadata nesnesini oluşturur
    final metadata = SettableMetadata(
      // dosyaya ait ek bilgileri tanımlar
      contentType: 'image/png', // dosyanın içerik türünü png olarak belirtir
      customMetadata: {
        'ekleyen': 'Berat Atmaca',
      }, // dosyaya özel ekleyen bilgisini kaydeder
    );

    // belirtilen dosyayı firebase storage üzerine yüklemeye başlar
    return ref.putFile(
      // yükleme işlemi için dosya nesnesini gönderir
      dosya,

      // dosyanın içerik türünü ve özel bilgilerini yükleme işlemine ekler
      metadata,
    ); // dosyayı metadata ile yüklemeye başlar ve yükleme görevini döndürür
  }

  Future<String> urlGetir(Reference ref) async {
    // dosyanın indirme bağlantısını döndüren asenkron metot
    return await ref.getDownloadURL(); // belirtilen dosyanın firebase indirme adresini getirir
  }

  Future<void> dosyaSil(String dosyaYolu) async {
    // belirtilen dosyayı silen asenkron metot

    // silinecek dosyanın firebase storage üzerindeki referansını oluşturur
    final Reference ref = _storage.ref().child(
      // silinecek dosyanın klasör ve dosya adını içeren yolunu kullanır
      dosyaYolu,
    ); // silinecek dosyanın storage referansını oluşturur

    // belirtilen dosyayı firebase storage üzerinden siler
    await ref
        .delete(); // dosyayı firebase storage üzerinden siler ve işlemi bekler
  }
}
