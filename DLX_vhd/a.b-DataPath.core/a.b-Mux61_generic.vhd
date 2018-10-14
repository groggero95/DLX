library IEEE;
use IEEE.std_logic_1164.all; 
--use WORK.constants.all; 

entity MUX61_generic is
	Generic (NB: integer:= 32);
	Port (	A:	In	std_logic_vector(NB-1 downto 0) ;
		B:	In	std_logic_vector(NB-1 downto 0);
		C:	In	std_logic_vector(NB-1 downto 0);
		D:	In	std_logic_vector(NB-1 downto 0);
		E:	In	std_logic_vector(NB-1 downto 0);
    	F:  In  std_logic_vector(NB-1 downto 0);		
		SEL:	In	std_logic_vector(2 downto 0);
		Y:	Out	std_logic_vector(NB-1 downto 0));
end MUX61_generic;

architecture BEHAVIORAL of MUX61_generic is
begin
	
	process (A,B,C,D,E,SEL)
	
	begin
		case SEL is
		when "000" =>		Y <= A;  
		when "001" =>		Y <= B;
		when "010" =>		Y <= C;
		when "011" =>		Y <= D;
		when "100" =>		Y <= E;
		when "101" =>		Y <= F;
		when others => null;
		end case;
	end process;
end BEHAVIORAL;



configuration CFG_MUX61_GEN_BEHAVIORAL of MUX61_GENERIC is
	for BEHAVIORAL
	end for;
end CFG_MUX61_GEN_BEHAVIORAL;


