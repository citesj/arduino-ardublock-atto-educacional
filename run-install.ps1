$ErrorActionPreference = "Stop"

$installerScript = Join-Path $PSScriptRoot "full-install-arduino.ps1"
if (-not (Test-Path $installerScript)) {
    throw "Script de instalação não encontrado: $installerScript"
}

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdministrator = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdministrator) {
    $powerShellPath = Join-Path $env:WINDIR "System32\WindowsPowerShell\v1.0\powershell.exe"
    $arguments = "-NoProfile -ExecutionPolicy AllSigned -File `"$PSCommandPath`""

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
            Write-Host "A solicitação de administrador foi cancelada." -ForegroundColor Yellow
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
    Write-Host "`nA instalação falhou." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    $exitCode = 1
}

Read-Host "Pressione Enter para fechar"
exit $exitCode

# SIG # Begin signature block
# MIIHNgYJKoZIhvcNAQcCoIIHJzCCByMCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDJ53BZ0LxTYsN6
# vae7czm8hFJMKD+59WLLgdVvlT+1tKCCBCAwggQcMIIChKADAgECAhAXGcataqcC
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
# AYI3AgEVMC8GCSqGSIb3DQEJBDEiBCBCWTXVUqGn+9+V+jI1vJ/gn2f72F+L6Aks
# /XQWsZB7AzANBgkqhkiG9w0BAQEFAASCAYAuoXudWHZGVyMLdvF4SXenF8DXJFc4
# 1Sa0SM3NomrGa2FvIugHUPkYl3Q4cs8hMDa/cYEF2o8taB8rm9ElKtNHHO3ejAWV
# 3c34cJ1vwTT7nMZ10+9k2+KTI/JOFy5lcdxw8x4NUlFey0I/shampC+2QsSi7qf6
# 9mA+xoBaKymMZzTHPjzJRezg8HZCoF6lTsYzDk4XMhqrnPXuLGnGOGP57Rvu7WDU
# lO43LNC9srmFd9Bw08TL1equVTgaS6R+tlXdQfpdD/o+sQY4uYdLPA4y20ANm4CP
# fg9O88Bt0C462A+mfj7oollfYX02OZsZ0Z9LvRtEm+SM2YsQPm4OQPIkxz3iPh93
# 8xpTZxLwBOq27e0gwLw8sCpi9+f9DJkW5kPCXuN/0L+sd1PA4ePkLZilqXiFRHDA
# Yj3PEfoc53A9VUVgikAg4E52hDkoQ11Y9rKdUpl2Bw9DckWizgcHoo3PISRiEKCF
# qegdY+K3PrZ+ApZc+46ElPCY07fyxlOCSnA=
# SIG # End signature block
