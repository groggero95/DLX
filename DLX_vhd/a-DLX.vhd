library ieee;
use ieee.std_logic_1164.all;
use work.myTypes.all;

entity DLX is
  generic (
    IR_SIZE      : integer := 32;       -- Instruction Register Size
    PC_SIZE      : integer := 32;       -- Program Counter Size
    NB           : integer := 32;
    LS           : integer := 5
    );       -- ALU_OPC_SIZE if explicit ALU Op Code Word Size
  port (
    CLK : in std_logic;
    RST : in std_logic);                -- Active Low
end DLX;


-- This architecture is currently not complete
-- it just includes:
-- instruction register (complete)
-- program counter (complete)
-- instruction ram memory (complete)
-- control unit (UNCOMPLETE)
--
architecture dlx_rtl of DLX is

 --------------------------------------------------------------------
 -- Components Declaration
 --------------------------------------------------------------------

-- Memory (won't be synthesized)

component RAM
generic ( NB : integer := 32;
          LS : integer := 5);
port (
    CLOCK   : IN  std_logic;
    RST     : IN  std_logic;
    --ENABLE  : IN  std_logic;
    RW      : IN  std_logic; -- read haigh write low
    D_TYPE  : IN  std_logic_vector(1 downto 0);
    US      : IN  std_logic;
    ADDRESS : IN  std_logic_vector(LS-1 downto 0);
    MEMIN   : IN  std_logic_vector(NB-1 downto 0);
    MEMOUT  : OUT std_logic_vector(NB-1 downto 0)
  );
end component;

  -- Control Unit
component dlx_cu
  port (
            -- INPUTS
            CLK       : IN std_logic;
            RST       : IN std_logic;       -- the TB requires it active low
            OPCODE    : IN std_logic_vector(OP_SIZE-1 downto 0);
            FUNC      : IN std_logic_vector(F_SIZE-1 downto 0);

            -- FIRST PIPE STAGE OUTPUTS
            --ENIF        : OUT std_logic;    -- 1 -> en   | 0 -> dis 
            STALL       : OUT std_logic;    -- 1 -> en   | 0 -> dis 
            -- SECOND PIPE STAGE OUTPUTS
            --ENDEC       : OUT std_logic;
            JMP         : OUT std_logic;     --
            RI          : OUT std_logic;
            BR_TYPE     : OUT std_logic_vector(1 downto 0);
            RD1         : OUT std_logic;     -- enables the read port 1 of the register file
            RD2         : OUT std_logic;     -- enables the read port 2 of the register file
            US          : OUT std_logic;     -- decides wether the operation is signed (0) or unsigned (1)           
            -- THIRD PIPE STAGE OUTPUTS
            --ENEX        : OUT std_logic;
            MUX1_SEL    : OUT std_logic;     -- select operand A (from RF) or C (immediate)
            MUX2_SEL    : OUT std_logic;     -- select operand B (from RF) or D (immediate)    
            UN_SEL      : OUT std_logic_vector(2 downto 0); -- unit select
            OP_SEL      : OUT std_logic_vector(3 downto 0); -- operation select
            PC_SEL      : OUT std_logic;    -- 0 -> pc+4 | 1 -> j/b
            -- FOURTH PIPE STAGE OUTPUTS
            --ENMEM       : OUT std_logic;
            RW          : OUT std_logic;
            D_TYPE      : OUT std_logic_vector(1 downto 0);
            -- FIFTH PIPE STAGE OUTPUTS
            WR          : OUT std_logic;     -- enables the write port of the register file
            MEM_ALU_SEL : OUT std_logic    
  );
end component;


component DATAPATH
  generic ( NB : integer := 32;
            LS : integer := 5;
            OPC : integer := 6;
            FN : integer := 11
        );
  port (  CLK          : IN  std_logic;
          STALL        : IN  std_logic;
          --ENIF         : IN  std_logic;
          --ENDEC        : IN  std_logic;
          --ENEX         : IN  std_logic;
          --ENMEM        : IN  std_logic;
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
          BR_TYPE      : IN  std_logic_vector(1 downto 0);
          UN_SEL       : IN  std_logic_vector(2 downto 0); -- unit selection signal
          OP_SEL       : IN  std_logic_vector(3 downto 0); -- operation selection
          EXT_MEM_IN   : IN  std_logic_vector(NB-1 downto 0); -- output of external memory
          US_MEM       : OUT std_logic; -- US output to ext memory
          HAZARD       : OUT std_logic;  -- possible hazard detection
          EXT_MEM_ADD  : OUT std_logic_vector(LS-1 downto 0); -- address to outer memory
          EXT_MEM_DATA : OUT std_logic_vector(NB-1 downto 0); -- data to outer memory
          FUNC         : OUT std_logic_vector(FN-1 downto 0); -- out of instruction memory
          OP_CODE      : OUT std_logic_vector(OPC-1 downto 0) -- out of instruction memory     
  );
end component;


  ----------------------------------------------------------------
  -- Signals Declaration
  ----------------------------------------------------------------
signal OPCODE    : std_logic_vector(OP_SIZE-1 downto 0);
signal FUNC      : std_logic_vector(F_SIZE-1 downto 0);
-- FIRST PIPAGE OUTPUTS
signal ENIF      : std_logic;    -- 1 -> en   | 0 -> dis 
signal STALL     : std_logic;    
-- SECOND PITAGE OUTPUTS
signal ENDEC     : std_logic;
signal JMP       : std_logic;     --
signal RI        : std_logic;
signal BR_TYPE   : std_logic_vector(1 downto 0);
signal RD1       : std_logic;     -- enables the read port 1 of the register file
signal RD2       : std_logic;     -- enables the read port 2 of the register file
signal US        : std_logic;     -- decides wether the operation is signed (0) or unsigned (1)
-- THIRD PIPAGE OUTPUTS
signal ENEX      : std_logic;
signal MUX1_SEL  : std_logic;     -- select operand A (from RF) or C (immediate)
signal MUX2_SEL  : std_logic;     -- select operand B (from RF) or D (immediate)    
signal UN_SEL    : std_logic_vector(2 downto 0); -- unit select
signal OP_SEL    : std_logic_vector(3 downto 0); -- operation select
signal PC_SEL    : std_logic;    -- 0 -> pc+4 | 1 -> j/b
-- FOURTH PITAGE OUTPUTS
signal ENMEM     : std_logic;
signal RW        : std_logic;
signal D_TYPE    : std_logic_vector(1 downto 0);
-- FIFTH PIPAGE OUTPUTS
signal WR        : std_logic;     -- enables the write port of the register file
signal MEM_ALU_SEL: std_logic;	-- select data for WB
  


  -- Data Ram Bus signals
signal EXT_MEM_IN   : std_logic_vector(NB-1 downto 0); -- output of external memory
signal EXT_MEM_ADD  : std_logic_vector(LS-1 downto 0); -- address to outer memory
signal EXT_MEM_DATA : std_logic_vector(NB-1 downto 0); -- data to outer memory

signal US_MEM, HAZARD : std_logic;



  begin  -- DLX

dp : DATAPATH port map(CLK, STALL, RST, JMP, RI, RD1, RD2, WR, PC_SEL, MEM_ALU_SEL, US, MUX1_SEL, MUX2_SEL, BR_TYPE, UN_SEL, OP_SEL, EXT_MEM_IN, US_MEM, HAZARD, EXT_MEM_ADD, EXT_MEM_DATA, FUNC, OPCODE);    

cu : dlx_cu port map(CLK,RST,OPCODE,FUNC,STALL,JMP,RI,BR_TYPE,RD1,RD2,US,MUX1_SEL,MUX2_SEL,UN_SEL,OP_SEL,PC_SEL,RW,D_TYPE,WR,MEM_ALU_SEL);

--mem: RAM port map (CLK, RST,ENMEM, RW, D_TYPE, US_MEM, EXT_MEM_ADD, EXT_MEM_DATA, EXT_MEM_IN);
mem: RAM port map (CLK, RST, RW, D_TYPE, US_MEM, EXT_MEM_ADD, EXT_MEM_DATA, EXT_MEM_IN);

    
    
end dlx_rtl;
