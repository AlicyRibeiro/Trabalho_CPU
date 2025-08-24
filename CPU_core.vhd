library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CPU_core is
    Port (
        clk             : in  STD_LOGIC;
        rst             : in  STD_LOGIC;
        ROM_mem         : in  STD_LOGIC_VECTOR(15 downto 0);
        flags_dp        : in  STD_LOGIC_VECTOR(15 downto 0);
        pc_dp           : in  STD_LOGIC_VECTOR(15 downto 0);
        ir_data_out     : out STD_LOGIC_VECTOR(15 downto 0);
        mem_addr_out    : out STD_LOGIC_VECTOR(15 downto 0);
        mem_addr_sel    : out STD_LOGIC;
        mem_we_out      : out STD_LOGIC;
        io_read_en_out  : out STD_LOGIC;
        io_write_en_out : out STD_LOGIC;
        rd_write_en_out : out STD_LOGIC;
        rd_data_sel_out : out STD_LOGIC_VECTOR(1 downto 0);
        alu_op_out      : out STD_LOGIC_VECTOR(3 downto 0);
        alu_a_sel_out   : out STD_LOGIC;
        alu_b_sel_out   : out STD_LOGIC;
        immed_out       : out STD_LOGIC_VECTOR(15 downto 0);
        addr_rd_out     : out STD_LOGIC_VECTOR(2 downto 0);
        addr_rm_out     : out STD_LOGIC_VECTOR(2 downto 0);
        addr_rn_out     : out STD_LOGIC_VECTOR(2 downto 0);
        io_data_sel_out : out STD_LOGIC
    );
end CPU_core;

architecture Structural of CPU_core is

    component FSM2 is
        port (
            clk          : in  std_logic;
            rst          : in  std_logic;
            IR_data      : in  std_logic_vector(15 downto 0);
            flag_z       : in  std_logic;
            flag_c       : in  std_logic;
            pc_we        : out std_logic;
            pc_inc_en    : out std_logic;
            ir_we        : out std_logic;
            mar_sel      : out std_logic;
            mem_we       : out std_logic;
            reg_we       : out std_logic;
            reg_sel_dest : out std_logic_vector(2 downto 0);
            alu_op       : out std_logic_vector(3 downto 0);
            alu_sel_a    : out std_logic_vector(1 downto 0);
            alu_sel_b    : out std_logic_vector(1 downto 0);
            io_read_en   : out std_logic;
            io_write_en  : out std_logic;
            sp_decr_en   : out std_logic;
            sp_inc_en    : out std_logic;
            io_data_sel  : out std_logic;
            sel_mux      : out std_logic_vector(1 downto 0)
        );
    end component;

    signal fsm_pc_we, fsm_pc_inc, fsm_ir_we, fsm_mem_we                   : STD_LOGIC;
    signal fsm_sp_decr, fsm_sp_inc, fsm_reg_we, fsm_io_read, fsm_io_write : STD_LOGIC;
    signal fsm_mar_sel                                                   : STD_LOGIC;
    signal fsm_io_data_sel                                               : STD_LOGIC;
    signal fsm_alu_op                                                    : STD_LOGIC_VECTOR(3 downto 0);
    signal fsm_alu_a_sel_v, fsm_alu_b_sel_v                              : STD_LOGIC_VECTOR(1 downto 0);
    signal fsm_sel_mux                                                   : STD_LOGIC_VECTOR(1 downto 0);
    signal fsm_reg_sel_dest                                              : STD_LOGIC_VECTOR(2 downto 0);
    signal ir_data, sp_val, pc_val, pc_next_val, sp_next_val             : STD_LOGIC_VECTOR(15 downto 0);

begin

    FSM_inst : FSM2
        port map (
            clk          => clk,
            rst          => rst,
            IR_data      => ir_data,
            flag_z       => flags_dp(6),
            flag_c       => flags_dp(0),
            pc_we        => fsm_pc_we,
            pc_inc_en    => fsm_pc_inc,
            ir_we        => fsm_ir_we,
            mar_sel      => fsm_mar_sel,
            mem_we       => fsm_mem_we,
            reg_we       => fsm_reg_we,
            reg_sel_dest => fsm_reg_sel_dest,
            alu_op       => fsm_alu_op,
            alu_sel_a    => fsm_alu_a_sel_v,
            alu_sel_b    => fsm_alu_b_sel_v,
            io_read_en   => fsm_io_read,
            io_write_en  => fsm_io_write,
            sp_decr_en   => fsm_sp_decr,
            sp_inc_en    => fsm_sp_inc,
            sel_mux      => fsm_sel_mux,
            io_data_sel  => fsm_io_data_sel
        );

    -- Processo do Instruction Register (IR)
    process(clk, rst)
    begin
        if rst = '1' then
            ir_data <= (others => '0');
        elsif rising_edge(clk) then
            if fsm_ir_we = '1' then
                ir_data <= ROM_mem;
            end if;
        end if;
    end process;

    -- Lógica do Program Counter (PC)
    pc_next_val <= pc_dp when fsm_pc_we = '1' else
                   std_logic_vector(unsigned(pc_val) + 1) when fsm_pc_inc = '1' else
                   pc_val;

    process(clk, rst)
    begin
        if rst = '1' then
            pc_val <= (others => '0');
        elsif rising_edge(clk) then
            pc_val <= pc_next_val;
        end if;
    end process;

    -- Lógica do Stack Pointer (SP)
    sp_next_val <= std_logic_vector(unsigned(sp_val) - 1) when fsm_sp_decr = '1' else
                   std_logic_vector(unsigned(sp_val) + 1) when fsm_sp_inc = '1' else
                   sp_val;

    process(clk, rst)
    begin
        if rst = '1' then
            sp_val <= x"00FF";
        elsif rising_edge(clk) then
            sp_val <= sp_next_val;
        end if;
    end process;

    -- Decodificador de valor imediato - CORRIGIDO
    process(ir_data)
    begin
        if ir_data(15 downto 11) = "00001" then -- Para desvios (JMP)
            immed_out <= std_logic_vector(resize(signed(ir_data(10 downto 2)), 16));
        elsif ir_data(15 downto 11) = "11111" and ir_data(1 downto 0) /= "01" then -- Para OUT #Im
            immed_out <= "00000000" & ir_data(7 downto 0); -- Pega os 8 bits de baixo
        else -- Para outros casos (como SHR #Im)
            immed_out <= "00000000000" & ir_data(4 downto 0);
        end if;
    end process;

    -- Decodificadores de endereço
    addr_rd_out <= fsm_reg_sel_dest;
    addr_rm_out <= ir_data(7 downto 5);
    addr_rn_out <= ir_data(4 downto 2);

    -- Conexões de saída
    mem_addr_sel    <= fsm_mar_sel;
    mem_addr_out    <= sp_val when fsm_mar_sel = '1' else pc_val;
    mem_we_out      <= fsm_mem_we;
    rd_write_en_out <= fsm_reg_we;
    alu_op_out      <= fsm_alu_op;
    alu_a_sel_out   <= fsm_alu_a_sel_v(0);
    alu_b_sel_out   <= fsm_alu_b_sel_v(0);
    io_read_en_out  <= fsm_io_read;
    io_write_en_out <= fsm_io_write;
    rd_data_sel_out <= fsm_sel_mux;
    IR_data_out     <= ir_data;
    io_data_sel_out <= fsm_io_data_sel;

end Structural;