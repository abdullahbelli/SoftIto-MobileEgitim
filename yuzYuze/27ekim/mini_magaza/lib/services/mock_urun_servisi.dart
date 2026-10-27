import '../models/urun.dart';
import '../models/kategori.dart';
import 'i_urun_service.dart';

class MockUrunServisi implements IUrunService{
    

    final List<Urun> _urunDeposu = const [
        Urun(
            id:1,
            baslik:"Macbook m5 pRO lAPTOP",
            aciklama:"Yüksek performanslı M5 çipsetli Pro Laptop",
            fiyat:179999.99,
            resimUrl:"https://picsum.photos/200",
            kategori:Kategori.elektronik,
            stokAdedi:5,    
        ),
        Urun(
            id:2,
            baslik:"Apple Iphone 18 Pro Max",
            aciklama:"En yeni teknoloji iPhone modeli",
            fiyat:149999.99,
            resimUrl:"https://picsum.photos/200",
            kategori:Kategori.elektronik,
            stokAdedi:14,    
        ),
        Urun(
            id:3,
            baslik:"Erkek L Gömlek",
            aciklama:"%100 Pamuk, Slim Fit",
            fiyat:499.99,
            resimUrl:"https://picsum.photos/200",
            kategori:Kategori.giyim,
            stokAdedi:34,    
        ),Urun(
            id:4,
            baslik:"Klasik Siyah Ayakkabı",
            aciklama:"%100 Deri, Deri tabanlı",
            fiyat:1299.99,
            resimUrl:"https://picsum.photos/200",
            kategori:Kategori.ayakkabi,
            stokAdedi:15,    
        ),Urun(
            id:5,
            baslik:"Beyaz Spor Ayakkabı",
            aciklama:"Yüksek performanslı M5 çipsetli Pro Laptop",
            fiyat:699.99,
            resimUrl:"https://picsum.photos/200",
            kategori:Kategori.ayakkabi,
            stokAdedi:42,    
        ),Urun(
            id:6,
            baslik:"Siyah Deri Ceket",
            aciklama:"%100 Kuzu Derisi, Premium Kalite",
            fiyat:899.99,
            resimUrl:"https://picsum.photos/200",
            kategori:Kategori.giyim,
            stokAdedi:18,    
        ),Urun(
            id: 7,
            baslik:"Kışlık Mont",
            aciklama:"%100 Pamuk, Slim Fit",
            fiyat:499.99,
            resimUrl:"https://picsum.photos/200",
            kategori:Kategori.giyim,
            stokAdedi:5,    
        ),Urun(
            id:8,
            baslik:"Kot Pantolon",
            aciklama:"%100 Pamuk, Slim Fit",
            fiyat:699.99,
            resimUrl:"https://picsum.photos/200",
            kategori:Kategori.giyim,
            stokAdedi:34,    
        ),Urun(
            id:9,
            baslik:"Siyah Bot",
            aciklama:"%100 Deri, Deri tabanlı",
            fiyat:1599.99,
            resimUrl:"https://picsum.photos/200",
            kategori:Kategori.ayakkabi,
            stokAdedi:25,    
        ),
        
    ];
    @override
    Future<List<Urun>> tumUrunleriGetir()async{
        await Future.delayed(const Duration(milliseconds: 1500));
        return List.from(_urunDeposu);
    }
    @override
    Future<List<Urun>> kategoriyeGoreGetir(Kategori kategori) async{
      await Future.delayed(const Duration(milliseconds: 400));
      if(kategori==Kategori.hepsi){
        return List.from(_urunDeposu);      
      }
      return _urunDeposu.where((urun) => urun.kategori == kategori).toList();    
    }

    @override
    Future<List<Urun>> adaGoreAra(String aramaMetni)async{
        await Future.delayed(const Duration(milliseconds:300));
        if(aramaMetni.trim().isEmpty){
            return List.from(_urunDeposu);
        }
        return _urunDeposu.where((urun){
            final baslikKucuk = urun.baslik.toLowerCase();
            final arananKucuk = aramaMetni.trim().toLowerCase();
            return baslikKucuk.contains(arananKucuk);
        }).toList();
    }   
}
