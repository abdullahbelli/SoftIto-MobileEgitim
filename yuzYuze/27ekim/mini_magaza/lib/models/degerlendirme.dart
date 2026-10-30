class Degerelendirme{
    final double puan;
    final int oySayisi;

    const Degerelendirme({
        required this.puan,
        required this.oySayisi,
    });

    factory Degerelendirme.fromJson(Map<String,dynamic> json){
        return Degerelendirme(
            puan:(json['rate'] as num?)?.toDouble() ?? 0.0,
            oySayisi:(json['count'] as num?)?.toInt() ?? 0,
        );
    }

}