1.Widget Tree
* İskelet
* İmmutable (değişmez)
* Çok ucuz (hafif)
* saniyede 60-120 kez ÇÖPE atılıp yeniden üretilir (120fps)
*Ekranda çizim yapmaz
* Sadece şablon sunar

2. Element Tree
* Yönteici & yaşayan iskeletin omurgası
* Mutable (değişken) durumu ve referansı hafızada canlı tutardeğişebilir
* widget ile render object arasındaki koordinatördür(organizasyonu sunar)

//canUpdate
//her widgetın bir keyi olmak zorunda
static bool canUpdate(Widget oldWidget,Widget newWidget){
    return oldWidget.runtimeType=new.Widget.runtimeType && oldWidget.key==newWidget.key;
}

State Yaşam Döngüsü

* StatefulWidget : immutable (olarak değişmez) her rebuildte yenden oluşturulur

* State : mutable(duurmu saklar) rebuild sırasında çöpe atıllmaz element tarafından devam eder

Eğer iki sınıf birleşik olsaydı her rebuild esnasında kullanııcı girdileri sayaçlar controllerlar vb. sıfırlanırdı. 