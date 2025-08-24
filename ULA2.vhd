library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ULA2 is
    Port (
        -- Entradas de dados
        A       : in  STD_LOGIC_VECTOR(15 downto 0); -- Operando A (geralmente de um registrador)
        B       : in  STD_LOGIC_VECTOR(15 downto 0); -- Operando B (de um registrador ou valor imediato)
        
        -- Entrada de controle
        op      : in  STD_LOGIC_VECTOR(3 downto 0); -- Código da operação vindo da FSM
        
        -- Saída de resultado
        ULA_out : out STD_LOGIC_VECTOR(15 downto 0); -- Resultado da operação
        
        -- Saídas de Status (Flags)
        flag_z  : out STD_LOGIC; -- Flag de Zero: '1' se o resultado for zero ou se A = B em CMP
        flag_c  : out STD_LOGIC  -- Flag de Carry/Menor que: '1' se A < B em CMP
    );
end ULA2;

architecture Behavioral of ULA2 is

    -- Sinais internos para os cálculos
    signal result : STD_LOGIC_VECTOR(15 downto 0);
    signal desloc    : INTEGER range 0 to 7;

    -- Constantes para os opcodes (para clareza e consistência com a FSM)
    constant OP_CMP     : std_logic_vector(3 downto 0) := "0000";
    constant OP_ADD     : std_logic_vector(3 downto 0) := "0010";
    constant OP_SHR     : std_logic_vector(3 downto 0) := "1011";
    constant OP_SHL     : std_logic_vector(3 downto 0) := "1100";
    constant OP_ROR     : std_logic_vector(3 downto 0) := "1101";
    constant OP_ROL     : std_logic_vector(3 downto 0) := "1110";
    constant OP_IMMD    : std_logic_vector(3 downto 0) := "0111"; -- Para passar um operando (ex: imediato)

begin

    -- Processo combinacional principal da ULA
    process(A, B, op)
    begin
        -- Converte a entrada B para a quantidade de deslocamento (shift/rotate)
        -- A arquitetura define um imediato de 3 bits, então pegamos B(2 downto 0)
        desloc <= to_integer(unsigned(B(2 downto 0)));

        -- Lógica de cálculo do resultado baseada no opcode
        case op is
            -- Soma (usada para calcular desvios: PC + #Im)
            when OP_ADD =>
                result <= std_logic_vector(unsigned(A) + unsigned(B));

            -- Deslocamento Lógico para a Direita
            when OP_SHR =>
                result <= std_logic_vector(shift_right(unsigned(A), desloc));

            -- Deslocamento Lógico para a Esquerda
            when OP_SHL =>
                result <= std_logic_vector(shift_left(unsigned(A), desloc));

            -- Rotação para a Direita
            when OP_ROR =>
                result <= std_logic_vector(rotate_right(unsigned(A), 1)); -- Rotação de 1 bit

            -- Rotação para a Esquerda
            when OP_ROL =>
                result <= std_logic_vector(rotate_left(unsigned(A), 1));  -- Rotação de 1 bit

            -- Passa a entrada B diretamente para a saída
            when OP_IMMD =>
                result <= B;
            
            -- Para CMP e outras operações, o resultado principal não é usado
            when others =>
                result <= (others => '0');
        end case;

        -- Lógica de Geração de Flags
        -- Tratamento especial para CMP, conforme a especificação
        if op = OP_CMP then
            -- Z = 1 se A = B, senão Z = 0
            if A = B then
                flag_z <= '1';
            else
                flag_z <= '0';
            end if;
            
            -- C = 1 se A < B, senão C = 0 (comparação sem sinal)
            if unsigned(A) < unsigned(B) then
                flag_c <= '1';
            else
                flag_c <= '0';
            end if;
        else
            -- Para todas as outras operações, o flag Z é baseado no resultado
            if unsigned(result) = 0 then
                flag_z <= '1';
            else
                flag_z <= '0';
            end if;
            
            -- O flag C não é usado pelas outras operações nesta arquitetura
            flag_c <= '0';
        end if;
    end process;

    -- Atribui o resultado interno à porta de saída
    ULA_out <= result;

end Behavioral;