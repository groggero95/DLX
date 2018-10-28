library IEEE;
use IEEE.std_logic_1164.all; 

-- Simple 3 input multiplexer with paremeter NB to decide the width of the inputs 

entity MUX31_generic is
	Generic (NB: integer:= 32);
	Port (	A	: In	std_logic_vector(NB-1 downto 0);
			B	: In	std_logic_vector(NB-1 downto 0);
			C	: In	std_logic_vector(NB-1 downto 0);
			SEL	: In	std_logic_vector(1 downto 0);
			Y	: Out	std_logic_vector(NB-1 downto 0)
		);
end MUX31_generic;

architecture BEHAVIORAL of MUX31_generic is
begin
	process(A,B,C,SEL)
	begin
		case SEL is
			when "00" =>		Y <= A;  
			when "01" =>		Y <= B;
			when "10" =>		Y <= C;
			when others => Y <= (others => '0');
		end case;
	end process;
end BEHAVIORAL;



configuration CFG_MUX31_GEN_BEHAVIORAL of MUX31_generic is
	for BEHAVIORAL
	end for;
end CFG_MUX31_GEN_BEHAVIORAL;


