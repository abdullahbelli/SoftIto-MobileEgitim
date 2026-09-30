//yuzme yetisi miix
// dalıyap mtodu
// su altına daldı
// denizci

mixin YuzmeYetisi {
  void suyaDal() {
    print("Su Altına Daldı");
  }
}

class TemelKarakter {
  final String ad;
  TemelKarakter({required this.ad});
}

class Denizci extends TemelKarakter with YuzmeYetisi {
  Denizci({required super.ad});

  void yuz() {
    print("$ad");
    suyaDal();
  }
}

void main() {
  final denizci = Denizci(ad: "Abdullah");
  denizci.yuz();
}
