# Processador Didático de 16 bits com E/S em VHDL
Este repositório contém o projeto de um processador didático de 16 bits desenvolvido em VHDL. O projeto foi realizado para a disciplina de Sistemas Digitais para Computadores (QXD0146) da Universidade Federal do Ceará (UFC), campus Quixadá, sob a orientação do Prof. Cristiano.

O objetivo principal foi a implementação de um conjunto de instruções customizado, com foco nas operações de Pilha, ULA, Desvio e, principalmente, Entrada/Saída (E/S), em um processador com arquitetura baseada em Unidade de Controle e Datapath separados.


 ## Instruções Implementadas
 O processador implementa um subconjunto de instruções, incluindo:

* **Grupo de Pilha**: `PSH`, `POP`.
* **Grupo de ULA**: `CMP`, `SHR`, `SHL`, `ROR`, `ROL`.
* **Grupo de Desvio**: `JMP`, `JEQ`, `JLT`, `JGT`.
* **Grupo de Entrada/Saída**: `IN Rd`, `OUT Rm`, `OUT #Im`.

## Arquitetura do Processador
A arquitetura segue um modelo clássico com Unidade de Controle e Caminho de Dados (Datapath) separados, onde cada componente possui uma responsabilidade bem definida.

* **Unidade de Controle (`FSM2.vhd`)**: Implementada como uma Máquina de Estados Finitos (FSM), atua como o cérebro do processador. Ela é responsável por seguir o ciclo de busca, decodificação e execução, gerando todos os sinais de controle necessários para os outros componentes.
* **Componente Central (`CPU_core.vhd`)**: Atua como a "cola" da unidade de processamento, contendo os registradores essenciais para o fluxo do programa (PC e IR) e instanciando a FSM. Ele também decodifica campos da instrução, como valores imediatos e endereços de registradores.
* **Caminho de Dados (`Datapath.vhd`)**: É o "músculo" do processador, onde os dados são manipulados. Contém a Unidade Lógica e Aritmética (`ULA2`) e o Banco de Registradores (`BancoRegs`).
* **Memória e Periféricos**: O sistema interage com uma memória de instruções (`ROM_teste_io`) e um dispositivo de Entrada/Saída simulado (`IO_Device`).

## Estrutura dos Arquivos

| Arquivo | Descrição |
| :--- | :--- |
| `Processador.vhd` | Módulo de topo do hardware, que conecta todos os componentes principais. |
| `CPU_core.vhd` | Unidade central, contém o PC, IR e instancia a FSM. Decodifica campos da instrução. |
| `FSM2.vhd` | Unidade de Controle (Máquina de Estados Finitos). Gera os sinais de controle. |
| `Datapath.vhd` | Caminho de Dados. Contém a ULA e o Banco de Registradores, executa as operações. |
| `BancoRegs.vhd` | Banco com 8 registradores de uso geral de 16 bits. |
| `Registrador.vhd` | Bloco de construção para um registrador genérico de 16 bits com `load enable`. |
| `ULA2.vhd` | Unidade Lógica e Aritmética de 16 bits. |
| `IO_Device.vhd` | Simula um dispositivo periférico de Entrada/Saída com um registrador interno. |
| `ROM_teste_io.vhd`| Memória ROM usada para a simulação, contendo o programa de teste para as instruções de E/S. |
| `tb_processador_io.vhd` | Testbench para a verificação funcional do processador, focado nas instruções de E/S. |


## Ferramentas Utilizadas
* **Software:** Xilinx Vivado v2024.2 
* **Linguagem:** VHDL
* **Hardware Alvo:** FPGA Xilinx Zynq-7000 (especificamente a parte `xc7z010clg400-1`) 
* **Placa de Desenvolvimento:** Digilent Zybo
* **Link:https://www.xilinx.com/support/download.html


## Como Simular o Projeto

###  Usando a GUI do Vivado
1.  Abra o projeto (`E_S.xpr`) no Vivado.
2.  Na janela "Sources", certifique-se de que os top-levels estão configurados corretamente:
    * Para **Síntese**: `Processador.vhd` (`Set as Top` em "Design Sources").
    * Para **Simulação**: `tb_processador_io.vhd` (`Set as Top` em "Simulation Sources").
3.  No painel esquerdo, clique em `Run Simulation -> Run Behavioral Simulation`.


* ## Autores e Contribuições
Este projeto foi desenvolvido em equipe, com as seguintes contribuições:

* **Ana Alicy Ribeiro**: Implementação e teste do grupo de instruções de **Entrada e Saída (`IN`, `OUT`)**, depuração final e integração do sistema.
* **Ana Beatriz Leite Damascena**: Implementação do grupo de instruções da **ULA (`CMP`, `SHR`, `SHL`, `ROR`, `ROL`)**.
* **Cicero Rodrigues da Silva Neto**: Implementação do grupo de instruções de **Pilha (`PSH`, `POP`)**.
* **Fabio Rodrigues Borges Filho**: Implementação do grupo de instruções de **Desvio (`JMP`, `JEQ`, `JLT`, `JGT`)**.
