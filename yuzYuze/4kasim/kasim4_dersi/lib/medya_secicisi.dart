import 'dart:io'; // dosya ve işletim sistemi işlemleri için kullanılan dart kütüphanesi

import 'package:image_picker/image_picker.dart'; // galeri ve kameradan görsel seçmeyi sağlayan paket

class MedyaSeciciServisi {
  // görsel seçme ve fotoğraf çekme işlemlerini yöneten sınıf
  final ImagePicker _picker =
      ImagePicker(); // görsel seçme işlemleri için picker nesnesi oluşturur

  Future<File?> galeridenSec() async {
    // galeriden görsel seçen ve boş değer döndürebilen asenkron metot
    final XFile? secilen = await _picker.pickImage(
      source: ImageSource.gallery, // galeriyi açar ve seçilen görseli bekler
      imageQuality: 80, //yüzde 80 üzeri çok tercih edilmez
      maxWidth: 1200,
    ); // görselin genişliğini en fazla 1200 piksel olacak şekilde sınırlar

    if (secilen == null) return null; // kullanıcı görsel seçmezse null döndürür
    return File(
      secilen.path,
    ); // seçilen görselin yolundan file nesnesi oluşturur
  }

  Future<File?> kmeradanCek() async {
    // kameradan fotoğraf çekip dosya döndüren asenkron metot
    final XFile? cekilen = await _picker.pickImage(
      source: ImageSource.camera, // kamerayı açar ve çekilen fotoğrafı bekler
      imageQuality:
          80, // fotoğrafın sıkıştırma kalite değerini 80 olarak belirler
      maxWidth: 1200,
    ); // fotoğrafın genişliğini en fazla 1200 piksel ile sınırlar
    if (cekilen == null) return null; // fotoğraf çekilmezse null döndürür
    return File(cekilen.path); // çekilen fotoğrafı file nesnesine dönüştürür
  }
}
