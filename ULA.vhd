library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ULA is
    Port (
        A: in  STD_LOGIC_VECTOR(3 downto 0);
        B: in  STD_LOGIC_VECTOR(3 downto 0);
        
        -- quantidade de deslocamento (para SHR/SHL)
        desloc: in  STD_LOGIC_VECTOR(4 downto 0);
        op: in  STD_LOGIC_VECTOR(3 downto 0);
        
        --Flags 
        Z_flag: out STD_LOGIC;
        C_flag: out STD_LOGIC;
        
        ULA_out : out STD_LOGIC_VECTOR(3 downto 0)
    );
end ULA;

architecture Behavioral of ULA is
begin
    process(A, B, desloc, op)
        variable temp_result : STD_LOGIC_VECTOR(3 downto 0);
        variable add_res     : STD_LOGIC_VECTOR(4 downto 0); -- 5 bits para capturar o carry
    begin
        C_flag <= '0';
        Z_flag <= '0';

        case op is
            when "0001" => -- ADD operation
                add_res := std_logic_vector(resize(unsigned(A), 5) + resize(unsigned(B), 5));
                temp_result := add_res(3 downto 0);
                C_flag <= add_res(4);

            when "0010" => -- SUB operation
                temp_result := std_logic_vector(unsigned(A) - unsigned(B));
                if (unsigned(A) < unsigned(B)) then
                    C_flag <= '1'; -- Borrow
                end if;

            when "0000" => -- CMP operation
                temp_result := std_logic_vector(unsigned(A) - unsigned(B));
                if (unsigned(A) < unsigned(B)) then
                    C_flag <= '1'; -- Borrow
                end if;

            when "1011" => -- SHR operation
                temp_result := std_logic_vector(shift_right(unsigned(A), to_integer(unsigned(desloc))));

            when "1100" => -- SHL operation
                temp_result := std_logic_vector(shift_left(unsigned(A), to_integer(unsigned(desloc))));

            when "1101" => -- ROR operation
                temp_result := A(0) & A(3 downto 1);

            when "1110" => -- ROL operation
                temp_result := A(2 downto 0) & A(3);

            when others =>
                temp_result := "1111"; -- Valor de erro
        end case;

        -- Definir a Flag Z com base no resultado
        if (temp_result = "0000") then
            Z_flag <= '1';
        end if;

        -- Atribuir o resultado final à saída
        if (op = "0000") then -- Para CMP, a saída não é o resultado
            ULA_out <= A;
        else
            ULA_out <= temp_result;
        end if;

    end process;
end Behavioral;