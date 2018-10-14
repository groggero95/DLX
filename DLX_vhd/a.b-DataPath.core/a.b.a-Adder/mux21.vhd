library IEEE;
use IEEE.std_logic_1164.all; --  libreria IEEE con definizione tipi standard logic


entity MUX21 is
	Port (	A:	In	std_logic;
		B:	In	std_logic;
		S:	In	std_logic;
		Y:	Out	std_logic);
end MUX21;


architecture BEHAVIORAL of MUX21 is

begin
	Y <= (A and S) or (B and not(S)); -- processo implicito

end BEHAVIORAL;



configuration CFG_MUX21_BEHAVIORAL of MUX21 is
	for BEHAVIORAL
	end for;
end CFG_MUX21_BEHAVIORAL;


