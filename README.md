# 🚀 Instalação: Arduino + ArduBlock

Siga as instruções abaixo para instalar o Arduino IDE e o ArduBlock. Escolha a seção de acordo com o seu sistema operacional.

## 🪟 Windows (PowerShell)

### 📥 Download Direto
> [**Baixe o instalador do Windows (.exe) na release mais recente**](https://github.com/citesj/arduino-ardublock-atto-educacional/releases/latest)

### Pré-requisitos
* Ter privilégios de Administrador no computador.
* Conexão com a internet para baixar os componentes durante a instalação.

### Como usar
1. Baixe somente o arquivo `.exe` na seção **Assets** da release mais recente. Não é necessário baixar os scripts ou outros arquivos.
2. Abra o `.exe` e confirme a solicitação de administrador do Windows.
3. Aguarde enquanto o instalador baixa e configura o Arduino IDE 1.8.19 e o ArduBlock. A janela mostra o resultado e permanece aberta ao final.
4. Quando aparecer **INSTALAÇÃO CONCLUÍDA COM SUCESSO**, pressione Enter para fechar. A placa estará configurada como **Arduino Uno**.

O instalador do Windows não é assinado digitalmente e pode exibir um aviso do SmartScreen. Baixe-o apenas pela página oficial de releases acima.

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

<sub>Documentação para mantenedores: [gerar e assinar o instalador do Windows](./MANUTENCAO.md).</sub>
