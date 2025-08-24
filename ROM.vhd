library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ROM is
    Port (
        addr : in  STD_LOGIC_VECTOR(15 downto 0);
        en   : in  STD_LOGIC;
        clk  : in  STD_LOGIC;
        dout : out STD_LOGIC_VECTOR(15 downto 0)
    );
end ROM;

architecture Behavioral of ROM is
    type memory is array(0 to 127) of std_logic_vector(7 downto 0);
    signal ROM_DATA : memory := (
        -- Programa de teste
        x"19", x"07",   -- mov r1, 7
        x"1A", x"05",   -- mov r2, 5
        x"43", x"28",   -- add r1, r2 → r3
        x"F0", x"62",   -- out r3
        x"F4", x"01",   -- in → r4
        others => x"00" -- Resto preenchido com 0
    );
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if en = '1' then
                dout(15 downto 8) <= ROM_DATA(to_integer(unsigned(addr)));
                dout(7 downto 0)  <= ROM_DATA(to_integer(unsigned(addr)) + 1);
            end if;
        end if;
    end process;
end Behavioral;
