library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all; 

entity blockPG is 
        Port (	Gik:	In	std_logic;
				Gk_1j:	In	std_logic;
				Pik:	In	std_logic;
				Pk_1j: 	In	std_logic;
				Pij:    Out std_logic;
				Gij:    Out std_logic
	);
end blockPG;



architecture behavioral of blockPG is


begin


Pij <= Pik and Pk_1j;


Gij <= Gik or ( Pik and Gk_1j );


end behavioral;


configuration CFG_PG_BEH of blockPG is
	for BEHAVIORAL
	end for;
end CFG_PG_BEH;




