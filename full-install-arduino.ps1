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
$arduinoDownloadUrl = "https://github.com/citesj/arduino-ardublock-atto-educacional/releases/download/v.1.0.2/arduino-1.8.19-windows.exe"
$ardublockZipUrl = "https://github.com/citesj/arduino-ardublock-atto-educacional/releases/download/v.1.0.2/ardublock.zip"
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
board=uno
target_package=arduino
target_platform=avr
editor.languages.current=pt_BR
editor.linenumbers=true
sketchbook.path=$($sketchbookPath.Replace('\', '\\'))
last.ide.version=1.8.19
"@

Set-Content -Path $preferencesPath -Value $prefsContent -Encoding ASCII
Write-Host "$SUCCESS_MARK Preferências aplicadas: Arduino Uno/ATmega328P e Idioma PT-BR." -ForegroundColor Green

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
# SIG # Begin signature block
# MIIHNgYJKoZIhvcNAQcCoIIHJzCCByMCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBf6Rafth7Xy1pC
# pjJqNlZRxlD466zAtxcWJspdGXgW9KCCBCAwggQcMIIChKADAgECAhAXGcataqcC
# nEqThA7Qpi+gMA0GCSqGSIb3DQEBCwUAMCYxJDAiBgNVBAMMG0FyZHVpbm8gQXJk
# dUJsb2NrIEluc3RhbGxlcjAeFw0yNjEwMjExNDIzNDJaFw0yOTEwMjExNDMzNDJa
# MCYxJDAiBgNVBAMMG0FyZHVpbm8gQXJkdUJsb2NrIEluc3RhbGxlcjCCAaIwDQYJ
# KoZIhvcNAQEBBQADggGPADCCAYoCggGBAMTKuUUbO8bGBq9QwlQLxdUMbA6ojeK0
# LHSC2MpwD7ndbmGPZeB9kXCHy5fqPEj5jw5mGYvoFfD8aHoMezYDM7IBWvRV2icU
# e87+RqsvPHNQVwdG+RssMjoB06pbFelYmFCO3jsHPgREYepxNCqel//ZVimzunS0
# y1N8Oh1yMhQ0xaBUQOqma7I0cYHMqhQvcT9KCyllMa8CTDflT+tjS8n0JKZmmqbi
# dUpzh1S3DMXslW7vlE/90gletg9sHNRIym1glN8Dpzpzx/i2mbsvpF77WeYfFHVh
# U4ySZegS2WNHuB/msnPBFYMhujif6xAKHMM3VDRMCAgIpBo44Z+DStb1oEyWSkyy
# p0Bs4I/UoIKwkDum2iQdLiTZkKd2Mohn9DfT0aDcTxEvObyvmQr90y7gd7Jl7vtD
# 4MDAVRh64IfjUAQA5NIdpbc/rc5tkH9kg6oOe/lOrCQK/CI/cECNykNLP0/DIxgU
# fIdSjTz9ttMkluv/HApc0ZpPLk68M8BFpQIDAQABo0YwRDAOBgNVHQ8BAf8EBAMC
# B4AwEwYDVR0lBAwwCgYIKwYBBQUHAwMwHQYDVR0OBBYEFPfPGLmdxXPhTFl0ecn9
# /gm06q6eMA0GCSqGSIb3DQEBCwUAA4IBgQCaz0vaG9rZ5rb4wy1KK5R86aeRvxJm
# CJmZFiKa9eDjnV7cfhPe+AHqoEJx7bBxT+BuM16fUEbwABXu7uSdP5RvpR6TeINq
# IuyT5Sh6TQoBouib0OJvQvjdQ7OJQ1XTeN6rfJQNKWdYpEVZZTgDFvicPGVwIaVn
# 609FafupRzU8wDwMRv155HRB7GtGG1FtY0/EceE1PQt9e9Vpkfne+R5YLsiwsxhs
# X+BHdsSvA2yX61OEXko1wyCswGajhz1pgJOMrh+7zlxykcLnMy/LLBCpvB2JEjbR
# G+IXNwFBtvYVmBBrMWoRWKMeT44V7chMBUFEbaXgsA3Bct2pTipRcNKw7KEnoGre
# Mpy9L0uQ/FXXnX/A/24YVLXxpTsLJn8cT/y0IX7cCX3iRhPj8S/3XoHU1snekyBF
# Qtdx1QpQSvqJSn/tR6Z95zrOYOhbZXr4bgZSI0syEVdO+5bz8xp+ev2tmdZzPd57
# OGBDqlFs5L/bmzUAQRpTX6rI1qV24YpWkYUxggJsMIICaAIBATA6MCYxJDAiBgNV
# BAMMG0FyZHVpbm8gQXJkdUJsb2NrIEluc3RhbGxlcgIQFxnGrWqnApxKk4QO0KYv
# oDANBglghkgBZQMEAgEFAKCBhDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkG
# CSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEE
# AYI3AgEVMC8GCSqGSIb3DQEJBDEiBCC8yJ7TJ9bXL5C75/+Glh9VIq7B2eNs2seH
# MRVWIMCYEDANBgkqhkiG9w0BAQEFAASCAYAQphqryloMKRR+kNSvEk4N5d+MLmpt
# tYkvCZWhfV4NCZT6LHcmc47UK8Ola5+8lLoirUB7VTLbxx2SGr0vOzsxYC1pTRv1
# C871+UBO5Zj1Bbf3P+tYOR0XoECVtWsbVtZxwa/wtffpTPmL1RGqGLcT6Ws6BqQr
# FaRWhD1r/PB8sPn7mIFC+nkwt+I64/9TsOVYuFI9kSkA/tyTFFDSmb2ha2BgW5yO
# cAulQco2BK3eW4YYx6IW8iUaQPcfa/LYIalVYG1WhKW9i6AiyG7mKbHtsKXvKLdw
# r0yAA46PvtGifYMMLxivhjbw/xE0726CKRyuhZOxXF7/xTnf8GXvLRzHYS7bsKlW
# XPWENuCOlF3ec8JK81ArWMmyHQQS1kql7hjGE9P6J8TQItY9R+8woqkEyNz/l9Bj
# NW3d7pWA785nUhBfzY89EjSJtUh60v7nrqTg6EnKNrfRt7APSz8xI8noCV9sYqj3
# J6c5xnTQISOWpGkgQTnhJckjIvi9+EZv98o=
# SIG # End signature block
