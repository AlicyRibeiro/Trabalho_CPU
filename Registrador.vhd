library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Registrador is
    Generic (
        valor : STD_LOGIC_VECTOR(15 downto 0) := x"0000"  -- Valor padrão após reset
    );
    Port ( 
        D   : in  STD_LOGIC_VECTOR(15 downto 0); -- Entrada de dados
        clk : in  STD_LOGIC;                     -- Clock
        rst : in  STD_LOGIC;                     -- Reset
        ld  : in  STD_LOGIC;                     -- Load habilitado
        Q   : out STD_LOGIC_VECTOR(15 downto 0)  -- Saída
    );
end Registrador;

architecture Behavioral of Registrador is
begin
    process(clk, rst)
    begin
        if rst = '1' then
            Q <= valor;  -- Reset assíncrono
        elsif rising_edge(clk) then
            if ld = '1' then
                Q <= D;  -- Carga condicional
            end if;
        end if;
    end process;
end Behavioral;
