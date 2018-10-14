library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.ALL;
use WORK.mfunc.all;
use work.myTypes.all;


entity DATAPATH is
	generic ( NB : integer := 32;
			      LS : integer := 5;
            OPC : integer := 6;
            FN : integer := 11
        );
	port (   CLK          : IN  std_logic;
           ENIF         : IN  std_logic;
           ENDEC        : IN  std_logic;
           ENEX         : IN  std_logic;
           ENMEM        : IN  std_logic;
  		     RST          : IN  std_logic;
           JMP          : IN  std_logic; -- jump or immediate bit 
           RI           : IN  std_logic;    
  		     RD1          : IN  std_logic; -- read enable 1
           RD2          : IN  std_logic; -- read enable 2
           WR           : IN  std_logic; -- write enable
           PC_SEL       : IN  std_logic; -- new instruction/jump
           MEM_ALU_SEL  : IN  std_logic; -- wb mem or alu out
  		     US           : IN  std_logic; -- signed unsigned
  		     MUX1_SEL     : IN  std_logic; -- select input to exeu A,B (registers) may be a problem 
           MUX2_SEL     : IN  std_logic; -- select input to exeu C,D (immediate)
           BR_TYPE 	    : IN  std_logic_vector(1 downto 0);
           UN_SEL       : IN  std_logic_vector(2 downto 0); -- unit selection signal
           OP_SEL       : IN  std_logic_vector(3 downto 0); -- operation selection
           EXT_MEM_IN   : IN  std_logic_vector(NB-1 downto 0); -- output of external memory
           US_MEM       : OUT std_logic; -- US output to ext memory
           HAZARD       : OUT std_logic;	-- possible hazard detection
           EXT_MEM_ADD  : OUT std_logic_vector(LS-1 downto 0); -- address to outer memory
           EXT_MEM_DATA : OUT std_logic_vector(NB-1 downto 0); -- data to outer memory
           FUNC         : OUT std_logic_vector(FN-1 downto 0); -- out of instruction memory
           OP_CODE      : OUT std_logic_vector(OPC-1 downto 0) -- out of instruction memory     
	);
end DATAPATH;



architecture BEHAVIORAL of DATAPATH is


component FETCH_UNIT
  generic (NB: integer := 32;
  			LS: integer:= 5
  			);
  port   (  CLK :       IN  std_logic;
            ENABLE :    IN  std_logic;
            RST :       IN  std_logic;
            PC_SEL :    IN  std_logic;
            JB_INST :   IN  std_logic_vector(NB-1 downto 0);
            FUNC :      OUT std_logic_vector(F_SIZE-1 downto 0);
            OPCODE :    OUT std_logic_vector(OP_SIZE-1 downto 0);
            NPC :       OUT std_logic_vector(NB-1 downto 0);
            INST_OUT :  OUT std_logic_vector(NB-1 downto 0)
          );
end component;

component DECODE_UNIT
  generic (NB: integer := 32;
  			RS: integer:= 32
  			);
  port   (  ENABLE :  IN std_logic;
            CLK :     IN std_logic;
            RST :     IN std_logic;
            DATAIN :  IN std_logic_vector(NB-1 downto 0);
            IMM1 :    IN std_logic_vector(NB-7 downto 0);
            IMM2 :    IN std_logic_vector(NB-1 downto 0);
            BR_TYPE : IN std_logic_vector(1 downto 0);
            JMP :     IN std_logic;
            RI:       IN std_logic;
            US :      IN std_logic;
            RD1:      IN std_logic;
            RD2:      IN std_logic;
            WR:       IN std_logic;
            ADD_WR:   IN std_logic_vector(getAddrSize(RS)-1 downto 0); 
            ADD_RD1:  IN std_logic_vector(getAddrSize(RS)-1 downto 0);
            ADD_RD2:  IN std_logic_vector(getAddrSize(RS)-1 downto 0);
            DEST_IN : IN std_logic_vector(getAddrSize(RS)-1 downto 0);
            HAZARD:   OUT std_logic;
            US_TO_EX: OUT std_logic;
            A : 			OUT std_logic_vector(NB-1 downto 0);
  			    B : 			OUT std_logic_vector(NB-1 downto 0);
           	C : 			OUT std_logic_vector(NB-1 downto 0);
           	D : 			OUT std_logic_vector(NB-1 downto 0);
           	DEST_OUT: OUT std_logic_vector(getAddrSize(RS)-1 downto 0)
          );
end component;


component EXECUTION_UNIT
  generic (NB: integer := 32;
  			LS: integer:= 5
  			);
  port 	 ( 	A : 			IN std_logic_vector(NB-1 downto 0);
  			    B : 			IN std_logic_vector(NB-1 downto 0);
           	C : 			IN std_logic_vector(NB-1 downto 0);
           	D : 			IN std_logic_vector(NB-1 downto 0);
           	DEST_IN : 		IN std_logic_vector(LS-1 downto 0);
           	ENABLE : 		IN std_logic;
           	CLK :			IN std_logic;
           	RST : 			IN std_logic;
           	US :			IN std_logic;
           	MUX1_SEL : 		IN std_logic;
           	MUX2_SEL : 		IN std_logic;
           	UN_SEL : 		IN std_logic_vector(2 downto 0);
           	OP_SEL :		IN std_logic_vector(3 downto 0);
            US_MEM :    OUT std_logic;
            TEMP_PC :   	OUT std_logic_vector(NB-1 downto 0);
           	ALU_OUT :		OUT std_logic_vector(NB-1 downto 0);
           	IMM_OUT : 		OUT std_logic_vector(NB-1 downto 0); -- ???
           	DEST_OUT: 		OUT std_logic_vector(LS-1 downto 0)
          );
end component;



component MEMORY_UNIT
	generic ( NB : integer := 32;
			  LS : integer := 5);
	port ( CLK :     IN  std_logic;
         ENABLE :  IN  std_logic;
         RST :     IN  std_logic;
         DEST_IN :   IN  std_logic_vector(LS-1 downto 0);
         FROM_MEM :  IN  std_logic_vector(NB-1 downto 0);
         FROM_ALU :  IN  std_logic_vector(NB-1 downto 0); -- Goes to memory
         ALU_OUT :   OUT std_logic_vector(NB-1 downto 0);
         MEM_OUT : OUT std_logic_vector(NB-1 downto 0);
         DEST_OUT :  OUT std_logic_vector(LS-1 downto 0)
  );
end component;


component WRITE_BACK_UNIT
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
end component;


signal A, B, C, D : std_logic_vector(NB-1 downto 0);
signal DEST_FROM_DECU, DEST_FROM_EXEU, DEST_FROM_MEMU, DEST_FROM_WRBU : std_logic_vector(LS-1 downto 0);
signal ALU_OUT : std_logic_vector(NB-1 downto 0);
signal ALU_TO_WB : std_logic_vector(NB-1 downto 0);
signal MEM_TO_WB : std_logic_vector(NB-1 downto 0);
signal DATA_WB : std_logic_vector(NB-1 downto 0);
signal INST : std_logic_vector(NB-1 downto 0);
signal NPC : std_logic_vector(NB-1 downto 0);
signal TEMP_PC : std_logic_vector(NB-1 downto 0);
signal TMP_MEM : std_logic_vector(NB-1 downto 0);

signal US_TO_EX: std_logic;


begin


ife_unit : FETCH_UNIT port map(CLK,ENIF,RST,PC_SEL,TEMP_PC,FUNC,OP_CODE,NPC,INST);

dec_unit : DECODE_UNIT port map (ENDEC,CLK,RST,DATA_WB,INST(25 downto 0),NPC,BR_TYPE,JMP,RI,US,RD1,RD2,WR,DEST_FROM_WRBU,INST(25 downto 21),INST(20 downto 16),INST(15 downto 11),HAZARD,US_TO_EX,A,B,C,D,DEST_FROM_DECU);

exe_unit : EXECUTION_UNIT port map (A,B,C,D,DEST_FROM_DECU,ENEX,CLK,RST,US_TO_EX,MUX1_SEL,MUX2_SEL,UN_SEL,OP_SEL,US_MEM,TEMP_PC,ALU_OUT,EXT_MEM_DATA,DEST_FROM_EXEU);
 
mem_unit : MEMORY_UNIT port map (CLK,ENMEM,RST,DEST_FROM_EXEU,EXT_MEM_IN,ALU_OUT,ALU_TO_WB,TMP_MEM,DEST_FROM_MEMU);

wrb_unit : WRITE_BACK_UNIT port map (MEM_ALU_SEL,DEST_FROM_MEMU,ALU_TO_WB,TMP_MEM,DATA_WB,DEST_FROM_WRBU);

EXT_MEM_ADD <= ALU_OUT(LS-1 downto 0);

	
end architecture BEHAVIORAL;