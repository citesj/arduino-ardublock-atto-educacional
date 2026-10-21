# Manutenção do instalador do Windows

Este documento é destinado a mantenedores que precisam gerar e assinar uma nova versão do instalador do Windows. As instruções de instalação para usuários finais estão no [README principal](./README.md).

O script [build-windows-installer.ps1](./build-windows-installer.ps1) assina o instalador [full-install-arduino.ps1](./full-install-arduino.ps1) e o inicializador [run-install.ps1](./run-install.ps1), usa o IExpress do Windows para empacotá-los e, em seguida, assina o `.exe` final com o mesmo certificado. O inicializador solicita elevação pelo UAC e mantém a janela aberta para mostrar sucesso ou erros.

## Criar um certificado de assinatura

Crie um certificado de assinatura de código no repositório pessoal do Windows:

```powershell
$cert = New-SelfSignedCertificate `
  -Type CodeSigningCert `
  -Subject "CN=Arduino ArduBlock Installer" `
  -CertStoreLocation Cert:\CurrentUser\My `
  -HashAlgorithm SHA256 `
  -KeyLength 3072 `
  -NotAfter (Get-Date).AddYears(3)
```

Para validar assinaturas neste computador, exporte e confie no certificado público:

```powershell
$publicCertPath = Join-Path $env:TEMP "arduino-installer-public.cer"
Export-Certificate -Cert $cert -FilePath $publicCertPath | Out-Null
certutil.exe -f -user -addstore Root $publicCertPath
certutil.exe -f -user -addstore TrustedPublisher $publicCertPath
Remove-Item $publicCertPath
```

## Gerar e assinar o instalador

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\build-windows-installer.ps1 -CertificateThumbprint $cert.Thumbprint
```

O `Bypass` vale somente para esse processo usado para gerar o pacote; o `.ps1` dentro do instalador é executado com `AllSigned`. O arquivo será criado em `dist\Instalador_Arduino_Atto.exe`. A chave privada permanece no repositório de certificados do usuário e não deve ser exportada nem distribuída.

Para outros computadores, distribua somente o certificado público por um canal confiável, confira a impressão digital (`$cert.Thumbprint`) e configure a confiança antes de executar o instalador, por exemplo:

```powershell
certutil.exe -user -addstore Root .\arduino-installer-public.cer
certutil.exe -user -addstore TrustedPublisher .\arduino-installer-public.cer
```

Um certificado autoassinado pode continuar gerando avisos do SmartScreen.

Para disponibilizar o certificado público a computadores gerenciados, exporte somente a parte pública:

```powershell
Export-Certificate -Cert $cert -FilePath .\arduino-installer-public.cer | Out-Null
```

Confirme a impressão digital do certificado antes de instalá-lo nos destinatários:

```powershell
certutil.exe -dump .\arduino-installer-public.cer
```
