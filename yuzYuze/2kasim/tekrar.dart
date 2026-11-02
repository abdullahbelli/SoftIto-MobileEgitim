//Mğlakat için önemli: Sealed sınıflar dışarıdan extend edilmez. Switch içinde tüm alt sınıflar üketilmek zorundaır.

sealed class OdemeDurumu{}

class OdemeBasaili extends OdemeDurumu {
    final ({String referansKodu , double tutar}) veri;
    OdemeBasaili(this.veri);
}

class OdemeBasarisiz extends OdemeDurumu{
    final String hataNedeni;
    OdemeBasarisiz(this.hataNedeni);
}

abstract class IBankaServisi{
    Future<OdemeDurumu> odeme({required double miktar});

}

mixin GuvenlikDenetmiMixin{
    bool tokenGecerliMi(String token){
        return token.isNotEmpty && token.length >=10;
    }
}

mixin AuditLogMixin{
    void islemKaydet(String mesaj){
        final zaman = DateTime.now().toIso8601String();
        print ('Log - $zaman: $mesaj');
    }
}


class GarantiBankasiServisi with GuvenlikDenetmiMixin,AuditLogMixin implements IBankaServisi{
    final String apiAnahtari;

    GarantiBankasiServisi({required this.apiAnahtari});

    @override
    Future<OdemeDurumu> odeme({required double miktar}) async{
        if(!tokenGecerliMi(apiAnahtari)){
            islemKaydet('Odeme Reddedildi. Geçersiz Api Anahtari');
            return OdemeBasarisiz('Yetkilendirme hatası: Geçersiz Token');
        }
    
        await Future.delayed(const Duration(milliseconds:1000));

        islemKaydet('$miktar tutarındaki ödeme Garanti Banksaı tarafında ONAYLANDI');

        return OdemeBasaili((referansKodu:'GRNT - ${DateTime.now().millisecondsSinceEpoch}', tutar: miktar));
    }
    
}

void odemeSonucunuEkranaBas(OdemeDurumu durum){
    final mesaj = switch(durum){
        OdemeBasaili b =>'Odeme Basarili. Ref : ${b.veri.referansKodu} , Tutar: ${b.veri.tutar} ₺',
        OdemeBasarisiz h => 'Ödeme Başarısız. Gerekçe : ${h.hataNedeni}',
    };
    print(mesaj);
}

void main(){
    GarantiBankasiServisi(apiAnahtari: "G_123456789").odeme(miktar: 250.0).then((durum) => odemeSonucunuEkranaBas(durum));
}

