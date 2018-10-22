library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.ALL;
use IEEE.math_real.all;
use WORK.all;
use WORK.mfunc.all;


entity register_file is
 generic (NB: integer := 32;  	-- bith width of each memory location
	 	  RS: integer := 32); -- # of registers
 port ( CLK:		IN std_logic;
 		RESET: 		IN std_logic;	-- syncronous reset
	 	RD1: 		IN std_logic;
	 	RD2: 		IN std_logic;
	 	WR: 		IN std_logic;
	 	ADD_WR: 	IN std_logic_vector(getAddrSize(RS)-1 downto 0); 
	 	ADD_RD1: 	IN std_logic_vector(getAddrSize(RS)-1 downto 0);
	 	ADD_RD2: 	IN std_logic_vector(getAddrSize(RS)-1 downto 0);
	 	DATAIN: 	IN std_logic_vector(NB-1 downto 0);
	 	HAZARD:		OUT std_logic;
     	OUT1: 		OUT std_logic_vector(NB-1 downto 0);
	 	OUT2: 		OUT std_logic_vector(NB-1 downto 0)
	);
end register_file;
-- getAddrSize => return the log2() of the argument if it is a power of 2
-- otherwise it round the result to the next power of 2
-- example getAddrSize(4) = 2, getAddrSize(5) = 3 and the same for 6 and 7

architecture behavioral of register_file is

        -- suggested structures
    subtype REG_ADDR is integer range 0 to RS-1; -- using natural type
	type REG_ARRAY is array(REG_ADDR) of std_logic_vector(NB-1 downto 0); -- Creating the memory type
	signal REGISTERS : REG_ARRAY; -- Memory part of the register

	
begin 
-- write your RF code 
REG: process(CLK)
begin
	if CLK'event and CLK = '1' then
		if (RESET='0') then	-- syncronous reset
			REGISTERS  <= (others  => (others  => '0')); -- Clear the memory at reset
			HAZARD <= '0';
		else
			if( WR ='1') then 
				if (((RD1 = '1') and (ADD_WR = ADD_RD1)) or ((RD2 = '1') and (ADD_WR = ADD_RD2))) then
					HAZARD <= '1';
					REGISTERS(to_integer(unsigned(ADD_WR))) <= DATAIN;
				else
					REGISTERS(to_integer(unsigned(ADD_WR))) <= DATAIN;
					HAZARD <= '0';
				end if;
			else 
				HAZARD <= '0';
			end if; 
		end if;
	end if;
end process REG;

rd : process(RD1,RD2,ADD_RD1,ADD_RD2,REGISTERS )
begin
	if( RD1 ='1') then 
		OUT1 <= REGISTERS(to_integer(unsigned(ADD_RD1)));
	else
		OUT1 <= (others => '0'); -- When disabled the output goes to high impedence
	end if; 

	if( RD2 ='1') then 
		OUT2 <= REGISTERS(to_integer(unsigned(ADD_RD2)));
	else 
		OUT2 <= (others => '0'); -- When disabled the output goes to high impedence
	end if;
end process ; -- rd
end behavioral;

----


configuration CFG_RF_BEH of register_file is
  for behavioral
  end for;
end configuration;
