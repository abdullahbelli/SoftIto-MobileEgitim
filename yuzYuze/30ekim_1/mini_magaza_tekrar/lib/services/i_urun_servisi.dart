import '../models/urun.dart';

abstract class IUrunServisi {
  Future<List<Urun>> urunleriGetir();

  Future<Urun?> urunGetirById(int id);
}
