library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.ALL;


entity MEMORY_UNIT is
	generic ( NB : integer := 32;
			  LS : integer := 5);
	port (	CLK : 		IN  std_logic;
			RST : 		IN  std_logic;
			DEST_IN : 	IN  std_logic_vector(LS-1 downto 0);
			FROM_MEM :	IN  std_logic_vector(NB-1 downto 0);
			FROM_ALU :	IN  std_logic_vector(NB-1 downto 0); -- Goes to memory
			ALU_OUT : 	OUT std_logic_vector(NB-1 downto 0);
			MEM_OUT :	OUT std_logic_vector(NB-1 downto 0);
			DEST_OUT : 	OUT std_logic_vector(LS-1 downto 0)
	);
end MEMORY_UNIT;



architecture BEHAVIORAL of MEMORY_UNIT is

component FD
	Generic (NB : integer := 32);
	Port (	CK:	In	std_logic;
			RESET:	In	std_logic;
			--EN : In std_logic;
			D:	In	std_logic_vector (NB-1 downto 0);
			Q:	Out	std_logic_vector (NB-1 downto 0) 
		);
end component;



begin

exec_reg : FD port map (CLK,RST,FROM_ALU,ALU_OUT);

mem_reg : FD port map (CLK,RST,FROM_MEM,MEM_OUT);

dest_reg : FD generic map (LS) port map (CLK,RST,DEST_IN,DEST_OUT);


	
end architecture BEHAVIORAL;