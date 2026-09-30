//mixin and with

mixin UcmaYetisi {
  int ucusIrtifasiMetre = 100;

  void gogeYuksel() {
    print(
      "Uçuş Yetisi: Kanatlarını açtı ve $ucusIrtifasiMetre metrey yüksledi",
    );
  }
}

mixin GorunmezlikYetisi {
  void pelerinOrt() {
    print("Görünmezlik: Düşmanların gözünden tamamen kayboldu");
  }
}

mixin AtesGucuYetisi {
  void alevSaldirisi() {
    print("Ateş Gücü: Kılıcını alevlendirdi ve alanı yaktı.");
  }
}

class TemelKarakter {
  final String ad;
  TemelKarakter({required this.ad});
}

class EfsaneviEjderBinicisi extends TemelKarakter
    with UcmaYetisi, AtesGucuYetisi {
  final String ejderhaAdi;

  EfsaneviEjderBinicisi({required this.ejderhaAdi, required super.ad});

  void hucumEt() {
    print("$ad ve ejderhası $ejderhaAdi savaşa atılıyor");
    gogeYuksel();
    alevSaldirisi();
  }
}

class GolgeSuikastci extends TemelKarakter with GorunmezlikYetisi {
  GolgeSuikastci({required super.ad});

  void suikastYap() {
    print("$ad hedefe sessizce yaklaşııyor");
    pelerinOrt();
    print("Kritik darbe vurdu.");
  }
}

void main() {
  print("Süper Güçler Başlatılıyor");
  final binici = EfsaneviEjderBinicisi(ejderhaAdi: "Abdullah", ad: "Belli");
  binici.hucumEt();
  final suikastci = GolgeSuikastci(ad: "Furkan");
  suikastci.suikastYap();
}
