import '../models/urun.dart';
import '../models/kategori.dart';

abstract class IUrunService{
    Future<List<Urun>> tumUrunleriGetir();
    Future<List<Urun>> kategoriyeGoreGetir(Kategori kategori);
    Future<List<Urun>> adaGoreAra(String aramaMetni);

}

