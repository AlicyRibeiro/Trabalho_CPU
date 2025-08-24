library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity IO_Device is
    Port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        write_en  : in  std_logic;                        -- Ativado pela instrução OUT
        read_en   : in  std_logic;                        -- Ativado pela instrução IN
        data_in   : in  std_logic_vector(15 downto 0);    -- Vem do Datapath (para escrita)
        data_out  : out std_logic_vector(15 downto 0)     -- Vai para o Datapath (para leitura)
    );
end IO_Device;

architecture Behavioral of IO_Device is
    signal internal_reg : std_logic_vector(15 downto 0) := (others => '0');
begin

    -- Escrita no registrador interno (OUT)
    process(clk, rst)
    begin
        if rst = '1' then
            internal_reg <= (others => '0');
        elsif rising_edge(clk) then
            if write_en = '1' then
                internal_reg <= data_in;
            end if;
        end if;
    end process;

    -- Leitura condicional do registrador (IN)
    data_out <= internal_reg when read_en = '1' else (others => 'Z'); -- alta impedância se não estiver lendo

end Behavioral;
