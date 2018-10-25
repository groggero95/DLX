library IEEE;
use IEEE.std_logic_1164.all; 
--use WORK.constants.all;

entity FD_INJ is
	Generic (NB : integer := 32);
	Port (	CK:	In	std_logic;
			RESET:	In	std_logic;
			INJ_ZERO : In std_logic;
			D:	In	std_logic_vector (NB-1 downto 0);
			Q:	Out	std_logic_vector (NB-1 downto 0) 
		);
end FD_INJ;



architecture BEHAV of FD_INJ is -- flip flop D with syncronous reset

	signal TMP_D : std_logic_vector(NB-1 downto 0);

begin


	process(INJ_ZERO,D)
	begin
		case INJ_ZERO is
			when '0' => TMP_D <= (others => '0');
			when '1' => TMP_D <= D;
			when  others => TMP_D <= (others => '0');
		end case;
	end process;


	PSYNCH: process(CK,RESET)
	begin

		if RESET='0' then -- active high reset 
	      	Q <= (others =>'0'); 
	  	elsif CK'event and CK='1' then -- positive edge triggered:
	      	Q <= TMP_D; -- input is written on output
	  	end if;
	end process;

end BEHAV;








