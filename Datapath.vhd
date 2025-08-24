library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Datapath is
    Port (
        clk           : in  STD_LOGIC;
        rst           : in  STD_LOGIC;
        data_IO       : in  STD_LOGIC_VECTOR(15 downto 0);
        data_JUMPER   : in  STD_LOGIC_VECTOR(15 downto 0);
        data_ULA      : in  STD_LOGIC_VECTOR(15 downto 0);
        data_STACK    : in  STD_LOGIC_VECTOR(15 downto 0);
        immed_in      : in  STD_LOGIC_VECTOR(15 downto 0);
        rd_write_en   : in  STD_LOGIC;
        rd_data_sel   : in  STD_LOGIC_VECTOR(1 downto 0);
        alu_a_sel     : in  STD_LOGIC;
        alu_b_sel     : in  STD_LOGIC;
        alu_op        : in  STD_LOGIC_VECTOR(3 downto 0);
        addr_rd_sel   : in  STD_LOGIC_VECTOR(2 downto 0);
        addr_rm_sel   : in  STD_LOGIC_VECTOR(2 downto 0);
        addr_rn_sel   : in  STD_LOGIC_VECTOR(2 downto 0);
        io_data_sel   : in  STD_LOGIC;
        data_out      : out STD_LOGIC_VECTOR(15 downto 0);
        flag_z        : out STD_LOGIC;
        flag_c        : out STD_LOGIC;
        R1_out : out std_logic_vector(15 downto 0)

    );
end Datapath;


architecture Structural of Datapath is
    -- Componentes (ULA2 e BancoReg)
    component BancoReg is
        Port (
            clk    : in  STD_LOGIC;
            rst    : in  STD_LOGIC;
            Rd_wr  : in  STD_LOGIC;
            Rm_sel : in  STD_LOGIC_VECTOR(2 downto 0);
            Rn_sel : in  STD_LOGIC_VECTOR(2 downto 0);
            Rd_sel : in  STD_LOGIC_VECTOR(2 downto 0);
            Rd     : in  STD_LOGIC_VECTOR(15 downto 0);
            Rm     : out STD_LOGIC_VECTOR(15 downto 0);
            Rn     : out STD_LOGIC_VECTOR(15 downto 0)
        );
        
    end component;
    


    component ULA2 is
        Port (
            A       : in  STD_LOGIC_VECTOR(15 downto 0);
            B       : in  STD_LOGIC_VECTOR(15 downto 0);
            op      : in  STD_LOGIC_VECTOR(3 downto 0);
            ULA_out : out STD_LOGIC_VECTOR(15 downto 0);
            flag_z  : out STD_LOGIC;
            flag_c  : out STD_LOGIC
        );
    end component;
    
    -- Sinais internos
    signal rm_val, rn_val    : STD_LOGIC_VECTOR(15 downto 0);
    signal ULA_out_val       : STD_LOGIC_VECTOR(15 downto 0);
    signal alu_in_a, alu_in_b: STD_LOGIC_VECTOR(15 downto 0);
    signal rd_write_data     : STD_LOGIC_VECTOR(15 downto 0);

begin
    u_ULA: ULA2
        port map (
            A       => alu_in_a,
            B       => alu_in_b,
            op      => alu_op,
            ULA_out => ULA_out_val,
            flag_z  => flag_z,
            flag_c  => flag_c
        );

    RegisterFile: BancoReg
        port map (
            clk    => clk,
            rst    => rst,
            Rd_wr  => rd_write_en,
            Rm_sel => addr_rm_sel,
            Rn_sel => addr_rn_sel,
            Rd_sel => addr_rd_sel,
            Rd     => rd_write_data,
            Rm     => rm_val,
            Rn     => rn_val
        );

    -- Lógica dos MUX
    alu_in_a <= rm_val; -- Simplificado, pode ser expandido com PC etc.
    alu_in_b <= immed_in when alu_b_sel = '1' else rn_val;

    with rd_data_sel select
    rd_write_data <= data_STACK  when "00",
                     data_JUMPER when "01",
                     data_IO     when "10",
                     data_ULA    when "11",
                     (others => '0') when others;

    -- NOVA LÓGICA QUE USA O SINAL DE CONTROLE
    -- Seleciona o dado a ser enviado para a porta de saída (usada pelo IO_Device)
    data_out <= immed_in when io_data_sel = '1' else rm_val;

R1_out <= rm_val when addr_rm_sel = "001" else (others => 'Z');

end Structural;