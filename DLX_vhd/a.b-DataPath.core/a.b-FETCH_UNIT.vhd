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
            STALL :     IN  std_logic;
            RST :       IN  std_logic;
            RST_DEC:    IN  std_logic;
            PC_SEL :    IN  std_logic;
            JB_INST :   IN  std_logic_vector(NB-1 downto 0);
            FUNC :      OUT std_logic_vector(F_SIZE-1 downto 0);
            OPCODE :    OUT std_logic_vector(OP_SIZE-1 downto 0);
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


signal NEW_PC, CUR_PC, NEXT_PC, IRAM_OUT, TMP_INST_OUT, PRED: std_logic_vector(NB-1 downto 0);
signal TMP_RST : std_logic;
signal M_H : std_logic_vector(1 downto 0);
signal TMP_PC_SEL : std_logic;

signal flush : std_logic;

begin

flush <=  ((not M_H(1)) or (not M_H(0))) and STALL;

--N_PC : FD generic map (NB) port map (CLK,flush,NEXT_PC,NPC);
N_PC : FD_INJ generic map (NB) port map (CLK,RST,flush,NEXT_PC,NPC);

process(CLK)
begin
  if CLK'event and CLK = '1' then
    TMP_RST <= RST;
  end if;
end process;

BP_UNIT : BP port map (CLK,RST,JB_INST,CUR_PC,NEXT_PC,NEW_PC,TMP_INST_OUT,M_H,PRED);

PC : FD generic map (NB) port map (CLK,TMP_RST,PRED,CUR_PC);

imem : IRAM port map (RST,CUR_PC,IRAM_OUT);

flush_mux : MUX21_generic generic map (NB) port map (IRAM_OUT,"00000000000000000000000000000000",flush,TMP_INST_OUT);

--INST : FD generic map (NB) port map (CLK,flush,TMP_INST_OUT,INST_OUT);
INST : FD generic map (NB) port map (CLK,RST,TMP_INST_OUT,INST_OUT);


--process(STALL,IRAM_OUT)
--begin
--  case STALL is
--    when '1' => TMP_INST_OUT <= IRAM_OUT;
--    when '0' => TMP_INST_OUT <= (others => '0');
--    when others => TMP_INST_OUT <= (others => '0');
--  end case;
--end process;

--process(flush,IRAM_OUT)
--begin
--  case flush is
--    when '1' => TMP_INST_OUT <= IRAM_OUT;
--    when '0' => TMP_INST_OUT <= (others => '0');
--    when others => TMP_INST_OUT <= (others => '0');
--  end case;
--end process;

MISS_HIT  <= M_H;

TMP_PC_SEL <= PC_SEL; 

-- 0 -> pc+4 | 1 -> from_alu
pc_mux : MUX21_generic generic map (NB) port map (JB_INST,NEXT_PC,TMP_PC_SEL,NEW_PC);


FUNC <= IRAM_OUT(10 downto 0);
OPCODE <= IRAM_OUT(NB-1 downto NB-6);

adder : process(CUR_PC)
begin

NEXT_PC <= std_logic_vector(unsigned(CUR_PC) + 4 );


end process;



end BEHAVIOR;