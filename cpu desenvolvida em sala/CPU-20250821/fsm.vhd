----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.06.2025 16:43:35
-- Design Name: 
-- Module Name: fsm - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fsm is
  generic (N : integer := 16);
  Port (clk : in std_logic;
        rst: in std_logic;
        rom_en: out std_logic;
        pc_clr: out std_logic;
        pc_inc: out std_logic;
        ir_ld : out std_logic;
        ir_data : in std_logic_vector(N-1 downto 0);
        immed: out std_logic_vector(N-1 downto 0);
        ram_sel :out std_logic;
        ram_we:out std_logic;
        rf_sel: out std_logic_vector(1 downto 0);
        rm_sel: out std_logic_vector(2 downto 0);
        rn_sel : out std_logic_vector(2 downto 0);
        rd_sel: out std_logic_vector(2 downto 0);
        rd_wr : out std_logic;
        ula_op: out std_logic_vector(3 downto 0)
   );
end fsm;

architecture Behavioral of fsm is

-- Estados da FSM
type state_type is (init,
                    fetch,
                    decode, 
                    exec_nop, 
                    exec_halt, 
                    exec_mov, 
                    exec_load, 
                    exec_store, 
                    exec_ula);

-- Sinais para represntar os estados
signal current_state, next_state: state_type;

-- Instrução lida
signal instruction: std_logic_vector(N-1 downto 0);
signal opcode:  std_logic_vector(3 downto 0);

begin

STATE_UPDATE:
    process (clk, rst)
    begin
        if (rst='1') then
         current_state <= init;
        elsif (rising_edge(clk)) then
         current_state <= next_state;
        end if;
    end process;
    
SIGNALS_UPDATE:
    process (rst, current_state, instruction)
    begin
        if (rst='0') then
        case current_state is
        
            when init => 
              -- atualizar as saídas
                  pc_clr <= '1';
                  pc_inc <= '0';
                  rom_en <= '0';
                  ir_ld <= '0';
                  immed <= X"0000";
                  ram_sel <= '0';
                  ram_we  <= '0';
                  rf_sel <= "00";
                  rd_sel <= "000";
                  rd_wr  <= '0';
                  rm_sel <= "000";
                  rn_sel <= "000";
                  ula_op <= "0000";
              -- transicao de estado
              next_state <= fetch;
              
            when fetch => 
            -- atualizar as saídas
              pc_clr <= '0';
              pc_inc <= '1';
              rom_en <= '1';
              ir_ld <= '1';
              immed <= X"0000";
              ram_sel <= '0';
              ram_we  <= '0';
              rf_sel <= "00";
              rd_sel <= "000";
              rd_wr  <= '0';
              rm_sel <= "000";
              rn_sel <= "000";
              ula_op <= "0000";
            -- transicao de estado
            next_state <= decode;
              
              
            when decode =>  
            -- atualizar as saídas
              pc_clr <= '0';
              pc_inc <= '0';
              rom_en <= '0';
              ir_ld <= '0';
              immed <= X"0000";
              ram_sel <= '0';
              ram_we  <= '0';
              rf_sel <= "00";
              rd_sel <= "000";
              rd_wr  <= '0';
              rm_sel <= "000";
              rn_sel <= "000";
              ula_op <= "0000";
              
            -- transicao de estado
            if (opcode = "0000") then
                next_state <= exec_nop; 
            elsif (opcode = "1111") then
                next_state <= exec_halt;
            elsif (opcode = "0001") then
                next_state <= exec_mov;
            elsif (opcode = "0010") then
                next_state <=exec_store;
            elsif (opcode = "0011") then
                next_state <= exec_load;
            elsif (opcode = "0100") then
                next_state <= exec_ula;
            elsif (opcode = "0101") then
                 next_state <= exec_ula;
            elsif (opcode = "0110") then
                next_state <= exec_ula;
            elsif (opcode = "0111") then
                next_state <= exec_ula;
            elsif (opcode = "1000") then
                next_state <= exec_ula;
            elsif (opcode = "1001") then
                next_state <= exec_ula;
            elsif (opcode = "1010") then
                next_state <= exec_ula;
            else 
                next_state <= exec_nop;
            end if;
            
            when  exec_nop => 
            -- atualizar as saídas
              
            -- transicao de estado
                next_state <= fetch;
            when  exec_halt => 
            -- atualizar as saídas
              
            -- transicao de estado
            next_state <= exec_halt;
            
            when  exec_mov => 
            -- atualizar as saídas
              immed <= X"00" & instruction(7 downto 0);
              rd_sel <= instruction(10 downto 8);
              rm_sel <= instruction(7 downto 5);
              rf_sel <= instruction(11) & '0';
              rd_wr  <= '1';
 
            -- transicao de estado
                next_state <= fetch;
            when  exec_store => 
            -- atualizar as saídas
               immed <= X"00" & instruction(10 downto 8) & instruction(4 downto 0);
               rm_sel <= instruction(7 downto 5);
               rn_sel <= instruction(4 downto 2);
               ram_sel <= instruction(11);
               ram_we  <= '1';
             
              
            -- transicao de estado
            next_state <= fetch;
            
            when exec_load => 
            -- atualizar as saídas
              rf_sel <= "01";
              rd_sel <= instruction(10 downto 8);
              rd_wr  <= '1';
              rm_sel <= instruction(7 downto 5);
              
            -- transicao de estado
            next_state <= fetch;

            
            when  exec_ula=> 
            -- atualizar as saídas

              
              rm_sel <= instruction(7 downto 5);
              rn_sel <= instruction(4 downto 2);
              rd_sel <= instruction(10 downto 8);
              rd_wr  <= '1';
              rf_sel <= "11";       
              ula_op <= instruction(15 downto 12);
              
            -- transicao de estado
            next_state <= fetch;
        end case;
    end if;
    
    
    end process;
    



instruction <= ir_data;
opcode <= ir_data(15 downto 12);

end Behavioral;
