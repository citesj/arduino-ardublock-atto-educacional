#!/bin/bash

# Script completo para instalação do Arduino IDE 1.8.19 + ArduBlock no Linux
# Autor: Eduardo "duZÃO" Henrique
# Data: 21/10/2026

echo "======================================================="
echo "=== Instalação Completa: Arduino IDE + ArduBlock ====="
echo "======================================================="
echo

# Verificar se a variável HOME está definida
if [ -z "$HOME" ]; then
    echo "Erro: Variável HOME não está definida."
    exit 1
fi

die() {
    echo "Erro: $*" >&2
    exit 1
}

for command in sudo wget tar unzip awk grep mktemp date chmod cp groups id mkdir rm mv cat; do
    if ! command -v "$command" >/dev/null 2>&1; then
        die "Comando necessário não encontrado: $command"
    fi
done

TEMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/arduino-install.XXXXXX") || die "Não foi possível criar o diretório temporário."
cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT
trap 'exit 1' HUP INT TERM

# Verificar se o usuário tem privilégios sudo
if ! sudo -n true 2>/dev/null; then
    echo "Este script requer privilégios sudo. Você será solicitado a inserir sua senha."
    echo
fi

echo "============================================="
echo "=== VERIFICAÇÃO DE INSTALAÇÕES PRÉVIAS ====="
echo "============================================="
echo

# Variáveis de controle
ARDUINO_INSTALLED=false
ARDUBLOCK_INSTALLED=false
ARDUINO_DIR="$HOME/Arduino"
ARDUINO_INSTALL_DIR="/opt/arduino-1.8.19"

# Verificar se o Arduino IDE já está instalado
echo "Verificando instalação do Arduino IDE..."
if [ -x "$ARDUINO_INSTALL_DIR/arduino" ]; then
    echo "✅ Arduino IDE 1.8.19 já está instalado em /opt/arduino-1.8.19"
    ARDUINO_INSTALLED=true
else
    echo "❌ Arduino IDE não encontrado. Será instalado."
fi

echo

# Verificar se o ArduBlock já está instalado
echo "Verificando instalação do ArduBlock..."
if [ -f "$ARDUINO_DIR/tools/ArduBlockTool/tool/ardublock-all.jar" ]; then
    echo "✅ ArduBlock já está instalado em $ARDUINO_DIR/tools"
    ARDUBLOCK_INSTALLED=true
else
    echo "❌ ArduBlock não encontrado. Será instalado."
fi

echo

# Instalar Arduino IDE apenas se não estiver instalado
if [ "$ARDUINO_INSTALLED" = false ]; then
    echo "========================================="
    echo "=== PARTE 1: INSTALAÇÃO ARDUINO IDE ==="
    echo "========================================="
    echo

    # Baixar o Arduino IDE
    echo "1. Baixando o Arduino IDE..."
    ARDUINO_ARCHIVE="$TEMP_DIR/arduino-1.8.19-linux64.tar.xz"
    if ! wget -O "$ARDUINO_ARCHIVE" https://github.com/citesj/arduino-ardublock-atto-educacional/releases/download/v.1.0.2/arduino-1.8.19-linux64.tar.xz; then
        die "Falha no download do Arduino IDE."
    fi

    if [ ! -s "$ARDUINO_ARCHIVE" ] || ! tar -tJf "$ARDUINO_ARCHIVE" >/dev/null 2>&1; then
        die "O arquivo baixado do Arduino IDE está vazio ou inválido."
    fi

    echo "Download do Arduino IDE concluído!"
    echo

    # Descompactar o TAR.XZ para /opt
    echo "2. Descompactando o arquivo TAR.XZ para /opt..."
    if ! sudo tar -C /opt -xf "$ARDUINO_ARCHIVE"; then
        die "Falha na descompactação do arquivo TAR.XZ para /opt."
    fi
    if [ ! -d "$ARDUINO_INSTALL_DIR" ] || [ ! -x "$ARDUINO_INSTALL_DIR/arduino" ] || [ ! -x "$ARDUINO_INSTALL_DIR/install.sh" ]; then
        die "O pacote não criou os arquivos esperados em $ARDUINO_INSTALL_DIR."
    fi

    echo "Descompactação concluída!"
    echo

    # Entrar na pasta descompactada
    echo "4. Entrando na pasta descompactada..."
    if ! cd "$ARDUINO_INSTALL_DIR"; then
        die "Não foi possível acessar $ARDUINO_INSTALL_DIR."
    fi

    # Mostrar diretório atual
    echo "Diretório atual:"
    pwd
    echo

    # Executar o instalador
    echo "5. Executando o instalador do Arduino IDE..."
    if ! sudo ./install.sh; then
        die "Falha durante a instalação do Arduino IDE."
    fi
    if [ ! -x "$ARDUINO_INSTALL_DIR/arduino" ]; then
        die "O executável do Arduino IDE não foi encontrado após a instalação."
    fi

    echo "Arduino IDE instalado com sucesso!"
    echo

    # O arquivo baixado será removido pela rotina de limpeza ao final.
    echo "6. O arquivo temporário do Arduino IDE será removido ao final."

    echo
else
    echo "========================================"
    echo "=== ARDUINO IDE JÁ ESTÁ INSTALADO ====="
    echo "========================================"
    echo "Pulando instalação do Arduino IDE..."
    echo
fi

# Instalar ArduBlock apenas se não estiver instalado
if [ "$ARDUBLOCK_INSTALLED" = false ]; then
    echo "======================================"
    echo "=== PARTE 2: INSTALAÇÃO ARDUBLOCK ==="
    echo "======================================"
    echo

    echo "Diretório do usuário: $HOME"
    echo "Diretório Arduino: $ARDUINO_DIR"
    echo

    # Verificar se o diretório Arduino existe
    if [ ! -d "$ARDUINO_DIR" ]; then
        echo "Aviso: O diretório $ARDUINO_DIR não existe."
        echo "Criando o diretório..."
        if ! mkdir -p "$ARDUINO_DIR"; then
            die "Não foi possível criar o diretório $ARDUINO_DIR."
        fi
        echo "Diretório criado com sucesso!"
    fi

    # Entrar na pasta Arduino
    echo "7. Entrando na pasta Arduino..."
    if ! cd "$ARDUINO_DIR"; then
        die "Não foi possível acessar o diretório $ARDUINO_DIR."
    fi

    echo "Diretório atual: $(pwd)"
    echo

    # Baixar o ArduBlock
    echo "8. Baixando o ArduBlock..."
    ARDUBLOCK_ARCHIVE="$TEMP_DIR/tools.zip"
    if ! wget -O "$ARDUBLOCK_ARCHIVE" https://attoeducacional.com.br/wp-content/uploads/2019/04/tools.zip; then
        die "Falha no download do ArduBlock."
    fi
    if [ ! -s "$ARDUBLOCK_ARCHIVE" ] || ! unzip -tq "$ARDUBLOCK_ARCHIVE" >/dev/null 2>&1; then
        die "O arquivo baixado do ArduBlock está vazio ou inválido."
    fi

    echo "Download do ArduBlock concluído!"
    echo

    # Descompactar o ArduBlock
    echo "9. Descompactando o ArduBlock..."
    if ! unzip -oq "$ARDUBLOCK_ARCHIVE" -d "$ARDUINO_DIR"; then
        die "Falha na descompactação do ArduBlock."
    fi
    if [ ! -f "$ARDUINO_DIR/tools/ArduBlockTool/tool/ardublock-all.jar" ]; then
        die "O pacote não criou o arquivo esperado do ArduBlock."
    fi

    echo "Descompactação do ArduBlock concluída!"
    echo

    echo "10. O arquivo temporário do ArduBlock será removido ao final."
    echo
else
    echo "===================================="
    echo "=== ARDUBLOCK JÁ ESTÁ INSTALADO ==="
    echo "===================================="
    echo "Pulando instalação do ArduBlock..."
    echo
fi

echo "================================================="
echo "=== PARTE 3: CONFIGURAÇÕES PADRÃO DO ARDUINO ==="
echo "================================================="
echo

# Definir o diretório de configurações do Arduino
ARDUINO_CONFIG_DIR="$HOME/.arduino15"
PREFERENCES_FILE="$ARDUINO_CONFIG_DIR/preferences.txt"

echo "11. Configurando preferências padrão do Arduino IDE..."

# Criar o diretório de configurações se não existir
if ! mkdir -p "$ARDUINO_CONFIG_DIR"; then
    die "Não foi possível criar o diretório de configurações $ARDUINO_CONFIG_DIR."
fi

# Fazer backup e preservar preferências já definidas pelo usuário.
if [ -f "$PREFERENCES_FILE" ]; then
    echo "Arquivo de preferências já existe. Criando backup..."
    BACKUP_FILE=$(mktemp "$PREFERENCES_FILE.backup.$(date +%Y%m%d_%H%M%S).XXXXXX") || die "Não foi possível criar o backup das preferências."
    if ! cp -p "$PREFERENCES_FILE" "$BACKUP_FILE"; then
        rm -f "$BACKUP_FILE"
        die "Não foi possível copiar o arquivo de preferências para o backup."
    fi
    echo "Backup criado: $BACKUP_FILE"
fi

# Aplicar valores padrão somente às preferências ainda inexistentes.
echo "Aplicando configurações padrão..."
PREFERENCES_DEFAULTS="$TEMP_DIR/preferences.defaults"
PREFERENCES_TEMP=$(mktemp "$ARDUINO_CONFIG_DIR/preferences.txt.XXXXXX") || die "Não foi possível criar um arquivo temporário de preferências."
if ! cat > "$PREFERENCES_DEFAULTS" << EOF
board=uno
target_package=arduino
target_platform=avr
editor.languages.current=pt_BR
editor.tabs.size=2
editor.font=Monospaced,plain,12
console=true
console.lines=4
editor.linenumbers=true
upload.verify=true
build.verbose=false
upload.verbose=false
runtime.preserve-temp-files=false
network.proxy_type=0
last.ide.version=1.8.19
last.hardware.refresh=0
editor.window.width.default=500
editor.window.height.default=600
editor.window.width.min=400
editor.window.height.min=290
build.path=/tmp/arduino_build_temp
build.warn_data_percentage=75
sketchbook.path=$HOME/Arduino
EOF
then
    rm -f "$PREFERENCES_TEMP"
    die "Não foi possível preparar os valores padrão das preferências."
fi

if [ -f "$PREFERENCES_FILE" ]; then
    if ! awk -F= '
        FNR == NR {
            key = substr($0, 1, index($0, "=") - 1)
            defaults[key] = $0
            order[++count] = key
            next
        }
        {
            separator = index($0, "=")
            if (separator > 0) {
                key = substr($0, 1, separator - 1)
                if (key in defaults) {
                    seen[key] = 1
                }
            }
            print
        }
        END {
            for (i = 1; i <= count; i++) {
                key = order[i]
                if (!(key in seen)) {
                    print defaults[key]
                }
            }
        }
    ' "$PREFERENCES_DEFAULTS" "$PREFERENCES_FILE" > "$PREFERENCES_TEMP"; then
        rm -f "$PREFERENCES_TEMP"
        die "Não foi possível mesclar as preferências existentes."
    fi
else
    if ! cp "$PREFERENCES_DEFAULTS" "$PREFERENCES_TEMP"; then
        rm -f "$PREFERENCES_TEMP"
        die "Não foi possível preparar as preferências padrão."
    fi
fi
if ! chmod 644 "$PREFERENCES_TEMP"; then
    rm -f "$PREFERENCES_TEMP"
    die "Não foi possível definir as permissões das preferências."
fi
if ! mv "$PREFERENCES_TEMP" "$PREFERENCES_FILE"; then
    rm -f "$PREFERENCES_TEMP"
    die "Não foi possível salvar o arquivo de preferências."
fi
echo "✅ Preferências verificadas; valores existentes foram preservados."
echo

# Adicionar usuário ao grupo dialout para acesso à porta serial
echo "12. Configurando permissões para porta serial..."
USER_NAME="${SUDO_USER:-${USER:-}}"
if [ -z "$USER_NAME" ]; then
    die "Não foi possível identificar o usuário para configurar o grupo dialout."
fi
USER_GROUPS=$(id -nG "$USER_NAME" 2>/dev/null) || die "Não foi possível verificar os grupos do usuário $USER_NAME."
if printf '%s\n' "$USER_GROUPS" | grep -qw dialout; then
    echo "✅ Usuário já está no grupo dialout."
else
    echo "Adicionando usuário ao grupo dialout..."
    if ! sudo usermod -a -G dialout "$USER_NAME"; then
        die "Não foi possível adicionar $USER_NAME ao grupo dialout. A instalação ficou incompleta."
    fi
    echo "✅ Usuário adicionado ao grupo dialout."
    echo "⚠️  IMPORTANTE: Você precisa fazer logout e login novamente"
    echo "    para que as permissões da porta serial tenham efeito."
fi

echo

echo "======================================================="
echo "=== INSTALAÇÃO COMPLETA REALIZADA COM SUCESSO! ======="
echo "======================================================="
echo

# Resumo do que foi feito
echo "RESUMO DA EXECUÇÃO:"
if [ "$ARDUINO_INSTALLED" = true ]; then
    echo "✅ Arduino IDE 1.8.19 (já instalado): /opt/arduino-1.8.19"
else
    echo "✅ Arduino IDE 1.8.19 (instalado agora): /opt/arduino-1.8.19"
fi

if [ "$ARDUBLOCK_INSTALLED" = true ]; then
    echo "✅ ArduBlock (já instalado): $ARDUINO_DIR"
else
    echo "✅ ArduBlock (instalado agora): $ARDUINO_DIR"
fi

echo "✅ Preferências verificadas (valores existentes preservados): $PREFERENCES_FILE"
echo
echo "VALORES PADRÃO DEFINIDOS QUANDO AUSENTES:"
echo "🔧 Placa: Arduino Uno"
echo "🔧 Idioma: Português Brasil"
echo
echo "COMO USAR:"
echo "1. Arduino IDE:"
echo "   - Encontre no menu de aplicações do seu sistema"
echo "   - Ou execute: /opt/arduino-1.8.19/arduino"
echo

echo "2. ArduBlock:"
echo "   - Abra o Arduino IDE"
echo "   - Vá em Ferramentas (Tools) → ArduBlock"
echo "   - O ArduBlock aparecerá no menu"
echo

echo "OBSERVAÇÕES IMPORTANTES:"
echo "⚠️  Se você foi adicionado ao grupo dialout, faça logout e login"
echo "    novamente para que as permissões da porta serial funcionem."
echo

echo "⚠️  As configurações podem ser alteradas posteriormente através"
echo "    do menu Arquivo → Preferências no Arduino IDE"
echo

echo "Instalação concluída! 🎉"
