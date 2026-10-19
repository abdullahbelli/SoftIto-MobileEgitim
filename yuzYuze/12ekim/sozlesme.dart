//soyutlama Abstractşon kavramı

//1.adım (sözleşmeler) contract
/*
abstract class AuthReposity {
  Future<String> login(String email, String password);
  Future<void> logout();
  bool get isAuth;
}

class FirebaseAuthReposity implements AuthReposity {
  @override
  Future<String> login(String email, String password) async {
    //gercek Fşrebase sdk çarpısı
    return "firebase_token_xyz_123";
  }

  @override
  Future<void> logout() async {
    //Fşrebase Logout
  }

  @override
  bool get isAuth => true;
}

//test ve offline simülasyonu
class MockAuthReposity implements AuthReposity {
  @override
  Future<String> login(String email, String password) async {
    await Future.delayed(Duration(seconds: 1));
    return "mock_token_abc_789";
  }

  @override
  Future<void> logout() async {}

  @override
  bool get isAuth => false;

}


mixin Logger {
  void log(String msg) => print("LOG:$msg");
}

mixin Analytics{
  void log(String msg) => print("ANALIZ: $msg");
}

class PaymentsService with Logger,Analytics{
  void pay(){ //asenkron çalışmadığı için analiz logu ezer en son analiz ekrana yazar
    log("Ödeme yapıldı");
  }


}

abstract class BaseWidget {
  
}
//sadece BaseWidget ve alt sınıflarda kullanılabilir
mixin LifeLogger on BaseWidget{
  void logInit()=>print("Widget başlatıldı");
}



extension StringValidator on String{
  bool get isValidEmail{
    final emailRegex=RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(this);
  }

  String toCapitalize(){
    if (isEmpty) return this;
      return this[0].toUpperCase() + substring(1);
  }
}


//Kullanımı

void main(){
  String email="belliabdullah@gmail.com";
  if (email.isValidEmail) {
    print("Geçerli Eposta");
  }else{
    print("Geçersiz Eposta");
  }
}


abstract class Identifiable{
  String get id;

}
// T tipi Mutlaka IDENTİFİABLE arayğzünü uygulamak ZORUNDADIR
class GenericCache<T extends Identifiable>{
  final Map<String,T> _storage={};

  void save (T item){
    _storage[item.id] =item;
    print("ıd:${item.id} önbelleğe alındı");
  }

  T? getById(String id) => _storage[id];//tip güvenliğini buradan sağlamış oldu
}
*/

import 'dart:async';

void main(){
  print("1.Senkron başladı");
  scheduleMicrotask((){
    print("2. Task oluştu (Vip kuyruk)");
  });

  Future((){ //bir sözlşeme olarak çalıştırıyor veri tipinin ne olduğundan bağımsız çalıştırır , işlem sürüyor mu hata mı aldın sonucu mu aldın hepsini takp eder
    print("3.standart Event Kuyruğu");
  });
  Future.microtask((){
    print("4. Future olan microtask çalıştı");
  });

  print("5. Senkron kod tamamlandı");
}