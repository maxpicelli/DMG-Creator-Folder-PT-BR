#!/bin/bash

echo "=== Criador de DMG ==="
echo
echo "Arraste o arquivo ou pasta para o terminal e pressione Enter:"
read -r FILE_PATH

# Limpar aspas e tratar espaços
FILE_PATH=$(echo "$FILE_PATH" | sed 's/^"\(.*\)"$/\1/' | sed 's/\\ / /g')

# Verificar se o arquivo existe
if [ ! -e "$FILE_PATH" ]; then
    echo "Erro: Arquivo ou pasta não encontrado: $FILE_PATH"
    exit 1
fi

APP_NAME=$(basename "$FILE_PATH")
echo "Item selecionado: $APP_NAME"

echo
echo "Nome para a DMG (sem extensão):"
read -r DMG_NAME

if [ -z "$DMG_NAME" ]; then
    DMG_NAME="${APP_NAME%.*}"
fi

VOLUME_NAME="$DMG_NAME"
BUILD_DIR="/tmp/dmg_build"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Copiar conteúdo: se for pasta, copiar o conteúdo; se for arquivo, copiar o próprio
if [ -d "$FILE_PATH" ]; then
    # Copia o conteúdo da pasta (arquivos individuais)
    cp -R "$FILE_PATH"/* "$BUILD_DIR/" 2>/dev/null || {
        # Se a pasta estiver vazia, copiar a pasta inteira
        cp -R "$FILE_PATH" "$BUILD_DIR/"
    }
else
    cp -R "$FILE_PATH" "$BUILD_DIR/"
fi

# Criar atalho para a pasta Applications
ln -s /Applications "$BUILD_DIR/Applications"

# Detectar itens
APP_ITEM=""
README_ITEM=""
OTHER_ITEMS=()

for item in "$BUILD_DIR"/*; do
    name=$(basename "$item")
    if [[ "$name" == *.app ]]; then
        APP_ITEM="$name"
    elif [[ "$name" == *README* ]]; then
        README_ITEM="$name"
    elif [[ "$name" != "Applications" ]]; then
        OTHER_ITEMS+=("$name")
    fi
done

# Criar DMG temporária
TEMP_DMG="/tmp/${DMG_NAME}-temp.dmg"
hdiutil create -volname "$VOLUME_NAME" -srcfolder "$BUILD_DIR" -ov -format UDRW "$TEMP_DMG"

# Montar a DMG (garantir que não exista volume montado com o mesmo nome)
if [ -d "/Volumes/$VOLUME_NAME" ]; then
    hdiutil detach "/Volumes/$VOLUME_NAME" 2>/dev/null || true
    sleep 1
fi
hdiutil attach "$TEMP_DMG" -mountpoint "/Volumes/$VOLUME_NAME"
sleep 2

# Gerar AppleScript para posicionar os ícones
SCRIPT="tell application \"Finder\"
    tell disk \"$VOLUME_NAME\"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set the bounds of container window to {300, 150, 850, 500}
        set viewOptions to the icon view options of container window
        set arrangement of viewOptions to not arranged
        set icon size of viewOptions to 128"

# Posicionar ícones horizontalmente em ordem fixa (centralizados)
x=150

if [ -n "$APP_ITEM" ]; then
    SCRIPT+="
        try
            set position of item \"$APP_ITEM\" of container window to {$x, 200}
        end try"
    x=$((x + 250))
fi

SCRIPT+="
    try
        set position of item \"Applications\" of container window to {$x, 200}
    end try"
x=$((x + 160))

if [ -n "$README_ITEM" ]; then
    SCRIPT+="
        try
            set position of item \"$README_ITEM\" of container window to {$x, 200}
        end try"
    x=$((x + 160))
fi

for item in "${OTHER_ITEMS[@]}"; do
    SCRIPT+="
        try
            set position of item \"$item\" of container window to {$x, 200}
        end try"
    x=$((x + 160))
done

SCRIPT+="
        update without registering applications
        delay 2
        close
        delay 2
        open
        delay 2
    end tell
end tell"

# Executar AppleScript
osascript -e "$SCRIPT"

echo "Pressione Enter depois que a janela da DMG aparecer corretamente..."
read

# Desmontar
hdiutil detach "/Volumes/$VOLUME_NAME"

# Converter para DMG final
mkdir -p "$HOME/Desktop"
FINAL_DMG="$HOME/Desktop/${DMG_NAME}.dmg"
hdiutil convert "$TEMP_DMG" -format UDZO -o "$FINAL_DMG"

# Limpar arquivos temporários
rm -rf "$BUILD_DIR"
rm "$TEMP_DMG"

echo
echo "✅ DMG criada em: $FINAL_DMG"