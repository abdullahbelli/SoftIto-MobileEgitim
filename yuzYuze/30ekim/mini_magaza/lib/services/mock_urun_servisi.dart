import 'i_urun_servisi.dart';
import '../models/kategori.dart';
import '../models/urun.dart';

class MockUrunServisi implements IUrunServisi{
    final List<Urun> _urunDeposu =const [
        Urun(
            id:1,
            baslik:"Macbook M5 Pro Laptop",
            aciklama:"Apple'ın en güçlü işlemcisine sahip yeni nesil Macbook Pro",
            fiyat:179999.99,
            resimUrl:"https://picsum.photos/200/200",
            kategori:Kategori.elektronik,
            stokAdedi:5,
        ),
        Urun(
            id:2,
            baslik:"Apple İphone 18 Pro Max",
            aciklama:"Apple'ın en gelişmiş kamera sistemine sahip yeni nesil İphone",
            fiyat:149999.99,
            resimUrl:"https://picsum.photos/400/400",
            kategori:Kategori.elektronik,
            stokAdedi:14,
        ),
        Urun(
            id:3,
            baslik:"Erkek Giyim Gömlek",
            aciklama:"Erkek Giyim Gömlek",
            fiyat:499.99,
            resimUrl:"https://picsum.photos/400/400",
            kategori:Kategori.giyim,
            stokAdedi:15,
        ),
        Urun(
            id:4,
            baslik:"Lenovo Thinkpad X1",
            aciklama:"iş Dünyasının Vazgeçilmezi İşlemciye sahip yeni nesil Macbook Pro",
            fiyat:17999.99,
            resimUrl:"https://picsum.photos/400/400",
            kategori:Kategori.elektronik,
            stokAdedi:5,
        ),
        Urun(
            id:5,
            baslik:"Adidas Sneackers",
            aciklama:"Adidas Sneackers",
            fiyat:1799.99,
            resimUrl:"https://picsum.photos/400/400",
            kategori:Kategori.ayakkabi,
            stokAdedi:132,
        ),
        Urun(
            id:6,
            baslik:"Nike Air Jordan",
            aciklama:"Nike Air Jordan",
            fiyat:2999.99,
            resimUrl:"https://picsum.photos/400/400",
            kategori:Kategori.ayakkabi,
            stokAdedi:132,
        ),
        Urun(
            id:7,
            baslik:"İnci Kolye",
            aciklama:"Zarif ve Şık İnci Kolye",
            fiyat:4999.99,
            resimUrl:"https://picsum.photos/400/400",
            kategori:Kategori.aksesuar,
            stokAdedi:25,
        ),
        Urun(
            id:8,
            baslik:"Apple Watch Series 10",
            aciklama:"Apple Watch Series 10",
            fiyat:25999.99,
            resimUrl:"https://picsum.photos/400/400",
            kategori:Kategori.elektronik,
            stokAdedi:5,
        ),
        Urun(
            id:9,
            baslik:"Erkek Deri Ceket",
            aciklama:"Erkek Deri Ceket",
            fiyat:1999.99,
            resimUrl:"https://picsum.photos/400/400",
            kategori:Kategori.giyim,
            stokAdedi:34,
        ),


    ];
    MockUrunServisi(){}

    @override
    Future<List<Urun>> tumUrunleriGetir() async{
        await Future.delayed(const Duration(milliseconds:3000));
        return List.from(_urunDeposu);
    }

    @override
    Future<List<Urun>> adaGoreAra(String aramaMetni) async{
        await Future.delayed(const Duration(milliseconds:300));
        if(aramaMetni.trim().isEmpty){
            return List.from(_urunDeposu);
        }

        return _urunDeposu.where((urun){
            final baslikKucuk = urun.baslik.toLowerCase();
            final arananKucuk = aramaMetni.toLowerCase();
            return baslikKucuk.contains(arananKucuk);
        }).toList();
    }

    @override
    Future<List<Urun>> kategoriyeGoreGetir(Kategori kategori) async {
        await Future.delayed(const Duration(milliseconds:400));
        if(kategori == Kategori.hepsi){
            return List.from(_urunDeposu);
        }
        return _urunDeposu.where((urun) => urun.kategori == kategori).toList();
    }

    

}