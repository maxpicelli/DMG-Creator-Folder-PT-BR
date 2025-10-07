#!/bin/bash

# Obter o diretório do script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Nome do aplicativo
APP_NAME="DMG-Creator-Folder-PT-BR.app"
APP_PATH="$SCRIPT_DIR/$APP_NAME"

echo "=== Criando DMG-Creator-Folder-PT-BR.app ==="

# Verificar se os arquivos necessários existem
if [ ! -f "$SCRIPT_DIR/criar-dmg.sh" ]; then
    echo "❌ Erro: criar-dmg.sh não encontrado em $SCRIPT_DIR"
    exit 1
fi

# Remover app anterior se existir
rm -rf "$APP_PATH"

# Criar estrutura do app
mkdir -p "$APP_PATH/Contents/"{MacOS,Resources}

# Criar Info.plist
cat > "$APP_PATH/Contents/Info.plist" << 'EOL'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>launcher.sh</string>
    <key>CFBundleIdentifier</key>
    <string>com.maxpicelli.dmgcreatorfolder</string>
    <key>CFBundleName</key>
    <string>DMG Creator Folder PT-BR</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.10</string>
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.utilities</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>CFBundleIconFile</key>
    <string>DMG-icon</string>
</dict>
</plist>
EOL

# Criar launcher script que abre o Terminal
cat > "$APP_PATH/Contents/MacOS/launcher.sh" << 'EOL'
#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
osascript -e "
tell application \"Terminal\"
    activate
    do script \"clear; \\\"$DIR/criar-dmg.sh\\\"; exit\"
end tell"
EOL

# Copiar o script principal
cp "$SCRIPT_DIR/criar-dmg.sh" "$APP_PATH/Contents/MacOS/criar-dmg.sh"

# Copiar o ícone para Resources (se existir)
if [ -f "$SCRIPT_DIR/DMG-icon.icns" ]; then
    cp "$SCRIPT_DIR/DMG-icon.icns" "$APP_PATH/Contents/Resources/"
else
    echo "⚠️  Aviso: DMG-icon.icns não encontrado, usando ícone padrão"
fi

# Tornar os scripts executáveis
chmod +x "$APP_PATH/Contents/MacOS/launcher.sh"
chmod +x "$APP_PATH/Contents/MacOS/criar-dmg.sh"

echo "✅ App criado em: $APP_PATH"
echo "Você pode abrir o app com: open \"$APP_PATH\""
