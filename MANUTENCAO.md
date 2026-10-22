# Manutenção do instalador do Windows

Este documento é destinado a mantenedores que precisam gerar uma nova versão do instalador do Windows. As instruções de instalação para usuários finais estão no [README principal](./README.md).

## Gerar o instalador

Em um computador Windows com o PowerShell e o IExpress (incluído no Windows), execute na pasta do repositório:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\build-windows-installer.ps1
```

O executável será criado em `dist\Instalador_Arduino_Atto.exe`. Para escolher outro destino:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\build-windows-installer.ps1 -OutputPath C:\caminho\Instalador_Arduino_Atto.exe
```

O `.exe` contém o script de instalação e seu inicializador. Ele baixa o Arduino IDE e o ArduBlock durante a execução, portanto o computador de destino precisa de conexão com a internet. Não é necessário distribuir os arquivos `.ps1` separadamente.

## Publicar uma release

Ao publicar uma release no GitHub, o workflow [build-windows-installer.yml](./.github/workflows/build-windows-installer.yml) gera o executável no Windows e o anexa automaticamente como asset `Instalador_Arduino_Atto.exe`. Não é necessário gerar nem anexar o arquivo manualmente.

O executável não é assinado digitalmente; o Windows pode exibir um aviso do SmartScreen. A publicação é feita na página oficial de releases do repositório.
