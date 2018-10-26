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
           STALL        : IN  std_logic;
  		     RST          : IN  std_logic;
           INST_EX      : IN  TYPE_STATE;
           INST_MEM     : IN  TYPE_STATE;
           INST_T_EX    : IN  std_logic;
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
           IRAM_OUT     : IN  std_logic_vector(NB-1 downto 0);
           EXT_MEM_IN   : IN  std_logic_vector(NB-1 downto 0); -- output of external memory
           FLUSH        : OUT std_logic;
           US_MEM       : OUT std_logic; -- US output to ext memory
           HAZARD       : OUT std_logic;	-- possible hazard detection
           EXT_MEM_ADD  : OUT std_logic_vector(LS-1 downto 0); -- address to outer memory
           EXT_MEM_DATA : OUT std_logic_vector(NB-1 downto 0); -- data to outer memory
           CURR_PC      : OUT std_logic_vector(NB-1 downto 0);
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
            MISS_HIT :  OUT std_logic_vector(1 downto 0)
          );
end component;

component DECODE_UNIT
  generic (NB: integer := 32;
  			   LS: integer:= 5
  			);
  port   (  CLK :     IN std_logic;
            RST :     IN std_logic;
            FLUSH :   IN std_logic;
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
            ADD_WR:   IN std_logic_vector(LS-1 downto 0); 
            ADD_RD1:  IN std_logic_vector(LS-1 downto 0);
            ADD_RD2:  IN std_logic_vector(LS-1 downto 0);
            DEST_IN : IN std_logic_vector(LS-1 downto 0);
            HAZARD:   OUT std_logic;
            US_TO_EX: OUT std_logic;
            A :       OUT std_logic_vector(NB-1 downto 0);
            B :       OUT std_logic_vector(NB-1 downto 0);
            C :       OUT std_logic_vector(NB-1 downto 0);
            D :       OUT std_logic_vector(NB-1 downto 0);
            RT:       OUT std_logic_vector(LS-1 downto 0); 
            RS:       OUT std_logic_vector(LS-1 downto 0); 
            DEST_OUT: OUT std_logic_vector(LS-1 downto 0)
          );
end component;


component EXECUTION_UNIT
  generic (NB: integer := 32;
  			LS: integer:= 5
  			);
  port 	 ( 	FW_MUX1_SEL : IN std_logic_vector(1 downto 0);
            FW_MUX2_SEL : IN std_logic_vector(1 downto 0);
            FW_EX :  IN std_logic_vector(NB-1 downto 0);
            FW_MEM : IN std_logic_vector(NB-1 downto 0);
            A :       IN std_logic_vector(NB-1 downto 0);
            B :       IN std_logic_vector(NB-1 downto 0);
            C :       IN std_logic_vector(NB-1 downto 0);
            D :       IN std_logic_vector(NB-1 downto 0);
            DEST_IN :     IN std_logic_vector(LS-1 downto 0);
            CLK :     IN std_logic;
            RST :       IN std_logic;
            US :      IN std_logic;
            MUX1_SEL :    IN std_logic;
            MUX2_SEL :    IN std_logic;
            UN_SEL :    IN std_logic_vector(2 downto 0);
            OP_SEL :    IN std_logic_vector(3 downto 0);
            US_MEM :    OUT std_logic;
            TEMP_PC :   OUT std_logic_vector(NB-1 downto 0);
            ALU_OUT :   OUT std_logic_vector(NB-1 downto 0);
            IMM_OUT :     OUT std_logic_vector(NB-1 downto 0);
            DEST_OUT:     OUT std_logic_vector(LS-1 downto 0)
          );
end component;



component MEMORY_UNIT
	generic ( NB : integer := 32;
			  LS : integer := 5);
	port ( CLK :     IN  std_logic;
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

component FOREWARD_UNIT
  generic (NB: integer := 32;
           LS: integer:= 5
        );
  port   (  INST_EX     : IN  TYPE_STATE;
            INST_MEM    : IN  TYPE_STATE;
            INST_T_EX   : IN  std_logic;
            Rs_EX       : IN  std_logic_vector(LS-1 downto 0);
            Rt_EX       : IN  std_logic_vector(LS-1 downto 0);
            Rd_MEM      : IN  std_logic_vector(LS-1 downto 0); -- dest from MEM stage
            Rd_WB       : IN  std_logic_vector(LS-1 downto 0); -- dest from WB stage
            CTL_MUX1    : OUT std_logic_vector(1 downto 0);
            CTL_MUX2    : OUT std_logic_vector(1 downto 0)
  );
end component;


signal A, B, C, D : std_logic_vector(NB-1 downto 0);
signal DEST_FROM_DECU, DEST_FROM_EXEU, DEST_FROM_MEMU, DEST_FROM_WRBU, RS, RT : std_logic_vector(LS-1 downto 0);
signal ALU_OUT : std_logic_vector(NB-1 downto 0);
signal ALU_TO_WB : std_logic_vector(NB-1 downto 0);
signal MEM_TO_WB : std_logic_vector(NB-1 downto 0);
signal DATA_WB : std_logic_vector(NB-1 downto 0);
signal INST : std_logic_vector(NB-1 downto 0);
signal NPC : std_logic_vector(NB-1 downto 0);
signal TEMP_PC : std_logic_vector(NB-1 downto 0);
signal TMP_MEM : std_logic_vector(NB-1 downto 0);

signal US_TO_EX : std_logic;
signal FW_MUX1_SEL, FW_MUX2_SEL, MISS_HIT : std_logic_vector(1 downto 0);

signal RST_DEC, STALL_IF : std_logic;


begin

RST_DEC <= RST and (MISS_HIT(1) nand MISS_HIT(0));

FLUSH <= RST_DEC;

ife_unit : FETCH_UNIT port map(CLK,STALL,RST,RST,PC_SEL,TEMP_PC,IRAM_OUT,FUNC,OP_CODE,CURR_PC,NPC,INST,MISS_HIT);
                                                                                                                             --     Rs = RD1          Rt = RD2          Rd = dest add                                                                            
dec_unit : DECODE_UNIT port map (CLK,RST,RST_DEC,DATA_WB,INST(25 downto 0),NPC,BR_TYPE,JMP,RI,US,RD1,RD2,WR,DEST_FROM_WRBU,INST(25 downto 21),INST(20 downto 16),INST(15 downto 11),HAZARD,US_TO_EX,A,B,C,D,RT,RS,DEST_FROM_DECU);

exe_unit : EXECUTION_UNIT port map (FW_MUX1_SEL,FW_MUX2_SEL,ALU_OUT,DATA_WB,A,B,C,D,DEST_FROM_DECU,CLK,RST,US_TO_EX,MUX1_SEL,MUX2_SEL,UN_SEL,OP_SEL,US_MEM,TEMP_PC,ALU_OUT,EXT_MEM_DATA,DEST_FROM_EXEU);
 
mem_unit : MEMORY_UNIT port map (CLK,RST,DEST_FROM_EXEU,EXT_MEM_IN,ALU_OUT,ALU_TO_WB,TMP_MEM,DEST_FROM_MEMU);

wrb_unit : WRITE_BACK_UNIT port map (MEM_ALU_SEL,DEST_FROM_MEMU,ALU_TO_WB,TMP_MEM,DATA_WB,DEST_FROM_WRBU);

fw_unit : FOREWARD_UNIT port map (INST_EX,INST_MEM,INST_T_EX,RS,RT,DEST_FROM_EXEU,DEST_FROM_MEMU,FW_MUX1_SEL,FW_MUX2_SEL);

EXT_MEM_ADD <= ALU_OUT(LS-1 downto 0);

	
end architecture BEHAVIORAL;