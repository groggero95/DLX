library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use work.const.all;


entity FETCH_UNIT is
  generic (NB: integer := 32;
  			LS: integer:= 5
  			);
  port 	 (  CLK :       IN  std_logic;
            STALL :     IN  std_logic;
            RST :       IN  std_logic;
            RST_DEC:    IN  std_logic;
            PC_SEL :    IN  std_logic;
            JB_INST :   IN  std_logic_vector(NB-1 downto 0);
            IRAM_OUT :  IN  std_logic_vector(NB-1 downto 0);
            FUNC :      OUT std_logic_vector(F_SIZE-1 downto 0);
            OPCODE :    OUT std_logic_vector(OP_SIZE-1 downto 0);
            CURR_PC :   OUT std_logic_vector(NB-1 downto 0);
            NPC :       OUT std_logic_vector(NB-1 downto 0);
            INST_OUT :  OUT std_logic_vector(NB-1 downto 0);
            MISS_HIT :  OUT std_logic_vector( 1 downto 0)
          );
end FETCH_UNIT;

architecture BEHAVIOR of FETCH_UNIT is


component FD
	Generic (NB : integer := 32);
	Port (	CK:	In	std_logic;
      		RESET:	In	std_logic;
      		D:	In	std_logic_vector (NB-1 downto 0);
      		Q:	Out	std_logic_vector (NB-1 downto 0) 
		);
end component;

component FD_INJ
  Generic (NB : integer := 32);
  Port (  CK: In  std_logic;
    RESET:  In  std_logic;
    INJ_ZERO : In std_logic;
    D:  In  std_logic_vector (NB-1 downto 0);
    Q:  Out std_logic_vector (NB-1 downto 0) 
    );
end component;

component BP
  generic(NB: integer     := 32;
          BP_LEN: integer   := 4
          );
  port(
        CLK       : in  std_logic;
        RST       : in  std_logic;
        EX_PC     : in  std_logic_vector(NB-1 downto 0);
        CURR_PC   : IN  std_logic_vector(NB-1 downto 0);
        NEXT_PC   : in  std_logic_vector(NB-1 downto 0);
        NEW_PC    : in  std_logic_vector(NB-1 downto 0);
        INST      : in  std_logic_vector(NB-1 downto 0);
        MISS_HIT  : out std_logic_vector(1 downto 0);
        PRED      : out std_logic_vector(NB-1 downto 0) -- to the PC input
    );
end component;


component MUX21_generic
	Generic (NB: integer:= 32);
	Port (	A:	In	std_logic_vector(NB-1 downto 0) ;
		B:	In	std_logic_vector(NB-1 downto 0);
		SEL:	In	std_logic;
		Y:	Out	std_logic_vector(NB-1 downto 0));
end component;


signal NEW_PC, CUR_PC, NEXT_PC, TMP_INST_OUT, PRED, ZERO: std_logic_vector(NB-1 downto 0);
signal TMP_RST : std_logic;
signal M_H : std_logic_vector(1 downto 0);
signal TMP_PC_SEL : std_logic;

signal flush : std_logic;

begin

ZERO <= (others  => '0');

flush <=  ((not M_H(1)) or (not M_H(0))) and STALL;

N_PC : FD_INJ generic map (NB) port map (CLK,RST,flush,NEXT_PC,NPC);

process(CLK)
begin
  if CLK'event and CLK = '1' then
    TMP_RST <= RST;
  end if;
end process;

BP_UNIT : BP port map (CLK,RST,JB_INST,CUR_PC,NEXT_PC,NEW_PC,TMP_INST_OUT,M_H,PRED);

PC : FD generic map (NB) port map (CLK,TMP_RST,PRED,CUR_PC);

flush_mux : MUX21_generic generic map (NB) port map (IRAM_OUT,ZERO,flush,TMP_INST_OUT);

INST : FD generic map (NB) port map (CLK,RST,TMP_INST_OUT,INST_OUT);

MISS_HIT  <= M_H;

TMP_PC_SEL <= PC_SEL; 

CURR_PC <= CUR_PC;

-- 0 -> pc+4 | 1 -> from_alu
pc_mux : MUX21_generic generic map (NB) port map (JB_INST,NEXT_PC,TMP_PC_SEL,NEW_PC);


FUNC <= IRAM_OUT(10 downto 0);
OPCODE <= IRAM_OUT(NB-1 downto NB-6);

adder : process(CUR_PC)
begin

NEXT_PC <= std_logic_vector(unsigned(CUR_PC) + 4 );


end process;



end BEHAVIOR;

configuration CFG_FETCH_UNIT of FETCH_UNIT is
for BEHAVIOR
  for all:BP 
    use configuration WORK.CFG_BP;
  end for;

  for all:FD 
    use configuration WORK.CFG_FD;
  end for;

  for all:FD_INJ 
    use configuration WORK.CFG_FD_INJ;
  end for;

  for all:MUX21_generic 
    use configuration WORK.CFG_MUX21_GEN_BEHAVIORAL;
  end for;
end for;

end CFG_FETCH_UNIT;


