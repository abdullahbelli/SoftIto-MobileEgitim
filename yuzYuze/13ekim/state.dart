/*1. createState()

2. mounted == true

3. initState()

4. didChangeDependencies() (widget değişimlerinde tetiklenir(Thema.of(context) bu adımda güvenli olarak çalıştırılır))

5. build(BuildContext context) (UI bölümü burada döndürür (ASLA İÇİNDE ASENKRON İŞLEM YAPILMAZ))

6. didUpdateWidget(oldWidget) (üst ebeveyn yeni bir parametre yolladığında çalışır)

7. deactivite() (ağaçtan geçici olarak kopma) 

8. dispose() (kalıcı olarak kapatma ( controller.dispose  Stream.cancel) vb. burada yapılır)

9. mounted == false

*/