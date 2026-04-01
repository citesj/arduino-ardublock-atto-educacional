# Script de Instalação Completa: Arduino IDE 1.8.19 + ArduBlock para Windows
# Autor: Eduardo "duZÃO" Henrique
# Data: 01/04/2026

# Força o PowerShell a entender caracteres especiais na leitura e na saída
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$ErrorActionPreference = "Stop"
$SUCCESS_MARK = "[OK]"

Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host "=== Instalação Completa: Arduino IDE + ArduBlock =====" -ForegroundColor Cyan
Write-Host "=======================================================" -ForegroundColor Cyan

# 1. Verificação de Privilégios
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Este script requer privilégios de Administrador. Execute o PowerShell como Administrador."
    exit
}

# Definição de Variáveis de Caminho
$arduinoDownloadUrl = "https://downloads.arduino.cc/arduino-1.8.19-windows.exe"
$ardublockZipUrl = "https://github.com/citesj/arduino-ardublock-atto-educacional/raw/refs/heads/main/tools.zip"
$tempDir = Join-Path $env:TEMP "ArduinoInstall"
$arduinoInstallDir = "C:\Program Files (x86)\Arduino"
$sketchbookPath = Join-Path $env:USERPROFILE "Documents\Arduino"
$preferencesPath = Join-Path $env:LOCALAPPDATA "Arduino15\preferences.txt"

if (-not (Test-Path $tempDir)) { New-Item -ItemType Directory -Path $tempDir }

Write-Host "`n[1/4] Verificando instalações prévias..." -ForegroundColor Yellow
$arduinoInstalled = Test-Path (Join-Path $arduinoInstallDir "arduino.exe")

# 2. Instalação do Arduino IDE
if (-not $arduinoInstalled) {
    Write-Host "-> Baixando Arduino IDE 1.8.19..." -ForegroundColor White
    $exePath = Join-Path $tempDir "arduino-setup.exe"
    Invoke-WebRequest -Uri $arduinoDownloadUrl -OutFile $exePath

    Write-Host "-> Iniciando instalação silenciosa..." -ForegroundColor White
    Start-Process -FilePath $exePath -ArgumentList "/S" -Wait
    Write-Host "$SUCCESS_MARK Arduino IDE instalado com sucesso." -ForegroundColor Green
} else {
    Write-Host "$SUCCESS_MARK Arduino IDE já detectado em $arduinoInstallDir." -ForegroundColor Green
}

# 3. Instalação do ArduBlock
Write-Host "`n[2/4] Configurando ArduBlock..." -ForegroundColor Yellow
if (-not (Test-Path $sketchbookPath)) { New-Item -ItemType Directory -Path $sketchbookPath }

$toolsZipPath = Join-Path $tempDir "tools.zip"
Write-Host "-> Baixando ArduBlock..." -ForegroundColor White
Invoke-WebRequest -Uri $ardublockZipUrl -OutFile $toolsZipPath

Write-Host "-> Descompactando ferramentas no Sketchbook..." -ForegroundColor White
Expand-Archive -Path $toolsZipPath -DestinationPath $sketchbookPath -Force
Write-Host "$SUCCESS_MARK ArduBlock configurado em $sketchbookPath\tools" -ForegroundColor Green

# 4. Configuração de Preferências (preferences.txt)
Write-Host "`n[3/4] Aplicando configurações padrão (Placa/Idioma)..." -ForegroundColor Yellow
$configDir = Split-Path $preferencesPath
if (-not (Test-Path $configDir)) { New-Item -ItemType Directory -Path $configDir }

# Backup se já existir
if (Test-Path $preferencesPath) {
    Copy-Item $preferencesPath "$preferencesPath.bak" -Force
}

$prefsContent = @"
board=diecimila
target_package=arduino
target_platform=avr
custom_cpu=diecimila_atmega328
editor.languages.current=pt_BR
editor.linenumbers=true
sketchbook.path=$($sketchbookPath.Replace('\', '\\'))
last.ide.version=1.8.19
"@

Set-Content -Path $preferencesPath -Value $prefsContent -Encoding ASCII
Write-Host "$SUCCESS_MARK Preferências aplicadas: Arduino Duemilanove/ATmega328P e Idioma PT-BR." -ForegroundColor Green

# 5. Limpeza
Write-Host "`n[4/4] Limpando arquivos temporários..." -ForegroundColor Yellow
Remove-Item $tempDir -Recurse -Force
Write-Host "$SUCCESS_MARK Limpeza concluída." -ForegroundColor Green

Write-Host "`n=======================================================" -ForegroundColor Cyan
Write-Host "       INSTALAÇÃO CONCLUÍDA COM SUCESSO!       " -ForegroundColor Cyan
Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host "Como usar:"
Write-Host "1. Abra o Arduino IDE no menu Iniciar."
Write-Host "2. Vá em Ferramentas -> ArduBlock para iniciar a interface de blocos."