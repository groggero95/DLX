library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use work.myTypes.all;


entity FETCH_UNIT is
  generic (NB: integer := 32;
  			LS: integer:= 5
  			);
  port 	 (  CLK :       IN  std_logic;
            ENABLE :    IN  std_logic;
            RST :       IN  std_logic;
            PC_SEL :    IN  std_logic;
            JB_INST :   IN  std_logic_vector(NB-1 downto 0);
            FUNC :      OUT std_logic_vector(F_SIZE-1 downto 0);
            OPCODE :    OUT std_logic_vector(OP_SIZE-1 downto 0);
            NPC :       OUT std_logic_vector(NB-1 downto 0);
            INST_OUT :  OUT std_logic_vector(NB-1 downto 0)
          );
end FETCH_UNIT;

architecture BEHAVIOR of FETCH_UNIT is


component FD
	Generic (NB : integer := 32);
	Port (	CK:	In	std_logic;
		RESET:	In	std_logic;
		EN : In std_logic;
		D:	In	std_logic_vector (NB-1 downto 0);
		Q:	Out	std_logic_vector (NB-1 downto 0) 
		);
end component;


component MUX21_generic
	Generic (NB: integer:= 32);
	Port (	A:	In	std_logic_vector(NB-1 downto 0) ;
		B:	In	std_logic_vector(NB-1 downto 0);
		SEL:	In	std_logic;
		Y:	Out	std_logic_vector(NB-1 downto 0));
end component;


  --Instruction Ram
component IRAM
  generic (
    RAM_DEPTH : integer := 512;
    I_SIZE : integer := 32;
    LS : integer := 5);
  port (
    Rst  : in  std_logic;
    Addr : in  std_logic_vector(I_SIZE - 1 downto 0);
    Dout : out std_logic_vector(I_SIZE - 1 downto 0)
    );
end component;


signal NEW_PC, CUR_PC, NEXT_PC, TMP_INST_OUT : std_logic_vector(NB-1 downto 0);


begin

N_PC : FD generic map (NB) port map (CLK,RST,ENABLE,NEXT_PC,NPC);

PC : FD generic map (NB) port map (CLK,RST,ENABLE,NEW_PC,CUR_PC);

imem : IRAM port map (RST,CUR_PC,TMP_INST_OUT);

INST : FD generic map (NB) port map (CLK,RST,ENABLE,TMP_INST_OUT,INST_OUT);

-- 0 -> pc+4 | 1 -> from_alu
pc_mux : MUX21_generic generic map (NB) port map (JB_INST,NEXT_PC,PC_SEL,NEW_PC);

FUNC <= TMP_INST_OUT(10 downto 0);
OPCODE <= TMP_INST_OUT(NB-1 downto NB-6);

adder : process(CUR_PC)
begin

NEXT_PC <= std_logic_vector(unsigned(CUR_PC) + 4 );


end process;



end BEHAVIOR;