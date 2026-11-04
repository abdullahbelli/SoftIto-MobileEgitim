
import 'dart:io'; // yerel dosya işlemlerini sağlayan dart kütüphanesi
import 'package:firebase_storage/firebase_storage.dart'; // firebase storage dosya yükleme ve depolama işlemlerini sağlar
import 'package:flutter/widgets.dart'; // flutter arayüz bileşenlerini içeren temel paket

class StorageServisi { // firebase storage işlemlerini yöneten servis sınıfı
  final FirebaseStorage _storage = FirebaseStorage.instance; // firebase storage servisinin mevcut örneğini alır

  UploadTask yuklemeBaslat({ // dosya yüklemesini başlatıp uploadtask nesnesi döndüren metot
    required File dosya, // yüklenecek dosyayı zorunlu parametre olarak alır
    required String hedefDizin, // dosyanın yükleneceği klasör yolunu alır
    required String dosyaAdi, // dosyanın kaydedileceği adı alır
  }){
    final Reference ref = _storage.ref().child('$hedefDizin/$dosyaAdi'); // storage üzerinde dosyanın hedef konumunu oluşturur
    final metadata=SettableMetadata( // dosyaya ait ek bilgileri tanımlayan metadata nesnesi
      contentType: 'image/jpeg', // dosyanın içerik türünü jpeg görsel olarak belirtir
      customMetadata: {'yukleyen' : 'Faik Fahri Fuat Fahrettin tek kişilik dev kadro'}, // dosyaya özel anahtar değer bilgisi ekler
    );
    return ref.putFile(dosya,metadata); // dosyayı metadata bilgileriyle yüklemeye başlar ve yükleme görevini döndürür
  }

  task.snapshot.listen((TaskSnapshot snapshot){ // yükleme durumundaki değişiklikleri dinlemeyi amaçlar
    final double yuzde = snapshot.bytesTransferred / snapshot.totalBytes; // yüklenen bayt miktarını toplam bayt miktarına bölerek ilerleme oranını hesaplar
    print('yukleniyor %${(yuzde * 100).toStringAsFixed(1)}'); // ilerleme oranını yüzdeye çevirip bir ondalık basamakla yazdırır
  })
}
