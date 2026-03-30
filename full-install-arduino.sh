#!/bin/bash

# Script completo para instalação do Arduino IDE 1.8.9 + ArduBlock no Linux
# Autor: Script gerado automaticamente
# Data: $(date)

echo "======================================================="
echo "=== Instalação Completa: Arduino IDE + ArduBlock ====="
echo "======================================================="
echo

# Verificar se o usuário tem privilégios sudo
if ! sudo -n true 2>/dev/null; then
    echo "Este script requer privilégios sudo. Você será solicitado a inserir sua senha."
    echo
fi

# Verificar se a variável HOME está definida
if [ -z "$HOME" ]; then
    echo "Erro: Variável HOME não está definida."
    exit 1
fi

echo "============================================="
echo "=== VERIFICAÇÃO DE INSTALAÇÕES PRÉVIAS ====="
echo "============================================="
echo

# Variáveis de controle
ARDUINO_INSTALLED=false
ARDUBLOCK_INSTALLED=false
ARDUINO_DIR="$HOME/Arduino"

# Verificar se o Arduino IDE já está instalado
echo "Verificando instalação do Arduino IDE..."
if [ -d "/opt/arduino-1.8.9" ] && [ -f "/opt/arduino-1.8.9/arduino" ]; then
    echo "✅ Arduino IDE 1.8.9 já está instalado em /opt/arduino-1.8.9"
    ARDUINO_INSTALLED=true
else
    echo "❌ Arduino IDE não encontrado. Será instalado."
fi

echo

# Verificar se o ArduBlock já está instalado
echo "Verificando instalação do ArduBlock..."
if [ -d "$ARDUINO_DIR/tools" ] && [ -d "$ARDUINO_DIR/tools/ArduBlockTool" ]; then
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
    wget https://downloads.arduino.cc/arduino-1.8.19-linux64.tar.xz

    # Verificar se o download foi bem-sucedido
    if [ $? -ne 0 ]; then
        echo "Erro: Falha no download do Arduino IDE."
        exit 1
    fi

    echo "Download do Arduino IDE concluído!"
    echo

    echo "Primeira descompactação concluída!"
    echo

    # Descompatação (TAR) para /opt
    echo "2. Descompactando para /opt..."
    sudo tar -C /opt -xf arduino-1.8.9-linux64.tar.xz

    # Verificar se a descompactação foi bem-sucedida
    if [ $? -ne 0 ]; then
        echo "Erro: Falha na descompactação do arquivo TAR."
        exit 1
    fi

    echo "Segunda descompactação concluída!"
    echo

    # Entrar na pasta descompactada
    echo "3. Entrando na pasta descompactada..."
    cd /opt/arduino-1.8.9

    # Mostrar diretório atual
    echo "Diretório atual:"
    pwd
    echo

    # Executar o instalador
    echo "4. Executando o instalador do Arduino IDE..."
    sudo ./install.sh

    # Verificar se a instalação foi bem-sucedida
    if [ $? -ne 0 ]; then
        echo "Erro durante a instalação do Arduino IDE."
        exit 1
    fi

    echo "Arduino IDE instalado com sucesso!"
    echo

    # Voltar para o diretório inicial e limpar arquivos do Arduino IDE
    echo "5. Limpando arquivos temporários do Arduino IDE..."
    cd - > /dev/null

    if [ -f "arduino-1.8.9-linux64.tar.zip" ]; then
        rm arduino-1.8.9-linux64.tar.zip
        echo "Arquivo arduino-1.8.9-linux64.tar.zip removido."
    fi

    if [ -f "arduino-1.8.9-linux64.tar.xz" ]; then
        rm arduino-1.8.9-linux64.tar.xz
        echo "Arquivo arduino-1.8.9-linux64.tar.xz removido."
    fi

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
        mkdir -p "$ARDUINO_DIR"
        
        if [ $? -eq 0 ]; then
            echo "Diretório criado com sucesso!"
        else
            echo "Erro: Não foi possível criar o diretório."
            exit 1
        fi
    fi

    # Entrar na pasta Arduino
    echo "6. Entrando na pasta Arduino..."
    cd "$ARDUINO_DIR"

    # Verificar se conseguiu entrar na pasta
    if [ $? -ne 0 ]; then
        echo "Erro: Não foi possível acessar o diretório $ARDUINO_DIR"
        exit 1
    fi

    echo "Diretório atual: $(pwd)"
    echo

    # Baixar o ArduBlock
    echo "7. Baixando o ArduBlock..."
    wget https://github.com/citesj/arduino-ardublock-atto-educacional/raw/refs/heads/main/tools.zip

    # Verificar se o download foi bem-sucedido
    if [ $? -ne 0 ]; then
        echo "Erro: Falha no download do ArduBlock."
        exit 1
    fi

    echo "Download do ArduBlock concluído!"
    echo

    # Descompactar o ArduBlock
    echo "8. Descompactando o ArduBlock..."
    unzip tools.zip

    # Verificar se a descompactação foi bem-sucedida
    if [ $? -ne 0 ]; then
        echo "Erro: Falha na descompactação do ArduBlock."
        exit 1
    fi

    echo "Descompactação do ArduBlock concluída!"
    echo

    # Limpar arquivo zip do ArduBlock
    echo "9. Limpando arquivos temporários do ArduBlock..."
    if [ -f "tools.zip" ]; then
        rm tools.zip
        echo "Arquivo tools.zip removido."
    fi

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

echo "10. Configurando preferências padrão do Arduino IDE..."

# Criar o diretório de configurações se não existir
if [ ! -d "$ARDUINO_CONFIG_DIR" ]; then
    echo "Criando diretório de configurações..."
    mkdir -p "$ARDUINO_CONFIG_DIR"
fi

# Verificar se já existe um arquivo de preferências
if [ -f "$PREFERENCES_FILE" ]; then
    echo "Arquivo de preferências já existe. Criando backup..."
    cp "$PREFERENCES_FILE" "$PREFERENCES_FILE.backup.$(date +%Y%m%d_%H%M%S)"
    echo "Backup criado: $PREFERENCES_FILE.backup.$(date +%Y%m%d_%H%M%S)"
fi

# Criar arquivo de preferências com as configurações solicitadas
echo "Aplicando configurações padrão..."
cat > "$PREFERENCES_FILE" << EOF
# Configurações padrão do Arduino IDE
# Gerado automaticamente pelo script de instalação

# Placa padrão: Arduino Duemilanove or Diecimila
board=diecimila

# Processador padrão: ATmega328P
target_package=arduino
target_platform=avr
custom_cpu=diecimila_atmega328

# Porta padrão
serial.port=/dev/ttyUSB0

# Idioma padrão: Português Brasil
editor.languages.current=pt_BR

# Outras configurações úteis
editor.tabs.size=2
editor.font=Monospaced,plain,12
console=true
console.lines=4
editor.linenumbers=true
upload.verify=true
build.verbose=false
upload.verbose=false
runtime.preserve-temp-files=false

# Configurações de rede
network.proxy_type=0

# Última versão checada
last.ide.version=1.8.9
last.hardware.refresh=0

# Editor
editor.window.width.default=500
editor.window.height.default=600
editor.window.width.min=400
editor.window.height.min=290

# Configurações de compilação
build.path=/tmp/arduino_build_temp
build.warn_data_percentage=75

# Sketchbook
sketchbook.path=$HOME/Arduino

EOF

# Verificar se o arquivo foi criado
if [ $? -eq 0 ]; then
    echo "✅ Arquivo de preferências criado com sucesso!"
else
    echo "❌ Erro ao criar arquivo de preferências."
    exit 1
fi

# Definir permissões adequadas
chmod 644 "$PREFERENCES_FILE"

echo "✅ Configurações padrão aplicadas:"
echo "   - Placa: Arduino Duemilanove or Diecimila"
echo "   - Processador: ATmega328P"
echo "   - Porta: /dev/ttyUSB0"
echo "   - Idioma: Português Brasil (pt_BR)"
echo

# Adicionar usuário ao grupo dialout para acesso à porta serial
echo "11. Configurando permissões para porta serial..."
if groups $USER | grep -q dialout; then
    echo "✅ Usuário já está no grupo dialout."
else
    echo "Adicionando usuário ao grupo dialout..."
    sudo usermod -a -G dialout $USER
    if [ $? -eq 0 ]; then
        echo "✅ Usuário adicionado ao grupo dialout."
        echo "⚠️  IMPORTANTE: Você precisa fazer logout e login novamente"
        echo "    para que as permissões da porta serial tenham efeito."
    else
        echo "❌ Erro ao adicionar usuário ao grupo dialout."
    fi
fi

echo

echo "======================================================="
echo "=== INSTALAÇÃO COMPLETA REALIZADA COM SUCESSO! ====="
echo "======================================================="
echo

# Resumo do que foi feito
echo "RESUMO DA EXECUÇÃO:"
if [ "$ARDUINO_INSTALLED" = true ]; then
    echo "✅ Arduino IDE 1.8.9 (já instalado): /opt/arduino-1.8.9"
else
    echo "✅ Arduino IDE 1.8.9 (instalado agora): /opt/arduino-1.8.9"
fi

if [ "$ARDUBLOCK_INSTALLED" = true ]; then
    echo "✅ ArduBlock (já instalado): $ARDUINO_DIR"
else
    echo "✅ ArduBlock (instalado agora): $ARDUINO_DIR"
fi

echo "✅ Configurações padrão aplicadas: $PREFERENCES_FILE"
echo
echo "CONFIGURAÇÕES PADRÃO APLICADAS:"
echo "🔧 Placa: Arduino Duemilanove or Diecimila"
echo "🔧 Processador: ATmega328P"
echo "🔧 Porta: /dev/ttyUSB0"
echo "🔧 Idioma: Português Brasil"
echo
echo "COMO USAR:"
echo "1. Arduino IDE:"
echo "   - Encontre no menu de aplicações do seu sistema"
echo "   - Ou execute: /opt/arduino-1.8.9/arduino"
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
echo "⚠️  Se a porta /dev/ttyUSB0 não existir, você pode alterá-la no"
echo "    Arduino IDE em: Ferramentas → Porta"
echo
echo "⚠️  As configurações podem ser alteradas posteriormente através"
echo "    do menu Arquivo → Preferências no Arduino IDE"
echo
echo "Instalação concluída! 🎉"