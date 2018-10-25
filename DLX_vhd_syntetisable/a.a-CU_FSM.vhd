library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myTypes.all;


entity DLX_CU is
  port (
            -- INPUTS
            CLK       : IN std_logic;
            RST       : IN std_logic;       -- the TB requires it active low
            OPCODE    : IN std_logic_vector(OP_SIZE-1 downto 0);
            FUNC      : IN std_logic_vector(F_SIZE-1 downto 0);

            FLUSH	  : IN std_logic;

            -- FIRST PIPE STAGE OUTPUTS
            STALL      	: OUT std_logic;    -- 1 -> en   | 0 -> dis 
            -- SECOND PIPE STAGE OUTPUTS
            JMP        	: OUT std_logic;     --
            RI          : OUT std_logic;
            BR_TYPE   	: OUT std_logic_vector(1 downto 0);
            RD1       	: OUT std_logic;     -- enables the read port 1 of the register file
            RD2       	: OUT std_logic;     -- enables the read port 2 of the register file
            US        	: OUT std_logic;     -- decides wether the operation is signed (0) or unsigned (1)           
            -- THIRD PIPE STAGE OUTPUTS
            MUX1_SEL  	: OUT std_logic;     -- select operand A (from RF) or C (immediate)
            MUX2_SEL  	: OUT std_logic;     -- select operand B (from RF) or D (immediate)    
            UN_SEL    	: OUT std_logic_vector(2 downto 0); -- unit select
            OP_SEL    	: OUT std_logic_vector(3 downto 0); -- operation select
            PC_SEL    	: OUT std_logic;    -- 0 -> pc+4 | 1 -> j/b
            -- FOURTH PIPE STAGE OUTPUTS
            RW        	: OUT std_logic;
            D_TYPE    	: OUT std_logic_vector(1 downto 0);
            -- FIFTH PIPE STAGE OUTPUTS
            WR        	: OUT std_logic;     -- enables the write port of the register file
            MEM_ALU_SEL : OUT std_logic;

            -- SIGNAL USED FOR FOREWARDING
            INST_T_EX	: OUT std_logic;
            INST_EX		: OUT TYPE_STATE;
            INST_MEM	: OUT TYPE_STATE
  );
end DLX_CU;

architecture DLX_CU_FSM of DLX_CU is
  
component FD
  Generic (NB : integer := 32);
  Port (  CK: In  std_logic;
    	  RESET:  In  std_logic;
    	  D:  In  std_logic_vector (NB-1 downto 0);
    	  Q:  Out std_logic_vector (NB-1 downto 0) 
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
                                
  signal cw   : std_logic_vector(CW_SIZE - 1 downto 0); -- full control word read from cw_mem
  

	--type TYPE_STATE is (
 --                       reset,
 --                       fetch,
 --                       stall_if
 -- 	);

  signal INST, INST1, INST2, INST3 : TYPE_STATE := reset;
  signal NEXT_INST : TYPE_STATE := reset;

  signal OPCODE1, OPCODE2, OPCODE3, OPCODE4 : std_logic_vector(OP_SIZE-1 downto 0);
  signal FUNC1, FUNC2 : std_logic_vector(F_SIZE-1 downto 0); 

  signal TMP1E ,TMP2E, TMP5E, TMP11M, TMP12M, TMP11W, TMP21W, TMP12W, TMP22W, TMP13W, TMP23W : std_logic_vector(0 downto 0);
  signal TMP1, TMP2, TMP3, TMP4, TMP5, TMP6, TMP7, TMP8, TMP9, TMP10, TMP11 : std_logic_vector(0 downto 0);
  signal TMP22M, TMP21M : std_logic_vector(1 downto 0);
  signal TMP3E : std_logic_vector(2 downto 0);
  signal TMP4E : std_logic_vector(3 downto 0);

  signal INST_TMP, INST_TMP1, INST_TMP2 : std_logic_vector(0 downto 0);
  

begin  -- dlx_cu_rtl


  OPPP1 : FD generic map (OP_SIZE) port map (CLK,RST,OPCODE,OPCODE1);
  OPPP2 : FD generic map (OP_SIZE) port map (CLK,RST,OPCODE1,OPCODE2);
  OPPP3 : FD generic map (OP_SIZE) port map (CLK,RST,OPCODE2,OPCODE3);
  OPPP4 : FD generic map (OP_SIZE) port map (CLK,RST,OPCODE3,OPCODE4);
  FUNPP1 : FD generic map (F_SIZE) port map (CLK,RST,FUNC,FUNC1);
  FUNPP2 : FD generic map (F_SIZE) port map (CLK,RST,FUNC1,FUNC2);
    

  -- This process update the current state at each clock cycle
    P_OPC : process(CLK, RST)          
    begin
        if RST='0' then -- Acrive low asyncronous reset
            INST <= reset;
        elsif (CLK ='1' and CLK'EVENT) then 
            INST <= NEXT_INST;
        end if;
    end process P_OPC;



    -- In this process we decide which will bw the next state acording to where we are now 
    -- and what are our input
    P_NEXT_STATE : process(INST, OPCODE, OPCODE1, FUNC)
    begin

        case INST is
          
          	when reset => NEXT_INST <= fetch;

			when fetch => if ( (OPCODE = ITYPE_J) or (OPCODE = ITYPE_JAL) or (OPCODE = ITYPE_JR) or (OPCODE = ITYPE_JALR)) then 
	          					NEXT_INST <= stall_if;
	          				else
	          					NEXT_INST <= fetch;
	          				end if;


           when stall_if => 	if ( (OPCODE1 = ITYPE_J) or (OPCODE1 = ITYPE_JAL) or (OPCODE1 = ITYPE_JR) or (OPCODE1 = ITYPE_JALR) ) then 
	          						NEXT_INST <= stall_if;
	          					else
	          						NEXT_INST <= fetch;
	          					end if;

          when others => NEXT_INST <= reset;
        
        end case;  

    end process P_NEXT_STATE;
   

    P_OUTPUTS_INST: process(INST,OPCODE,FUNC)
    begin

        case INST is       
          	when reset =>   cw <= "00000000000000000000000";
            
          	when fetch =>  
	            case OPCODE is
	              	when RTYPE =>   
	                            case FUNC is
	                            	when RTYPE_SLL  => cw <= "10000111110110000000011";               
	                            	when RTYPE_SRL  => cw <= "10000111110110001000011";                        
	                            	when RTYPE_SRA  => cw <= "10000110110110001000011";                        
	                            	when RTYPE_ADD  => cw <= "10000110110000000000011";                        
	                            	when RTYPE_ADDU => cw <= "10000111110000000000011";                        
	                            	when RTYPE_SUB  => cw <= "10000110110000001000011";                        
	                            	when RTYPE_SUBU => cw <= "10000111110000001000011";                        
	                            	when RTYPE_AND  => cw <= "10000110111001000000011";                        
	                            	when RTYPE_OR   => cw <= "10000110111001110000011";                        
	                            	when RTYPE_XOR  => cw <= "10000110111000110000011";                        
	                            	when RTYPE_SEQ  => cw <= "10000110110010001000011";                        
	                            	when RTYPE_SNE  => cw <= "10000110110010011000011";                        
	                            	when RTYPE_SLT  => cw <= "10000110110011011000011";                        
	                            	when RTYPE_SGT  => cw <= "10000110110011111000011";                        
	                            	when RTYPE_SLE  => cw <= "10000110110011001000011";                        
	                            	when RTYPE_SGE  => cw <= "10000110110011101000011";                        
	                            	when RTYPE_SLTU => cw <= "10000111110011011000011";                        
	                            	when RTYPE_SGTU => cw <= "10000111110011111000011";                        
	                            	when RTYPE_SLEU => cw <= "10000111110011001000011";                        
	                            	when RTYPE_SGEU => cw <= "10000111110011101000011";                        
	                            	when others   =>   cw <= "00000000000000000000000";                        
	                            end case;

	                when ITYPE_J => cw <= "11000000000000000100000";

	                when ITYPE_JAL => cw <= "11000000001010000100011";

	                when ITYPE_JR => cw <= "11000100110000000100000";

	                when ITYPE_JALR => cw <= "11000100111010000100011";
					
	                when ITYPE_BEQZ => cw <= "10010100000000000100000";

	                when ITYPE_BNEZ => cw <= "10011100000000000100000";

	                when ITYPE_ADDI => cw <= "10100100100000000000011";

	                when ITYPE_ADDUI => cw <= "10100101100000000000011";

	                when ITYPE_SUBI => cw <= "10100100100000001000011";

	                when ITYPE_SUBUI => cw <= "10100101100000001000011";

	                when ITYPE_ANDI => cw <= "10100100101001000000011";

	                when ITYPE_ORI => cw <= "10100100101001110000011";

	                when ITYPE_XORI => cw <= "10100100101000110000011";

	                when ITYPE_SLLI => cw <= "10100101100110000000011";

	                when ITYPE_SRLI => cw <= "10100101100110001000011";

	                when ITYPE_SRAI => cw <= "10100100100110001000011";

	                when ITYPE_NOP => cw <= "00000000000000000000000";

	                when ITYPE_SEQI => cw <= "10100100100010001000011";

	                when ITYPE_SNEI => cw <= "10100100100010011000011";

	                when ITYPE_SLTI => cw <= "10100100100011011000011";

	                when ITYPE_SGTI => cw <= "10100100100011111000011";
	                                  
	                when ITYPE_SLEI => cw <= "10100100100011001000011";

	                when ITYPE_SGEI => cw <= "10100100100011101000011";
	                                  
	                when ITYPE_SB => cw <= "10100110100000000010100";

	                when ITYPE_SH => cw <= "10100110100000000011000";
	                                  
	                when ITYPE_SW => cw <= "10100110100000000011100";

	                when ITYPE_LB => cw <= "10100100100000000000110";
	                                  
	                when ITYPE_LH => cw <= "10100100100000000001010";
	                
	                when ITYPE_LW => cw <= "10100100100000000001110";
	                
	                when ITYPE_LBU => cw <= "10100101100000000000110";
	                
	                when ITYPE_LHU => cw <= "10100101100000000001010";
	                
	                when ITYPE_SLTUI => cw <= "10100101100011011000011";
	                
	                when ITYPE_SGTUI => cw <= "10100101100011111000011";
	                
	                when ITYPE_SLEUI => cw <= "10100101100011001000011";
	                
	                when ITYPE_SGEUI => cw <= "10100101100011101000011";
	                
	              	when others =>  cw <= (others => '0');
	            end case;

        	when stall_if => cw <= (others => '0');
		
			when others => cw <=  (others => '0');
        
        end case;
           
    end process P_OUTPUTS_INST;



STALL       <= cw(CW_SIZE-1);
-- SECOND PIPE STAGE OUTPUTS

pipe1_JMP : FD generic map(1) port map(CLK,RST,cw(CW_SIZE-2 downto CW_SIZE-2),TMP1);
pipe1_RI  : FD generic map(1) port map(CLK,RST,cw(CW_SIZE-3 downto CW_SIZE-3),TMP2);
pipe1_BR  : FD generic map(2) port map(CLK,RST,cw(CW_SIZE-4 downto CW_SIZE-5),BR_TYPE);
pipe1_RD1 : FD generic map(1) port map(CLK,RST,cw(CW_SIZE-6 downto CW_SIZE-6),TMP3);
pipe1_RD2 : FD generic map(1) port map(CLK,RST,cw(CW_SIZE-7 downto CW_SIZE-7),TMP4);
pipe1_US  : FD generic map(1) port map(CLK,RST,cw(CW_SIZE-8 downto CW_SIZE-8),TMP5);

JMP <= TMP1(0);
RI  <= TMP2(0);
RD1 <= TMP3(0);
RD2 <= TMP4(0); 
US  <= TMP5(0);
   
-- THIRD PIPE STAGE OUTPUTS
pipe1_MX1  : FD generic map(1) port map(CLK,RST,cw(CW_SIZE-9  downto CW_SIZE-9),TMP1E);
pipe1_MX2  : FD generic map(1) port map(CLK,RST,cw(CW_SIZE-10 downto CW_SIZE-10),TMP2E);
pipe1_UN   : FD generic map(3) port map(CLK,RST,cw(CW_SIZE-11 downto CW_SIZE-13),TMP3E);
pipe1_OP   : FD generic map(4) port map(CLK,RST,cw(CW_SIZE-14 downto CW_SIZE-17),TMP4E);
pipe1_PC   : FD generic map(1) port map(CLK,RST,cw(CW_SIZE-18 downto CW_SIZE-18),TMP5E);

pipe2_MX1  : FD generic map(1) port map(CLK,RST,TMP1E,TMP6);
pipe2_MX2  : FD generic map(1) port map(CLK,RST,TMP2E,TMP7);
pipe2_UN   : FD generic map(3) port map(CLK,RST,TMP3E,UN_SEL);
pipe2_OP   : FD generic map(4) port map(CLK,RST,TMP4E,OP_SEL);
pipe2_PC   : FD generic map(1) port map(CLK,RST,TMP5E,TMP8);

MUX1_SEL <= TMP6(0);
MUX2_SEL <= TMP7(0);
PC_SEL	 <= TMP8(0);

-- FOURTH PIPE STAGE OUTPUTS
pipe1_RW  : FD generic map(1) port map(CLK,RST,cw(CW_SIZE-19 downto CW_SIZE-19),TMP11M);
pipe1_DT  : FD generic map(2) port map(CLK,RST,cw(CW_SIZE-20 downto CW_SIZE-21),TMP21M);

pipe2_RW  : FD generic map(1) port map(CLK,RST,TMP11M,TMP12M);
pipe2_DT  : FD generic map(2) port map(CLK,RST,TMP21M,TMP22M);

pipe3_RW  : FD generic map(1) port map(CLK,RST,TMP12M,TMP9);
pipe3_DT  : FD generic map(2) port map(CLK,RST,TMP22M,D_TYPE);

RW <= TMP9(0);

pipe1_WR  : FD_INJ generic map(1) port map(CLK,RST,FLUSH,cw(CW_SIZE-22 downto CW_SIZE-22),TMP11W);
pipe1_MM  : FD generic map(1) port map(CLK,RST,cw(CW_SIZE-23 downto CW_SIZE-23),TMP21W);

pipe2_WR  : FD_INJ generic map(1) port map(CLK,FLUSH,RST,TMP11W,TMP12W);
pipe2_MM  : FD generic map(1) port map(CLK,RST,TMP21W,TMP22W);

pipe3_WR  : FD generic map(1) port map(CLK,RST,TMP12W,TMP13W);
pipe3_MM  : FD generic map(1) port map(CLK,RST,TMP22W,TMP23W);

pipe4_WR  : FD generic map(1) port map(CLK,RST,TMP13W,TMP10);
pipe4_MM  : FD generic map(1) port map(CLK,RST,TMP23W,TMP11);

WR <= TMP10(0);
MEM_ALU_SEL <= TMP11(0);



INST_TYPE : process( OPCODE )
begin
	case OPCODE is
		when RTYPE => INST_TMP(0) <= '1';
		when others => INST_TMP(0) <= '0';
	end case;
end process INST_TYPE;

pipe1_INST  : FD generic map(1) port map(CLK,RST,INST_TMP,INST_TMP1); -- DECODE
pipe2_INST  : FD generic map(1) port map(CLK,RST,INST_TMP1,INST_TMP2); -- EXECUTE

INST_T_EX <= INST_TMP2(0);

-- DECODE
process(CLK, RST)          
begin
    if RST='0' then -- Acrive low asyncronous reset
        INST1 <= reset;
    elsif (CLK ='1' and CLK'EVENT) then 
        INST1 <= INST;
    end if;
end process;

-- EXECUTE
process(CLK, RST)          
begin
    if RST='0' then -- Acrive low asyncronous reset
        INST2 <= reset;
    elsif (CLK ='1' and CLK'EVENT) then 
        INST2 <= INST1;
    end if;
end process;


-- MEMORY
process(CLK, RST)          
begin
    if RST='0' then -- Acrive low asyncronous reset
        INST3 <= reset;
    elsif (CLK ='1' and CLK'EVENT) then 
        INST3 <= INST2;
    end if;
end process;

INST_EX  <= INST2;

INST_MEM <= INST3;


end DLX_CU_FSM;

configuration CFG_DLX_CU of DLX_CU is
for DLX_CU_FSM
  for all:FD
    use configuration WORK.CFG_FD;
  end for;

  for all:FD_INJ
    use configuration WORK.CFG_FD_INJ;
  end for;

end for;
end CFG_DLX_CU;
