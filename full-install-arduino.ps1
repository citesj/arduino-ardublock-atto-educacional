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
        [System.IO.File]::Replace($preferencesTempPath, $preferencesPath, $backupPath)
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
