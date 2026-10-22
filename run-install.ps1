$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

$ErrorActionPreference = "Stop"

$installerScript = Join-Path $PSScriptRoot "full-install-arduino.ps1"
if (-not (Test-Path $installerScript)) {
    throw "Script de instalação não encontrado: $installerScript"
}

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdministrator = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdministrator) {
    $powerShellPath = Join-Path $env:WINDIR "System32\WindowsPowerShell\v1.0\powershell.exe"
    $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""

    try {
        $elevatedProcess = Start-Process `
            -FilePath $powerShellPath `
            -ArgumentList $arguments `
            -Verb RunAs `
            -Wait `
            -PassThru
        exit $elevatedProcess.ExitCode
    }
    catch [System.ComponentModel.Win32Exception] {
        if ($_.Exception.NativeErrorCode -eq 1223) {
            Write-Host "A solicitacao de administrador foi cancelada." -ForegroundColor Yellow
            Read-Host "Pressione Enter para fechar"
            exit 1
        }

        throw
    }
}

try {
    & $installerScript
    Write-Host "`nInstalação concluída." -ForegroundColor Green
    $exitCode = 0
}
catch {
    Write-Host "`nA instalacao falhou." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    $exitCode = 1
}

Read-Host "Pressione Enter para fechar"
exit $exitCode
