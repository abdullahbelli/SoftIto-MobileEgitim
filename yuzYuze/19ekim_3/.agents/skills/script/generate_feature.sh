#!/usr/bin/env bash
# ==============================================================================
# Script: generate_feature.sh
# Proje: Susadım (Fitness Su ve Kalori Takip Uygulaması)
# Standart: project.md & .agents/skills/SKILL.md (flutter-feature-scaffold)
# Açıklama: Yeni bir özellik (feature) modülü için Clean UI, ValueNotifier mimarisi,
#           <40 satır build kuralına uygun parçalı widget'lar ve birim test
#           iskeletini otomatik olarak oluşturur.
# ==============================================================================

set -euo pipefail

# Renk tanımlamaları (Neon & Dark Obsidian Paleti Uyumlu)
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Kullanım kılavuzu
show_help() {
    echo -e "${CYAN}${BOLD}Susadım v1 - Özellik İskeleti Oluşturucu (Feature Scaffold)${NC}"
    echo -e "Kullanım: $0 <ozellik_adi> [hedef_dizin]"
    echo ""
    echo -e "Argümanlar:"
    echo -e "  ${BOLD}ozellik_adi${NC}   : Oluşturulacak özelliğin adı (snake_case, örn: water_tracker, workout, competition, profile)"
    echo -e "  ${BOLD}hedef_dizin${NC}   : (Opsiyonel) Flutter projesinin kök dizini. Belirtilmezse mevcut dizin kullanılır."
    echo ""
    echo -e "Seçenekler:"
    echo -e "  -h, --help       : Bu yardım mesajını gösterir."
    echo ""
    echo -e "Örnekler:"
    echo -e "  $0 workout"
    echo -e "  $0 water_tracker /Users/d1-11/Documents/GitHub/SoftIto-MobileEgitim/yuzYuze/19ekim_3/susadim"
    echo ""
    exit 0
}

# Parametre kontrolü
if [[ $# -eq 0 ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    show_help
fi

FEATURE_RAW="$1"
PROJECT_ROOT="${2:-.}"

# Özellik adını normalize et (snake_case)
FEATURE_NAME=$(echo "$FEATURE_RAW" | tr '[:upper:]' '[:lower:]' | tr '-' '_' | tr ' ' '_')

# PascalCase ve camelCase dönüşümleri
to_pascal_case() {
    echo "$1" | awk -F_ '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1' OFS=''
}

to_camel_case() {
    local pascal
    pascal=$(to_pascal_case "$1")
    echo "$(tr '[:upper:]' '[:lower:]' <<< "${pascal:0:1}")${pascal:1}"
}

PASCAL_NAME=$(to_pascal_case "$FEATURE_NAME")
CAMEL_NAME=$(to_camel_case "$FEATURE_NAME")

# Dizin yolları
FEATURE_DIR="${PROJECT_ROOT}/lib/features/${FEATURE_NAME}"
CONTROLLERS_DIR="${FEATURE_DIR}/controllers"
MODELS_DIR="${FEATURE_DIR}/models"
VIEW_DIR="${FEATURE_DIR}/view"
WIDGETS_DIR="${FEATURE_DIR}/widgets"
TEST_DIR="${PROJECT_ROOT}/test/features/${FEATURE_NAME}"

echo -e "${CYAN}============================================================${NC}"
echo -e "${BOLD}Susadım Özellik İskeleti Oluşturuluyor: ${GREEN}${FEATURE_NAME}${NC}"
echo -e "${CYAN}============================================================${NC}"
echo -e "Sınıf Adı      : ${BOLD}${PASCAL_NAME}${NC}"
echo -e "Hedef Dizin    : ${FEATURE_DIR}"
echo -e "Test Dizini    : ${TEST_DIR}"
echo ""

# Dizinleri oluştur
mkdir -p "${CONTROLLERS_DIR}" "${MODELS_DIR}" "${VIEW_DIR}" "${WIDGETS_DIR}" "${TEST_DIR}"

# ------------------------------------------------------------------------------
# 1. Model Dosyası: models/<feature_name>_model.dart
# ------------------------------------------------------------------------------
MODEL_FILE="${MODELS_DIR}/${FEATURE_NAME}_model.dart"
cat <<EOF > "${MODEL_FILE}"
import 'package:flutter/foundation.dart';

/// ${PASCAL_NAME} veri modeli (İmmutable mimari)
@immutable
class ${PASCAL_NAME}Model {
  final String id;
  final String title;
  final int value;
  final DateTime createdAt;

  const ${PASCAL_NAME}Model({
    required this.id,
    required this.title,
    required this.value,
    required this.createdAt,
  });

  /// Değişen alanları güncelleyerek yeni nesne kopyası üretir
  ${PASCAL_NAME}Model copyWith({
    String? id,
    String? title,
    int? value,
    DateTime? createdAt,
  }) {
    return ${PASCAL_NAME}Model(
      id: id ?? this.id,
      title: title ?? this.title,
      value: value ?? this.value,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// JSON haritasından model oluşturur
  factory ${PASCAL_NAME}Model.fromJson(Map<String, dynamic> json) {
    return ${PASCAL_NAME}Model(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      value: json['value'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  /// Modeli JSON haritasına dönüştürür
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'value': value,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ${PASCAL_NAME}Model &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          value == other.value;

  @override
  int get hashCode => id.hashCode ^ value.hashCode;
}
EOF

# ------------------------------------------------------------------------------
# 2. Controller Dosyası: controllers/<feature_name>_controller.dart
# ------------------------------------------------------------------------------
CONTROLLER_FILE="${CONTROLLERS_DIR}/${FEATURE_NAME}_controller.dart"
cat <<EOF > "${CONTROLLER_FILE}"
import 'package:flutter/foundation.dart';
import '../models/${FEATURE_NAME}_model.dart';

/// ${PASCAL_NAME} durum ve iş mantığı yöneticisi (ValueNotifier reaktif mimarisi)
class ${PASCAL_NAME}Controller {
  /// Birincil sayaç/seviye durumu
  final ValueNotifier<int> totalCount = ValueNotifier<int>(0);

  /// Liste geçmişi durumu
  final ValueNotifier<List<${PASCAL_NAME}Model>> items =
      ValueNotifier<List<${PASCAL_NAME}Model>>(<${PASCAL_NAME}Model>[]);

  /// Yükleniyor durumu
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  /// Hedef eşik değeri
  final int goalThreshold = 100;

  /// Değer artırma metodu
  void increment([int delta = 10]) {
    totalCount.value += delta;
    _recordItem('Değer artırıldı (+\$delta)', delta);
  }

  /// Durumu sıfırlama metodu
  void reset() {
    totalCount.value = 0;
    items.value = <${PASCAL_NAME}Model>[];
  }

  /// Yeni kayıt ekleme yardımcı metodu
  void _recordItem(String title, int value) {
    final newItem = ${PASCAL_NAME}Model(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      value: value,
      createdAt: DateTime.now(),
    );
    items.value = [newItem, ...items.value];
  }

  /// Bellek sızıntılarını önlemek için dinleyicileri serbest bırakır
  void dispose() {
    totalCount.dispose();
    items.dispose();
    isLoading.dispose();
  }
}
EOF

# ------------------------------------------------------------------------------
# 3. Parçalı Widget 1: widgets/<feature_name>_card.dart (<40 satır build kuralı)
# ------------------------------------------------------------------------------
CARD_FILE="${WIDGETS_DIR}/${FEATURE_NAME}_card.dart"
cat <<EOF > "${CARD_FILE}"
import 'package:flutter/material.dart';

/// ${PASCAL_NAME} özet kartı (<40 satır build metodu kuralına uygun)
class ${PASCAL_NAME}Card extends StatelessWidget {
  final int current;
  final int goal;

  const ${PASCAL_NAME}Card({
    super.key,
    required this.current,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (goal > 0) ? (current / goal).clamp(0.0, 1.0) : 0.0;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${PASCAL_NAME} Durumu',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: progress, minHeight: 8),
            const SizedBox(height: 8),
            Text(
              '\$current / \$goal (%\${(progress * 100).toInt()})',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
EOF

# ------------------------------------------------------------------------------
# 4. Parçalı Widget 2: widgets/<feature_name>_action_buttons.dart (<40 satır build)
# ------------------------------------------------------------------------------
ACTION_FILE="${WIDGETS_DIR}/${FEATURE_NAME}_action_buttons.dart"
cat <<EOF > "${ACTION_FILE}"
import 'package:flutter/material.dart';

/// ${PASCAL_NAME} hızlı aksiyon butonları (<40 satır build kuralına uygun)
class ${PASCAL_NAME}ActionButtons extends StatelessWidget {
  final VoidCallback onIncrement;
  final VoidCallback onReset;

  const ${PASCAL_NAME}ActionButtons({
    super.key,
    required this.onIncrement,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: onIncrement,
            icon: const Icon(Icons.add),
            label: const Text('Ekle (+10)'),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: onReset,
          icon: const Icon(Icons.refresh),
          label: const Text('Sıfırla'),
        ),
      ],
    );
  }
}
EOF

# ------------------------------------------------------------------------------
# 5. Görünüm (View) Dosyası: view/<feature_name>_view.dart (StatelessWidget)
# ------------------------------------------------------------------------------
VIEW_FILE="${VIEW_DIR}/${FEATURE_NAME}_view.dart"
cat <<EOF > "${VIEW_FILE}"
import 'package:flutter/material.dart';
import '../controllers/${FEATURE_NAME}_controller.dart';
import '../widgets/${FEATURE_NAME}_action_buttons.dart';
import '../widgets/${FEATURE_NAME}_card.dart';

/// ${PASCAL_NAME} Ana Görünümü (StatelessWidget + ValueNotifier mimarisi)
class ${PASCAL_NAME}View extends StatelessWidget {
  final ${PASCAL_NAME}Controller controller;

  const ${PASCAL_NAME}View({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('${PASCAL_NAME} Modülü'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ValueListenableBuilder<int>(
              valueListenable: controller.totalCount,
              builder: (context, count, _) {
                return ${PASCAL_NAME}Card(
                  current: count,
                  goal: controller.goalThreshold,
                );
              },
            ),
            const SizedBox(height: 16),
            ${PASCAL_NAME}ActionButtons(
              onIncrement: () => controller.increment(10),
              onReset: controller.reset,
            ),
          ],
        ),
      ),
    );
  }
}
EOF

# ------------------------------------------------------------------------------
# 6. Birim Test Dosyası: test/features/<feature_name>/<feature_name>_controller_test.dart
# ------------------------------------------------------------------------------
TEST_FILE="${TEST_DIR}/${FEATURE_NAME}_controller_test.dart"
cat <<EOF > "${TEST_FILE}"
import 'package:flutter_test/flutter_test.dart';
import 'package:susadim/features/${FEATURE_NAME}/controllers/${FEATURE_NAME}_controller.dart';

void main() {
  group('${PASCAL_NAME}Controller Testleri', () {
    late ${PASCAL_NAME}Controller controller;

    setUp(() {
      controller = ${PASCAL_NAME}Controller();
    });

    tearDown(() {
      controller.dispose();
    });

    test('Başlangıç durumu sıfır olmalıdır', () {
      expect(controller.totalCount.value, 0);
      expect(controller.items.value.isEmpty, true);
    });

    test('increment çağrıldığında sayaç artmalı ve kayıt eklenmelidir', () {
      controller.increment(15);
      expect(controller.totalCount.value, 15);
      expect(controller.items.value.length, 1);
      expect(controller.items.value.first.value, 15);
    });

    test('reset çağrıldığında durum sıfırlanmalıdır', () {
      controller.increment(20);
      controller.reset();
      expect(controller.totalCount.value, 0);
      expect(controller.items.value.isEmpty, true);
    });
  });
}
EOF

# Script çalıştırma yetkisi ver
chmod +x "${BASH_SOURCE[0]}"

echo -e "${GREEN}✓ Tüm dosyalar standartlara uygun olarak başarıyla oluşturuldu!${NC}"
echo ""
echo -e "${BOLD}Oluşturulan Dosyalar:${NC}"
echo -e "  [Model]      : ${MODEL_FILE}"
echo -e "  [Controller] : ${CONTROLLER_FILE}"
echo -e "  [Widget 1]   : ${CARD_FILE}"
echo -e "  [Widget 2]   : ${ACTION_FILE}"
echo -e "  [View]       : ${VIEW_FILE}"
echo -e "  [Unit Test]  : ${TEST_FILE}"
echo ""
echo -e "${YELLOW}${BOLD}Doğrulama Adımları:${NC}"
echo -e "1. Statik kod analizi yapın: ${BOLD}flutter analyze${NC} (0 hata, 0 uyarı şartı)"
echo -e "2. Testleri çalıştırın:       ${BOLD}flutter test ${TEST_FILE}${NC}"
echo -e "${CYAN}============================================================${NC}"
