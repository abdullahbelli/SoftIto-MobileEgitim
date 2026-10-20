import 'package:flutter/material.dart'; // InheritedWidget ve BuildContext için Flutter paketi.

import '../../data/repositories/app_repository.dart'; // Paylaşılacak veri deposu sınıfı.
import '../theme/theme_controller.dart'; // Paylaşılacak tema yöneticisi sınıfı.

/// Rotiva uygulama durumunu (repository) ve temasını (themeController) widget ağacına aktaran InheritedWidget.
/// Flutter'da 'Provider' paketinin temelini oluşturan yerleşik mekanizmadır.
/// Bu sayede ağacın herhangi bir derinliğindeki widget, 'RotivaScope.of(context)' diyerek
/// parametre taşımak (prop drilling) zorunda kalmadan merkezi verilere ulaşabilir.
class RotivaScope extends InheritedWidget {
  final AppRepository
  repository; // Tüm ekranların erişebileceği merkezi veri deposu
  final ThemeController themeController; // Açık/koyu tema kontrolörü

  const RotivaScope({
    super.key,
    required this.repository,
    required this.themeController,
    required super.child, // Altındaki widget ağacı
  });

  /// Widget ağacından geriye doğru giderek en yakın RotivaScope örneğini bulan statik metot.
  /// Örnek kullanım: 'final repo = RotivaScope.of(context).repository;'
  static RotivaScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<RotivaScope>();
    assert(
      scope != null,
      'RotivaScope widget ağacında bulunamadı. Lütfen üst widgetları kontrol ediniz.',
    );
    return scope!;
  }

  /// Eğer repository veya themeController referansı değişirse, bu widget'a abone olan alt widget'ları uyarır.
  @override
  bool updateShouldNotify(RotivaScope oldWidget) {
    return repository != oldWidget.repository ||
        themeController != oldWidget.themeController;
  }
}
