library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FSM2 is
    port (
        clk            : in  std_logic;
        rst            : in  std_logic;
        IR_data        : in  std_logic_vector(15 downto 0);
        flag_z         : in  std_logic;
        flag_c         : in  std_logic;
        pc_we          : out std_logic;
        pc_inc_en      : out std_logic;
        ir_we          : out std_logic;
        mar_sel        : out std_logic;
        mem_we         : out std_logic;
        reg_we         : out std_logic;
        reg_sel_dest   : out std_logic_vector(2 downto 0);
        alu_op         : out std_logic_vector(3 downto 0);
        alu_sel_a      : out std_logic_vector(1 downto 0);
        alu_sel_b      : out std_logic_vector(1 downto 0);
        io_read_en     : out std_logic;
        io_write_en    : out std_logic;
        sp_decr_en     : out std_logic;
        sp_inc_en      : out std_logic;
        sel_mux        : out std_logic_vector(1 downto 0);
        io_data_sel : out STD_LOGIC
    );
end entity FSM2;

architecture fsm_arch of FSM2 is
    type state_t is (
        s_fetch, s_decode, s_exec_psh_rn, s_exec_pop_rd, s_exec_cmp,
        s_exec_branch, s_exec_in, s_exec_out_rm, s_exec_out_im,
        s_exec_shr, s_exec_shl, s_exec_ror, s_exec_rol
    );
    signal current_state, next_state : state_t;

    -- Constantes da ULA e MUX
    constant ALU_OP_CMP    : std_logic_vector(3 downto 0) := "0001";
    constant ALU_OP_ADD    : std_logic_vector(3 downto 0) := "0010";
    constant ALU_OP_SHR    : std_logic_vector(3 downto 0) := "0011";
    constant ALU_OP_SHL    : std_logic_vector(3 downto 0) := "0100";
    constant ALU_OP_ROR    : std_logic_vector(3 downto 0) := "0101";
    constant ALU_OP_ROL    : std_logic_vector(3 downto 0) := "0110";
    constant ALU_OP_PASS_B : std_logic_vector(3 downto 0) := "0111";
    constant mux_STACK     : std_logic_vector(1 downto 0) := "00";
    constant mux_JUMPER    : std_logic_vector(1 downto 0) := "01";
    constant mux_IO        : std_logic_vector(1 downto 0) := "10";
    constant mux_ULA       : std_logic_vector(1 downto 0) := "11";

begin
    -- Processo de atualização de estado (síncrono)
    process(clk, rst)
    begin
        if rst = '1' then
            current_state <= s_fetch;
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;

    -- Lógica combinacional de próximo estado e saídas
    process(current_state, IR_data, flag_z, flag_c)
    begin
        -- Valores padrão para os sinais
        pc_we        <= '0';
        pc_inc_en    <= '0';
        ir_we        <= '0';
        mar_sel      <= '0';
        mem_we       <= '0';
        reg_we       <= '0';
        reg_sel_dest <= "000";
        alu_op       <= "0000";
        alu_sel_a    <= "00";
        alu_sel_b    <= "00";
        io_read_en   <= '0';
        io_write_en  <= '0';
        sp_decr_en   <= '0';
        sp_inc_en    <= '0';
        sel_mux      <= mux_ULA;
        io_data_sel  <= '0';
        next_state   <= s_fetch;

        case current_state is
            when s_fetch =>
                mar_sel   <= '0';
                ir_we     <= '1';
                pc_inc_en <= '1';
                next_state<= s_decode;

            when s_decode =>
                -- LÓGICA DE DECODIFICAÇÃO CORRIGIDA COM IF-ELSIF
                -- Checa primeiro os opcodes de 5 bits
                if IR_data(15 downto 11) = "00000" then      -- Grupo PILHA/ULA
                    if IR_data(1 downto 0) = "01" then
                        next_state <= s_exec_psh_rn;
                    elsif IR_data(1 downto 0) = "10" then
                        next_state <= s_exec_pop_rd;
                    elsif IR_data(1 downto 0) = "11" then
                        next_state <= s_exec_cmp;
                    else
                        next_state <= s_fetch;
                    end if;
                elsif IR_data(15 downto 11) = "00001" then  -- Desvios
                    next_state <= s_exec_branch;
                elsif IR_data(15 downto 11) = "11111" then  -- E/S
                    if IR_data(1 downto 0) = "01" then
                        next_state <= s_exec_in;
                    else
                        next_state <= s_exec_out_im;
                    end if;
                elsif IR_data(15 downto 11) = "11110" then  -- E/S
                    next_state <= s_exec_out_rm;
                -- Agora checa os opcodes de 4 bits
                elsif IR_data(15 downto 12) = "1011" then  -- SHR
                    next_state <= s_exec_shr;
                elsif IR_data(15 downto 12) = "1100" then  -- SHL
                    next_state <= s_exec_shl;
                elsif IR_data(15 downto 12) = "1101" then  -- ROR
                    next_state <= s_exec_ror;
                elsif IR_data(15 downto 12) = "1110" then  -- ROL
                    next_state <= s_exec_rol;
                else -- Se não for nenhuma das anteriores
                    next_state <= s_fetch;
                end if;

            when s_exec_psh_rn =>
                mar_sel    <= '1';
                mem_we     <= '1';
                sel_mux    <= mux_STACK;
                sp_decr_en <= '1';
                next_state <= s_fetch;

            when s_exec_pop_rd =>
                mar_sel    <= '1';
                reg_we     <= '1';
                reg_sel_dest <= IR_data(10 downto 8);
                sel_mux    <= mux_STACK;
                sp_inc_en  <= '1';
                next_state <= s_fetch;

            when s_exec_cmp =>
                alu_op     <= ALU_OP_CMP;
                sel_mux    <= mux_ULA;
                next_state <= s_fetch;

            when s_exec_branch =>
                sel_mux <= mux_JUMPER;
                case IR_data(1 downto 0) is
                    when "00" => -- JMP
                        pc_we <= '1';
                        alu_op <= ALU_OP_ADD;
                    when "01" => -- JEQ
                        if flag_z = '1' and flag_c = '0' then
                            pc_we <= '1';
                            alu_op <= ALU_OP_ADD;
                        end if;
                    when "10" => -- JLT
                        if flag_z = '0' and flag_c = '1' then
                            pc_we <= '1';
                            alu_op <= ALU_OP_ADD;
                        end if;
                    when "11" => -- JGT
                        if flag_z = '0' and flag_c = '0' then
                            pc_we <= '1';
                            alu_op <= ALU_OP_ADD;
                        end if;
                    when others => null;
                end case;
                next_state <= s_fetch;

            when s_exec_in =>
                reg_we       <= '1';
                reg_sel_dest <= IR_data(10 downto 8);
                io_read_en   <= '1';
                sel_mux      <= mux_IO;
                next_state   <= s_fetch;

            when s_exec_out_rm =>
                io_write_en <= '1';
                io_data_sel <= '0';
                next_state  <= s_fetch;

            when s_exec_out_im =>
                io_write_en <= '1';
                io_data_sel <= '1';
                next_state  <= s_fetch;

            when s_exec_shr =>
                reg_we       <= '1';
                reg_sel_dest <= IR_data(10 downto 8);
                alu_op       <= ALU_OP_SHR;
                sel_mux      <= mux_ULA;
                next_state   <= s_fetch;

            when s_exec_shl =>
                reg_we       <= '1';
                reg_sel_dest <= IR_data(10 downto 8);
                alu_op       <= ALU_OP_SHL;
                sel_mux      <= mux_ULA;
                next_state   <= s_fetch;

            when s_exec_ror =>
                reg_we       <= '1';
                reg_sel_dest <= IR_data(10 downto 8);
                alu_op       <= ALU_OP_ROR;
                sel_mux      <= mux_ULA;
                next_state   <= s_fetch;

            when s_exec_rol =>
                reg_we       <= '1';
                reg_sel_dest <= IR_data(10 downto 8);
                alu_op       <= ALU_OP_ROL;
                sel_mux      <= mux_ULA;
                next_state   <= s_fetch;
        end case;
    end process;
end architecture fsm_arch;
