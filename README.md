# 🚀 Tutorial de Instalação: Arduino + ArduBlock

Este repositório contém scripts de automação para configurar rapidamente o ambiente de desenvolvimento. Escolha a seção abaixo de acordo com o seu sistema operacional.

## 🪟 Windows (PowerShell)

### 📥 Download Direto
> [**Clique aqui para baixar o instalador do Windows (.exe)**](https://github.com/citesj/arduino-ardublock-atto-educacional/releases/download/v1.0.1/instalador_arduino_ardublock.EXE)

O link acima aponta para a última versão do instalador já publicada. Para gerar uma nova versão com os arquivos atuais, siga [Como gerar o instalador Windows](#como-gerar-o-instalador-windows).

### Pré-requisitos
* Ter privilégios de Administrador no computador.
* Conexão com a internet para baixar os componentes.

### Como usar
1.  **Baixe o instalador**: Obtenha o arquivo `Instalador_Arduino_Atto.exe`.
2.  **Abra o instalador**: O Windows solicitará permissão de administrador. Confirme a janela do UAC para continuar.
3.  **Aguarde a automação**: O instalador baixará a IDE 1.8.19 e instalará o ArduBlock automaticamente. A janela permanecerá aberta para exibir o resultado.
4.  **Conclusão [OK]:**: Quando a mensagem "INSTALAÇÃO CONCLUÍDA" aparecer, a placa já estará configurada como **Arduino Uno / ATmega328P** e pronta para uso. Pressione Enter para fechar a janela.

As preferências já existentes do Arduino são preservadas; o instalador cria um backup e acrescenta somente os padrões que ainda não estiverem definidos. Downloads e arquivos instalados são verificados antes de informar sucesso.

Para um instalador assinado com certificado autoassinado, o computador precisa confiar previamente no certificado público do editor. O instalador não deve instalar esse certificado silenciosamente.

### Como gerar o instalador Windows

O script [build-windows-installer.ps1](./build-windows-installer.ps1) assina o instalador [full-install-arduino.ps1](./full-install-arduino.ps1) e o inicializador [run-install.ps1](./run-install.ps1), usa o IExpress do Windows para empacotá-los e, em seguida, assina o `.exe` final com o mesmo certificado. O inicializador solicita elevação pelo UAC e mantém a janela aberta para mostrar sucesso ou erros.

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

Gere e assine o instalador:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\build-windows-installer.ps1 -CertificateThumbprint $cert.Thumbprint
```

O `Bypass` vale somente para esse processo usado para gerar o pacote; o `.ps1` dentro do instalador é executado com `AllSigned`. O arquivo será criado em `dist\Instalador_Arduino_Atto.exe`. A chave privada permanece no repositório de certificados do usuário e não deve ser exportada nem distribuída. Para outros computadores, distribua somente o certificado público por um canal confiável, confira a impressão digital (`$cert.Thumbprint`) e configure a confiança antes de executar o instalador, por exemplo:

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

---

## 🐧 Linux (Bash)

### 📥 Download Direto
> [**Clique aqui para baixar o instalador do Linux (.sh)**](https://github.com/citesj/arduino-ardublock-atto-educacional/releases/download/v1.0.1/full-install-arduino.sh)

### Pré-requisitos
* Sistema baseado em Debian/Ubuntu (ou que suporte `apt` e `wget`).
* Privilégios de `sudo`.

### Como usar
1.  **Dê permissão de execução**:
    * Abra o terminal na pasta do script e digite:
    ```bash
    chmod +x full-install-arduino.sh
    ```
2.  **Execute o script**:
    ```bash
    ./full-install-arduino.sh
    ```
3.  **Senha de Administrador**: O sistema solicitará sua senha para instalar a IDE no diretório `/opt`.
4.  **Reinicie a sessão**: Se o seu usuário for adicionado ao grupo `dialout` (para acessar a porta USB), você deve fazer **Logout** e **Login** novamente para que a alteração tenha efeito.
5.  **Preferências existentes**: No Linux, o instalador preserva as preferências já definidas e só adiciona valores padrão ausentes. Se uma etapa necessária falhar, ele encerra com erro em vez de informar sucesso.

---

## 🛠️ Como acessar o ArduBlock após instalar

Independente do sistema, o processo para abrir a interface de blocos é o mesmo:

1.  Abra o **Arduino IDE**.
2.  No menu superior, vá em **Ferramentas (Tools)**.
3.  Clique em **ArduBlock**.
4.  Uma nova janela se abrirá com a interface de programação por blocos.

### Configurações Padrão Aplicadas
Os scripts já deixam a IDE pré-configurada com:
* **Placa**: Arduino Uno.
* **Processador**: ATmega328P.
* **Idioma**: Português Brasil (pt_BR).
