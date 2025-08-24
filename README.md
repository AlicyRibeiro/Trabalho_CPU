# Sistemas-Digitais
 Implementação de instruções  para o processador desenvolvido em sala

# Processador Didático de 16 bits com E/S em VHDL
Este repositório contém o projeto de um processador didático de 16 bits desenvolvido em VHDL. O projeto foi realizado para a disciplina de Sistemas Digitais para Computadores (QXD0146) da Universidade Federal do Ceará (UFC), campus Quixadá, sob a orientação do Prof. Cristiano.

O objetivo principal foi a implementação de um conjunto de instruções customizado, com foco nas operações de Pilha, ULA, Desvio e, principalmente, Entrada/Saída (E/S), em um processador com arquitetura baseada em Unidade de Controle e Datapath separados.

 ## Instruções Implementadas
 O processador implementa um subconjunto de instruções, incluindo[cite: 29]:

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
