library IEEE;
use IEEE.std_logic_1164.all; 
--use WORK.constants.all;

entity FD is
	Generic (NB : integer := 32);
	Port (	CK:	In	std_logic;
		RESET:	In	std_logic;
		--EN : In std_logic;
		D:	In	std_logic_vector (NB-1 downto 0);
		Q:	Out	std_logic_vector (NB-1 downto 0) 
		);
end FD;



architecture BEHAV of FD is -- flip flop D with syncronous reset

	signal TMP_Q : std_logic_vector(NB-1 downto 0);

begin
	PSYNCH: process(CK,RESET)
	begin

		if RESET='0' then -- active high reset 
	      TMP_Q <= (others =>'0'); 
	  	elsif CK'event and CK='1' then -- positive edge triggered:
	    	--if (EN = '1') then
	      		TMP_Q <= D; -- input is written on output
	    	--else
	     -- 		TMP_Q <= (others => '0');
	    	--end if;
	  	end if;
	end process;

	Q <= TMP_Q;
	--process(EN)
	--begin
	--	if (EN = '1') then
	--		Q <= TMP_Q;
	--	else
	--		Q <= (others => '0');
	--	end if;

	--end process;

end BEHAV;








