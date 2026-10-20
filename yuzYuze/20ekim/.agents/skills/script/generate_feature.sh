#!/usr/bin/env bash
set -euo pipefail

# Filizora - Güvenli Feature Klasörü Oluşturucu
# Kullanım: bash .agents/skills/script/generate_feature.sh <özellik_adi> [hedef_kok_dizin]

if [ $# -lt 1 ]; then
  echo "Hata: Özellik adı belirtilmelidir!"
  echo "Kullanım: $0 <özellik_adi> [hedef_kok_dizin]"
  echo "Örnek: $0 mentor_matching"
  exit 1
fi

FEATURE_NAME="$1"

# Özellik adı kontrolü: yalnızca küçük harf, rakam ve alt çizgi (snake_case)
if ! [[ "$FEATURE_NAME" =~ ^[a-z][a-z0-9_]*$ ]]; then
  echo "Hata: Geçersiz özellik adı '$FEATURE_NAME'!"
  echo "Özellik adı yalnızca küçük harfle başlamalı, küçük harf, rakam ve alt çizgi içermelidir (snake_case)."
  exit 1
fi

# Hedef kök dizini belirle
TARGET_BASE="${2:-}"
if [ -z "$TARGET_BASE" ]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  if [ -d "$SCRIPT_DIR/../../filizora/lib/features" ]; then
    TARGET_BASE="$SCRIPT_DIR/../../filizora/lib/features"
  elif [ -d "filizora/lib/features" ]; then
    TARGET_BASE="filizora/lib/features"
  elif [ -d "lib/features" ]; then
    TARGET_BASE="lib/features"
  else
    TARGET_BASE="./$FEATURE_NAME"
  fi
fi

FEATURE_DIR="$TARGET_BASE/$FEATURE_NAME"

# Eğer hedef yol bir dosyaysa üzerine yazma ve iptal et
if [ -f "$FEATURE_DIR" ]; then
  echo "Hata: '$FEATURE_DIR' adında bir dosya zaten var! Güvenlik nedeniyle işlem durduruldu."
  exit 1
fi

# Hedef klasör zaten varsa kullanıcıya bildir
if [ -d "$FEATURE_DIR" ]; then
  echo "Bilgi: '$FEATURE_DIR' klasörü zaten mevcut. Var olan dosyaların üzerine yazılmıyor."
  echo "Klasör yapısı doğrulanıyor:"
  mkdir -p "$FEATURE_DIR/controller"
  mkdir -p "$FEATURE_DIR/models"
  mkdir -p "$FEATURE_DIR/view"
  mkdir -p "$FEATURE_DIR/widget"
  echo "✓ Özellik klasörleri hazır: $FEATURE_DIR"
  exit 0
fi

echo "Özellik oluşturuluyor: $FEATURE_NAME"
echo "Hedef dizin: $FEATURE_DIR"

# Gerekli 4 alt klasörü oluştur
mkdir -p "$FEATURE_DIR/controller"
mkdir -p "$FEATURE_DIR/models"
mkdir -p "$FEATURE_DIR/view"
mkdir -p "$FEATURE_DIR/widget"

echo "✓ Başarıyla oluşturulan alt klasörler:"
echo "  - $FEATURE_DIR/controller/"
echo "  - $FEATURE_DIR/models/"
echo "  - $FEATURE_DIR/view/"
echo "  - $FEATURE_DIR/widget/"
echo "Tamamlandı."
