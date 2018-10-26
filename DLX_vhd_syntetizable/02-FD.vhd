library IEEE;
use IEEE.std_logic_1164.all; 

-- Simple D flip flop

entity FD is
	Generic (NB : integer := 32);
	Port (	CK:	In	std_logic;
			RESET:	In	std_logic;
			D:	In	std_logic_vector (NB-1 downto 0);
			Q:	Out	std_logic_vector (NB-1 downto 0) 
		);
end FD;



architecture BEHAV of FD is -- flip flop D with asyncronous reset

	signal TMP_Q : std_logic_vector(NB-1 downto 0);

begin
	PSYNCH: process(CK,RESET)
	begin

		if RESET='0' then -- active low reset 
	      	TMP_Q <= (others =>'0'); 
	  	elsif CK'event and CK='1' then -- positive edge triggered:
	      	TMP_Q <= D; -- input is written on output
	  	end if;
	end process;

	Q <= TMP_Q;

end BEHAV;


configuration CFG_FD of FD is	
  for BEHAV
  end for;
end CFG_FD;





