library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Bloco ENTITY que estava faltando ou incorreto
entity processador is
    Port (
        clk         : in  STD_LOGIC;
        rst         : in  STD_LOGIC;
        io_in_data  : in  STD_LOGIC_VECTOR(15 downto 0);
        io_out_data : out STD_LOGIC_VECTOR(15 downto 0);
        io_write_en : out STD_LOGIC;
        io_read_en  : out STD_LOGIC;
        R1_out : out std_logic_vector(15 downto 0)

    );
end processador;


-- Bloco ARCHITECTURE que já corrigimos antes
architecture Structural of processador is

    -- === Sinais internos ===
    signal rom_data          : STD_LOGIC_VECTOR(15 downto 0);
    signal pc_rom_addr       : STD_LOGIC_VECTOR(15 downto 0);
    signal flags             : STD_LOGIC_VECTOR(15 downto 0);
    signal ir_data           : STD_LOGIC_VECTOR(15 downto 0);
    signal mem_addr          : STD_LOGIC_VECTOR(15 downto 0);
    signal mem_sel           : STD_LOGIC;
    signal mem_we            : STD_LOGIC;
    signal reg_write_en      : STD_LOGIC;
    signal rd_data_sel       : STD_LOGIC_VECTOR(1 downto 0);
    signal alu_op            : STD_LOGIC_VECTOR(3 downto 0);
    signal alu_sel_a         : STD_LOGIC;
    signal alu_sel_b         : STD_LOGIC;
    signal immed             : STD_LOGIC_VECTOR(15 downto 0);
    signal addr_rd           : STD_LOGIC_VECTOR(2 downto 0);
    signal addr_rm           : STD_LOGIC_VECTOR(2 downto 0);
    signal addr_rn           : STD_LOGIC_VECTOR(2 downto 0);
    signal pc_dp             : STD_LOGIC_VECTOR(15 downto 0);
    signal cpu_io_write_en   : STD_LOGIC;
    signal cpu_io_read_en    : STD_LOGIC;
    signal cpu_io_data_sel   : STD_LOGIC;
    signal dp_data_out_to_io : STD_LOGIC_VECTOR(15 downto 0);
    signal io_data_to_dp     : STD_LOGIC_VECTOR(15 downto 0);

begin

    -- Para SIMULAÇÃO, use a ROM de teste.
    -- Para SÍNTESE FINAL, troque 'ROM_teste_io' por 'ROM'.
    ROM_prog: entity work.ROM_teste_io
        port map (
            addr => pc_rom_addr,
            en   => '1',
            clk  => clk,
            dout => rom_data
        );

    CPU_inst: entity work.CPU_core
        port map (
            clk             => clk,
            rst             => rst,
            ROM_mem         => rom_data,
            flags_dp        => flags,
            pc_dp           => pc_rom_addr,
            ir_data_out     => ir_data,
            mem_addr_out    => mem_addr,
            mem_addr_sel    => mem_sel,
            mem_we_out      => mem_we,
            io_read_en_out  => cpu_io_read_en,
            io_write_en_out => cpu_io_write_en,
            rd_write_en_out => reg_write_en,
            rd_data_sel_out => rd_data_sel,
            alu_op_out      => alu_op,
            alu_a_sel_out   => alu_sel_a,
            alu_b_sel_out   => alu_sel_b,
            immed_out       => immed,
            addr_rd_out     => addr_rd,
            addr_rm_out     => addr_rm,
            addr_rn_out     => addr_rn,
            io_data_sel_out => cpu_io_data_sel
        );

    DP_inst: entity work.Datapath
        port map (
            clk           => clk,
            rst           => rst,
            data_IO       => io_data_to_dp,
            data_JUMPER   => immed,
            data_ULA      => (others => '0'),
            data_STACK    => (others => '0'),
            immed_in      => immed,
            rd_write_en   => reg_write_en,
            rd_data_sel   => rd_data_sel,
            alu_a_sel     => alu_sel_a,
            alu_b_sel     => alu_sel_b,
            alu_op        => alu_op,
            addr_rd_sel   => addr_rd,
            addr_rm_sel   => addr_rm,
            addr_rn_sel   => addr_rn,
            io_data_sel   => cpu_io_data_sel,
            data_out      => dp_data_out_to_io,
            flag_z        => flags(6),
            flag_c        => flags(0),
            R1_out => R1_out
        );

    IO_inst: entity work.IO_Device
        port map (
            clk      => clk,
            rst      => rst,
            write_en => cpu_io_write_en,
            read_en  => cpu_io_read_en,
            data_in  => dp_data_out_to_io,
            data_out => io_data_to_dp
        );

    -- Conexão final com as portas externas do processador
    io_write_en <= cpu_io_write_en;
    io_read_en  <= cpu_io_read_en;
    io_out_data <= dp_data_out_to_io;
    io_data_to_dp <= io_in_data;

end Structural;