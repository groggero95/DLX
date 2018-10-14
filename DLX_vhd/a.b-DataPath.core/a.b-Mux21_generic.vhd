library IEEE;
use IEEE.std_logic_1164.all; 
--use WORK.constants.all; 

entity MUX21_generic is
	Generic (NB: integer:= 32);
	Port (	A:	In	std_logic_vector(NB-1 downto 0) ;
		B:	In	std_logic_vector(NB-1 downto 0);
		SEL:	In	std_logic;
		Y:	Out	std_logic_vector(NB-1 downto 0));
end MUX21_generic;

architecture BEHAVIORAL of MUX21_generic is
begin
	process(A,B,SEL)
	begin
		case SEL is
		when '1' =>		Y <= A;  
		when '0' =>		Y <= B;
		when others => null;
		end case;
	end process;
end BEHAVIORAL;



configuration CFG_MUX21_GEN_BEHAVIORAL of MUX21_GENERIC is
	for BEHAVIORAL
	end for;
end CFG_MUX21_GEN_BEHAVIORAL;


