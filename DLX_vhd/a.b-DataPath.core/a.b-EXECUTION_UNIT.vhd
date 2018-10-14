library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;


entity EXECUTION_UNIT is
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
            TEMP_PC :   OUT std_logic_vector(NB-1 downto 0);
           	ALU_OUT :		OUT std_logic_vector(NB-1 downto 0);
           	IMM_OUT : 		OUT std_logic_vector(NB-1 downto 0);
           	DEST_OUT: 		OUT std_logic_vector(LS-1 downto 0)
          );
end EXECUTION_UNIT;

architecture BEHAVIOR of EXECUTION_UNIT is

component SHIFTER
  generic (NB: integer := 32;
  			LS: integer:= 5
  			);
  port 	 ( 	FUNC: 			IN std_logic_vector(1 downto 0);
  			US: 			IN std_logic;
           	DATA1: 			IN std_logic_vector(NB-1 downto 0);
           	DATA2: 			IN std_logic_vector(LS-1 downto 0);
           	OUTSHFT: 		OUT std_logic_vector(NB-1 downto 0)
          );
end component;


component BOOTHMUL 
		generic (NB: integer:= 32); -- Number of output bits
		port (	A: in std_logic_vector((NB/2)-1 downto 0);
				B: in std_logic_vector((NB/2)-1 downto 0);
				C: out std_logic_vector(NB-1 downto 0)
			);
end component;



component LOGIC
	generic (NB : integer := 32);
	port (
    SEL		: in  std_logic_vector(3 downto 0);
    A 		: in  std_logic_vector(NB-1 downto 0);
    B 		: in  std_logic_vector(NB-1 downto 0);
    RES 	: out std_logic_vector(NB-1 downto 0)
  );
end component;


component p4addgen
 	 Generic(NB : integer := 32;
 	 		 CW : integer := 4	
 	 		);
 	 port (
 	 		A 	: In 	std_logic_vector( NB-1 downto 0);
 	 		B 	: In 	std_logic_vector( NB-1 downto 0);
 	 		Ci 	: In 	std_logic; 
 	 		Co 	: Out 	std_logic;
 	 		S 	: Out 	std_logic_vector( NB-1 downto 0)	
 	 	);
end component;


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

component comparator
		generic (NB : integer := 32);
        Port (	AdderRes :	In	std_logic_vector(NB-1 downto 0);
        -- first digit for A, second digit for B
		MSB:	 In std_logic_vector(1 downto 0);
		CO :  In std_logic;
		OP_CODE: In std_logic_vector(2 downto 0);
		US: 	 In std_logic;
		SOUT :   Out std_logic_vector(NB-1 downto 0)
	);
end component;

component MUX61_generic
	Generic (NB: integer:= 32);
	Port (	A:	In	std_logic_vector(NB-1 downto 0) ;
		B:	In	std_logic_vector(NB-1 downto 0);
		C:	In	std_logic_vector(NB-1 downto 0);
		D:	In	std_logic_vector(NB-1 downto 0);
		E:	In	std_logic_vector(NB-1 downto 0);
    F:  In  std_logic_vector(NB-1 downto 0);
		SEL:	In	std_logic_vector(2 downto 0);
		Y:	Out	std_logic_vector(NB-1 downto 0));
end component;



signal TERM1, TERM2, TERM3 : std_logic_vector(NB-1 downto 0);
signal MUX2_OUT: std_logic_vector(NB-1 downto 0);
signal ADD_OUT, MUL_OUT, LOGIC_OUT, SHFT_OUT : std_logic_vector(NB-1 downto 0);
signal CA_OUT: std_logic;
signal MSB : std_logic_vector(1 downto 0);
signal COMP_OUT : std_logic_vector(NB-1 downto 0);
signal JMP_RET : std_logic_vector(NB-1 downto 0);
signal TMP_DEST_OUT : std_logic_vector(LS-1 downto 0);
signal US_TMP1, US_TMP2 : std_logic_vector(0 downto 0);




begin

US_TMP1(0) <= US;

US_MEM <= US_TMP2(0);

MSB <= TERM1(31) & TERM2(31);

mux1 : MUX21_generic port map (A,D,MUX1_SEL,TERM1);
mux2 : MUX21_generic port map (B,C,MUX2_SEL,TERM2);

--to_mem_reg : FD generic map (NB) port map (CLK,RST,ENABLE,B,);
process(OP_SEL,TERM2)
begin

  if OP_SEL(0) = '1' then -- TODO change things to do sub or change coding for comparator
    TERM3 <= not TERM2;
  else 
    TERM3 <= TERM2;
  end if;
end process;

adder : p4addgen port map(TERM1, TERM3, OP_SEL(0), CA_OUT, ADD_OUT);

multiplier : BOOTHMUL port map (TERM1((NB/2)-1 downto 0), TERM2((NB/2)-1 downto 0), MUL_OUT);

shift_rot : SHIFTER port map(OP_SEL(1 downto 0), US, TERM1, TERM2(4 downto 0), SHFT_OUT);

comparison : comparator port map (ADD_OUT, MSB,CA_OUT,OP_SEL(3 downto 1),US,COMP_OUT);

log_un : LOGIC port map (OP_SEL, TERM1, TERM2, LOGIC_OUT);

destination_register : FD generic map (LS) port map (CLK,RST,ENABLE,TMP_DEST_OUT,DEST_OUT);
output_register : FD port map (CLK,RST,ENABLE,MUX2_OUT,ALU_OUT);
imm_register : FD port map (CLK,RST,ENABLE,B,IMM_OUT); -- da rivedere
us_register : FD generic map (1) port map (CLK,RST,ENABLE,US_TMP1,US_TMP2);

mux_out : MUX61_generic port map (ADD_OUT,COMP_OUT,MUL_OUT,SHFT_OUT,LOGIC_OUT,JMP_RET,UN_SEL,MUX2_OUT);

TEMP_PC <= ADD_OUT;


jmp_adder : process(D)
begin

JMP_RET <= std_logic_vector(unsigned(D) + 4 );

end process; 

dest_sel : process( OP_SEL,DEST_IN )
begin
  if (OP_SEL = "101") then
    TMP_DEST_OUT <= "11111";
  else
    TMP_DEST_OUT <= DEST_IN;
  end if;
  
end process ; -- dest_sel

end BEHAVIOR;