library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use WORK.mfunc.all;


entity DECODE_UNIT is
  generic (NB: integer := 32;
  			   RS: integer:= 32
  			);
  port 	 (  ENABLE :  IN std_logic;
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
end DECODE_UNIT;

architecture BEHAVIOR of DECODE_UNIT is


component FD
	Generic (NB : integer := 32);
	Port (	CK:	In	std_logic;
		RESET:	In	std_logic;
		EN : In std_logic;
		D:	In	std_logic_vector (NB-1 downto 0);
		Q:	Out	std_logic_vector (NB-1 downto 0) 
		);
end component;


component register_file
  generic (NB: integer := 32;   -- bith width of each memory location
           RS: integer := 32); -- # of registers
  port ( CLK:      IN std_logic;
         RESET:    IN std_logic; -- syncronous reset
         RD1:      IN std_logic;
         RD2:      IN std_logic;
         WR:       IN std_logic;
         ADD_WR:   IN std_logic_vector(getAddrSize(RS)-1 downto 0); 
         ADD_RD1:  IN std_logic_vector(getAddrSize(RS)-1 downto 0);
         ADD_RD2:  IN std_logic_vector(getAddrSize(RS)-1 downto 0);
         DATAIN:   IN std_logic_vector(NB-1 downto 0);
         HAZARD:   OUT std_logic;
         OUT1:     OUT std_logic_vector(NB-1 downto 0);
         OUT2:     OUT std_logic_vector(NB-1 downto 0)
    );
end component;

-- 0 -> A, 1 -> B
component MUX21_generic
  Generic (NB: integer:= 32);
  Port (  A:  In  std_logic_vector(NB-1 downto 0) ;
    B:  In  std_logic_vector(NB-1 downto 0);
    SEL:  In  std_logic;
    Y:  Out std_logic_vector(NB-1 downto 0));
end component;

component SIGN_EXT
  Generic (NB: integer:= 32);
  Port (  A:  In  std_logic_vector(NB-7 downto 0) ;
          US: In  std_logic;
          JMP: In  std_logic;
          Y:  Out std_logic_vector(NB-1 downto 0)
    );
end component;


signal OUT1, OUT2 : std_logic_vector(NB-1 downto 0);
signal EXT1: std_logic_vector(NB-1 downto 0);
signal DEST_ADD : std_logic_vector(getAddrSize(RS)-1 downto 0);
signal TO_IMM1 : std_logic_vector(NB-1 downto 0);
signal US_TMP1, US_TMP2 : std_logic_vector(0 downto 0);


begin

US_TMP1(0) <= US;

US_TO_EX <= US_TMP2(0);

reg_file : register_file port map (CLK,RST,RD1,RD2,WR,ADD_WR,ADD_RD1,ADD_RD2,DATAIN,HAZARD,OUT1,OUT2);

reg_a : FD port map (CLK,RST,ENABLE,OUT1,A);

reg_b : FD port map (CLK,RST,ENABLE,OUT2,B);

exted : SIGN_EXT port map (IMM1,US,JMP,EXT1);

us_register : FD generic map (1) port map (CLK,RST,ENABLE,US_TMP1,US_TMP2);

imm_reg1 : FD port map (CLK,RST,ENABLE,TO_IMM1,C);

imm_reg2 : FD port map (CLK,RST,ENABLE,IMM2,D);

mux_dest : MUX21_generic generic map (getAddrSize(RS)) port map (ADD_RD2,DEST_IN,RI,DEST_ADD); -- aggiungere un mux per selezionare registro 31 da scrivere

dest_reg : FD generic map (getAddrSize(RS)) port map (CLK,RST,ENABLE,DEST_ADD,DEST_OUT);

is_zero : process( BR_TYPE,OUT1, EXT1 )
begin
  case (BR_TYPE) is
    when "10" => 
              if (unsigned(OUT1) = 0) then
                TO_IMM1 <= (others  => '0');
              else
                TO_IMM1 <= EXT1;
              end if;
    when "11" => 
              if (unsigned(OUT1) /= 0) then
                TO_IMM1 <= (others  => '0');
              else
                TO_IMM1 <= EXT1;
              end if;
      
    when others =>  TO_IMM1 <= EXT1;
  end case;
  
end process ; -- is_zero



end BEHAVIOR;