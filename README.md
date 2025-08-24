# Sistemas-Digitais
 Implementação de instruções  para o processador desenvolvido em sala

# Processador Didático de 16 bits com E/S em VHDL
Este repositório contém o projeto de um processador didático de 16 bits desenvolvido em VHDL. O projeto foi realizado para a disciplina de Sistemas Digitais para Computadores (QXD0146) da Universidade Federal do Ceará (UFC), campus Quixadá, sob a orientação do Prof. Cristiano.

O objetivo principal foi a implementação de um conjunto de instruções customizado, com foco nas operações de Pilha, ULA, Desvio e, principalmente, Entrada/Saída (E/S), em um processador com arquitetura baseada em Unidade de Controle e Datapath separados.

 ## Instruções Implementadas
 O processador implementa um subconjunto de instruções, incluindo[cite: 29]:

* [cite_start]**Grupo de Pilha**: `PSH`, `POP`[cite: 29].
* [cite_start]**Grupo de ULA**: `CMP`, `SHR`, `SHL`, `ROR`, `ROL`[cite: 29].
* [cite_start]**Grupo de Desvio**: `JMP`, `JEQ`, `JLT`, `JGT`[cite: 29].
* [cite_start]**Grupo de Entrada/Saída**: `IN Rd`, `OUT Rm`, `OUT #Im`[cite: 29].
