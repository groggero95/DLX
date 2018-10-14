library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;	

entity SIGN_EXT is
	Generic (NB: integer:= 32);
	Port (	A:	In	std_logic_vector(NB-7 downto 0) ;
			US:	In	std_logic;
			JMP: In  std_logic;
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





