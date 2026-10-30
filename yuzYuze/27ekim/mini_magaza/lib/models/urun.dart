import 'package:mini_magaza/models/kategori.dart';
import 'degerlendirme.dart';

class Urun {
  final int id;
  final String baslik;
  final String aciklama;
  final double fiyat;
  final String resimUrl;
  final Kategori kategori;
  final int stokAdedi;
  final bool favoriMi;
  final Degerelendirme degerlendirme;


    const Urun({
      required this.id,
      required this.baslik,
      required this.aciklama,
      required this.fiyat,
      required this.resimUrl,
      required this.kategori,
      required this.stokAdedi,
      required this.degerlendirme,
      this.favoriMi = false,

    });


    factory Urun.fromJson(Map<String,dynamic> json){
      return Urun(
        id : json['id'] as int,
        baslik: json['title'] as String,
        fiyat : (json['price'] as num).toDouble(),
        aciklama : json['description'] as String,
        kategori : json['category'] as Kategori,
        resimUrl: json['image'] as String,
        degerlendirme : Degerelendirme.fromJson(json['rating'] as Map<String,dynamic>),
        stokAdedi: 15,
        favoriMi:false,
      );
    }

    Urun copyWith({
        int? id,
        String? baslik,
        String? aciklama,
        double? fiyat,
        String? resimUrl,
        Kategori? kategori,
        int? stokAdedi,
        Degerelendirme? degerlendirme,
        bool? favoriMi,
    }){
        return Urun(
        id: id ?? this.id,
        baslik: baslik ?? this.baslik,
        aciklama: aciklama ?? this.aciklama,
        fiyat: fiyat ?? this.fiyat,
        resimUrl: resimUrl ?? this.resimUrl,
        kategori: kategori ?? this.kategori,
        stokAdedi: stokAdedi ?? this.stokAdedi,
        degerlendirme:degerlendirme ?? this.degerlendirme,
        favoriMi: favoriMi ?? this.favoriMi,
    );
  }

  @override
  String toString(){
    return 'Urun(id :$id,baslik: $baslik,fiyat:$fiyat ₺,favoriMi: $favoriMi)';
  }
}