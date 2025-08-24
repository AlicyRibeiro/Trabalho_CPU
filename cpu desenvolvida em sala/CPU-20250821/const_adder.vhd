----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.06.2025 17:03:42
-- Design Name: 
-- Module Name: const_adder - Behavioral
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
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity const_adder is
    generic (N: integer := 16;
             B: integer :=1);
    Port ( A : in STD_LOGIC_VECTOR (N-1 downto 0);
           S : out STD_LOGIC_VECTOR (N-1 downto 0));
end const_adder;

architecture Behavioral of const_adder is

begin

S <= A + B;

end Behavioral;
