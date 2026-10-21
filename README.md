# 🚀 Instalação: Arduino + ArduBlock

Siga as instruções abaixo para instalar o Arduino IDE e o ArduBlock. Escolha a seção de acordo com o seu sistema operacional.

## 🪟 Windows (PowerShell)

### 📥 Download Direto
> [**Clique aqui para baixar o instalador do Windows (.exe)**](https://github.com/citesj/arduino-ardublock-atto-educacional/releases/download/v1.0.1/instalador_arduino_ardublock.EXE)

### Pré-requisitos
* Ter privilégios de Administrador no computador.
* Conexão com a internet para baixar os componentes.

### Como usar
1.  **Baixe o instalador** pelo link acima.
2.  **Abra o arquivo baixado**: O Windows solicitará permissão de administrador. Confirme a janela do UAC para continuar.
3.  **Aguarde a automação**: O instalador baixará a IDE 1.8.19 e instalará o ArduBlock automaticamente. A janela permanecerá aberta para exibir o resultado.
4.  **Conclusão [OK]:**: Quando a mensagem "INSTALAÇÃO CONCLUÍDA" aparecer, a placa já estará configurada como **Arduino Uno** e pronta para uso. Pressione Enter para fechar a janela.

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
