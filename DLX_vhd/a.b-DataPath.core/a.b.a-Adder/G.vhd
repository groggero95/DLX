library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all; 

entity G is 
        Port (	Gik:	In	std_logic;
		Gk_1j:	In	std_logic;
		Pik:	In	std_logic;
		Gij:    Out 	std_logic
	);
end G;



architecture behavioral of G is


begin

Gij <= Gik or ( Pik and Gk_1j );


end behavioral;

configuration CFG_G_BEH of G is
	for BEHAVIORAL
	end for;
end CFG_G_BEH;
