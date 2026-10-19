// canavar sınıfı
// kükre metodu
// kurt canavarı ejderha canaaavarı kükremeler ekrna yazılacak

abstract class Canavar {
  final String canavar;

  Canavar({required this.canavar});

  void kukre();
}

class Kurt extends Canavar {
  Kurt({required super.canavar});

  @override
  void kukre() {
    print("$canavar kükredi AUUUUUUUUUUU AUUUUUUUUUUUUUUUUU");
  }
}

class Ejderha extends Canavar {
  Ejderha({required super.canavar});

  @override
  void kukre() {
    print("$canavar kükredi ŞŞŞŞŞŞŞŞŞŞŞŞŞŞŞŞŞŞŞŞŞŞŞŞŞŞŞŞŞŞŞŞŞŞ");
  }
}

void main() {
  final kurt = Kurt(canavar: "Bozkurt");
  final ejderha = Ejderha(canavar: "Dişsiz");

  kurt.kukre();
  ejderha.kukre();
}
