import 'dart:ffi';

abstract class LoncaUyesi {
  final String rumuz;

  LoncaUyesi({required this.rumuz});

  //soyut metot  abstract method
  void ozelYetenekKullan();

  void loncaSelamVer() {
    print("$rumuz Lonca Bayrağını Selamladı: Onur ve zafer için");
  }
}

class Sovalye extends LoncaUyesi {
  Sovalye({required super.rumuz});

  @override
  void ozelYetenekKullan() {
    print("$rumuz Demir kalkanını kaldırdı ve savunma duvarı ördü");
  }
}

class Sifaci extends LoncaUyesi {
  Sifaci({required super.rumuz});

  @override
  void ozelYetenekKullan() {
    print("$rumuz Kutsal ışık büyüsüyle tüm takımın canını tazeledi");
  }
}

void savasAlanindaKomutVer(List<LoncaUyesi> takim) {
  print("Liderin emriyle takım yetenekleri devreye grisin");
  for (var t in takim) {
    t.loncaSelamVer();
    //Herkes kendi özel yeteneğini kulasnı
    t.ozelYetenekKullan();
  }
}

void main() {
  print("Lonca Takımı");
  final List<LoncaUyesi> loncaBirligi = [
    Sovalye(rumuz: "Kızıl Şövalye Adil"),
    Sifaci(rumuz: "Orman Perisi Elif"),
    Sovalye(rumuz: "Güöüş muhafız Eren"),
  ];

  //Hepsini tek bir emir ile çalıştırıyoruz
  savasAlanindaKomutVer(loncaBirligi);
}
