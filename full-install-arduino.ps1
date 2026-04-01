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
# SIG # Begin signature block
# MIIb1wYJKoZIhvcNAQcCoIIbyDCCG8QCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUoPJOcZXODkoBRiux/QbwSQ3Y
# iDGgghZGMIIDCDCCAfCgAwIBAgIQHEGhrFoqXblNzsEKuIWU3DANBgkqhkiG9w0B
# AQsFADAcMRowGAYDVQQDDBFNZXVTY3JpcHRBc3NpbmFkbzAeFw0yNjA0MDExNzE3
# MjNaFw0yODA0MDExNzI3MjNaMBwxGjAYBgNVBAMMEU1ldVNjcmlwdEFzc2luYWRv
# MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAncBvU5cp/8ZuaBhYznP3
# 5zRe/i2Qfj2SU5LFZwG9wtKM94c+/lSp2HE8cMdzmPoaEB+7Q2q8vvKpe2BpgDrK
# oKi9q8GvH3FcCGZhSRwCNjSDkVCB5LEWd60E7edXVl1O3Z1Sf5nUvF2eeo5UX7Ze
# UttCd82PurKtTy5ERzl0aUkU6S2jRj19O816IURnCQc0rJ/fcrW08aWNvZNxrIjA
# tqEZpMsnLOAxHYwUDeQbM4RJL1EXBJL9H+sBVK7Kp/6F94IxPtuu3ctaIsgzPdfE
# QvvUj7Ey2lZmtMrsecOvJTMdRZ6CDGqDguUq4bzWrmncTBpa2rE2NrdgbcFu70Lt
# 2QIDAQABo0YwRDAOBgNVHQ8BAf8EBAMCB4AwEwYDVR0lBAwwCgYIKwYBBQUHAwMw
# HQYDVR0OBBYEFLb0rAaO0C2Q1589ia9rTamif4CjMA0GCSqGSIb3DQEBCwUAA4IB
# AQArS5o6COCNSyrwyupcXWQ2dDXr9iilqE7vGOP1ZDNvIbn9keqS3aUqfBxXwkFK
# alf0YSPMHuDCXyXdopr70l+VV/TRX+t1e8KAOTTcDKern/y3Oydz/fmCqHMCI2RA
# Ka25F0oM1EHfIeyKhwio3QCTSAn/7OQiyHWqptev7oCEG6EbSjAwjkqfQ/Ye1zF9
# BBUWJRwk/j9uNhtGtBgqj7pca4XIBstjzVjCvfyEepB5gjQbh+XM22MNC/1DZtfq
# sgylCBRCYVCpdVahBaoXrXMZg95StM5GqvRYqh4W1VGUEelS1rz7v7+8BqvzOFUX
# CWJ6u2PcIea+8Y5qtFaum8YnMIIFjTCCBHWgAwIBAgIQDpsYjvnQLefv21DiCEAY
# WjANBgkqhkiG9w0BAQwFADBlMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNl
# cnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdp
# Q2VydCBBc3N1cmVkIElEIFJvb3QgQ0EwHhcNMjIwODAxMDAwMDAwWhcNMzExMTA5
# MjM1OTU5WjBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkw
# FwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdpQ2VydCBUcnVz
# dGVkIFJvb3QgRzQwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC/5pBz
# aN675F1KPDAiMGkz7MKnJS7JIT3yithZwuEppz1Yq3aaza57G4QNxDAf8xukOBbr
# VsaXbR2rsnnyyhHS5F/WBTxSD1Ifxp4VpX6+n6lXFllVcq9ok3DCsrp1mWpzMpTR
# EEQQLt+C8weE5nQ7bXHiLQwb7iDVySAdYyktzuxeTsiT+CFhmzTrBcZe7FsavOvJ
# z82sNEBfsXpm7nfISKhmV1efVFiODCu3T6cw2Vbuyntd463JT17lNecxy9qTXtyO
# j4DatpGYQJB5w3jHtrHEtWoYOAMQjdjUN6QuBX2I9YI+EJFwq1WCQTLX2wRzKm6R
# AXwhTNS8rhsDdV14Ztk6MUSaM0C/CNdaSaTC5qmgZ92kJ7yhTzm1EVgX9yRcRo9k
# 98FpiHaYdj1ZXUJ2h4mXaXpI8OCiEhtmmnTK3kse5w5jrubU75KSOp493ADkRSWJ
# tppEGSt+wJS00mFt6zPZxd9LBADMfRyVw4/3IbKyEbe7f/LVjHAsQWCqsWMYRJUa
# dmJ+9oCw++hkpjPRiQfhvbfmQ6QYuKZ3AeEPlAwhHbJUKSWJbOUOUlFHdL4mrLZB
# dd56rF+NP8m800ERElvlEFDrMcXKchYiCd98THU/Y+whX8QgUWtvsauGi0/C1kVf
# nSD8oR7FwI+isX4KJpn15GkvmB0t9dmpsh3lGwIDAQABo4IBOjCCATYwDwYDVR0T
# AQH/BAUwAwEB/zAdBgNVHQ4EFgQU7NfjgtJxXWRM3y5nP+e6mK4cD08wHwYDVR0j
# BBgwFoAUReuir/SSy4IxLVGLp6chnfNtyA8wDgYDVR0PAQH/BAQDAgGGMHkGCCsG
# AQUFBwEBBG0wazAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29t
# MEMGCCsGAQUFBzAChjdodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNl
# cnRBc3N1cmVkSURSb290Q0EuY3J0MEUGA1UdHwQ+MDwwOqA4oDaGNGh0dHA6Ly9j
# cmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcmwwEQYD
# VR0gBAowCDAGBgRVHSAAMA0GCSqGSIb3DQEBDAUAA4IBAQBwoL9DXFXnOF+go3Qb
# PbYW1/e/Vwe9mqyhhyzshV6pGrsi+IcaaVQi7aSId229GhT0E0p6Ly23OO/0/4C5
# +KH38nLeJLxSA8hO0Cre+i1Wz/n096wwepqLsl7Uz9FDRJtDIeuWcqFItJnLnU+n
# BgMTdydE1Od/6Fmo8L8vC6bp8jQ87PcDx4eo0kxAGTVGamlUsLihVo7spNU96LHc
# /RzY9HdaXFSMb++hUD38dglohJ9vytsgjTVgHAIDyyCwrFigDkBjxZgiwbJZ9VVr
# zyerbHbObyMt9H5xaiNrIv8SuFQtJ37YOtnwtoeW/VvRXKwYw02fc7cBqZ9Xql4o
# 4rmUMIIGtDCCBJygAwIBAgIQDcesVwX/IZkuQEMiDDpJhjANBgkqhkiG9w0BAQsF
# ADBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQL
# ExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdpQ2VydCBUcnVzdGVkIFJv
# b3QgRzQwHhcNMjUwNTA3MDAwMDAwWhcNMzgwMTE0MjM1OTU5WjBpMQswCQYDVQQG
# EwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xQTA/BgNVBAMTOERpZ2lDZXJ0
# IFRydXN0ZWQgRzQgVGltZVN0YW1waW5nIFJTQTQwOTYgU0hBMjU2IDIwMjUgQ0Ex
# MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAtHgx0wqYQXK+PEbAHKx1
# 26NGaHS0URedTa2NDZS1mZaDLFTtQ2oRjzUXMmxCqvkbsDpz4aH+qbxeLho8I6jY
# 3xL1IusLopuW2qftJYJaDNs1+JH7Z+QdSKWM06qchUP+AbdJgMQB3h2DZ0Mal5kY
# p77jYMVQXSZH++0trj6Ao+xh/AS7sQRuQL37QXbDhAktVJMQbzIBHYJBYgzWIjk8
# eDrYhXDEpKk7RdoX0M980EpLtlrNyHw0Xm+nt5pnYJU3Gmq6bNMI1I7Gb5IBZK4i
# vbVCiZv7PNBYqHEpNVWC2ZQ8BbfnFRQVESYOszFI2Wv82wnJRfN20VRS3hpLgIR4
# hjzL0hpoYGk81coWJ+KdPvMvaB0WkE/2qHxJ0ucS638ZxqU14lDnki7CcoKCz6eu
# m5A19WZQHkqUJfdkDjHkccpL6uoG8pbF0LJAQQZxst7VvwDDjAmSFTUms+wV/FbW
# Bqi7fTJnjq3hj0XbQcd8hjj/q8d6ylgxCZSKi17yVp2NL+cnT6Toy+rN+nM8M7Ln
# LqCrO2JP3oW//1sfuZDKiDEb1AQ8es9Xr/u6bDTnYCTKIsDq1BtmXUqEG1NqzJKS
# 4kOmxkYp2WyODi7vQTCBZtVFJfVZ3j7OgWmnhFr4yUozZtqgPrHRVHhGNKlYzyjl
# roPxul+bgIspzOwbtmsgY1MCAwEAAaOCAV0wggFZMBIGA1UdEwEB/wQIMAYBAf8C
# AQAwHQYDVR0OBBYEFO9vU0rp5AZ8esrikFb2L9RJ7MtOMB8GA1UdIwQYMBaAFOzX
# 44LScV1kTN8uZz/nupiuHA9PMA4GA1UdDwEB/wQEAwIBhjATBgNVHSUEDDAKBggr
# BgEFBQcDCDB3BggrBgEFBQcBAQRrMGkwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3Nw
# LmRpZ2ljZXJ0LmNvbTBBBggrBgEFBQcwAoY1aHR0cDovL2NhY2VydHMuZGlnaWNl
# cnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RHNC5jcnQwQwYDVR0fBDwwOjA4oDag
# NIYyaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RH
# NC5jcmwwIAYDVR0gBBkwFzAIBgZngQwBBAIwCwYJYIZIAYb9bAcBMA0GCSqGSIb3
# DQEBCwUAA4ICAQAXzvsWgBz+Bz0RdnEwvb4LyLU0pn/N0IfFiBowf0/Dm1wGc/Do
# 7oVMY2mhXZXjDNJQa8j00DNqhCT3t+s8G0iP5kvN2n7Jd2E4/iEIUBO41P5F448r
# SYJ59Ib61eoalhnd6ywFLerycvZTAz40y8S4F3/a+Z1jEMK/DMm/axFSgoR8n6c3
# nuZB9BfBwAQYK9FHaoq2e26MHvVY9gCDA/JYsq7pGdogP8HRtrYfctSLANEBfHU1
# 6r3J05qX3kId+ZOczgj5kjatVB+NdADVZKON/gnZruMvNYY2o1f4MXRJDMdTSlOL
# h0HCn2cQLwQCqjFbqrXuvTPSegOOzr4EWj7PtspIHBldNE2K9i697cvaiIo2p61E
# d2p8xMJb82Yosn0z4y25xUbI7GIN/TpVfHIqQ6Ku/qjTY6hc3hsXMrS+U0yy+GWq
# AXam4ToWd2UQ1KYT70kZjE4YtL8Pbzg0c1ugMZyZZd/BdHLiRu7hAWE6bTEm4XYR
# kA6Tl4KSFLFk43esaUeqGkH/wyW4N7OigizwJWeukcyIPbAvjSabnf7+Pu0VrFgo
# iovRDiyx3zEdmcif/sYQsfch28bZeUz2rtY/9TCA6TD8dC3JE3rYkrhLULy7Dc90
# G6e8BlqmyIjlgp2+VqsS9/wQD7yFylIz0scmbKvFoW2jNrbM1pD2T7m3XDCCBu0w
# ggTVoAMCAQICEAqA7xhLjfEFgtHEdqeVdGgwDQYJKoZIhvcNAQELBQAwaTELMAkG
# A1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMUEwPwYDVQQDEzhEaWdp
# Q2VydCBUcnVzdGVkIEc0IFRpbWVTdGFtcGluZyBSU0E0MDk2IFNIQTI1NiAyMDI1
# IENBMTAeFw0yNTA2MDQwMDAwMDBaFw0zNjA5MDMyMzU5NTlaMGMxCzAJBgNVBAYT
# AlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMyRGlnaUNlcnQg
# U0hBMjU2IFJTQTQwOTYgVGltZXN0YW1wIFJlc3BvbmRlciAyMDI1IDEwggIiMA0G
# CSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDQRqwtEsae0OquYFazK1e6b1H/hnAK
# Ad/KN8wZQjBjMqiZ3xTWcfsLwOvRxUwXcGx8AUjni6bz52fGTfr6PHRNv6T7zsf1
# Y/E3IU8kgNkeECqVQ+3bzWYesFtkepErvUSbf+EIYLkrLKd6qJnuzK8Vcn0DvbDM
# emQFoxQ2Dsw4vEjoT1FpS54dNApZfKY61HAldytxNM89PZXUP/5wWWURK+IfxiOg
# 8W9lKMqzdIo7VA1R0V3Zp3DjjANwqAf4lEkTlCDQ0/fKJLKLkzGBTpx6EYevvOi7
# XOc4zyh1uSqgr6UnbksIcFJqLbkIXIPbcNmA98Oskkkrvt6lPAw/p4oDSRZreiwB
# 7x9ykrjS6GS3NR39iTTFS+ENTqW8m6THuOmHHjQNC3zbJ6nJ6SXiLSvw4Smz8U07
# hqF+8CTXaETkVWz0dVVZw7knh1WZXOLHgDvundrAtuvz0D3T+dYaNcwafsVCGZKU
# hQPL1naFKBy1p6llN3QgshRta6Eq4B40h5avMcpi54wm0i2ePZD5pPIssoszQyF4
# //3DoK2O65Uck5Wggn8O2klETsJ7u8xEehGifgJYi+6I03UuT1j7FnrqVrOzaQoV
# JOeeStPeldYRNMmSF3voIgMFtNGh86w3ISHNm0IaadCKCkUe2LnwJKa8TIlwCUNV
# wppwn4D3/Pt5pwIDAQABo4IBlTCCAZEwDAYDVR0TAQH/BAIwADAdBgNVHQ4EFgQU
# 5Dv88jHt/f3X85FxYxlQQ89hjOgwHwYDVR0jBBgwFoAU729TSunkBnx6yuKQVvYv
# 1Ensy04wDgYDVR0PAQH/BAQDAgeAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMIMIGV
# BggrBgEFBQcBAQSBiDCBhTAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNl
# cnQuY29tMF0GCCsGAQUFBzAChlFodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20v
# RGlnaUNlcnRUcnVzdGVkRzRUaW1lU3RhbXBpbmdSU0E0MDk2U0hBMjU2MjAyNUNB
# MS5jcnQwXwYDVR0fBFgwVjBUoFKgUIZOaHR0cDovL2NybDMuZGlnaWNlcnQuY29t
# L0RpZ2lDZXJ0VHJ1c3RlZEc0VGltZVN0YW1waW5nUlNBNDA5NlNIQTI1NjIwMjVD
# QTEuY3JsMCAGA1UdIAQZMBcwCAYGZ4EMAQQCMAsGCWCGSAGG/WwHATANBgkqhkiG
# 9w0BAQsFAAOCAgEAZSqt8RwnBLmuYEHs0QhEnmNAciH45PYiT9s1i6UKtW+FERp8
# FgXRGQ/YAavXzWjZhY+hIfP2JkQ38U+wtJPBVBajYfrbIYG+Dui4I4PCvHpQuPqF
# gqp1PzC/ZRX4pvP/ciZmUnthfAEP1HShTrY+2DE5qjzvZs7JIIgt0GCFD9ktx0Lx
# xtRQ7vllKluHWiKk6FxRPyUPxAAYH2Vy1lNM4kzekd8oEARzFAWgeW3az2xejEWL
# NN4eKGxDJ8WDl/FQUSntbjZ80FU3i54tpx5F/0Kr15zW/mJAxZMVBrTE2oi0fcI8
# VMbtoRAmaaslNXdCG1+lqvP4FbrQ6IwSBXkZagHLhFU9HCrG/syTRLLhAezu/3Lr
# 00GrJzPQFnCEH1Y58678IgmfORBPC1JKkYaEt2OdDh4GmO0/5cHelAK2/gTlQJIN
# qDr6JfwyYHXSd+V08X1JUPvB4ILfJdmL+66Gp3CSBXG6IwXMZUXBhtCyIaehr0Xk
# BoDIGMUG1dUtwq1qmcwbdUfcSYCn+OwncVUXf53VJUNOaMWMts0VlRYxe5nK+At+
# DI96HAlXHAL5SlfYxJ7La54i71McVWRP66bW+yERNpbJCjyCYG2j+bdpxo/1Cy4u
# PcU3AWVPGrbn5PhDBf3Froguzzhk++ami+r3Qrx5bIbY3TVzgiFI7Gq3zWcxggT7
# MIIE9wIBATAwMBwxGjAYBgNVBAMMEU1ldVNjcmlwdEFzc2luYWRvAhAcQaGsWipd
# uU3OwQq4hZTcMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAA
# MBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgor
# BgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBT9OVSpVeSW0M56/2j0r4yRCh7ruTAN
# BgkqhkiG9w0BAQEFAASCAQAf1ptRsOwyKQJzh9As0kP50+LFuw0iO7/Vz5Lz0oXf
# NF4AdFHU9tWPYpAXY/9rxiWYZ+Nqa92CgceOVfuv0yyHS0Q6BW1ucwnpUoz0QQ2w
# XmJvYySt5Dr/l9fa+g03lNcYv7M7pb3HMiBW16yBVGYlqltGFex2ZjZUlggHrFT6
# U4jxQVjs3mJUu4l3bXwymVYzms+Mp2lztdEhLJkCzZIPKZgHPFIquaXHI0EqyzF/
# mTGlUyyTnFs4WIEk2HzZ0XvxNTxq2Nbcl8ysY1iXBuk99jAAyshMlAC06/3Zh0aA
# fYlvMdumc8Iam3SbhkhiFEoqR74irloLDY0FDxcV9bTMoYIDJjCCAyIGCSqGSIb3
# DQEJBjGCAxMwggMPAgEBMH0waTELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lD
# ZXJ0LCBJbmMuMUEwPwYDVQQDEzhEaWdpQ2VydCBUcnVzdGVkIEc0IFRpbWVTdGFt
# cGluZyBSU0E0MDk2IFNIQTI1NiAyMDI1IENBMQIQCoDvGEuN8QWC0cR2p5V0aDAN
# BglghkgBZQMEAgEFAKBpMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZI
# hvcNAQkFMQ8XDTI2MDQwMTE4MDQwMlowLwYJKoZIhvcNAQkEMSIEIBCr1wr9nD2L
# E5BICEResECl0lAf7y7t81jGPU+ebZDWMA0GCSqGSIb3DQEBAQUABIICAMeH0y8P
# biaVZkgzJF0sPPFT9+REnbjcWi7/E8L1VDcXjFIfRSpC21hg2Y/t6g30/sn28gU3
# cZSLBg6EaYb81SxY2TxAWN+hSg8S7/8KfG6sX1hfrAchBBpMXmYYYUeBHqyKmrEV
# BIyUFgcXw+zAcgJzM2h1AlTKJbI8gnhR7/yHC8eaU62U9/th9o5LWBlESXX709k/
# fx8gip8ok1Goq9m4uKnsSXACsihivhVSmH0N5fRX25X8weBNwSnjq0ivI7dRuhAh
# fRXy5/v4r/igN6ze8hNGt5xc8wmVgxm7qDWan9wdl0pF4/ahTVj49LrUbvlgNF/y
# Y0c68Z4udDDSEgA/0gb2LadWzx/hfjB6guJ0iXBVXLcmfG299QdHS82LtgJyv/KS
# G152oI5AoQ4XsJDm0pjPhzA8iu4Yj+hAhdKWxP5RZh4EfzrSTM3/UtjltB5nJ5hR
# IEhCGtyTZoxTDK+dq7v9bwWQo9ShmYhjs46twYjrnFVo70eY37zZIsjKqfgZUOHQ
# 6//fI04hGtITAfIequ9iBiYMqNB9izYyMR+hbrGfs4ne7RDUHjMPmddxxnI0WjYH
# jCgUB2BbzjpxkOarSMnPNklgk4W40StBwcXuqwpuQUpmhd2r881xEuY7EUaoiNdK
# RKjI/H+rOjzsH4SnGH7I6WQWPzpI2DoqDSks
# SIG # End signature block
