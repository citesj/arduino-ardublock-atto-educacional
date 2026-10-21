param(
    [Parameter(Mandatory = $true)]
    [string]$CertificateThumbprint,
    [string]$OutputPath
)

$ErrorActionPreference = "Stop"

$repositoryRoot = $PSScriptRoot
$installerScript = Join-Path $repositoryRoot "full-install-arduino.ps1"
$iexpressPath = Join-Path $env:WINDIR "System32\iexpress.exe"

if (-not (Test-Path $installerScript)) {
    throw "Script de instalação não encontrado: $installerScript"
}

if (-not (Test-Path $iexpressPath)) {
    throw "IExpress não foi encontrado: $iexpressPath"
}

if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $OutputPath = Join-Path $repositoryRoot "dist\Instalador_Arduino_Atto.exe"
}

$OutputPath = [System.IO.Path]::GetFullPath($OutputPath)
$outputDirectory = Split-Path -Parent $OutputPath
if (-not (Test-Path $outputDirectory)) {
    New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
}

$certificatePath = "Cert:\CurrentUser\My\$CertificateThumbprint"
$certificate = Get-Item -Path $certificatePath -ErrorAction Stop
if (-not $certificate.HasPrivateKey) {
    throw "O certificado selecionado não possui uma chave privada acessível."
}

$signingEku = $certificate.Extensions |
    Where-Object { $_.Oid.Value -eq "2.5.29.37" } |
    Select-Object -First 1
if (-not $signingEku -or $signingEku.EnhancedKeyUsages.Value -notcontains "1.3.6.1.5.5.7.3.3") {
    throw "O certificado selecionado não possui o uso de assinatura de código."
}

$scriptSignature = Set-AuthenticodeSignature `
    -FilePath $installerScript `
    -Certificate $certificate `
    -HashAlgorithm SHA256
if ($scriptSignature.Status -ne "Valid") {
    throw "Falha ao assinar o script: $($scriptSignature.StatusMessage)"
}

$stagingDirectory = Join-Path $env:TEMP ("ArduinoInstaller-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $stagingDirectory | Out-Null

try {
    Copy-Item -Path $installerScript -Destination (Join-Path $stagingDirectory "full-install-arduino.ps1")
    $launcherPath = Join-Path $stagingDirectory "run-install.cmd"
    Set-Content -Path $launcherPath -Encoding ASCII -Value @'
@echo off
powershell.exe -NoProfile -ExecutionPolicy AllSigned -File "%~dp0full-install-arduino.ps1"
exit /b %ERRORLEVEL%
'@

    $sedPath = Join-Path $stagingDirectory "installer.sed"
    $sedContent = @"
[Strings]
InstallPrompt=
DisplayLicense=
FinishMessage=
TargetName=$stagingDirectory\Instalador_Arduino_Atto.exe
FriendlyName=Arduino IDE e ArduBlock
AppLaunched=cmd /c run-install.cmd
PostInstallCmd=<None>
AdminQuietInstCmd=
UserQuietInstCmd=
FILE0="full-install-arduino.ps1"
FILE1="run-install.cmd"
[Version]
Class=IEXPRESS
SEDVersion=3
[Options]
PackagePurpose=InstallApp
ShowInstallProgramWindow=1
HideExtractAnimation=1
UseLongFileName=1
InsideCompressed=1
CAB_FixedSize=0
CAB_ResvCodeSigning=0
RebootMode=N
InstallPrompt=%InstallPrompt%
DisplayLicense=%DisplayLicense%
FinishMessage=%FinishMessage%
TargetName=%TargetName%
FriendlyName=%FriendlyName%
AppLaunched=%AppLaunched%
PostInstallCmd=%PostInstallCmd%
AdminQuietInstCmd=%AdminQuietInstCmd%
UserQuietInstCmd=%UserQuietInstCmd%
SourceFiles=SourceFiles
[SourceFiles]
SourceFiles0=$stagingDirectory
[SourceFiles0]
%FILE0%=
%FILE1%=
"@
    Set-Content -Path $sedPath -Value $sedContent -Encoding ASCII

    $iexpressProcess = Start-Process `
        -FilePath $iexpressPath `
        -ArgumentList @("/N", "/Q", $sedPath) `
        -Wait `
        -PassThru
    if ($iexpressProcess.ExitCode -ne 0) {
        throw "IExpress terminou com código $($iexpressProcess.ExitCode)."
    }
    $stagedInstallerPath = Join-Path $stagingDirectory "Instalador_Arduino_Atto.exe"
    if (-not (Test-Path $stagedInstallerPath)) {
        throw "IExpress não gerou o instalador esperado: $stagedInstallerPath"
    }

    $installerSignature = Set-AuthenticodeSignature `
        -FilePath $stagedInstallerPath `
        -Certificate $certificate `
        -HashAlgorithm SHA256
    if ($installerSignature.Status -ne "Valid") {
        throw "Falha ao assinar o instalador: $($installerSignature.StatusMessage)"
    }

    Copy-Item -Path $stagedInstallerPath -Destination $OutputPath -Force
    $finalSignature = Get-AuthenticodeSignature -FilePath $OutputPath
    if ($finalSignature.Status -ne "Valid") {
        throw "A assinatura do instalador gerado não é válida: $($finalSignature.StatusMessage)"
    }

    Write-Host "Script assinado e validado: $installerScript" -ForegroundColor Green
    Write-Host "Instalador assinado e validado: $OutputPath" -ForegroundColor Green
}
finally {
    if (Test-Path $stagingDirectory) {
        Remove-Item -Path $stagingDirectory -Recurse -Force
    }
}
