#!/bin/bash

# DMG Creator Folder PT-BR - Script de Instalação Automática
# Criado por Max.1974

set -e

echo "🚀 DMG Creator Folder PT-BR - Instalação Automática"
echo "=================================================="
echo

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para imprimir mensagens coloridas
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar se estamos no macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "Este script é apenas para macOS!"
    exit 1
fi

# Verificar se o Terminal tem permissões
print_status "Verificando permissões..."

# Criar diretório de instalação
INSTALL_DIR="$HOME/DMG-Creator-Folder-PT-BR"
print_status "Criando diretório de instalação: $INSTALL_DIR"

# Remover instalação anterior se existir
if [ -d "$INSTALL_DIR" ]; then
    print_warning "Removendo instalação anterior..."
    rm -rf "$INSTALL_DIR"
fi

mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Baixar arquivos do repositório
print_status "Baixando arquivos do repositório..."

# Baixar criar-dmg.sh
curl -fsSL https://raw.githubusercontent.com/maxpicelli/DMG-Creator-Folder-PT-BR/main/criar-dmg.sh -o criar-dmg.sh

# Baixar build-folder-app.sh
curl -fsSL https://raw.githubusercontent.com/maxpicelli/DMG-Creator-Folder-PT-BR/main/build-folder-app.sh -o build-folder-app.sh

# Baixar DMG-icon.icns (se existir)
curl -fsSL https://raw.githubusercontent.com/maxpicelli/DMG-Creator-Folder-PT-BR/main/DMG-icon.icns -o DMG-icon.icns 2>/dev/null || {
    print_warning "Ícone personalizado não encontrado, usando ícone padrão"
    rm -f DMG-icon.icns
}

# Baixar README.md
curl -fsSL https://raw.githubusercontent.com/maxpicelli/DMG-Creator-Folder-PT-BR/main/README.md -o README.md

# Tornar scripts executáveis
chmod +x criar-dmg.sh
chmod +x build-folder-app.sh

print_success "Arquivos baixados com sucesso!"

# Criar o aplicativo
print_status "Criando aplicativo DMG-Creator-Folder-PT-BR.app..."
./build-folder-app.sh

if [ -d "DMG-Creator-Folder-PT-BR.app" ]; then
    print_success "Aplicativo criado com sucesso!"
    
    # Mover para Applications (opcional)
    print_status "Deseja instalar o aplicativo na pasta Applications? (y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        if [ -d "/Applications/DMG-Creator-Folder-PT-BR.app" ]; then
            print_warning "Removendo versão anterior do Applications..."
            rm -rf "/Applications/DMG-Creator-Folder-PT-BR.app"
        fi
        
        cp -R "DMG-Creator-Folder-PT-BR.app" "/Applications/"
        print_success "Aplicativo instalado em /Applications/DMG-Creator-Folder-PT-BR.app"
        
        # Criar atalho na área de trabalho
        ln -sf "/Applications/DMG-Creator-Folder-PT-BR.app" "$HOME/Desktop/DMG-Creator-Folder-PT-BR.app"
        print_success "Atalho criado na área de trabalho!"
    fi
else
    print_error "Falha ao criar o aplicativo!"
    exit 1
fi

echo
echo "🎉 Instalação Concluída!"
echo "========================"
echo
echo "📱 Para usar o DMG Creator Folder PT-BR:"
echo "   1. Abra o aplicativo DMG-Creator-Folder-PT-BR.app"
echo "   2. Ou execute: open \"$INSTALL_DIR/DMG-Creator-Folder-PT-BR.app\""
echo
echo "📁 Arquivos instalados em: $INSTALL_DIR"
echo "🔗 Repositório: https://github.com/maxpicelli/DMG-Creator-Folder-PT-BR"
echo

# Abrir a pasta de instalação no Finder
print_status "Abrindo pasta de instalação no Finder..."
print_status "Caminho: $INSTALL_DIR"

# Verificar se a pasta existe
if [ -d "$INSTALL_DIR" ]; then
    print_status "Pasta encontrada, abrindo..."
    # Usar osascript para abrir no Finder (mais confiável)
    osascript -e "tell application \"Finder\" to open POSIX file \"$INSTALL_DIR\"" 2>/dev/null || open "$INSTALL_DIR"
    sleep 1
    print_success "Pasta aberta no Finder!"
else
    print_error "Pasta não encontrada: $INSTALL_DIR"
    print_status "Tentando abrir pasta atual..."
    osascript -e "tell application \"Finder\" to open POSIX file \"$PWD\"" 2>/dev/null || open "$PWD"
fi

print_success "Obrigado por usar o DMG Creator Folder PT-BR! 🚀"
