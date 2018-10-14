library IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;


entity MUX_SHIFT is 
		generic (	NB: integer:= 32;
				N_sh: integer:= 0
				);
		port (	A: in std_logic_vector(NB-1 downto 0);
				sel: in std_logic_vector(2 downto 0);
				AS: out std_logic;
				B: out std_logic_vector(2*NB-1 downto 0)
			);
end MUX_SHIFT;

architecture BEHAVIORAL of MUX_SHIFT is

begin
	


MUX:	process(A, sel)
				variable temp_A : std_logic_vector(2*NB-1 downto 0);
				begin
					case sel is
						when "000" => 
										B <= (others => '0');
										AS <= '0';
						when "001" => 
										B <= std_logic_vector(shift_left(resize(signed(A), 2*NB), N_sh));
										AS <= '0';
						when "010" => 
										B <= std_logic_vector(shift_left(resize(signed(A), 2*NB), N_sh)); 
										AS <= '0';
						when "011" => 
										B <= std_logic_vector(shift_left(resize(signed(A), 2*NB), N_sh+1));
										AS <= '0';
						when "100" => 	
										temp_A := std_logic_vector(shift_left(resize(signed(A), 2*NB), N_sh+1));
										B <= not temp_A;
									--	B <= std_logic_vector(shift_left(signed(neg_A), N_sh+1));
										AS <= '1';
						when "101" => 
										temp_A := std_logic_vector(shift_left(resize(signed(A), 2*NB), N_sh));
										B <= not temp_A;
									--	B <= std_logic_vector(shift_left(signed(neg_A), N_sh));
										AS <= '1';
						when "110" => 
										temp_A := std_logic_vector(shift_left(resize(signed(A), 2*NB), N_sh));
										B <= not temp_A;
									--	B <= std_logic_vector(shift_left(signed(neg_A), N_sh));
										AS <= '1';
						when "111" => 
										B <= (others => '0');
										AS <= '0';
						when others => 
										B <= (others => '0');
										AS <= '0';
--report "unreachable" severity failure;
					end case;
		end process;
	
end BEHAVIORAL;

configuration CFG_MUX_SH_MUL_BEHAVIORAL of MUX_SHIFT is
	for BEHAVIORAL
	end for;
end CFG_MUX_SH_MUL_BEHAVIORAL;
