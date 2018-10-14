library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all; 

entity comparator is
		generic (NB : integer := 32);
        Port (	AdderRes :	In	std_logic_vector(NB-1 downto 0);
        -- first digit for A, second digit for B
		MSB:	 In std_logic_vector(1 downto 0);
		CO :  In std_logic;
		OP_CODE: In std_logic_vector(2 downto 0);
		US: 	 In std_logic;
		SOUT :   Out std_logic_vector(NB-1 downto 0)
	);
end comparator;



architecture behavioral of comparator is

signal EQ, LE, LT, GE, GT : std_logic;


signal bigNor : std_logic;

begin

	bigNor <= not(or_reduce(AdderRes));
	SIGN: process(US, bigNor, CO, MSB)
	
	begin
		-- UNSIGNED
		if (US='1') then
			GT <= not(bigNor) and CO;
			GE <= CO;
			EQ <= bigNor;
			LT <= not(CO);
			LE <= bigNor or not(CO);
		else
			-- SIGNED
			if((MSB(1) xnor MSB(0)) = '1') then
				GT <= not(bigNor) and CO;
				GE <= CO;
				EQ <= bigNor;
				LT <= not(CO);
				LE <= bigNor or not(CO);
			else
				GT <= not(bigNor) and MSB(0);
				GE <= MSB(0);
				EQ <= bigNor;
				LT <= not(bigNor) and MSB(1);
				LE <= MSB(1);
			end if;	
		end if;
	end process;

	ASSIGN_OUT : process(EQ, LE, LT, GE, GT, OP_CODE)

	begin
		case (OP_CODE) is

			when "000" => SOUT(0) <= EQ;
			
			when "001" => SOUT(0) <= (not EQ);

			when "110" => SOUT(0) <= GE;

			when "111" => SOUT(0) <= GT;

			when "101" => SOUT(0) <= LT;

			when "100" => SOUT(0) <= LE;

			when others => SOUT(0) <= '0';


		end case;


	end process;

	SOUT(NB-1 downto 1) <= (others => '0');--"0000000000000000000000000000000";--(others => '0');


end behavioral;






