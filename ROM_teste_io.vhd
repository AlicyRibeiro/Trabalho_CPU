library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ROM_teste_io is
    Port (
        addr : in  STD_LOGIC_VECTOR(15 downto 0);
        en   : in  STD_LOGIC;
        clk  : in  STD_LOGIC;
        dout : out STD_LOGIC_VECTOR(15 downto 0)
    );
end ROM_teste_io;

architecture Behavioral of ROM_teste_io is
    -- A memória é de 8 bits, e o processador busca 16 bits por vez (2 posições)
    type memory is array(0 to 127) of std_logic_vector(7 downto 0);
    
    -- Programa de Teste para E/S
    -- 1. OUT #42   ; Escreve o valor imediato 42 (0x2A) no dispositivo de E/S
    -- 2. IN R1     ; Lê um valor do dispositivo de E/S e armazena em R1
    -- 3. OUT R1    ; Escreve o valor de R1 no dispositivo de E/S
    -- 4. JMP -2    ; Laço infinito para "parar" o processador
    signal ROM_DATA : memory := (
        -- Instrução 1: OUT #Im (opcode: 11111, imed: 0x2A). Usando um formato plausível: x"F82A"
        x"F8", x"2A",  -- Endereços 0, 1

        -- Instrução 2: IN R1 (opcode: 11111, Rd=1, modo=01): x"F901"
        x"F9", x"01",  -- Endereços 2, 3

        -- Instrução 3: OUT R1 (opcode: 11110, Rm=1): x"E0A0" (Rm=R1, bits 7-5 = 001 -> 0xA0)
        x"E0", x"A0",  -- Endereços 4, 5
        
        -- Instrução 4: JMP -2 (salto para si mesmo, PC = PC - 2)
        x"13", x"FC",  -- Endereços 6, 7

        -- Restante da memória preenchido com 0
        others => x"00"
    );
begin
    process(clk)
    begin
         if rising_edge(clk) then
        if en = '1' then
            -- Verifica se o endereço está dentro da faixa da nossa memória
            if (to_integer(unsigned(addr)) < ROM_DATA'length) then
                dout(15 downto 8) <= ROM_DATA(to_integer(unsigned(addr)));
                dout(7 downto 0)  <= ROM_DATA(to_integer(unsigned(addr)) + 1);
            else
                -- Para endereços fora da faixa, retorna um valor padrão (ex: 0)
                dout <= (others => '0');
            end if;
        end if;
    end if;
    end process;
end Behavioral;