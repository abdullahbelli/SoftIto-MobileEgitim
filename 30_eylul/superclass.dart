//Üst sınıf
class TemekSavasci {
  final String ad;
  final double temelGuc;

  TemekSavasci({required this.ad, required this.temelGuc});

  void saldir() {
    print("[$ad] Temel fiziksel yumruk attı. Hasar $temelGuc");
  }
}

class Buyucu extends TemekSavasci {
  int manaPuani;

  Buyucu({required this.manaPuani, required super.ad, required super.temelGuc});

  @override
  void saldir() {
    if (manaPuani >= 10) {
      manaPuani -= 10;
      print(
        "[$ad] kişi alev topu fırlattı. Hasar: ${temelGuc * 2} Kalan Mana:$manaPuani",
      );
    } else {
      print("Mana tükendi");
      super.saldir();
    }
  }
}

class Okcu extends TemekSavasci {
  int okSayisi;

  Okcu({required this.okSayisi, required super.ad, required super.temelGuc});

  @override
  void saldir() {
    if (okSayisi > 0) {
      okSayisi--;
      print(
        "[$ad] Hedefe zehirli ok fırlattı: Hasar: ${temelGuc * 1.5} Kalan Ok Sayısı: $okSayisi",
      );
    } else {
      print("Ok Bitti");
      super.saldir();
    }
  }
}

void main() {
  print("Savaş Arenası");

  final asker = TemekSavasci(ad: "Abdullah", temelGuc: 20.0);
  //Ymruk atar
  asker.saldir();
  print("----------------------");
  final merlin = Buyucu(manaPuani: 20, ad: "Furkan", temelGuc: 40.0);
  merlin.saldir();
  print("----------------------");
  final legolas = Okcu(okSayisi: 5, ad: "Legolas", temelGuc: 35.0);
  legolas.saldir();
}
