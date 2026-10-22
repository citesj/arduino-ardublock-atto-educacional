param(
    [string]$OutputPath
)

$ErrorActionPreference = "Stop"

$repositoryRoot = $PSScriptRoot
$installerScript = Join-Path $repositoryRoot "full-install-arduino.ps1"
$launcherScript = Join-Path $repositoryRoot "run-install.ps1"
$iexpressPath = Join-Path $env:WINDIR "System32\iexpress.exe"

if (-not (Test-Path $installerScript)) {
    throw "Script de instalação não encontrado: $installerScript"
}

if (-not (Test-Path $launcherScript)) {
    throw "Inicializador de instalação não encontrado: $launcherScript"
}

if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $OutputPath = Join-Path $repositoryRoot "dist\Instalador_Arduino_Atto.exe"
}

if (-not (Test-Path $iexpressPath)) {
    throw "IExpress não foi encontrado: $iexpressPath"
}

$OutputPath = [System.IO.Path]::GetFullPath($OutputPath)
$outputDirectory = Split-Path -Parent $OutputPath
if (-not (Test-Path $outputDirectory)) {
    New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
}

$stagingDirectory = Join-Path $env:TEMP ("ArduinoInstaller-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $stagingDirectory | Out-Null

try {
    Copy-Item -Path $installerScript -Destination (Join-Path $stagingDirectory "full-install-arduino.ps1")
    Copy-Item -Path $launcherScript -Destination (Join-Path $stagingDirectory "run-install.ps1")

    $sedPath = Join-Path $stagingDirectory "installer.sed"
    $sedContent = @"
[Strings]
InstallPrompt=
DisplayLicense=
FinishMessage=
TargetName=$stagingDirectory\Instalador_Arduino_Atto.exe
FriendlyName=Arduino IDE e ArduBlock
AppLaunched=powershell.exe -NoProfile -ExecutionPolicy Bypass -File run-install.ps1
PostInstallCmd=<None>
AdminQuietInstCmd=
UserQuietInstCmd=
FILE0="full-install-arduino.ps1"
FILE1="run-install.ps1"
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

    Copy-Item -Path $stagedInstallerPath -Destination $OutputPath -Force

    Write-Host "Instalador criado: $OutputPath" -ForegroundColor Green
}
finally {
    if (Test-Path $stagingDirectory) {
        Remove-Item -Path $stagingDirectory -Recurse -Force
    }
}
