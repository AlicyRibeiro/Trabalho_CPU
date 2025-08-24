
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;


entity ula is
  Generic (N_BITS :integer:=16);
  Port (
    A: in std_logic_vector (N_BITS-1 downto 0);
    B: in std_logic_vector (N_BITS-1 downto 0);
    Q: out std_logic_vector (N_BITS-1 downto 0);
    op: in std_logic_vector(3 downto 0)
   );
end ula;

architecture Behavioral of ula is
   signal s_add: std_logic_vector (N_BITS-1 downto 0);
   signal s_sub: std_logic_vector (N_BITS-1 downto 0);
   signal s_mul: std_logic_vector (2*N_BITS-1 downto 0);
   signal s_and: std_logic_vector (N_BITS-1 downto 0);
   signal s_orr: std_logic_vector (N_BITS-1 downto 0);
   signal s_not: std_logic_vector (N_BITS-1 downto 0);
   signal s_xor: std_logic_vector (N_BITS-1 downto 0);
   
begin

s_add <= A + B;
s_sub <= A - B;
s_mul <= A * B;
s_and <= A and B;
s_orr <= A or B;
s_not <= not A;
s_xor <= A xor B;

Q <= s_add when op = "0100" else
     s_sub when op = "0101" else
     s_mul(N_BITS-1 downto 0) when op = "0110" else
     s_and when op = "0111" else
     s_orr when op = "1000" else
     s_not when op = "1001" else
     s_xor when op = "1010" else
     (others => '0');

end Behavioral;
