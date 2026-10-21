# Script de Instalação Completa: Arduino IDE 1.8.19 + ArduBlock para Windows
# Autor: Eduardo "duZÃO" Henrique
# Data: 21/10/2026

# Força o PowerShell a entender caracteres especiais na leitura e na saída
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$ErrorActionPreference = "Stop"
$SUCCESS_MARK = "[OK]"

Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host "=== Instalação Completa: Arduino IDE + ArduBlock =====" -ForegroundColor Cyan
Write-Host "=======================================================" -ForegroundColor Cyan

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw "Este script requer privilégios de Administrador. Execute o PowerShell como Administrador."
}

$arduinoDownloadUrl = "https://github.com/citesj/arduino-ardublock-atto-educacional/releases/download/v.1.0.2/arduino-1.8.19-windows.exe"
$ardublockZipUrl = "https://github.com/citesj/arduino-ardublock-atto-educacional/releases/download/v.1.0.2/ardublock.zip"
$arduinoInstallDir = "C:\Program Files (x86)\Arduino"

if ([string]::IsNullOrWhiteSpace($env:TEMP) -or [string]::IsNullOrWhiteSpace($env:USERPROFILE) -or [string]::IsNullOrWhiteSpace($env:LOCALAPPDATA)) {
    throw "Não foi possível determinar os diretórios temporário e de usuário."
}

$tempDir = Join-Path $env:TEMP ("ArduinoInstall-" + [guid]::NewGuid().ToString("N"))
$sketchbookPath = Join-Path $env:USERPROFILE "Documents\Arduino"
$preferencesPath = Join-Path $env:LOCALAPPDATA "Arduino15\preferences.txt"
$ardublockJarPath = Join-Path $sketchbookPath "tools\ArduBlockTool\tool\ardublock-all.jar"

New-Item -ItemType Directory -Path $tempDir -ErrorAction Stop | Out-Null

try {
    Write-Host "`n[1/4] Verificando instalação do Arduino IDE..." -ForegroundColor Yellow
    $arduinoExecutable = Join-Path $arduinoInstallDir "arduino.exe"
    if (-not (Test-Path -LiteralPath $arduinoExecutable -PathType Leaf)) {
        Write-Host "-> Baixando Arduino IDE 1.8.19..." -ForegroundColor White
        $exePath = Join-Path $tempDir "arduino-setup.exe"
        Invoke-WebRequest -Uri $arduinoDownloadUrl -OutFile $exePath -UseBasicParsing
        if (-not (Test-Path -LiteralPath $exePath -PathType Leaf) -or (Get-Item -LiteralPath $exePath).Length -eq 0) {
            throw "O arquivo baixado do Arduino IDE está vazio ou não foi criado."
        }

        Write-Host "-> Iniciando instalação silenciosa..." -ForegroundColor White
        $installProcess = Start-Process -FilePath $exePath -ArgumentList "/S" -Wait -PassThru
        if ($installProcess.ExitCode -ne 0) {
            throw "O instalador do Arduino IDE terminou com código $($installProcess.ExitCode)."
        }
        if (-not (Test-Path -LiteralPath $arduinoExecutable -PathType Leaf)) {
            throw "O executável do Arduino IDE não foi encontrado após a instalação."
        }
        Write-Host "$SUCCESS_MARK Arduino IDE instalado com sucesso." -ForegroundColor Green
    }
    else {
        Write-Host "$SUCCESS_MARK Arduino IDE já detectado em $arduinoInstallDir." -ForegroundColor Green
    }

    Write-Host "`n[2/4] Verificando instalação do ArduBlock..." -ForegroundColor Yellow
    if (-not (Test-Path -LiteralPath $sketchbookPath -PathType Container)) {
        New-Item -ItemType Directory -Path $sketchbookPath -Force -ErrorAction Stop | Out-Null
    }
    if (-not (Test-Path -LiteralPath $ardublockJarPath -PathType Leaf)) {
        $toolsZipPath = Join-Path $tempDir "tools.zip"
        $stagingDirectory = Join-Path $tempDir "ardublock"
        Write-Host "-> Baixando ArduBlock..." -ForegroundColor White
        Invoke-WebRequest -Uri $ardublockZipUrl -OutFile $toolsZipPath -UseBasicParsing
        if (-not (Test-Path -LiteralPath $toolsZipPath -PathType Leaf) -or (Get-Item -LiteralPath $toolsZipPath).Length -eq 0) {
            throw "O arquivo baixado do ArduBlock está vazio ou não foi criado."
        }

        Write-Host "-> Validando e descompactando ferramentas..." -ForegroundColor White
        New-Item -ItemType Directory -Path $stagingDirectory -ErrorAction Stop | Out-Null
        Expand-Archive -LiteralPath $toolsZipPath -DestinationPath $stagingDirectory -ErrorAction Stop
        $stagedArdublockJarPath = Join-Path $stagingDirectory "tools\ArduBlockTool\tool\ardublock-all.jar"
        if (-not (Test-Path -LiteralPath $stagedArdublockJarPath -PathType Leaf)) {
            throw "O pacote baixado não contém o arquivo esperado do ArduBlock."
        }

        Copy-Item -LiteralPath (Join-Path $stagingDirectory "tools") -Destination $sketchbookPath -Recurse -Force -ErrorAction Stop
        if (-not (Test-Path -LiteralPath $ardublockJarPath -PathType Leaf)) {
            throw "O arquivo do ArduBlock não foi encontrado após a instalação."
        }
        Write-Host "$SUCCESS_MARK ArduBlock configurado em $sketchbookPath\tools" -ForegroundColor Green
    }
    else {
        Write-Host "$SUCCESS_MARK ArduBlock já detectado em $sketchbookPath\tools." -ForegroundColor Green
    }

    Write-Host "`n[3/4] Aplicando configurações padrão (Placa/Idioma)..." -ForegroundColor Yellow
    $configDir = Split-Path -Parent $preferencesPath
    New-Item -ItemType Directory -Path $configDir -Force -ErrorAction Stop | Out-Null
    $preferenceDefaults = [ordered]@{
        board = "uno"
        target_package = "arduino"
        target_platform = "avr"
        'editor.languages.current' = "pt_BR"
        'editor.linenumbers' = "true"
        'sketchbook.path' = $sketchbookPath.Replace('\', '\\')
        'last.ide.version' = "1.8.19"
    }
    $preferencesTempPath = Join-Path $configDir ("preferences.txt." + [guid]::NewGuid().ToString("N") + ".tmp")

    if (Test-Path -LiteralPath $preferencesPath -PathType Leaf) {
        $backupPath = "$preferencesPath.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss').$([guid]::NewGuid().ToString('N'))"
        Copy-Item -LiteralPath $preferencesPath -Destination $backupPath -ErrorAction Stop
        if (-not (Test-Path -LiteralPath $backupPath -PathType Leaf)) {
            throw "Não foi possível confirmar o backup das preferências."
        }
        Write-Host "Backup das preferências criado: $backupPath" -ForegroundColor Gray

        $existingLines = [System.IO.File]::ReadAllLines($preferencesPath)
        $existingKeys = @{}
        foreach ($line in $existingLines) {
            $separator = $line.IndexOf("=")
            if ($separator -gt 0) {
                $existingKeys[$line.Substring(0, $separator)] = $true
            }
        }
        $missingLines = @(
            foreach ($key in $preferenceDefaults.Keys) {
                if (-not $existingKeys.ContainsKey($key)) {
                    "$key=$($preferenceDefaults[$key])"
                }
            }
        )
        Copy-Item -LiteralPath $preferencesPath -Destination $preferencesTempPath -ErrorAction Stop
        if ($missingLines.Count -gt 0) {
            $existingText = [System.IO.File]::ReadAllText($preferencesPath)
            $separator = if ($existingText.Length -gt 0 -and -not $existingText.EndsWith("`n")) { "`r`n" } else { "" }
            $appendText = $separator + ($missingLines -join "`r`n") + "`r`n"
            $preferenceBytes = [System.IO.File]::ReadAllBytes($preferencesPath)
            $preferencesEncoding = [System.Text.Encoding]::ASCII
            if ($preferenceBytes.Length -ge 4 -and $preferenceBytes[0] -eq 0 -and $preferenceBytes[1] -eq 0 -and $preferenceBytes[2] -eq 0xFE -and $preferenceBytes[3] -eq 0xFF) {
                $preferencesEncoding = New-Object System.Text.UTF32Encoding($true, $false)
            }
            elseif ($preferenceBytes.Length -ge 4 -and $preferenceBytes[0] -eq 0xFF -and $preferenceBytes[1] -eq 0xFE -and $preferenceBytes[2] -eq 0 -and $preferenceBytes[3] -eq 0) {
                $preferencesEncoding = New-Object System.Text.UTF32Encoding($false, $false)
            }
            elseif ($preferenceBytes.Length -ge 3 -and $preferenceBytes[0] -eq 0xEF -and $preferenceBytes[1] -eq 0xBB -and $preferenceBytes[2] -eq 0xBF) {
                $preferencesEncoding = New-Object System.Text.UTF8Encoding($false)
            }
            elseif ($preferenceBytes.Length -ge 2 -and $preferenceBytes[0] -eq 0xFE -and $preferenceBytes[1] -eq 0xFF) {
                $preferencesEncoding = [System.Text.Encoding]::BigEndianUnicode
            }
            elseif ($preferenceBytes.Length -ge 2 -and $preferenceBytes[0] -eq 0xFF -and $preferenceBytes[1] -eq 0xFE) {
                $preferencesEncoding = [System.Text.Encoding]::Unicode
            }
            [System.IO.File]::AppendAllText($preferencesTempPath, $appendText, $preferencesEncoding)
        }
    }
    else {
        $defaultLines = @(
            foreach ($key in $preferenceDefaults.Keys) {
                "$key=$($preferenceDefaults[$key])"
            }
        )
        [System.IO.File]::WriteAllLines($preferencesTempPath, $defaultLines, [System.Text.Encoding]::ASCII)
    }

    if (Test-Path -LiteralPath $preferencesPath -PathType Leaf) {
        [System.IO.File]::Replace($preferencesTempPath, $preferencesPath, $null)
    }
    else {
        Move-Item -LiteralPath $preferencesTempPath -Destination $preferencesPath -ErrorAction Stop
    }
    if (-not (Test-Path -LiteralPath $preferencesPath -PathType Leaf)) {
        throw "O arquivo de preferências não foi criado."
    }
    Write-Host "$SUCCESS_MARK Preferências verificadas; valores existentes foram preservados." -ForegroundColor Green

    Write-Host "`n[4/4] Limpando arquivos temporários..." -ForegroundColor Yellow
    Write-Host "$SUCCESS_MARK Instalação concluída." -ForegroundColor Green

    Write-Host "`n=======================================================" -ForegroundColor Cyan
    Write-Host "       INSTALAÇÃO CONCLUÍDA COM SUCESSO!       " -ForegroundColor Cyan
    Write-Host "=======================================================" -ForegroundColor Cyan
    Write-Host "Como usar:"
    Write-Host "1. Abra o Arduino IDE no menu Iniciar."
    Write-Host "2. Vá em Ferramentas -> ArduBlock para iniciar a interface de blocos."
}
finally {
    if (Test-Path -LiteralPath $tempDir) {
        try {
            Remove-Item -LiteralPath $tempDir -Recurse -Force -ErrorAction Stop
            Write-Host "$SUCCESS_MARK Limpeza concluída." -ForegroundColor Green
        }
        catch {
            Write-Warning "Não foi possível remover os arquivos temporários em $tempDir : $($_.Exception.Message)"
        }
    }
}
# SIG # Begin signature block
# MIIHNgYJKoZIhvcNAQcCoIIHJzCCByMCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCEfDfC2um84woj
# ZXSMVS/NDk1+SbxKNyiY5ddP+KHbGaCCBCAwggQcMIIChKADAgECAhAXGcataqcC
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
# AYI3AgEVMC8GCSqGSIb3DQEJBDEiBCCm4QZTqTB6H9JChhiztQ63e7sibZdGdbi+
# ozUOs+7gezANBgkqhkiG9w0BAQEFAASCAYBXDGZPahO+zDR9wv05bi4E5Webyr+q
# kBgXcKqsK2fPYD7ck3ikCN78+C/nQFEr9iKrQy8gXbJHtNfFt2QUstR0X7eXfbSe
# z/bi5anLi1EK0EBKSf59rNhHi7wSf2qoE2sGKCzRYVy66M+eGiXYJR0HL50AgyQ0
# bzrU63jZDw69aTxhy2MXwOuyxOscBoxJBNNwVVv1dsjRpGOp15JUyg3qTDnGgCot
# xo7s9ZK0plMzbDj9mba7ANBgywqfnMWr5GPsDdtLEb/sX+xtcL1KpJqbl8+yM3J7
# BwwJYqiJWavJ+SQvUHnVabss97Ejiku4QmMSoGi+qL1MmKToMSwgnXRI5w0KTRt+
# jToIkxhM/md4O5bipG/seQH/QJSdYQSzqOs9pCwObxXFmM/AVCdAahRKmsrPrY8B
# q7gj4tHUod3mq9AtDGBL869mlD3jCEK/xsGhOQR22quPMofqcxOqe3YfPXMPfk7B
# sh4OmtdURQyTB2tvCyFH+X1eLTd9ieOtmOA=
# SIG # End signature block
