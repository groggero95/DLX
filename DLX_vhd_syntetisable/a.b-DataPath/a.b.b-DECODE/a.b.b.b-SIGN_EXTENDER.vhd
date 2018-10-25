library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.const.all;	

-- Block used to extend immediate values coming from the instuction

entity SIGN_EXT is
	Port (	A:	In	std_logic_vector(NB-7 downto 0) ; -- The input is on 26 bits as it is used also with address in jump instructions
			US:	In	std_logic;	-- 0 -> Sign extend as an unsiged number 1 -> Sign extend as an unsiged number (consider only last 16 bits)
			JMP: In  std_logic; -- 1 -> extend the 26 bit address as a signed number
			Y:	Out	std_logic_vector(NB-1 downto 0)
		);
end SIGN_EXT;

architecture BEHAVIORAL of SIGN_EXT is
begin
	process(A,US,JMP)
	begin
		if JMP = '1' then
			Y <= std_logic_vector(resize(signed(A),Y'length));
		elsif US = '1' then
			Y <= std_logic_vector(resize(unsigned(A(15 downto 0)),Y'length));
		else 
			Y <= std_logic_vector(resize(signed(A(15 downto 0)),Y'length));
		end if;
	end process;
	
end BEHAVIORAL;


configuration CFG_SIGN_EXT of SIGN_EXT is	
  for BEHAVIORAL
  end for;
end CFG_SIGN_EXT;


