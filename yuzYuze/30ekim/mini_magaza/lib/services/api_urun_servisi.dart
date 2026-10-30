import 'dart:convert';
import 'package:http/http.dart';
import '../models/urun.dart';
import '../models/kategori.dart';
import 'i_urun_servisi.dart';

class ApiUrunServisi implements IUrunServisi{
    static const String _baseUrl = 'https://fakestoreapi.com/products';

    @override 
    Future<List<Urun>> tumUrunleriGetir() async{
        final uri = Uri.parse(_baseUrl);
        try{
            final yanit = await http.get(uri).timeout(
                const Duration(seconds:10),
                onTimeout:()=> throw Exception("Ağ isteği zaman aşımına uğradı(Timeout)"),
            );
            if(yanit.statusCode == 200){
                final List<dynamic> hamListe = jsonDecode(utf8.decode(yanit.bodyBytes));
                return hamListe.map((tekilJson)=>Urun.fromJson(tekilJson as Map<String,dynamic>)).toList();
            }else{
                throw Exception('Sunucıu hatası oluştu! Durum Kodu:${yanit.statusCode}');
            }
        }catch(hata){
            throw Exception('İnternet Bağlantısı Kurulamadı: $hata');
        }
    }

    @override
    Future<List<Urun>> kategoriyeGoreGetir(Kategori kategori) async{
        if(kategori == Kategori.hepsi){
            return tumUrunleriGetir();
        };
        String kategoriYolu;
        switch(kategori){
            case Kategori.elektronik: 
                kategoriYolu = 'electronics';
            break;
            case Kategori.giyim:
                kategoriYolu="men's clothing";
            break;
            case Kategori.mobilya:
                kategoriYolu ='jewelery';
                break;
            default:
                return tumUrunleriGetir();
        };

        final uri = Uri.parse('$_baseUrl/category/$kategoriYolu');
        final yanit = await http.get.(uri);

        if(yanit.statusCode == 200){
            final List<dynamic> hamListe = jsonDecode(utf8.decode(yanit.bodyBytes));
            return hamListe.map((j)=>Urun.fromJson(j as Map<String,dynamic>)).toList();
        }else{
            throw Exception('Kategori Filtreleme Hatası: ${yanit.statusCode}');
        }
    }

    @override
    Future<List<Urun>> adaGoreGetir(String aramaMetni) async{
        final tumUrunler = await tumUrunleriGetir();
        if(aramaMetni.trim().isEmpty) return tumUrunler;

        return tumUrunler.where((urun){
            return urun.baslik.toLowerCase().contains(aramaMetni.toLowerCase()) || urun.aciklama.toLowerCase().contains(aramaMetni.toLowerCase()).toList();//içeride return yazmamız gerekiyor çünkü true false değilde o urununun metin olarak dönmesini istiyoruz return olması her bir gezmede true false dönecekti. metin verileri olmayacaktı.
            //where içerisinde trim yapmamaızın nedeni contains metodunun "Kelime1 kelime2" gibi bir string'in olsun bu kendisi bunları ayırıp tek tek içeriyormu diye bakması contains bizim için hallediyor.
            //projeye çalıştır ekrana gelsin mock apiden değil gerçek verilerden yapıcaksın
        })

    }
    
}