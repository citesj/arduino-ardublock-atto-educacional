# 🚀 Tutorial de Instalação: Arduino + ArduBlock

Este repositório contém scripts de automação para configurar rapidamente o ambiente de desenvolvimento. Escolha a seção abaixo de acordo com o seu sistema operacional.

## 🪟 Windows (PowerShell)

### Pré-requisitos
* Ter privilégios de Administrador no computador.
* Conexão com a internet para baixar os componentes.

### Como usar
1.  **Baixe o script**: Certifique-se de que o arquivo `full-install-arduino.ps1` está na sua pasta de Downloads.
2.  **Abra o PowerShell como Administrador**:
    * Clique no Menu Iniciar, digite "PowerShell".
    * Clique com o botão direito e selecione **"Executar como Administrador"**.
3.  **Habilite a execução de scripts** (caso necessário):
    * No terminal, digite: `Set-ExecutionPolicy RemoteSigned -Scope Process` e confirme com `S`.
4.  **Navegue até a pasta e execute**:
    ```powershell
    cd $env:USERPROFILE\Downloads
    .\full-install-arduino.ps1
    ```
5.  **Aguarde o [OK]**: O script baixará a IDE, instalará o ArduBlock e configurará a placa para **Arduino Duemilanove / ATmega328P** automaticamente.

---

## 🐧 Linux (Bash)

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

---

## 🛠️ Como acessar o ArduBlock após instalar

Independente do sistema, o processo para abrir a interface de blocos é o mesmo:

1.  Abra o **Arduino IDE**.
2.  No menu superior, vá em **Ferramentas (Tools)**.
3.  Clique em **ArduBlock**.
4.  Uma nova janela se abrirá com a interface de programação por blocos.

### Configurações Padrão Aplicadas
Os scripts já deixam a IDE pré-configurada com:
* **Placa**: Arduino Duemilanove or Diecimila.
* **Processador**: ATmega328P.
* **Idioma**: Português Brasil (pt_BR).
