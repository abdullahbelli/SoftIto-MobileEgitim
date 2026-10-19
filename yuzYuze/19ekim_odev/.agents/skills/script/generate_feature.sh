#!/usr/bin/env bash

# ==============================================================================
# Feature Generator Script for Dijital Günlüğüm
# ==============================================================================
# Kullanım:
#   bash script/generate_feature.sh <feature_name>
# Örnek:
#   bash script/generate_feature.sh mood_tracker
# ==============================================================================

set -e

# 1. Parametre Kontrolü
if [ -z "$1" ]; then
  echo "Hata: Feature adı belirtilmedi."
  echo "Kullanım: bash generate_feature.sh <feature_name>"
  echo "Örnek: bash generate_feature.sh mood_tracker"
  exit 1
fi

FEATURE_NAME="$1"

# 2. İsim Doğrulama (snake_case olmalı: küçük harf, rakam ve alt çizgi, harfle başlamalı)
if [[ ! "$FEATURE_NAME" =~ ^[a-z][a-z0-9_]*$ ]]; then
  echo "Hata: Geçersiz feature adı: '$FEATURE_NAME'"
  echo "Feature adı sadece küçük harf, rakam ve alt çizgi içermeli, harf ile başlamalıdır."
  echo "Örnek: mood_tracker, voice_notes, settings"
  exit 1
fi

# 3. Proje Kök Dizinini Bulma
# Script nerede çalıştırılırsa çalıştırılsın '19ekim_odev' veya 'project.md' bulunan kök dizini tespit eder
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$SCRIPT_DIR"

while [ "$ROOT_DIR" != "/" ] && [ ! -f "$ROOT_DIR/project.md" ] && [ ! -f "$ROOT_DIR/pubspec.yaml" ]; do
  PARENT="$(dirname "$ROOT_DIR")"
  if [ "$PARENT" = "$ROOT_DIR" ]; then
    break
  fi
  ROOT_DIR="$PARENT"
done

if [ ! -f "$ROOT_DIR/project.md" ] && [ ! -f "$ROOT_DIR/pubspec.yaml" ]; then
  # Fallback olarak script'in iki üst dizini
  ROOT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
fi

echo "Proje kök dizini: $ROOT_DIR"

FEATURE_DIR="$ROOT_DIR/lib/features/$FEATURE_NAME"

# PascalCase dönüşümü (Örn: mood_tracker -> MoodTracker)
to_pascal_case() {
  local input="$1"
  local result=""
  IFS='_' read -ra PARTS <<< "$input"
  for part in "${PARTS[@]}"; do
    first_char="$(echo "${part:0:1}" | tr '[:lower:]' '[:upper:]')"
    rest="$(echo "${part:1}" | tr '[:upper:]' '[:lower:]')"
    result="${result}${first_char}${rest}"
  done
  echo "$result"
}

PASCAL_NAME=$(to_pascal_case "$FEATURE_NAME")

echo "Feature oluşturuluyor: $FEATURE_NAME ($PASCAL_NAME)"

# Klasörleri oluştur
mkdir -p "$FEATURE_DIR/controllers"
mkdir -p "$FEATURE_DIR/models"
mkdir -p "$FEATURE_DIR/view"
mkdir -p "$FEATURE_DIR/widgets"

MODEL_FILE="$FEATURE_DIR/models/${FEATURE_NAME}_model.dart"
CONTROLLER_FILE="$FEATURE_DIR/controllers/${FEATURE_NAME}_controller.dart"
VIEW_FILE="$FEATURE_DIR/view/${FEATURE_NAME}_view.dart"
CARD_FILE="$FEATURE_DIR/widgets/${FEATURE_NAME}_card.dart"

# 4. Dosya Şablonları

# MODEL
if [ -f "$MODEL_FILE" ]; then
  echo "Uyarı: $MODEL_FILE zaten mevcut, üzerine yazılmadı."
else
  cat <<EOF > "$MODEL_FILE"
import 'package:flutter/foundation.dart';

@immutable
class ${PASCAL_NAME}Model {
  final String id;
  final DateTime createdAt;
  final String title;

  const ${PASCAL_NAME}Model({
    required this.id,
    required this.createdAt,
    required this.title,
  });

  ${PASCAL_NAME}Model copyWith({
    String? id,
    DateTime? createdAt,
    String? title,
  }) {
    return ${PASCAL_NAME}Model(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      title: title ?? this.title,
    );
  }

  factory ${PASCAL_NAME}Model.fromJson(Map<String, dynamic> json) {
    return ${PASCAL_NAME}Model(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      title: json['title'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'title': title,
    };
  }
}
EOF
  echo "Oluşturuldu: $MODEL_FILE"
fi

# CONTROLLER
if [ -f "$CONTROLLER_FILE" ]; then
  echo "Uyarı: $CONTROLLER_FILE zaten mevcut, üzerine yazılmadı."
else
  cat <<EOF > "$CONTROLLER_FILE"
import 'package:flutter/foundation.dart';
import '../models/${FEATURE_NAME}_model.dart';

class ${PASCAL_NAME}Controller {
  final ValueNotifier<List<${PASCAL_NAME}Model>> items =
      ValueNotifier<List<${PASCAL_NAME}Model>>([]);

  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  void addItem(${PASCAL_NAME}Model item) {
    items.value = [...items.value, item];
  }

  void removeItem(String id) {
    items.value = items.value.where((element) => element.id != id).toList();
  }

  void dispose() {
    items.dispose();
    isLoading.dispose();
  }
}
EOF
  echo "Oluşturuldu: $CONTROLLER_FILE"
fi

# CARD WIDGET
if [ -f "$CARD_FILE" ]; then
  echo "Uyarı: $CARD_FILE zaten mevcut, üzerine yazılmadı."
else
  cat <<EOF > "$CARD_FILE"
import 'package:flutter/material.dart';
import '../models/${FEATURE_NAME}_model.dart';

class ${PASCAL_NAME}Card extends StatelessWidget {
  final ${PASCAL_NAME}Model item;
  final VoidCallback? onTap;

  const ${PASCAL_NAME}Card({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(item.title),
        subtitle: Text(item.createdAt.toString()),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
EOF
  echo "Oluşturuldu: $CARD_FILE"
fi

# VIEW
if [ -f "$VIEW_FILE" ]; then
  echo "Uyarı: $VIEW_FILE zaten mevcut, üzerine yazılmadı."
else
  cat <<EOF > "$VIEW_FILE"
import 'package:flutter/material.dart';
import '../controllers/${FEATURE_NAME}_controller.dart';
import '../models/${FEATURE_NAME}_model.dart';
import '../widgets/${FEATURE_NAME}_card.dart';

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
        title: const Text('${PASCAL_NAME}'),
      ),
      body: ValueListenableBuilder<List<${PASCAL_NAME}Model>>(
        valueListenable: controller.items,
        builder: (context, items, _) {
          if (items.isEmpty) {
            return const Center(
              child: Text('Kayıt bulunamadı.'),
            );
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return ${PASCAL_NAME}Card(item: items[index]);
            },
          );
        },
      ),
    );
  }
}
EOF
  echo "Oluşturuldu: $VIEW_FILE"
fi

echo "Feature oluşturma tamamlandı: $FEATURE_NAME"
