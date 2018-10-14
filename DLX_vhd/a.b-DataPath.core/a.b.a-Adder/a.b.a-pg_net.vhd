library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all; 

entity pg_net is 
        Port (	a:	In	std_logic;
		b:		In	std_logic;
		p:  	Out     std_logic;
		g:    	Out 	std_logic
	);
end pg_net;


architecture behavioral of pg_net is

begin

g <= a and b;

p <= a xor b;

end behavioral;


configuration CFG_PGN_NET_BEH of pg_net is
	for BEHAVIORAL
	end for;
end CFG_PGN_NET_BEH;



