library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.ALL;


entity WRITE_BACK_UNIT is
	generic ( NB : integer := 32;
			  LS : integer := 5
		);
	port (	MEM_ALU_SEL : 	IN std_logic;
			DEST_IN : 		IN  std_logic_vector(LS-1 downto 0);
			FROM_ALU :	IN  std_logic_vector(NB-1 downto 0);
			FROM_MEM : 	IN  std_logic_vector(NB-1 downto 0);
			DATA_OUT : 	OUT  std_logic_vector(NB-1 downto 0);
			DEST_OUT : 	OUT std_logic_vector(LS-1 downto 0)
	);
end WRITE_BACK_UNIT;



architecture BEHAVIORAL of WRITE_BACK_UNIT is


component MUX21_generic
	Generic (NB: integer:= 32);
	Port (	A:	In	std_logic_vector(NB-1 downto 0) ;
		B:	In	std_logic_vector(NB-1 downto 0);
		SEL:	In	std_logic;
		Y:	Out	std_logic_vector(NB-1 downto 0));
end component;

begin

wb_mux : MUX21_generic generic map (NB) port map (FROM_ALU,FROM_MEM,MEM_ALU_SEL,DATA_OUT);

DEST_OUT <= DEST_IN ;
	
end architecture BEHAVIORAL;