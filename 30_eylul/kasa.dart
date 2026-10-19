import 'dart:async';

class Kasa {
  final String oyuncuAdi;
  int _altinMiktari = 0;

  Kasa({required this.oyuncuAdi});

  int get altinMiktari {
    return _altinMiktari;
  }

  set altinMiktari(int yeniAltin) {
    if (yeniAltin <= 0) {
      _altinMiktari = altinMiktari;
      print("Sahte altın gelemez.");
    } else {
      _altinMiktari += yeniAltin;
      print("Tebrikler $oyuncuAdi $yeniAltin para kazandın");
    }
  }
}

void main() {
  print("Altın Sistemi");

  final baslangicAltin = Kasa(oyuncuAdi: "Abdullah Belli");
  print("Başlangıç altın: ${baslangicAltin.altinMiktari}");
  baslangicAltin.altinMiktari = -20;
  baslangicAltin.altinMiktari = 50;
}
