library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity BancoReg is
    Port (
        clk    : in STD_LOGIC;
        rst    : in STD_LOGIC;
        Rd_wr  : in STD_LOGIC;
        Rd_sel : in STD_LOGIC_VECTOR(2 downto 0);   -- selecionar registrador de destino
        Rm_sel : in STD_LOGIC_VECTOR(2 downto 0);   -- selecionar registrador fonte 1
        Rn_sel : in STD_LOGIC_VECTOR(2 downto 0);   -- selecionar registrador fonte 2
        Rd     : in STD_LOGIC_VECTOR(15 downto 0);  -- dado a ser escrito
        Rm     : out STD_LOGIC_VECTOR(15 downto 0); -- saída do registrador Rm
        Rn     : out STD_LOGIC_VECTOR(15 downto 0)  -- saída do registrador Rn
    );
end BancoReg;

architecture Behavioral of BancoReg is
    type BancoRegArray is array(0 to 7) of STD_LOGIC_VECTOR(15 downto 0);
    signal Reg : BancoRegArray;
    signal control : STD_LOGIC_VECTOR(7 downto 0);  -- controle de carregamento

begin
    -- Gerar sinais de carga para cada registrador
    process(Rd_wr, Rd_sel)
    begin
        control <= (others => '0');
        if Rd_wr = '1' then
            control(conv_integer(unsigned(Rd_sel))) <= '1';
        end if;
    end process;

    -- Instanciar os 8 registradores
    g1 : for i in 0 to 7 generate
        Rp : entity work.Registrador(Behavioral)
            port map (
                D   => Rd,
                clk => clk,
                rst => rst,
                ld  => control(i),
                Q   => Reg(i)
            );
    end generate;

    -- Multiplexadores para saída dos registradores fonte
    Rm <= Reg(conv_integer(unsigned(Rm_sel)));
    Rn <= Reg(conv_integer(unsigned(Rn_sel)));

end Behavioral;
