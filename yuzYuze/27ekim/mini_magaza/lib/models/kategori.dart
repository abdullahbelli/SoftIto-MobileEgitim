enum Kategori{
    hepsi,
    elektronik,
    taki,
    erkekGiyim,
    kadinGiyim;

    
}

extension KategoriExtension on Kategori{
    String get gorunenAd{
        switch(this){
            case Kategori.hepsi:
                return 'Tümü';
            case Kategori.elektronik:
                return 'Elektronik';
            case Kategori.taki:
                return 'Taki & Mücevher';
            case Kategori.erkekGiyim:
                return 'Erkek Giyim';
            case Kategori.kadinGiyim:
                return 'Kadın Giyim';
        }
    }
    
    static Kategori apiMetindenUret(String apiMetni){
        switch(apiMetni.toLowerCase().trim()){
            case 'electronics':
                return Kategori.elektronik;
            case 'jewelery':
                return Kategori.taki;
            case "men's clothing":
                return Kategori.taki;
            case "women's clothing":
                return Kategori.kadinGiyim;
            default:
                return Kategori.elektronik;
        }
    }
}