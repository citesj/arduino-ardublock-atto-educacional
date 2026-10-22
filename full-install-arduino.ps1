# Script de Instalação Completa: Arduino IDE 1.8.19 + ArduBlock para Windows
# Autor: Eduardo "duZÃO" Henrique
# Data: 21/10/2026

# Força o PowerShell a entender caracteres especiais na leitura e na saída
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$ErrorActionPreference = "Stop"
$SUCCESS_MARK = "[OK]"

function Write-UserStatus {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [string]$Color = "White"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$timestamp] $Message"
    Write-Host $Message -ForegroundColor $Color

    if ($script:InstallLogPath) {
        try {
            Add-Content -LiteralPath $script:InstallLogPath -Value $line -Encoding UTF8
        }
        catch {
            # Ignora falhas de log para não interromper a instalação.
        }
    }
}

function Write-StepHeader {
    param(
        [Parameter(Mandatory = $true)]
        [int]$Step,

        [Parameter(Mandatory = $true)]
        [string]$Title
    )

    Write-Progress -Activity "Instalação completa do Arduino IDE + ArduBlock" -Status $Title -PercentComplete (($Step / 4) * 100)
    Write-Host "`n[$Step/4] $Title" -ForegroundColor Yellow
    Write-UserStatus -Message "Iniciando etapa $Step de 4: $Title" -Color Gray
}

function Write-StepSuccess {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    Write-Host "$SUCCESS_MARK $Message" -ForegroundColor Green
    Write-UserStatus -Message $Message -Color Green
}

Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host "=== Instalação Completa: Arduino IDE + ArduBlock =====" -ForegroundColor Cyan
Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host "Iniciando verificação de pré-requisitos e preparação do ambiente." -ForegroundColor Cyan

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
$script:InstallLogPath = Join-Path $tempDir "install.log"

New-Item -ItemType Directory -Path $tempDir -ErrorAction Stop | Out-Null

try {
    Write-UserStatus -Message "Diretório temporário de instalação criado em: $tempDir" -Color Gray

    Write-StepHeader -Step 1 -Title "Verificando instalação do Arduino IDE..."
    $arduinoExecutable = Join-Path $arduinoInstallDir "arduino.exe"
    if (-not (Test-Path -LiteralPath $arduinoExecutable -PathType Leaf)) {
        Write-UserStatus -Message "Arduino IDE não encontrado na instalação padrão. Preparando download do instalador..." -Color White
        $exePath = Join-Path $tempDir "arduino-setup.exe"
        Write-UserStatus -Message "Baixando o instalador do Arduino IDE 1.8.19..." -Color White
        Invoke-WebRequest -Uri $arduinoDownloadUrl -OutFile $exePath -UseBasicParsing
        if (-not (Test-Path -LiteralPath $exePath -PathType Leaf) -or (Get-Item -LiteralPath $exePath).Length -eq 0) {
            throw "O arquivo baixado do Arduino IDE está vazio ou não foi criado."
        }

        Write-UserStatus -Message "Instalador baixado. Iniciando a instalação em modo automático..." -Color White
        Write-Progress -Activity "Instalando Arduino IDE 1.8.19" -Status "Aguarde enquanto o instalador conclui a configuração." -PercentComplete 25

        $installProcess = Start-Process -FilePath $exePath -ArgumentList "/S" -PassThru
        while (-not $installProcess.HasExited) {
            Write-Progress -Activity "Instalando Arduino IDE 1.8.19" -Status "Aguarde..." -PercentComplete 50
            Start-Sleep -Seconds 2
        }
        Write-Progress -Activity "Instalando Arduino IDE 1.8.19" -Completed

        if ($installProcess.ExitCode -ne 0) {
            throw "O instalador do Arduino IDE terminou com código $($installProcess.ExitCode)."
        }
        if (-not (Test-Path -LiteralPath $arduinoExecutable -PathType Leaf)) {
            throw "O executável do Arduino IDE não foi encontrado após a instalação."
        }
        Write-StepSuccess -Message "Arduino IDE instalado com sucesso."
    }
    else {
        Write-StepSuccess -Message "Arduino IDE já detectado em $arduinoInstallDir."
    }

    Write-StepHeader -Step 2 -Title "Verificando instalação do ArduBlock..."
    if (-not (Test-Path -LiteralPath $sketchbookPath -PathType Container)) {
        Write-UserStatus -Message "Criando diretório de sketchbook em $sketchbookPath" -Color Gray
        New-Item -ItemType Directory -Path $sketchbookPath -Force -ErrorAction Stop | Out-Null
    }
    if (-not (Test-Path -LiteralPath $ardublockJarPath -PathType Leaf)) {
        $toolsZipPath = Join-Path $tempDir "tools.zip"
        $stagingDirectory = Join-Path $tempDir "ardublock"
        Write-UserStatus -Message "Baixando pacote do ArduBlock..." -Color White
        Invoke-WebRequest -Uri $ardublockZipUrl -OutFile $toolsZipPath -UseBasicParsing
        if (-not (Test-Path -LiteralPath $toolsZipPath -PathType Leaf) -or (Get-Item -LiteralPath $toolsZipPath).Length -eq 0) {
            throw "O arquivo baixado do ArduBlock está vazio ou não foi criado."
        }

        Write-UserStatus -Message "Validando conteúdo do pacote e preparando a instalação do ArduBlock." -Color White
        New-Item -ItemType Directory -Path $stagingDirectory -ErrorAction Stop | Out-Null
        Expand-Archive -LiteralPath $toolsZipPath -DestinationPath $stagingDirectory -ErrorAction Stop
        $stagedArdublockJarPath = Join-Path $stagingDirectory "tools\ArduBlockTool\tool\ardublock-all.jar"
        if (-not (Test-Path -LiteralPath $stagedArdublockJarPath -PathType Leaf)) {
            throw "O pacote baixado não contém o arquivo esperado do ArduBlock."
        }

        Write-UserStatus -Message "Copiando arquivos do ArduBlock para o sketchbook do Arduino..." -Color White
        Copy-Item -LiteralPath (Join-Path $stagingDirectory "tools") -Destination $sketchbookPath -Recurse -Force -ErrorAction Stop
        if (-not (Test-Path -LiteralPath $ardublockJarPath -PathType Leaf)) {
            throw "O arquivo do ArduBlock não foi encontrado após a instalação."
        }
        Write-StepSuccess -Message "ArduBlock configurado em $sketchbookPath\tools."
    }
    else {
        Write-StepSuccess -Message "ArduBlock já detectado em $sketchbookPath\tools."
    }

    Write-StepHeader -Step 3 -Title "Aplicando configurações padrão do Arduino (placa, idioma e sketchbook)..."
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
        Write-UserStatus -Message "Backup das preferências criado em: $backupPath" -Color Gray

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
    Write-StepSuccess -Message "Preferências verificadas; valores existentes foram preservados."

    Write-StepHeader -Step 4 -Title "Finalizando instalação e limpando arquivos temporários..."
    Write-UserStatus -Message "Instalação concluída com sucesso. O ambiente foi configurado para uso do Arduino + ArduBlock." -Color Green
    Write-UserStatus -Message "Arquivos temporários serão removidos ao final da execução." -Color Gray

    Write-Host "`n=======================================================" -ForegroundColor Cyan
    Write-Host "       INSTALAÇÃO CONCLUÍDA COM SUCESSO!       " -ForegroundColor Cyan
    Write-Host "=======================================================" -ForegroundColor Cyan
    Write-Host "Como usar:" -ForegroundColor White
    Write-Host "1. Abra o Arduino IDE no menu Iniciar." -ForegroundColor White
    Write-Host "2. Vá em Ferramentas -> ArduBlock para iniciar a interface de blocos." -ForegroundColor White
    Write-Host "3. Se necessário, revise as preferências em Arquivo -> Preferências do Arduino." -ForegroundColor White
    Write-Host "4. Arquivo de diagnóstico: $tempDir\install.log" -ForegroundColor Gray
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

# Fim do script
