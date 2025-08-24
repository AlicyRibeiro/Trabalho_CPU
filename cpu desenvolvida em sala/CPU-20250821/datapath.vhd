library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity datapath is
 Generic (N :integer := 16);
 Port
 (
 -- Portas do Register File
 rn_sel :in std_logic_vector (2 downto 0);
 rm_sel :in std_logic_vector (2 downto 0);
 rd_sel :in std_logic_vector (2 downto 0);
 rd_wr  :in std_logic;

 -- ULA
 op_ula: in std_logic_vector (3 downto 0);
 
 -- Mux Rd
 rd_ram : in std_logic_vector (N-1 downto 0);
 rd_immd : in std_logic_vector (N-1 downto 0);
 sel_rd_mux: in std_logic_vector (1 downto 0);
 
 -- RAM
 Rm : out std_logic_vector (N-1 downto 0);
 Rn : out std_logic_vector (N-1 downto 0);
 
 --clock e reset 
 clk  :in std_logic;
 rst  :in std_logic   
 
 );
end datapath;

architecture Behavioral of datapath is
  signal s_rd: std_logic_vector (N-1 downto 0);
  signal s_rm: std_logic_vector (N-1 downto 0);
  signal s_rn: std_logic_vector (N-1 downto 0);
  signal s_Q: std_logic_vector (N-1 downto 0);
begin

RF:
  entity work.register_file
  generic map(N => N)
  port map(
   Rm_sel => rm_sel,
   Rn_sel => rn_sel,
   Rd_sel => rd_sel,
   Rd_wr  => rd_wr,
   Rd => s_rd,
   Rm => s_rm,
   Rn => s_rn,
   clk => clk,
   rst => rst
  );

ULA:
  entity work.ula
  generic map(N_BITS => N)
  port map (
    A => s_rm,
    B => s_rn,
    Q => s_Q,
    op => op_ula
   );

MuxRd:
  entity work.mux4x1
  generic map(N => N)
  Port map(
   I0 => s_rm,
   I1 => rd_ram,
   I2 => rd_immd,
   I3 => s_Q,
   sel => sel_rd_mux,
   O0  => s_rd
  );

Rm <= s_rm;
Rn <= s_rn;

end Behavioral;
