library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myTypes.all;


entity dlx_cu is
  port (
            -- INPUTS
            CLK       : IN std_logic;
            RST       : IN std_logic;       -- the TB requires it active low
            OPCODE    : IN std_logic_vector(OP_SIZE-1 downto 0);
            FUNC      : IN std_logic_vector(F_SIZE-1 downto 0);

            -- FIRST PIPE STAGE OUTPUTS
            ENIF      	: OUT std_logic;    -- 1 -> en   | 0 -> dis 
            -- SECOND PIPE STAGE OUTPUTS
            ENDEC     	: OUT std_logic;
            JMP        	: OUT std_logic;     --
            RI          : OUT std_logic;
            BR_TYPE   	: OUT std_logic_vector(1 downto 0);
            RD1       	: OUT std_logic;     -- enables the read port 1 of the register file
            RD2       	: OUT std_logic;     -- enables the read port 2 of the register file
            US        	: OUT std_logic;     -- decides wether the operation is signed (0) or unsigned (1)           
            -- THIRD PIPE STAGE OUTPUTS
            ENEX      	: OUT std_logic;
            MUX1_SEL  	: OUT std_logic;     -- select operand A (from RF) or C (immediate)
            MUX2_SEL  	: OUT std_logic;     -- select operand B (from RF) or D (immediate)    
            UN_SEL    	: OUT std_logic_vector(2 downto 0); -- unit select
            OP_SEL    	: OUT std_logic_vector(3 downto 0); -- operation select
            PC_SEL    	: OUT std_logic;    -- 0 -> pc+4 | 1 -> j/b
            -- FOURTH PIPE STAGE OUTPUTS
            ENMEM     	: OUT std_logic;
            RW        	: OUT std_logic;
            D_TYPE    	: OUT std_logic_vector(1 downto 0);
            -- FIFTH PIPE STAGE OUTPUTS
            WR        	: OUT std_logic;     -- enables the write port of the register file
            MEM_ALU_SEL : OUT std_logic    
  );
end dlx_cu;

architecture dlx_cu_fsm of dlx_cu is
  
component FD
  Generic (NB : integer := 32);
  Port (  CK: In  std_logic;
    RESET:  In  std_logic;
    EN : In std_logic;
    D:  In  std_logic_vector (NB-1 downto 0);
    Q:  Out std_logic_vector (NB-1 downto 0) 
    );
end component;
                                
  signal cw   : std_logic_vector(CW_SIZE - 1 downto 0); -- full control word read from cw_mem
  signal cw1   : std_logic_vector(CW_SIZE - 1 downto 0);
  signal cw2   : std_logic_vector(CW_SIZE - 1 downto 0);
  signal cw3   : std_logic_vector(CW_SIZE - 1 downto 0);
  signal cw4   : std_logic_vector(CW_SIZE - 1 downto 0);
  signal cw5   : std_logic_vector(CW_SIZE - 1 downto 0);

  -- declarations for FSM implementation (to be completed whith alla states!)
	type TYPE_STATE is (
                        reset,
                        fetch,
                        decode,
                        execute,
                        memory,
                        write_back,
                        stall_if,
                        stall_d,
                        stall_ex,
                        stall_mem,
                        stall_wb                          
  );

  signal INST1 : TYPE_STATE := reset;
  signal NEXT_INST1 : TYPE_STATE := reset;

  signal INST2 : TYPE_STATE := reset;
  signal NEXT_INST2 : TYPE_STATE := reset;

  signal INST3 : TYPE_STATE := reset;
  signal NEXT_INST3 : TYPE_STATE := reset;

  signal INST4 : TYPE_STATE := reset;
  signal NEXT_INST4 : TYPE_STATE := reset;

  signal INST5 : TYPE_STATE := reset;
  signal NEXT_INST5 : TYPE_STATE := reset;

  signal OPCODE1, OPCODE2, OPCODE3, OPCODE4 : std_logic_vector(OP_SIZE-1 downto 0);
  signal FUNC1, FUNC2 : std_logic_vector(F_SIZE-1 downto 0); 

begin  -- dlx_cu_rtl


  OPPP1 : FD generic map (OP_SIZE) port map (CLK,RST,'1',OPCODE,OPCODE1);
  OPPP2 : FD generic map (OP_SIZE) port map (CLK,RST,'1',OPCODE1,OPCODE2);
  OPPP3 : FD generic map (OP_SIZE) port map (CLK,RST,'1',OPCODE2,OPCODE3);
  OPPP4 : FD generic map (OP_SIZE) port map (CLK,RST,'1',OPCODE3,OPCODE4);

  FUNPP1 : FD generic map (F_SIZE) port map (CLK,RST,'1',FUNC,FUNC1);
  FUNPP2 : FD generic map (F_SIZE) port map (CLK,RST,'1',FUNC1,FUNC2);
    

  -- This process update the current state at each clock cycle
    P_OPC : process(CLK, RST)          
    begin
        if RST='0' then -- Acrive low asyncronous reset
            INST1 <= reset;
            INST2 <= reset;
            INST3 <= reset;
            INST4 <= reset;
            INST5 <= reset;
        elsif (CLK ='1' and CLK'EVENT) then 
            INST1 <= NEXT_INST1;
            INST2 <= NEXT_INST2;
            INST3 <= NEXT_INST3;
            INST4 <= NEXT_INST4;
            INST5 <= NEXT_INST5;
        end if;
    end process P_OPC;



    -- In this process we decide which will bw the next state acording to where we are now 
    -- and what are our input
    P_NEXT_STATE_1 : process(INST1, OPCODE, OPCODE1, FUNC)
    begin

        case INST1 is
          
          when reset => NEXT_INST1 <= fetch;

          when fetch => NEXT_INST1 <= decode;

          when decode => NEXT_INST1 <=  execute;

          when execute => NEXT_INST1 <= memory;

          when memory => NEXT_INST1 <= write_back;

          when write_back => if ( (OPCODE = ITYPE_J) or (OPCODE = ITYPE_JAL) or (OPCODE = ITYPE_JR) or (OPCODE = ITYPE_JALR) ) then --or (OPCODE1 = ITYPE_J)) then
          					 	NEXT_INST1 <= stall_if;
          					 else
          					 	NEXT_INST1 <= fetch;
          					 end if;

          when stall_if => NEXT_INST1 <= stall_d;

          when stall_d => NEXT_INST1 <= stall_ex;

          when stall_ex => NEXT_INST1 <= stall_mem;

          when stall_mem => NEXT_INST1 <= stall_wb;

          when stall_wb => NEXT_INST1 <= fetch; 

          when others => NEXT_INST1 <= reset;	--TODO we need to  stall the pipe for 2 cycle (maybe 3) after a jump
        
        end case;  

    end process P_NEXT_STATE_1;


    -- In this process we decide which will bw the next state acording to where we are now 
    -- and what are our input
    P_NEXT_STATE_2 : process(INST2, OPCODE, OPCODE1, FUNC)
    begin

        case INST2 is
          
          when reset => NEXT_INST2 <= stall_wb;          

          when fetch => NEXT_INST2 <= decode;

          when decode => NEXT_INST2 <=  execute;

          when execute => NEXT_INST2 <= memory;

          when memory => NEXT_INST2 <= write_back;

          when write_back => if ((OPCODE = ITYPE_J) or (OPCODE = ITYPE_JAL) or (OPCODE = ITYPE_JR) or (OPCODE = ITYPE_JALR)) then-- or (OPCODE1 = ITYPE_J)) then
          					 	NEXT_INST2 <= stall_if;
          					 else
          					 	NEXT_INST2 <= fetch;
          					 end if;

          when stall_if => NEXT_INST2 <= stall_d;

          when stall_d => NEXT_INST2 <= stall_ex;

          when stall_ex => NEXT_INST2 <= stall_mem;

          when stall_mem => NEXT_INST2 <= stall_wb;

          when stall_wb => NEXT_INST2 <= fetch; 

          when others => NEXT_INST2 <= reset;
        
        end case;  

    end process P_NEXT_STATE_2;

    -- In this process we decide which will bw the next state acording to where we are now 
    -- and what are our input
    P_NEXT_STATE_3 : process(INST3, OPCODE, OPCODE1, FUNC)
    begin

        case INST3 is
          
          when reset => NEXT_INST3 <= stall_mem;

          when fetch => NEXT_INST3 <= decode;

          when decode => NEXT_INST3 <=  execute;

          when execute => NEXT_INST3 <= memory;

          when memory => NEXT_INST3 <= write_back;

          when write_back => if ((OPCODE = ITYPE_J) or (OPCODE = ITYPE_JAL) or (OPCODE = ITYPE_JR) or (OPCODE = ITYPE_JALR)) then-- or (OPCODE1 = ITYPE_J)) then
          					 	NEXT_INST3 <= stall_if;
          					 else
          					 	NEXT_INST3 <= fetch;
          					 end if;

          when stall_if => NEXT_INST3 <= stall_d;

          when stall_d => NEXT_INST3 <= stall_ex;

          when stall_ex => NEXT_INST3 <= stall_mem;

          when stall_mem => NEXT_INST3 <= stall_wb;

          when stall_wb => NEXT_INST3 <= fetch;

          when others => NEXT_INST3 <= reset;
        
        end case;  

    end process P_NEXT_STATE_3;

    -- In this process we decide which will bw the next state acording to where we are now 
    -- and what are our input
    P_NEXT_STATE_4 : process(INST4, OPCODE, OPCODE1, FUNC)
    begin

        case INST4 is
          
          when reset => NEXT_INST4 <= stall_ex;

          when fetch => NEXT_INST4 <= decode;

          when decode => NEXT_INST4 <=  execute;

          when execute => NEXT_INST4 <= memory;

          when memory => NEXT_INST4 <= write_back;

          when write_back => if ((OPCODE = ITYPE_J) or (OPCODE = ITYPE_JAL) or (OPCODE = ITYPE_JR) or (OPCODE = ITYPE_JALR)) then-- or (OPCODE1 = ITYPE_J)) then
          					 	NEXT_INST4 <= stall_if;
          					 else
          					 	NEXT_INST4 <= fetch;
          					 end if;

          when stall_if => NEXT_INST4 <= stall_d;

          when stall_d => NEXT_INST4 <= stall_ex;

          when stall_ex => NEXT_INST4 <= stall_mem;

          when stall_mem => NEXT_INST4 <= stall_wb;

          when stall_wb => NEXT_INST4 <= fetch;

          when others => NEXT_INST4 <= reset;
        
        end case;  

    end process P_NEXT_STATE_4;

    -- In this process we decide which will bw the next state acording to where we are now 
    -- and what are our input
    P_NEXT_STATE_5 : process(INST5, OPCODE, OPCODE1, FUNC)
    begin

        case INST5 is
          
          when reset => NEXT_INST5 <= stall_d;
                        
          when fetch => NEXT_INST5 <= decode;

          when decode => NEXT_INST5 <=  execute;

          when execute => NEXT_INST5 <= memory;

          when memory => NEXT_INST5 <= write_back;

          when write_back => if ((OPCODE = ITYPE_J) or (OPCODE = ITYPE_JAL) or (OPCODE = ITYPE_JR) or (OPCODE = ITYPE_JALR)) then -- or (OPCODE1 = ITYPE_J)) then
          					 	NEXT_INST5 <= stall_if;
          					 else
          					 	NEXT_INST5 <= fetch;
          					 end if;

          when stall_if => NEXT_INST5 <= stall_d;

          when stall_d => NEXT_INST5 <= stall_ex;

          when stall_ex => NEXT_INST5 <= stall_mem;

          when stall_mem => NEXT_INST5 <= stall_wb;

          when stall_wb => NEXT_INST5 <= fetch;         

          when others => NEXT_INST5 <= reset;
        
        end case;  

    end process P_NEXT_STATE_5;


    P_OUTPUTS_INST1: process(INST1,OPCODE,OPCODE1,OPCODE2,OPCODE3,OPCODE4,FUNC1,FUNC2)
    begin

        case INST1 is       
          when reset =>   cw1 <= "00000000000000000000000000";
            
          when fetch =>  
            case OPCODE is
              when RTYPE | ITYPE_J | ITYPE_ADDI | ITYPE_ADDUI | ITYPE_SUBI | ITYPE_SUBUI | ITYPE_ANDI | ITYPE_ORI | ITYPE_XORI | ITYPE_SLLI | ITYPE_SRLI | ITYPE_SRAI | ITYPE_NOP | ITYPE_SEQI | ITYPE_SNEI | ITYPE_SLTI | ITYPE_SGTI | ITYPE_SLEI | ITYPE_SGEI | ITYPE_SLTUI | ITYPE_SGTUI | ITYPE_SLEUI | ITYPE_SGEUI | ITYPE_SB | ITYPE_SH | ITYPE_SW | ITYPE_LB | ITYPE_LH | ITYPE_LW | ITYPE_LBU | ITYPE_LHU | ITYPE_JAL | ITYPE_JR | ITYPE_JALR => cw1 <= (CW_SIZE-1 => '1', others => '0');
              when others => cw1 <= (CW_SIZE-1 => '0', others => '0');
            end case;
                
          when decode =>
            case OPCODE1 is
              	when RTYPE  => 	cw1(CW_SIZE-1) <= '0';
                             	  cw1(CW_SIZE-2 downto CW_SIZE-8) <= "1000011";
                             	  cw1(CW_SIZE-10 downto CW_SIZE-26) <= (others => '0');

	                            case FUNC1 is
	                              	when RTYPE_SLL | RTYPE_SRL | RTYPE_ADDU | RTYPE_SUBU | RTYPE_SLTU | RTYPE_SGTU | RTYPE_SLEU | RTYPE_SGEU => cw1(CW_SIZE-9) <= '1';               
	                              	when RTYPE_SRA | RTYPE_ADD | RTYPE_SUB  | RTYPE_AND  | RTYPE_OR   | RTYPE_XOR  | RTYPE_SEQ  | RTYPE_SNE | RTYPE_SLT | RTYPE_SGT | RTYPE_SLE | RTYPE_SGE => cw1(CW_SIZE-9) <= '0';                 
	                              	when others   =>   cw1(CW_SIZE-9) <= '0';                       
	                            end case;

                when ITYPE_J | ITYPE_JAL => 
                                cw1(CW_SIZE-1) <= '0';
                             	  cw1(CW_SIZE-2 downto CW_SIZE-9) <= "11000000";
                             	  cw1(CW_SIZE-10 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_JR | ITYPE_JALR => 
                                cw1(CW_SIZE-1) <= '0';
                                cw1(CW_SIZE-2 downto CW_SIZE-9) <= "11000100";
                                cw1(CW_SIZE-10 downto CW_SIZE-26) <= (others => '0');
                
                when ITYPE_ADDI | ITYPE_SUBI | ITYPE_ANDI | ITYPE_ORI | ITYPE_XORI | ITYPE_SRAI | ITYPE_SEQI | ITYPE_SNEI | ITYPE_SLTI | ITYPE_SGTI | ITYPE_SLEI | ITYPE_SGEI | ITYPE_LB | ITYPE_LH | ITYPE_LW => 
                                   cw1(CW_SIZE-1) <= '0';
                                   cw1(CW_SIZE-2 downto CW_SIZE-9) <= "10100100";
                                   cw1(CW_SIZE-10 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_ADDUI | ITYPE_SUBUI | ITYPE_SLLI | ITYPE_SRLI | ITYPE_SLTUI | ITYPE_SGTUI | ITYPE_SLEUI | ITYPE_SGEUI | ITYPE_LBU | ITYPE_LHU => 
                                    cw1(CW_SIZE-1) <= '0';
                                    cw1(CW_SIZE-2 downto CW_SIZE-9) <= "10100101";
                                    cw1(CW_SIZE-10 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SB | ITYPE_SH | ITYPE_SW => 
                                    cw1(CW_SIZE-1) <= '0';
                                    cw1(CW_SIZE-2 downto CW_SIZE-9) <= "10100110";
                                    cw1(CW_SIZE-10 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_NOP => cw1 <= (others => '0');

                when others => cw1 <= (others => '0');
            end case;

          when execute =>
            case OPCODE2 is
              	when RTYPE => cw1(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                              cw1(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');
  
	                            case FUNC2 is
	                            	when RTYPE_SLL  => cw1(CW_SIZE-10 downto CW_SIZE-20) <= "11101100000";               
	                            	when RTYPE_SRL  => cw1(CW_SIZE-10 downto CW_SIZE-20) <= "11101100010";                        
	                            	when RTYPE_SRA  => cw1(CW_SIZE-10 downto CW_SIZE-20) <= "11101100010";                        
	                            	when RTYPE_ADD  => cw1(CW_SIZE-10 downto CW_SIZE-20) <= "11100000000";                        
	                            	when RTYPE_ADDU => cw1(CW_SIZE-10 downto CW_SIZE-20) <= "11100000000";                        
	                            	when RTYPE_SUB  => cw1(CW_SIZE-10 downto CW_SIZE-20) <= "11100000010";                        
	                            	when RTYPE_SUBU => cw1(CW_SIZE-10 downto CW_SIZE-20) <= "11100000010";                        
	                            	when RTYPE_AND  => cw1(CW_SIZE-10 downto CW_SIZE-20) <= "11110010000";                        
	                            	when RTYPE_OR   => cw1(CW_SIZE-10 downto CW_SIZE-20) <= "11110011100";                        
	                            	when RTYPE_XOR  => cw1(CW_SIZE-10 downto CW_SIZE-20) <= "11110001100";                        
	                            	when RTYPE_SEQ  => cw1(CW_SIZE-10 downto CW_SIZE-20) <= "11100100010";                        
	                            	when RTYPE_SNE  => cw1(CW_SIZE-10 downto CW_SIZE-20) <= "11100100110";                        
	                            	when RTYPE_SLT  => cw1(CW_SIZE-10 downto CW_SIZE-20) <= "11100110110";                        
	                            	when RTYPE_SGT  => cw1(CW_SIZE-10 downto CW_SIZE-20) <= "11100111110";                        
	                            	when RTYPE_SLE  => cw1(CW_SIZE-10 downto CW_SIZE-20) <= "11100110010";                        
	                            	when RTYPE_SGE  => cw1(CW_SIZE-10 downto CW_SIZE-20) <= "11100111010";                        
	                            	when RTYPE_SLTU => cw1(CW_SIZE-10 downto CW_SIZE-20) <= "11100110110";                        
	                            	when RTYPE_SGTU => cw1(CW_SIZE-10 downto CW_SIZE-20) <= "11100111110";                        
	                            	when RTYPE_SLEU => cw1(CW_SIZE-10 downto CW_SIZE-20) <= "11100110010";                        
	                            	when RTYPE_SGEU => cw1(CW_SIZE-10 downto CW_SIZE-20) <= "11100111010";                        
	                            	when others   =>   cw1(CW_SIZE-10 downto CW_SIZE-20) <= "00000000000";                        
	                            end case;

                when ITYPE_J => cw1(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                				        cw1(CW_SIZE-10 downto CW_SIZE-20) <= "10000000001"; 
                            	  cw1(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_JAL => cw1(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw1(CW_SIZE-10 downto CW_SIZE-20) <= "10010100001"; 
                                  cw1(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_JR => cw1(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw1(CW_SIZE-10 downto CW_SIZE-20) <= "11100000001"; 
                                  cw1(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_JALR => cw1(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw1(CW_SIZE-10 downto CW_SIZE-20) <= "11110100001"; 
                                  cw1(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');
                  
                when ITYPE_ADDI  | ITYPE_ADDUI | ITYPE_SB | ITYPE_SH | ITYPE_SW | ITYPE_LB | ITYPE_LH | ITYPE_LW | ITYPE_LBU | ITYPE_LHU => 
                                   cw1(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                   cw1(CW_SIZE-10 downto CW_SIZE-20) <= "11000000000"; 
                                   cw1(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SUBI  | ITYPE_SUBUI => 
                                   cw1(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                   cw1(CW_SIZE-10 downto CW_SIZE-20) <= "11000000010"; 
                                   cw1(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');


                when ITYPE_ANDI => 
                                  cw1(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw1(CW_SIZE-10 downto CW_SIZE-20) <= "11010010000"; 
                                  cw1(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_ORI => 
                                  cw1(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw1(CW_SIZE-10 downto CW_SIZE-20) <= "11010011100"; 
                                  cw1(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_XORI => 
                                  cw1(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw1(CW_SIZE-10 downto CW_SIZE-20) <= "11010001100"; 
                                  cw1(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SLLI => 
                                  cw1(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw1(CW_SIZE-10 downto CW_SIZE-20) <= "11001100000"; 
                                  cw1(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SRLI => 
                                  cw1(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw1(CW_SIZE-10 downto CW_SIZE-20) <= "11001100010"; 
                                  cw1(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SRAI => 
                                  cw1(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw1(CW_SIZE-10 downto CW_SIZE-20) <= "11001100010"; 
                                  cw1(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_NOP => 
                                  cw1(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw1(CW_SIZE-10 downto CW_SIZE-20) <= "00000000000"; 
                                  cw1(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SEQI => 
                                  cw1(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw1(CW_SIZE-10 downto CW_SIZE-20) <= "11000100010"; 
                                  cw1(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SNEI => 
                                  cw1(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw1(CW_SIZE-10 downto CW_SIZE-20) <= "11000100110"; 
                                  cw1(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SLTI | ITYPE_SLTUI => 
                                  cw1(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw1(CW_SIZE-10 downto CW_SIZE-20) <= "11000110110"; 
                                  cw1(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SGTI | ITYPE_SGTUI => 
                                  cw1(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw1(CW_SIZE-10 downto CW_SIZE-20) <= "11000111110"; 
                                  cw1(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SLEI | ITYPE_SLEUI => 
                                  cw1(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw1(CW_SIZE-10 downto CW_SIZE-20) <= "11000110010"; 
                                  cw1(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SGEI | ITYPE_SGEUI => 
                                  cw1(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw1(CW_SIZE-10 downto CW_SIZE-20) <= "11000111010"; 
                                  cw1(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');
                                
              	when others =>  cw1 <= (others => '0');
            end case;  


          when memory => 
            case OPCODE3 is
              	when RTYPE | ITYPE_ADDI | ITYPE_ADDUI | ITYPE_SUBI | ITYPE_SUBUI | ITYPE_ANDI | ITYPE_ORI | ITYPE_XORI | ITYPE_SLLI | ITYPE_SRLI | ITYPE_SRAI | ITYPE_SEQI | ITYPE_SNEI | ITYPE_SLTI | ITYPE_SGTI | ITYPE_SLEI | ITYPE_SGEI | ITYPE_SLTUI | ITYPE_SGTUI | ITYPE_SLEUI | ITYPE_SGEUI | ITYPE_JAL | ITYPE_JALR => 
                               cw1(CW_SIZE-1 downto CW_SIZE-20) <= (others => '0');
                               cw1(CW_SIZE-21 downto CW_SIZE-24) <= "1000";
                               cw1(CW_SIZE-25 downto CW_SIZE-26) <= (others => '0');
                
                when ITYPE_SB  => cw1(CW_SIZE-1 downto CW_SIZE-20) <= (others => '0');
                               	  cw1(CW_SIZE-21 downto CW_SIZE-24) <= "1101";
                                  cw1(CW_SIZE-25 downto CW_SIZE-26) <= (others => '0');
                
                when ITYPE_SH  => cw1(CW_SIZE-1 downto CW_SIZE-20) <= (others => '0');
                               	  cw1(CW_SIZE-21 downto CW_SIZE-24) <= "1110";
                                  cw1(CW_SIZE-25 downto CW_SIZE-26) <= (others => '0');
                
                when ITYPE_SW  => cw1(CW_SIZE-1 downto CW_SIZE-20) <= (others => '0');
                               	  cw1(CW_SIZE-21 downto CW_SIZE-24) <= "1111";
                                  cw1(CW_SIZE-25 downto CW_SIZE-26) <= (others => '0');
                
                when ITYPE_LB | ITYPE_LBU => 
                				  cw1(CW_SIZE-1 downto CW_SIZE-20) <= (others => '0');
                               	  cw1(CW_SIZE-21 downto CW_SIZE-24) <= "1001";
                                  cw1(CW_SIZE-25 downto CW_SIZE-26) <= (others => '0');
                
                when ITYPE_LH | ITYPE_LHU => 
                				  cw1(CW_SIZE-1 downto CW_SIZE-20) <= (others => '0');
                               	  cw1(CW_SIZE-21 downto CW_SIZE-24) <= "1010";
                                  cw1(CW_SIZE-25 downto CW_SIZE-26) <= (others => '0');
                
                when ITYPE_LW  => cw1(CW_SIZE-1 downto CW_SIZE-20) <= (others => '0');
                               	  cw1(CW_SIZE-21 downto CW_SIZE-24) <= "1011";
                                  cw1(CW_SIZE-25 downto CW_SIZE-26) <= (others => '0');
                
                when ITYPE_J | ITYPE_JR | ITYPE_NOP => cw1 <= (others => '0');
              	when others => cw1 <= (others => '0');
            end case;
                    

          when write_back => 
            case OPCODE4 is
              	when RTYPE | ITYPE_ADDI | ITYPE_ADDUI | ITYPE_SUBI | ITYPE_SUBUI | ITYPE_ANDI | ITYPE_ORI | ITYPE_XORI | ITYPE_SLLI | ITYPE_SRLI | ITYPE_SRAI | ITYPE_NOP | ITYPE_SEQI | ITYPE_SNEI | ITYPE_SLTI | ITYPE_SGTI | ITYPE_SLEI | ITYPE_SGEI | ITYPE_SLTUI | ITYPE_SGTUI | ITYPE_SLEUI | ITYPE_SGEUI | ITYPE_JAL | ITYPE_JALR => 
                                cw1 <= (CW_SIZE-25 => '1', CW_SIZE-26 => '1',others => '0');
                when ITYPE_J | ITYPE_JR | ITYPE_SB | ITYPE_SH | ITYPE_SW => cw1 <= (others => '0');
                when ITYPE_LB | ITYPE_LH | ITYPE_LW | ITYPE_LBU | ITYPE_LHU =>  cw1 <= (CW_SIZE-25 => '1', CW_SIZE-26 => '0',others => '0');
              	when others => cw1 <= (others => '0');             
            end case;

          when stall_if => cw1 <= (others => '0');

          when stall_d => cw1 <= (others => '0'); 

          when stall_ex => cw1 <= (others => '0');
                           
          when stall_mem => cw1 <= (others => '0');

          when stall_wb => cw1 <= (others => '0');

          when others => cw1 <=  (others => '0');
        end case;
           
    end process P_OUTPUTS_INST1;


P_OUTPUTS_INST2: process(INST2,OPCODE,OPCODE1,OPCODE2,OPCODE3,OPCODE4,FUNC1,FUNC2)
    begin

        case INST2 is       
          when reset =>   cw2 <= "00000000000000000000000000";
            
          when fetch =>  
            case OPCODE is
              when RTYPE | ITYPE_J | ITYPE_ADDI | ITYPE_ADDUI | ITYPE_SUBI | ITYPE_SUBUI | ITYPE_ANDI | ITYPE_ORI | ITYPE_XORI | ITYPE_SLLI | ITYPE_SRLI | ITYPE_SRAI | ITYPE_NOP | ITYPE_SEQI | ITYPE_SNEI | ITYPE_SLTI | ITYPE_SGTI | ITYPE_SLEI | ITYPE_SGEI | ITYPE_SLTUI | ITYPE_SGTUI | ITYPE_SLEUI | ITYPE_SGEUI | ITYPE_SB | ITYPE_SH | ITYPE_SW | ITYPE_LB | ITYPE_LH | ITYPE_LW | ITYPE_LBU | ITYPE_LHU | ITYPE_JAL | ITYPE_JR | ITYPE_JALR => cw2 <= (CW_SIZE-1 => '1', others => '0');
              when others => cw2 <= (CW_SIZE-1 => '0', others => '0');
            end case;
                
          when decode =>
            case OPCODE1 is
                when RTYPE  =>  cw2(CW_SIZE-1) <= '0';
                                cw2(CW_SIZE-2 downto CW_SIZE-8) <= "1000011";
                                cw2(CW_SIZE-10 downto CW_SIZE-26) <= (others => '0');

                              case FUNC1 is
                                  when RTYPE_SLL | RTYPE_SRL | RTYPE_ADDU | RTYPE_SUBU | RTYPE_SLTU | RTYPE_SGTU | RTYPE_SLEU | RTYPE_SGEU => cw2(CW_SIZE-9) <= '1';               
                                  when RTYPE_SRA | RTYPE_ADD | RTYPE_SUB  | RTYPE_AND  | RTYPE_OR   | RTYPE_XOR  | RTYPE_SEQ  | RTYPE_SNE | RTYPE_SLT | RTYPE_SGT | RTYPE_SLE | RTYPE_SGE => cw2(CW_SIZE-9) <= '0';                 
                                  when others   =>   cw2(CW_SIZE-9) <= '0';                       
                              end case;

                when ITYPE_J | ITYPE_JAL => 
                                cw2(CW_SIZE-1) <= '0';
                                cw2(CW_SIZE-2 downto CW_SIZE-9) <= "11000000";
                                cw2(CW_SIZE-10 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_JR | ITYPE_JALR => 
                                cw2(CW_SIZE-1) <= '0';
                                cw2(CW_SIZE-2 downto CW_SIZE-9) <= "11000100";
                                cw2(CW_SIZE-10 downto CW_SIZE-26) <= (others => '0');
                
                when ITYPE_ADDI | ITYPE_SUBI | ITYPE_ANDI | ITYPE_ORI | ITYPE_XORI | ITYPE_SRAI | ITYPE_SEQI | ITYPE_SNEI | ITYPE_SLTI | ITYPE_SGTI | ITYPE_SLEI | ITYPE_SGEI | ITYPE_LB | ITYPE_LH | ITYPE_LW => 
                                   cw2(CW_SIZE-1) <= '0';
                                   cw2(CW_SIZE-2 downto CW_SIZE-9) <= "10100100";
                                   cw2(CW_SIZE-10 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_ADDUI | ITYPE_SUBUI | ITYPE_SLLI | ITYPE_SRLI | ITYPE_SLTUI | ITYPE_SGTUI | ITYPE_SLEUI | ITYPE_SGEUI | ITYPE_LBU | ITYPE_LHU => 
                                    cw2(CW_SIZE-1) <= '0';
                                    cw2(CW_SIZE-2 downto CW_SIZE-9) <= "10100101";
                                    cw2(CW_SIZE-10 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SB | ITYPE_SH | ITYPE_SW => 
                                    cw2(CW_SIZE-1) <= '0';
                                    cw2(CW_SIZE-2 downto CW_SIZE-9) <= "10100110";
                                    cw2(CW_SIZE-10 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_NOP => cw2 <= (others => '0');

                when others => cw2 <= (others => '0');
            end case;

          when execute =>
            case OPCODE2 is
                when RTYPE => cw2(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                              cw2(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');
  
                              case FUNC2 is
                                when RTYPE_SLL  => cw2(CW_SIZE-10 downto CW_SIZE-20) <= "11101100000";               
                                when RTYPE_SRL  => cw2(CW_SIZE-10 downto CW_SIZE-20) <= "11101100010";                        
                                when RTYPE_SRA  => cw2(CW_SIZE-10 downto CW_SIZE-20) <= "11101100010";                        
                                when RTYPE_ADD  => cw2(CW_SIZE-10 downto CW_SIZE-20) <= "11100000000";                        
                                when RTYPE_ADDU => cw2(CW_SIZE-10 downto CW_SIZE-20) <= "11100000000";                        
                                when RTYPE_SUB  => cw2(CW_SIZE-10 downto CW_SIZE-20) <= "11100000010";                        
                                when RTYPE_SUBU => cw2(CW_SIZE-10 downto CW_SIZE-20) <= "11100000010";                        
                                when RTYPE_AND  => cw2(CW_SIZE-10 downto CW_SIZE-20) <= "11110010000";                        
                                when RTYPE_OR   => cw2(CW_SIZE-10 downto CW_SIZE-20) <= "11110011100";                        
                                when RTYPE_XOR  => cw2(CW_SIZE-10 downto CW_SIZE-20) <= "11110001100";                        
                                when RTYPE_SEQ  => cw2(CW_SIZE-10 downto CW_SIZE-20) <= "11100100010";                        
                                when RTYPE_SNE  => cw2(CW_SIZE-10 downto CW_SIZE-20) <= "11100100110";                        
                                when RTYPE_SLT  => cw2(CW_SIZE-10 downto CW_SIZE-20) <= "11100110110";                        
                                when RTYPE_SGT  => cw2(CW_SIZE-10 downto CW_SIZE-20) <= "11100111110";                        
                                when RTYPE_SLE  => cw2(CW_SIZE-10 downto CW_SIZE-20) <= "11100110010";                        
                                when RTYPE_SGE  => cw2(CW_SIZE-10 downto CW_SIZE-20) <= "11100111010";                        
                                when RTYPE_SLTU => cw2(CW_SIZE-10 downto CW_SIZE-20) <= "11100110110";                        
                                when RTYPE_SGTU => cw2(CW_SIZE-10 downto CW_SIZE-20) <= "11100111110";                        
                                when RTYPE_SLEU => cw2(CW_SIZE-10 downto CW_SIZE-20) <= "11100110010";                        
                                when RTYPE_SGEU => cw2(CW_SIZE-10 downto CW_SIZE-20) <= "11100111010";                        
                                when others   =>   cw2(CW_SIZE-10 downto CW_SIZE-20) <= "00000000000";                        
                              end case;

                when ITYPE_J => cw2(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                cw2(CW_SIZE-10 downto CW_SIZE-20) <= "10000000001"; 
                                cw2(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_JAL => cw2(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw2(CW_SIZE-10 downto CW_SIZE-20) <= "10010100001"; 
                                  cw2(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_JR => cw2(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw2(CW_SIZE-10 downto CW_SIZE-20) <= "11100000001"; 
                                  cw2(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_JALR => cw2(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw2(CW_SIZE-10 downto CW_SIZE-20) <= "11110100001"; 
                                  cw2(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');
                  
                when ITYPE_ADDI  | ITYPE_ADDUI | ITYPE_SB | ITYPE_SH | ITYPE_SW | ITYPE_LB | ITYPE_LH | ITYPE_LW | ITYPE_LBU | ITYPE_LHU => 
                                   cw2(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                   cw2(CW_SIZE-10 downto CW_SIZE-20) <= "11000000000"; 
                                   cw2(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SUBI  | ITYPE_SUBUI => 
                                   cw2(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                   cw2(CW_SIZE-10 downto CW_SIZE-20) <= "11000000010"; 
                                   cw2(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');


                when ITYPE_ANDI => 
                                  cw2(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw2(CW_SIZE-10 downto CW_SIZE-20) <= "11010010000"; 
                                  cw2(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_ORI => 
                                  cw2(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw2(CW_SIZE-10 downto CW_SIZE-20) <= "11010011100"; 
                                  cw2(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_XORI => 
                                  cw2(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw2(CW_SIZE-10 downto CW_SIZE-20) <= "11010001100"; 
                                  cw2(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SLLI => 
                                  cw2(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw2(CW_SIZE-10 downto CW_SIZE-20) <= "11001100000"; 
                                  cw2(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SRLI => 
                                  cw2(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw2(CW_SIZE-10 downto CW_SIZE-20) <= "11001100010"; 
                                  cw2(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SRAI => 
                                  cw2(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw2(CW_SIZE-10 downto CW_SIZE-20) <= "11001100010"; 
                                  cw2(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_NOP => 
                                  cw2(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw2(CW_SIZE-10 downto CW_SIZE-20) <= "00000000000"; 
                                  cw2(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SEQI => 
                                  cw2(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw2(CW_SIZE-10 downto CW_SIZE-20) <= "11000100010"; 
                                  cw2(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SNEI => 
                                  cw2(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw2(CW_SIZE-10 downto CW_SIZE-20) <= "11000100110"; 
                                  cw2(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SLTI | ITYPE_SLTUI => 
                                  cw2(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw2(CW_SIZE-10 downto CW_SIZE-20) <= "11000110110"; 
                                  cw2(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SGTI | ITYPE_SGTUI => 
                                  cw2(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw2(CW_SIZE-10 downto CW_SIZE-20) <= "11000111110"; 
                                  cw2(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SLEI | ITYPE_SLEUI => 
                                  cw2(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw2(CW_SIZE-10 downto CW_SIZE-20) <= "11000110010"; 
                                  cw2(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SGEI | ITYPE_SGEUI => 
                                  cw2(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw2(CW_SIZE-10 downto CW_SIZE-20) <= "11000111010"; 
                                  cw2(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');
                                
                when others =>  cw2 <= (others => '0');
            end case;  


          when memory => 
            case OPCODE3 is
                when RTYPE | ITYPE_ADDI | ITYPE_ADDUI | ITYPE_SUBI | ITYPE_SUBUI | ITYPE_ANDI | ITYPE_ORI | ITYPE_XORI | ITYPE_SLLI | ITYPE_SRLI | ITYPE_SRAI | ITYPE_SEQI | ITYPE_SNEI | ITYPE_SLTI | ITYPE_SGTI | ITYPE_SLEI | ITYPE_SGEI | ITYPE_SLTUI | ITYPE_SGTUI | ITYPE_SLEUI | ITYPE_SGEUI | ITYPE_JAL | ITYPE_JALR => 
                               cw2(CW_SIZE-1 downto CW_SIZE-20) <= (others => '0');
                               cw2(CW_SIZE-21 downto CW_SIZE-24) <= "1000";
                               cw2(CW_SIZE-25 downto CW_SIZE-26) <= (others => '0');
                
                when ITYPE_SB  => cw2(CW_SIZE-1 downto CW_SIZE-20) <= (others => '0');
                                  cw2(CW_SIZE-21 downto CW_SIZE-24) <= "1101";
                                  cw2(CW_SIZE-25 downto CW_SIZE-26) <= (others => '0');
                
                when ITYPE_SH  => cw2(CW_SIZE-1 downto CW_SIZE-20) <= (others => '0');
                                  cw2(CW_SIZE-21 downto CW_SIZE-24) <= "1110";
                                  cw2(CW_SIZE-25 downto CW_SIZE-26) <= (others => '0');
                
                when ITYPE_SW  => cw2(CW_SIZE-1 downto CW_SIZE-20) <= (others => '0');
                                  cw2(CW_SIZE-21 downto CW_SIZE-24) <= "1111";
                                  cw2(CW_SIZE-25 downto CW_SIZE-26) <= (others => '0');
                
                when ITYPE_LB | ITYPE_LBU => 
                          cw2(CW_SIZE-1 downto CW_SIZE-20) <= (others => '0');
                                  cw2(CW_SIZE-21 downto CW_SIZE-24) <= "1001";
                                  cw2(CW_SIZE-25 downto CW_SIZE-26) <= (others => '0');
                
                when ITYPE_LH | ITYPE_LHU => 
                          cw2(CW_SIZE-1 downto CW_SIZE-20) <= (others => '0');
                                  cw2(CW_SIZE-21 downto CW_SIZE-24) <= "1010";
                                  cw2(CW_SIZE-25 downto CW_SIZE-26) <= (others => '0');
                
                when ITYPE_LW  => cw2(CW_SIZE-1 downto CW_SIZE-20) <= (others => '0');
                                  cw2(CW_SIZE-21 downto CW_SIZE-24) <= "1011";
                                  cw2(CW_SIZE-25 downto CW_SIZE-26) <= (others => '0');
                
                when ITYPE_J | ITYPE_JR | ITYPE_NOP => cw2 <= (others => '0');
                when others => cw2 <= (others => '0');
            end case;
                    

          when write_back => 
            case OPCODE4 is
                when RTYPE | ITYPE_ADDI | ITYPE_ADDUI | ITYPE_SUBI | ITYPE_SUBUI | ITYPE_ANDI | ITYPE_ORI | ITYPE_XORI | ITYPE_SLLI | ITYPE_SRLI | ITYPE_SRAI | ITYPE_NOP | ITYPE_SEQI | ITYPE_SNEI | ITYPE_SLTI | ITYPE_SGTI | ITYPE_SLEI | ITYPE_SGEI | ITYPE_SLTUI | ITYPE_SGTUI | ITYPE_SLEUI | ITYPE_SGEUI | ITYPE_JAL | ITYPE_JALR => 
                                cw2 <= (CW_SIZE-25 => '1', CW_SIZE-26 => '1',others => '0');
                when ITYPE_J | ITYPE_JR | ITYPE_SB | ITYPE_SH | ITYPE_SW => cw2 <= (others => '0');
                when ITYPE_LB | ITYPE_LH | ITYPE_LW | ITYPE_LBU | ITYPE_LHU =>  cw2 <= (CW_SIZE-25 => '1', CW_SIZE-26 => '0',others => '0');
                when others => cw2 <= (others => '0');             
            end case;

          when stall_if => cw2 <= (others => '0');

          when stall_d => cw2 <= (others => '0'); 

          when stall_ex => cw2 <= (others => '0');
                           
          when stall_mem => cw2 <= (others => '0');

          when stall_wb => cw2 <= (others => '0');

          when others => cw2 <=  (others => '0');
        end case;      
          
    end process P_OUTPUTS_INST2;


P_OUTPUTS_INST3: process(INST3,OPCODE,OPCODE1,OPCODE2,OPCODE3,OPCODE4,FUNC,FUNC1,FUNC2)
    begin

        case INST3 is       
          when reset =>   cw3 <= "00000000000000000000000000";
            
          when fetch =>  
            case OPCODE is
              when RTYPE | ITYPE_J | ITYPE_ADDI | ITYPE_ADDUI | ITYPE_SUBI | ITYPE_SUBUI | ITYPE_ANDI | ITYPE_ORI | ITYPE_XORI | ITYPE_SLLI | ITYPE_SRLI | ITYPE_SRAI | ITYPE_NOP | ITYPE_SEQI | ITYPE_SNEI | ITYPE_SLTI | ITYPE_SGTI | ITYPE_SLEI | ITYPE_SGEI | ITYPE_SLTUI | ITYPE_SGTUI | ITYPE_SLEUI | ITYPE_SGEUI | ITYPE_SB | ITYPE_SH | ITYPE_SW | ITYPE_LB | ITYPE_LH | ITYPE_LW | ITYPE_LBU | ITYPE_LHU | ITYPE_JAL | ITYPE_JR | ITYPE_JALR => cw3 <= (CW_SIZE-1 => '1', others => '0');
              when others => cw3 <= (CW_SIZE-1 => '0', others => '0');
            end case;
                
          when decode =>
            case OPCODE1 is
                when RTYPE  =>  cw3(CW_SIZE-1) <= '0';
                                cw3(CW_SIZE-2 downto CW_SIZE-8) <= "1000011";
                                cw3(CW_SIZE-10 downto CW_SIZE-26) <= (others => '0');

                              case FUNC1 is
                                  when RTYPE_SLL | RTYPE_SRL | RTYPE_ADDU | RTYPE_SUBU | RTYPE_SLTU | RTYPE_SGTU | RTYPE_SLEU | RTYPE_SGEU => cw3(CW_SIZE-9) <= '1';               
                                  when RTYPE_SRA | RTYPE_ADD | RTYPE_SUB  | RTYPE_AND  | RTYPE_OR   | RTYPE_XOR  | RTYPE_SEQ  | RTYPE_SNE | RTYPE_SLT | RTYPE_SGT | RTYPE_SLE | RTYPE_SGE => cw3(CW_SIZE-9) <= '0';                 
                                  when others   =>   cw3(CW_SIZE-9) <= '0';                       
                              end case;

                when ITYPE_J | ITYPE_JAL => 
                                cw3(CW_SIZE-1) <= '0';
                                cw3(CW_SIZE-2 downto CW_SIZE-9) <= "11000000";
                                cw3(CW_SIZE-10 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_JR | ITYPE_JALR => 
                                cw3(CW_SIZE-1) <= '0';
                                cw3(CW_SIZE-2 downto CW_SIZE-9) <= "11000100";
                                cw3(CW_SIZE-10 downto CW_SIZE-26) <= (others => '0');
                
                when ITYPE_ADDI | ITYPE_SUBI | ITYPE_ANDI | ITYPE_ORI | ITYPE_XORI | ITYPE_SRAI | ITYPE_SEQI | ITYPE_SNEI | ITYPE_SLTI | ITYPE_SGTI | ITYPE_SLEI | ITYPE_SGEI | ITYPE_LB | ITYPE_LH | ITYPE_LW => 
                                   cw3(CW_SIZE-1) <= '0';
                                   cw3(CW_SIZE-2 downto CW_SIZE-9) <= "10100100";
                                   cw3(CW_SIZE-10 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_ADDUI | ITYPE_SUBUI | ITYPE_SLLI | ITYPE_SRLI | ITYPE_SLTUI | ITYPE_SGTUI | ITYPE_SLEUI | ITYPE_SGEUI | ITYPE_LBU | ITYPE_LHU => 
                                    cw3(CW_SIZE-1) <= '0';
                                    cw3(CW_SIZE-2 downto CW_SIZE-9) <= "10100101";
                                    cw3(CW_SIZE-10 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SB | ITYPE_SH | ITYPE_SW => 
                                    cw3(CW_SIZE-1) <= '0';
                                    cw3(CW_SIZE-2 downto CW_SIZE-9) <= "10100110";
                                    cw3(CW_SIZE-10 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_NOP => cw3 <= (others => '0');

                when others => cw3 <= (others => '0');
            end case;

          when execute =>
            case OPCODE2 is
                when RTYPE => cw3(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                              cw3(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');
  
                              case FUNC2 is
                                when RTYPE_SLL  => cw3(CW_SIZE-10 downto CW_SIZE-20) <= "11101100000";               
                                when RTYPE_SRL  => cw3(CW_SIZE-10 downto CW_SIZE-20) <= "11101100010";                        
                                when RTYPE_SRA  => cw3(CW_SIZE-10 downto CW_SIZE-20) <= "11101100010";                        
                                when RTYPE_ADD  => cw3(CW_SIZE-10 downto CW_SIZE-20) <= "11100000000";                        
                                when RTYPE_ADDU => cw3(CW_SIZE-10 downto CW_SIZE-20) <= "11100000000";                        
                                when RTYPE_SUB  => cw3(CW_SIZE-10 downto CW_SIZE-20) <= "11100000010";                        
                                when RTYPE_SUBU => cw3(CW_SIZE-10 downto CW_SIZE-20) <= "11100000010";                        
                                when RTYPE_AND  => cw3(CW_SIZE-10 downto CW_SIZE-20) <= "11110010000";                        
                                when RTYPE_OR   => cw3(CW_SIZE-10 downto CW_SIZE-20) <= "11110011100";                        
                                when RTYPE_XOR  => cw3(CW_SIZE-10 downto CW_SIZE-20) <= "11110001100";                        
                                when RTYPE_SEQ  => cw3(CW_SIZE-10 downto CW_SIZE-20) <= "11100100010";                        
                                when RTYPE_SNE  => cw3(CW_SIZE-10 downto CW_SIZE-20) <= "11100100110";                        
                                when RTYPE_SLT  => cw3(CW_SIZE-10 downto CW_SIZE-20) <= "11100110110";                        
                                when RTYPE_SGT  => cw3(CW_SIZE-10 downto CW_SIZE-20) <= "11100111110";                        
                                when RTYPE_SLE  => cw3(CW_SIZE-10 downto CW_SIZE-20) <= "11100110010";                        
                                when RTYPE_SGE  => cw3(CW_SIZE-10 downto CW_SIZE-20) <= "11100111010";                        
                                when RTYPE_SLTU => cw3(CW_SIZE-10 downto CW_SIZE-20) <= "11100110110";                        
                                when RTYPE_SGTU => cw3(CW_SIZE-10 downto CW_SIZE-20) <= "11100111110";                        
                                when RTYPE_SLEU => cw3(CW_SIZE-10 downto CW_SIZE-20) <= "11100110010";                        
                                when RTYPE_SGEU => cw3(CW_SIZE-10 downto CW_SIZE-20) <= "11100111010";                        
                                when others   =>   cw3(CW_SIZE-10 downto CW_SIZE-20) <= "00000000000";                        
                              end case;

                when ITYPE_J => cw3(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                cw3(CW_SIZE-10 downto CW_SIZE-20) <= "10000000001"; 
                                cw3(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_JAL => cw3(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw3(CW_SIZE-10 downto CW_SIZE-20) <= "10010100001"; 
                                  cw3(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_JR => cw3(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw3(CW_SIZE-10 downto CW_SIZE-20) <= "11100000001"; 
                                  cw3(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_JALR => cw3(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw3(CW_SIZE-10 downto CW_SIZE-20) <= "11110100001"; 
                                  cw3(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');
                  
                when ITYPE_ADDI  | ITYPE_ADDUI | ITYPE_SB | ITYPE_SH | ITYPE_SW | ITYPE_LB | ITYPE_LH | ITYPE_LW | ITYPE_LBU | ITYPE_LHU => 
                                   cw3(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                   cw3(CW_SIZE-10 downto CW_SIZE-20) <= "11000000000"; 
                                   cw3(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SUBI  | ITYPE_SUBUI => 
                                   cw3(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                   cw3(CW_SIZE-10 downto CW_SIZE-20) <= "11000000010"; 
                                   cw3(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');


                when ITYPE_ANDI => 
                                  cw3(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw3(CW_SIZE-10 downto CW_SIZE-20) <= "11010010000"; 
                                  cw3(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_ORI => 
                                  cw3(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw3(CW_SIZE-10 downto CW_SIZE-20) <= "11010011100"; 
                                  cw3(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_XORI => 
                                  cw3(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw3(CW_SIZE-10 downto CW_SIZE-20) <= "11010001100"; 
                                  cw3(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SLLI => 
                                  cw3(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw3(CW_SIZE-10 downto CW_SIZE-20) <= "11001100000"; 
                                  cw3(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SRLI => 
                                  cw3(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw3(CW_SIZE-10 downto CW_SIZE-20) <= "11001100010"; 
                                  cw3(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SRAI => 
                                  cw3(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw3(CW_SIZE-10 downto CW_SIZE-20) <= "11001100010"; 
                                  cw3(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_NOP => 
                                  cw3(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw3(CW_SIZE-10 downto CW_SIZE-20) <= "00000000000"; 
                                  cw3(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SEQI => 
                                  cw3(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw3(CW_SIZE-10 downto CW_SIZE-20) <= "11000100010"; 
                                  cw3(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SNEI => 
                                  cw3(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw3(CW_SIZE-10 downto CW_SIZE-20) <= "11000100110"; 
                                  cw3(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SLTI | ITYPE_SLTUI => 
                                  cw3(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw3(CW_SIZE-10 downto CW_SIZE-20) <= "11000110110"; 
                                  cw3(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SGTI | ITYPE_SGTUI => 
                                  cw3(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw3(CW_SIZE-10 downto CW_SIZE-20) <= "11000111110"; 
                                  cw3(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SLEI | ITYPE_SLEUI => 
                                  cw3(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw3(CW_SIZE-10 downto CW_SIZE-20) <= "11000110010"; 
                                  cw3(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SGEI | ITYPE_SGEUI => 
                                  cw3(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw3(CW_SIZE-10 downto CW_SIZE-20) <= "11000111010"; 
                                  cw3(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');
                                
                when others =>  cw3 <= (others => '0');
            end case;  


          when memory => 
            case OPCODE3 is
                when RTYPE | ITYPE_ADDI | ITYPE_ADDUI | ITYPE_SUBI | ITYPE_SUBUI | ITYPE_ANDI | ITYPE_ORI | ITYPE_XORI | ITYPE_SLLI | ITYPE_SRLI | ITYPE_SRAI | ITYPE_SEQI | ITYPE_SNEI | ITYPE_SLTI | ITYPE_SGTI | ITYPE_SLEI | ITYPE_SGEI | ITYPE_SLTUI | ITYPE_SGTUI | ITYPE_SLEUI | ITYPE_SGEUI | ITYPE_JAL | ITYPE_JALR => 
                               cw3(CW_SIZE-1 downto CW_SIZE-20) <= (others => '0');
                               cw3(CW_SIZE-21 downto CW_SIZE-24) <= "1000";
                               cw3(CW_SIZE-25 downto CW_SIZE-26) <= (others => '0');
                
                when ITYPE_SB  => cw3(CW_SIZE-1 downto CW_SIZE-20) <= (others => '0');
                                  cw3(CW_SIZE-21 downto CW_SIZE-24) <= "1101";
                                  cw3(CW_SIZE-25 downto CW_SIZE-26) <= (others => '0');
                
                when ITYPE_SH  => cw3(CW_SIZE-1 downto CW_SIZE-20) <= (others => '0');
                                  cw3(CW_SIZE-21 downto CW_SIZE-24) <= "1110";
                                  cw3(CW_SIZE-25 downto CW_SIZE-26) <= (others => '0');
                
                when ITYPE_SW  => cw3(CW_SIZE-1 downto CW_SIZE-20) <= (others => '0');
                                  cw3(CW_SIZE-21 downto CW_SIZE-24) <= "1111";
                                  cw3(CW_SIZE-25 downto CW_SIZE-26) <= (others => '0');
                
                when ITYPE_LB | ITYPE_LBU => 
                          cw3(CW_SIZE-1 downto CW_SIZE-20) <= (others => '0');
                                  cw3(CW_SIZE-21 downto CW_SIZE-24) <= "1001";
                                  cw3(CW_SIZE-25 downto CW_SIZE-26) <= (others => '0');
                
                when ITYPE_LH | ITYPE_LHU => 
                          cw3(CW_SIZE-1 downto CW_SIZE-20) <= (others => '0');
                                  cw3(CW_SIZE-21 downto CW_SIZE-24) <= "1010";
                                  cw3(CW_SIZE-25 downto CW_SIZE-26) <= (others => '0');
                
                when ITYPE_LW  => cw3(CW_SIZE-1 downto CW_SIZE-20) <= (others => '0');
                                  cw3(CW_SIZE-21 downto CW_SIZE-24) <= "1011";
                                  cw3(CW_SIZE-25 downto CW_SIZE-26) <= (others => '0');
                
                when ITYPE_J | ITYPE_JR | ITYPE_NOP => cw3 <= (others => '0');
                when others => cw3 <= (others => '0');
            end case;
                    

          when write_back => 
            case OPCODE4 is
                when RTYPE | ITYPE_ADDI | ITYPE_ADDUI | ITYPE_SUBI | ITYPE_SUBUI | ITYPE_ANDI | ITYPE_ORI | ITYPE_XORI | ITYPE_SLLI | ITYPE_SRLI | ITYPE_SRAI | ITYPE_NOP | ITYPE_SEQI | ITYPE_SNEI | ITYPE_SLTI | ITYPE_SGTI | ITYPE_SLEI | ITYPE_SGEI | ITYPE_SLTUI | ITYPE_SGTUI | ITYPE_SLEUI | ITYPE_SGEUI | ITYPE_JAL | ITYPE_JALR => 
                                cw3 <= (CW_SIZE-25 => '1', CW_SIZE-26 => '1',others => '0');
                when ITYPE_J | ITYPE_JR | ITYPE_SB | ITYPE_SH | ITYPE_SW => cw3 <= (others => '0');
                when ITYPE_LB | ITYPE_LH | ITYPE_LW | ITYPE_LBU | ITYPE_LHU =>  cw3 <= (CW_SIZE-25 => '1', CW_SIZE-26 => '0',others => '0');
                when others => cw3 <= (others => '0');             
            end case;

          when stall_if => cw3 <= (others => '0');

          when stall_d => cw3 <= (others => '0'); 

          when stall_ex => cw3 <= (others => '0');
                           
          when stall_mem => cw3 <= (others => '0');

          when stall_wb => cw3 <= (others => '0');

          when others => cw3 <=  (others => '0');
        end case; 

    end process P_OUTPUTS_INST3;


    P_OUTPUTS_INST4: process(INST4,OPCODE,OPCODE1,OPCODE2,OPCODE3,OPCODE4,FUNC1,FUNC2)
    begin

        case INST4 is       
          when reset =>   cw4 <= "00000000000000000000000000";
            
          when fetch =>  
            case OPCODE is
              when RTYPE | ITYPE_J | ITYPE_ADDI | ITYPE_ADDUI | ITYPE_SUBI | ITYPE_SUBUI | ITYPE_ANDI | ITYPE_ORI | ITYPE_XORI | ITYPE_SLLI | ITYPE_SRLI | ITYPE_SRAI | ITYPE_NOP | ITYPE_SEQI | ITYPE_SNEI | ITYPE_SLTI | ITYPE_SGTI | ITYPE_SLEI | ITYPE_SGEI | ITYPE_SLTUI | ITYPE_SGTUI | ITYPE_SLEUI | ITYPE_SGEUI | ITYPE_SB | ITYPE_SH | ITYPE_SW | ITYPE_LB | ITYPE_LH | ITYPE_LW | ITYPE_LBU | ITYPE_LHU | ITYPE_JAL | ITYPE_JR | ITYPE_JALR => cw4 <= (CW_SIZE-1 => '1', others => '0');
              when others => cw4 <= (CW_SIZE-1 => '0', others => '0');
            end case;
                
          when decode =>
            case OPCODE1 is
                when RTYPE  =>  cw4(CW_SIZE-1) <= '0';
                                cw4(CW_SIZE-2 downto CW_SIZE-8) <= "1000011";
                                cw4(CW_SIZE-10 downto CW_SIZE-26) <= (others => '0');

                              case FUNC1 is
                                  when RTYPE_SLL | RTYPE_SRL | RTYPE_ADDU | RTYPE_SUBU | RTYPE_SLTU | RTYPE_SGTU | RTYPE_SLEU | RTYPE_SGEU => cw4(CW_SIZE-9) <= '1';               
                                  when RTYPE_SRA | RTYPE_ADD | RTYPE_SUB  | RTYPE_AND  | RTYPE_OR   | RTYPE_XOR  | RTYPE_SEQ  | RTYPE_SNE | RTYPE_SLT | RTYPE_SGT | RTYPE_SLE | RTYPE_SGE => cw4(CW_SIZE-9) <= '0';                 
                                  when others   =>   cw4(CW_SIZE-9) <= '0';                       
                              end case;

                when ITYPE_J | ITYPE_JAL => 
                                cw4(CW_SIZE-1) <= '0';
                                cw4(CW_SIZE-2 downto CW_SIZE-9) <= "11000000";
                                cw4(CW_SIZE-10 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_JR | ITYPE_JALR => 
                                cw4(CW_SIZE-1) <= '0';
                                cw4(CW_SIZE-2 downto CW_SIZE-9) <= "11000100";
                                cw4(CW_SIZE-10 downto CW_SIZE-26) <= (others => '0');
                
                when ITYPE_ADDI | ITYPE_SUBI | ITYPE_ANDI | ITYPE_ORI | ITYPE_XORI | ITYPE_SRAI | ITYPE_SEQI | ITYPE_SNEI | ITYPE_SLTI | ITYPE_SGTI | ITYPE_SLEI | ITYPE_SGEI | ITYPE_LB | ITYPE_LH | ITYPE_LW => 
                                   cw4(CW_SIZE-1) <= '0';
                                   cw4(CW_SIZE-2 downto CW_SIZE-9) <= "10100100";
                                   cw4(CW_SIZE-10 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_ADDUI | ITYPE_SUBUI | ITYPE_SLLI | ITYPE_SRLI | ITYPE_SLTUI | ITYPE_SGTUI | ITYPE_SLEUI | ITYPE_SGEUI | ITYPE_LBU | ITYPE_LHU => 
                                    cw4(CW_SIZE-1) <= '0';
                                    cw4(CW_SIZE-2 downto CW_SIZE-9) <= "10100101";
                                    cw4(CW_SIZE-10 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SB | ITYPE_SH | ITYPE_SW => 
                                    cw4(CW_SIZE-1) <= '0';
                                    cw4(CW_SIZE-2 downto CW_SIZE-9) <= "10100110";
                                    cw4(CW_SIZE-10 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_NOP => cw4 <= (others => '0');

                when others => cw4 <= (others => '0');
            end case;

          when execute =>
            case OPCODE2 is
                when RTYPE => cw4(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                              cw4(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');
  
                              case FUNC2 is
                                when RTYPE_SLL  => cw4(CW_SIZE-10 downto CW_SIZE-20) <= "11101100000";               
                                when RTYPE_SRL  => cw4(CW_SIZE-10 downto CW_SIZE-20) <= "11101100010";                        
                                when RTYPE_SRA  => cw4(CW_SIZE-10 downto CW_SIZE-20) <= "11101100010";                        
                                when RTYPE_ADD  => cw4(CW_SIZE-10 downto CW_SIZE-20) <= "11100000000";                        
                                when RTYPE_ADDU => cw4(CW_SIZE-10 downto CW_SIZE-20) <= "11100000000";                        
                                when RTYPE_SUB  => cw4(CW_SIZE-10 downto CW_SIZE-20) <= "11100000010";                        
                                when RTYPE_SUBU => cw4(CW_SIZE-10 downto CW_SIZE-20) <= "11100000010";                        
                                when RTYPE_AND  => cw4(CW_SIZE-10 downto CW_SIZE-20) <= "11110010000";                        
                                when RTYPE_OR   => cw4(CW_SIZE-10 downto CW_SIZE-20) <= "11110011100";                        
                                when RTYPE_XOR  => cw4(CW_SIZE-10 downto CW_SIZE-20) <= "11110001100";                        
                                when RTYPE_SEQ  => cw4(CW_SIZE-10 downto CW_SIZE-20) <= "11100100010";                        
                                when RTYPE_SNE  => cw4(CW_SIZE-10 downto CW_SIZE-20) <= "11100100110";                        
                                when RTYPE_SLT  => cw4(CW_SIZE-10 downto CW_SIZE-20) <= "11100110110";                        
                                when RTYPE_SGT  => cw4(CW_SIZE-10 downto CW_SIZE-20) <= "11100111110";                        
                                when RTYPE_SLE  => cw4(CW_SIZE-10 downto CW_SIZE-20) <= "11100110010";                        
                                when RTYPE_SGE  => cw4(CW_SIZE-10 downto CW_SIZE-20) <= "11100111010";                        
                                when RTYPE_SLTU => cw4(CW_SIZE-10 downto CW_SIZE-20) <= "11100110110";                        
                                when RTYPE_SGTU => cw4(CW_SIZE-10 downto CW_SIZE-20) <= "11100111110";                        
                                when RTYPE_SLEU => cw4(CW_SIZE-10 downto CW_SIZE-20) <= "11100110010";                        
                                when RTYPE_SGEU => cw4(CW_SIZE-10 downto CW_SIZE-20) <= "11100111010";                        
                                when others   =>   cw4(CW_SIZE-10 downto CW_SIZE-20) <= "00000000000";                        
                              end case;

                when ITYPE_J => cw4(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                cw4(CW_SIZE-10 downto CW_SIZE-20) <= "10000000001"; 
                                cw4(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_JAL => cw4(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw4(CW_SIZE-10 downto CW_SIZE-20) <= "10010100001"; 
                                  cw4(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_JR => cw4(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw4(CW_SIZE-10 downto CW_SIZE-20) <= "11100000001"; 
                                  cw4(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_JALR => cw4(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw4(CW_SIZE-10 downto CW_SIZE-20) <= "11110100001"; 
                                  cw4(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');
                  
                when ITYPE_ADDI  | ITYPE_ADDUI | ITYPE_SB | ITYPE_SH | ITYPE_SW | ITYPE_LB | ITYPE_LH | ITYPE_LW | ITYPE_LBU | ITYPE_LHU => 
                                   cw4(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                   cw4(CW_SIZE-10 downto CW_SIZE-20) <= "11000000000"; 
                                   cw4(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SUBI  | ITYPE_SUBUI => 
                                   cw4(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                   cw4(CW_SIZE-10 downto CW_SIZE-20) <= "11000000010"; 
                                   cw4(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');


                when ITYPE_ANDI => 
                                  cw4(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw4(CW_SIZE-10 downto CW_SIZE-20) <= "11010010000"; 
                                  cw4(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_ORI => 
                                  cw4(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw4(CW_SIZE-10 downto CW_SIZE-20) <= "11010011100"; 
                                  cw4(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_XORI => 
                                  cw4(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw4(CW_SIZE-10 downto CW_SIZE-20) <= "11010001100"; 
                                  cw4(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SLLI => 
                                  cw4(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw4(CW_SIZE-10 downto CW_SIZE-20) <= "11001100000"; 
                                  cw4(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SRLI => 
                                  cw4(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw4(CW_SIZE-10 downto CW_SIZE-20) <= "11001100010"; 
                                  cw4(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SRAI => 
                                  cw4(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw4(CW_SIZE-10 downto CW_SIZE-20) <= "11001100010"; 
                                  cw4(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_NOP => 
                                  cw4(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw4(CW_SIZE-10 downto CW_SIZE-20) <= "00000000000"; 
                                  cw4(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SEQI => 
                                  cw4(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw4(CW_SIZE-10 downto CW_SIZE-20) <= "11000100010"; 
                                  cw4(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SNEI => 
                                  cw4(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw4(CW_SIZE-10 downto CW_SIZE-20) <= "11000100110"; 
                                  cw4(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SLTI | ITYPE_SLTUI => 
                                  cw4(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw4(CW_SIZE-10 downto CW_SIZE-20) <= "11000110110"; 
                                  cw4(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SGTI | ITYPE_SGTUI => 
                                  cw4(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw4(CW_SIZE-10 downto CW_SIZE-20) <= "11000111110"; 
                                  cw4(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SLEI | ITYPE_SLEUI => 
                                  cw4(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw4(CW_SIZE-10 downto CW_SIZE-20) <= "11000110010"; 
                                  cw4(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SGEI | ITYPE_SGEUI => 
                                  cw4(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw4(CW_SIZE-10 downto CW_SIZE-20) <= "11000111010"; 
                                  cw4(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');
                                
                when others =>  cw4 <= (others => '0');
            end case;  


          when memory => 
            case OPCODE3 is
                when RTYPE | ITYPE_ADDI | ITYPE_ADDUI | ITYPE_SUBI | ITYPE_SUBUI | ITYPE_ANDI | ITYPE_ORI | ITYPE_XORI | ITYPE_SLLI | ITYPE_SRLI | ITYPE_SRAI | ITYPE_SEQI | ITYPE_SNEI | ITYPE_SLTI | ITYPE_SGTI | ITYPE_SLEI | ITYPE_SGEI | ITYPE_SLTUI | ITYPE_SGTUI | ITYPE_SLEUI | ITYPE_SGEUI | ITYPE_JAL | ITYPE_JALR => 
                               cw4(CW_SIZE-1 downto CW_SIZE-20) <= (others => '0');
                               cw4(CW_SIZE-21 downto CW_SIZE-24) <= "1000";
                               cw4(CW_SIZE-25 downto CW_SIZE-26) <= (others => '0');
                
                when ITYPE_SB  => cw4(CW_SIZE-1 downto CW_SIZE-20) <= (others => '0');
                                  cw4(CW_SIZE-21 downto CW_SIZE-24) <= "1101";
                                  cw4(CW_SIZE-25 downto CW_SIZE-26) <= (others => '0');
                
                when ITYPE_SH  => cw4(CW_SIZE-1 downto CW_SIZE-20) <= (others => '0');
                                  cw4(CW_SIZE-21 downto CW_SIZE-24) <= "1110";
                                  cw4(CW_SIZE-25 downto CW_SIZE-26) <= (others => '0');
                
                when ITYPE_SW  => cw4(CW_SIZE-1 downto CW_SIZE-20) <= (others => '0');
                                  cw4(CW_SIZE-21 downto CW_SIZE-24) <= "1111";
                                  cw4(CW_SIZE-25 downto CW_SIZE-26) <= (others => '0');
                
                when ITYPE_LB | ITYPE_LBU => 
                          cw4(CW_SIZE-1 downto CW_SIZE-20) <= (others => '0');
                                  cw4(CW_SIZE-21 downto CW_SIZE-24) <= "1001";
                                  cw4(CW_SIZE-25 downto CW_SIZE-26) <= (others => '0');
                
                when ITYPE_LH | ITYPE_LHU => 
                          cw4(CW_SIZE-1 downto CW_SIZE-20) <= (others => '0');
                                  cw4(CW_SIZE-21 downto CW_SIZE-24) <= "1010";
                                  cw4(CW_SIZE-25 downto CW_SIZE-26) <= (others => '0');
                
                when ITYPE_LW  => cw4(CW_SIZE-1 downto CW_SIZE-20) <= (others => '0');
                                  cw4(CW_SIZE-21 downto CW_SIZE-24) <= "1011";
                                  cw4(CW_SIZE-25 downto CW_SIZE-26) <= (others => '0');
                
                when ITYPE_J | ITYPE_JR | ITYPE_NOP => cw4 <= (others => '0');
                when others => cw4 <= (others => '0');
            end case;
                    

          when write_back => 
            case OPCODE4 is
                when RTYPE | ITYPE_ADDI | ITYPE_ADDUI | ITYPE_SUBI | ITYPE_SUBUI | ITYPE_ANDI | ITYPE_ORI | ITYPE_XORI | ITYPE_SLLI | ITYPE_SRLI | ITYPE_SRAI | ITYPE_NOP | ITYPE_SEQI | ITYPE_SNEI | ITYPE_SLTI | ITYPE_SGTI | ITYPE_SLEI | ITYPE_SGEI | ITYPE_SLTUI | ITYPE_SGTUI | ITYPE_SLEUI | ITYPE_SGEUI | ITYPE_JAL | ITYPE_JALR => 
                                cw4 <= (CW_SIZE-25 => '1', CW_SIZE-26 => '1',others => '0');
                when ITYPE_J | ITYPE_JR | ITYPE_SB | ITYPE_SH | ITYPE_SW => cw4 <= (others => '0');
                when ITYPE_LB | ITYPE_LH | ITYPE_LW | ITYPE_LBU | ITYPE_LHU =>  cw4 <= (CW_SIZE-25 => '1', CW_SIZE-26 => '0',others => '0');
                when others => cw4 <= (others => '0');             
            end case;

          when stall_if => cw4 <= (others => '0');

          when stall_d => cw4 <= (others => '0'); 

          when stall_ex => cw4 <= (others => '0');
                           
          when stall_mem => cw4 <= (others => '0');

          when stall_wb => cw4 <= (others => '0');

          when others => cw4 <=  (others => '0');
        end case;  

    end process P_OUTPUTS_INST4;


    P_OUTPUTS_INST5: process(INST5,OPCODE,OPCODE1,OPCODE2,OPCODE3,OPCODE4,FUNC,FUNC1,FUNC2)
    begin

        case INST5 is       
          when reset =>   cw5 <= "00000000000000000000000000";
            
          when fetch =>  
            case OPCODE is
              when RTYPE | ITYPE_J | ITYPE_ADDI | ITYPE_ADDUI | ITYPE_SUBI | ITYPE_SUBUI | ITYPE_ANDI | ITYPE_ORI | ITYPE_XORI | ITYPE_SLLI | ITYPE_SRLI | ITYPE_SRAI | ITYPE_NOP | ITYPE_SEQI | ITYPE_SNEI | ITYPE_SLTI | ITYPE_SGTI | ITYPE_SLEI | ITYPE_SGEI | ITYPE_SLTUI | ITYPE_SGTUI | ITYPE_SLEUI | ITYPE_SGEUI | ITYPE_SB | ITYPE_SH | ITYPE_SW | ITYPE_LB | ITYPE_LH | ITYPE_LW | ITYPE_LBU | ITYPE_LHU | ITYPE_JAL | ITYPE_JR | ITYPE_JALR => cw5 <= (CW_SIZE-1 => '1', others => '0');
              when others => cw5 <= (CW_SIZE-1 => '0', others => '0');
            end case;
                
          when decode =>
            case OPCODE1 is
                when RTYPE  =>  cw5(CW_SIZE-1) <= '0';
                                cw5(CW_SIZE-2 downto CW_SIZE-8) <= "1000011";
                                cw5(CW_SIZE-10 downto CW_SIZE-26) <= (others => '0');

                              case FUNC1 is
                                  when RTYPE_SLL | RTYPE_SRL | RTYPE_ADDU | RTYPE_SUBU | RTYPE_SLTU | RTYPE_SGTU | RTYPE_SLEU | RTYPE_SGEU => cw5(CW_SIZE-9) <= '1';               
                                  when RTYPE_SRA | RTYPE_ADD | RTYPE_SUB  | RTYPE_AND  | RTYPE_OR   | RTYPE_XOR  | RTYPE_SEQ  | RTYPE_SNE | RTYPE_SLT | RTYPE_SGT | RTYPE_SLE | RTYPE_SGE => cw5(CW_SIZE-9) <= '0';                 
                                  when others   =>   cw5(CW_SIZE-9) <= '0';                       
                              end case;

                when ITYPE_J | ITYPE_JAL => 
                                cw5(CW_SIZE-1) <= '0';
                                cw5(CW_SIZE-2 downto CW_SIZE-9) <= "11000000";
                                cw5(CW_SIZE-10 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_JR | ITYPE_JALR => 
                                cw5(CW_SIZE-1) <= '0';
                                cw5(CW_SIZE-2 downto CW_SIZE-9) <= "11000100";
                                cw5(CW_SIZE-10 downto CW_SIZE-26) <= (others => '0');
                
                when ITYPE_ADDI | ITYPE_SUBI | ITYPE_ANDI | ITYPE_ORI | ITYPE_XORI | ITYPE_SRAI | ITYPE_SEQI | ITYPE_SNEI | ITYPE_SLTI | ITYPE_SGTI | ITYPE_SLEI | ITYPE_SGEI | ITYPE_LB | ITYPE_LH | ITYPE_LW => 
                                   cw5(CW_SIZE-1) <= '0';
                                   cw5(CW_SIZE-2 downto CW_SIZE-9) <= "10100100";
                                   cw5(CW_SIZE-10 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_ADDUI | ITYPE_SUBUI | ITYPE_SLLI | ITYPE_SRLI | ITYPE_SLTUI | ITYPE_SGTUI | ITYPE_SLEUI | ITYPE_SGEUI | ITYPE_LBU | ITYPE_LHU => 
                                    cw5(CW_SIZE-1) <= '0';
                                    cw5(CW_SIZE-2 downto CW_SIZE-9) <= "10100101";
                                    cw5(CW_SIZE-10 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SB | ITYPE_SH | ITYPE_SW => 
                                    cw5(CW_SIZE-1) <= '0';
                                    cw5(CW_SIZE-2 downto CW_SIZE-9) <= "10100110";
                                    cw5(CW_SIZE-10 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_NOP => cw5 <= (others => '0');

                when others => cw5 <= (others => '0');
            end case;

          when execute =>
            case OPCODE2 is
                when RTYPE => cw5(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                              cw5(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');
  
                              case FUNC2 is
                                when RTYPE_SLL  => cw5(CW_SIZE-10 downto CW_SIZE-20) <= "11101100000";               
                                when RTYPE_SRL  => cw5(CW_SIZE-10 downto CW_SIZE-20) <= "11101100010";                        
                                when RTYPE_SRA  => cw5(CW_SIZE-10 downto CW_SIZE-20) <= "11101100010";                        
                                when RTYPE_ADD  => cw5(CW_SIZE-10 downto CW_SIZE-20) <= "11100000000";                        
                                when RTYPE_ADDU => cw5(CW_SIZE-10 downto CW_SIZE-20) <= "11100000000";                        
                                when RTYPE_SUB  => cw5(CW_SIZE-10 downto CW_SIZE-20) <= "11100000010";                        
                                when RTYPE_SUBU => cw5(CW_SIZE-10 downto CW_SIZE-20) <= "11100000010";                        
                                when RTYPE_AND  => cw5(CW_SIZE-10 downto CW_SIZE-20) <= "11110010000";                        
                                when RTYPE_OR   => cw5(CW_SIZE-10 downto CW_SIZE-20) <= "11110011100";                        
                                when RTYPE_XOR  => cw5(CW_SIZE-10 downto CW_SIZE-20) <= "11110001100";                        
                                when RTYPE_SEQ  => cw5(CW_SIZE-10 downto CW_SIZE-20) <= "11100100010";                        
                                when RTYPE_SNE  => cw5(CW_SIZE-10 downto CW_SIZE-20) <= "11100100110";                        
                                when RTYPE_SLT  => cw5(CW_SIZE-10 downto CW_SIZE-20) <= "11100110110";                        
                                when RTYPE_SGT  => cw5(CW_SIZE-10 downto CW_SIZE-20) <= "11100111110";                        
                                when RTYPE_SLE  => cw5(CW_SIZE-10 downto CW_SIZE-20) <= "11100110010";                        
                                when RTYPE_SGE  => cw5(CW_SIZE-10 downto CW_SIZE-20) <= "11100111010";                        
                                when RTYPE_SLTU => cw5(CW_SIZE-10 downto CW_SIZE-20) <= "11100110110";                        
                                when RTYPE_SGTU => cw5(CW_SIZE-10 downto CW_SIZE-20) <= "11100111110";                        
                                when RTYPE_SLEU => cw5(CW_SIZE-10 downto CW_SIZE-20) <= "11100110010";                        
                                when RTYPE_SGEU => cw5(CW_SIZE-10 downto CW_SIZE-20) <= "11100111010";                        
                                when others   =>   cw5(CW_SIZE-10 downto CW_SIZE-20) <= "00000000000";                        
                              end case;

                when ITYPE_J => cw5(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                cw5(CW_SIZE-10 downto CW_SIZE-20) <= "10000000001"; 
                                cw5(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_JAL => cw5(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw5(CW_SIZE-10 downto CW_SIZE-20) <= "10010100001"; 
                                  cw5(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_JR => cw5(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw5(CW_SIZE-10 downto CW_SIZE-20) <= "11100000001"; 
                                  cw5(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_JALR => cw5(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw5(CW_SIZE-10 downto CW_SIZE-20) <= "11110100001"; 
                                  cw5(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');
                  
                when ITYPE_ADDI  | ITYPE_ADDUI | ITYPE_SB | ITYPE_SH | ITYPE_SW | ITYPE_LB | ITYPE_LH | ITYPE_LW | ITYPE_LBU | ITYPE_LHU => 
                                   cw5(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                   cw5(CW_SIZE-10 downto CW_SIZE-20) <= "11000000000"; 
                                   cw5(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SUBI  | ITYPE_SUBUI => 
                                   cw5(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                   cw5(CW_SIZE-10 downto CW_SIZE-20) <= "11000000010"; 
                                   cw5(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');


                when ITYPE_ANDI => 
                                  cw5(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw5(CW_SIZE-10 downto CW_SIZE-20) <= "11010010000"; 
                                  cw5(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_ORI => 
                                  cw5(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw5(CW_SIZE-10 downto CW_SIZE-20) <= "11010011100"; 
                                  cw5(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_XORI => 
                                  cw5(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw5(CW_SIZE-10 downto CW_SIZE-20) <= "11010001100"; 
                                  cw5(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SLLI => 
                                  cw5(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw5(CW_SIZE-10 downto CW_SIZE-20) <= "11001100000"; 
                                  cw5(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SRLI => 
                                  cw5(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw5(CW_SIZE-10 downto CW_SIZE-20) <= "11001100010"; 
                                  cw5(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SRAI => 
                                  cw5(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw5(CW_SIZE-10 downto CW_SIZE-20) <= "11001100010"; 
                                  cw5(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_NOP => 
                                  cw5(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw5(CW_SIZE-10 downto CW_SIZE-20) <= "00000000000"; 
                                  cw5(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SEQI => 
                                  cw5(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw5(CW_SIZE-10 downto CW_SIZE-20) <= "11000100010"; 
                                  cw5(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SNEI => 
                                  cw5(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw5(CW_SIZE-10 downto CW_SIZE-20) <= "11000100110"; 
                                  cw5(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SLTI | ITYPE_SLTUI => 
                                  cw5(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw5(CW_SIZE-10 downto CW_SIZE-20) <= "11000110110"; 
                                  cw5(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SGTI | ITYPE_SGTUI => 
                                  cw5(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw5(CW_SIZE-10 downto CW_SIZE-20) <= "11000111110"; 
                                  cw5(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SLEI | ITYPE_SLEUI => 
                                  cw5(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw5(CW_SIZE-10 downto CW_SIZE-20) <= "11000110010"; 
                                  cw5(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');

                when ITYPE_SGEI | ITYPE_SGEUI => 
                                  cw5(CW_SIZE-1 downto CW_SIZE-9) <= (others => '0');
                                  cw5(CW_SIZE-10 downto CW_SIZE-20) <= "11000111010"; 
                                  cw5(CW_SIZE-21 downto CW_SIZE-26) <= (others => '0');
                                
                when others =>  cw5 <= (others => '0');
            end case;  


          when memory => 
            case OPCODE3 is
                when RTYPE | ITYPE_ADDI | ITYPE_ADDUI | ITYPE_SUBI | ITYPE_SUBUI | ITYPE_ANDI | ITYPE_ORI | ITYPE_XORI | ITYPE_SLLI | ITYPE_SRLI | ITYPE_SRAI | ITYPE_SEQI | ITYPE_SNEI | ITYPE_SLTI | ITYPE_SGTI | ITYPE_SLEI | ITYPE_SGEI | ITYPE_SLTUI | ITYPE_SGTUI | ITYPE_SLEUI | ITYPE_SGEUI | ITYPE_JAL | ITYPE_JALR => 
                               cw5(CW_SIZE-1 downto CW_SIZE-20) <= (others => '0');
                               cw5(CW_SIZE-21 downto CW_SIZE-24) <= "1000";
                               cw5(CW_SIZE-25 downto CW_SIZE-26) <= (others => '0');
                
                when ITYPE_SB  => cw5(CW_SIZE-1 downto CW_SIZE-20) <= (others => '0');
                                  cw5(CW_SIZE-21 downto CW_SIZE-24) <= "1101";
                                  cw5(CW_SIZE-25 downto CW_SIZE-26) <= (others => '0');
                
                when ITYPE_SH  => cw5(CW_SIZE-1 downto CW_SIZE-20) <= (others => '0');
                                  cw5(CW_SIZE-21 downto CW_SIZE-24) <= "1110";
                                  cw5(CW_SIZE-25 downto CW_SIZE-26) <= (others => '0');
                
                when ITYPE_SW  => cw5(CW_SIZE-1 downto CW_SIZE-20) <= (others => '0');
                                  cw5(CW_SIZE-21 downto CW_SIZE-24) <= "1111";
                                  cw5(CW_SIZE-25 downto CW_SIZE-26) <= (others => '0');
                
                when ITYPE_LB | ITYPE_LBU => 
                          cw5(CW_SIZE-1 downto CW_SIZE-20) <= (others => '0');
                                  cw5(CW_SIZE-21 downto CW_SIZE-24) <= "1001";
                                  cw5(CW_SIZE-25 downto CW_SIZE-26) <= (others => '0');
                
                when ITYPE_LH | ITYPE_LHU => 
                          cw5(CW_SIZE-1 downto CW_SIZE-20) <= (others => '0');
                                  cw5(CW_SIZE-21 downto CW_SIZE-24) <= "1010";
                                  cw5(CW_SIZE-25 downto CW_SIZE-26) <= (others => '0');
                
                when ITYPE_LW  => cw5(CW_SIZE-1 downto CW_SIZE-20) <= (others => '0');
                                  cw5(CW_SIZE-21 downto CW_SIZE-24) <= "1011";
                                  cw5(CW_SIZE-25 downto CW_SIZE-26) <= (others => '0');
                
                when ITYPE_J | ITYPE_JR | ITYPE_NOP => cw5 <= (others => '0');
                when others => cw5 <= (others => '0');
            end case;
                    

          when write_back => 
            case OPCODE4 is
                when RTYPE | ITYPE_ADDI | ITYPE_ADDUI | ITYPE_SUBI | ITYPE_SUBUI | ITYPE_ANDI | ITYPE_ORI | ITYPE_XORI | ITYPE_SLLI | ITYPE_SRLI | ITYPE_SRAI | ITYPE_NOP | ITYPE_SEQI | ITYPE_SNEI | ITYPE_SLTI | ITYPE_SGTI | ITYPE_SLEI | ITYPE_SGEI | ITYPE_SLTUI | ITYPE_SGTUI | ITYPE_SLEUI | ITYPE_SGEUI | ITYPE_JAL | ITYPE_JALR => 
                                cw5 <= (CW_SIZE-25 => '1', CW_SIZE-26 => '1',others => '0');
                when ITYPE_J | ITYPE_JR | ITYPE_SB | ITYPE_SH | ITYPE_SW => cw5 <= (others => '0');
                when ITYPE_LB | ITYPE_LH | ITYPE_LW | ITYPE_LBU | ITYPE_LHU =>  cw5 <= (CW_SIZE-25 => '1', CW_SIZE-26 => '0',others => '0');
                when others => cw5 <= (others => '0');             
            end case;

          when stall_if => cw5 <= (others => '0');

          when stall_d => cw5 <= (others => '0'); 

          when stall_ex => cw5 <= (others => '0');
                           
          when stall_mem => cw5 <= (others => '0');

          when stall_wb => cw5 <= (others => '0');

          when others => cw5 <=  (others => '0');
        end case;  
                   
    end process P_OUTPUTS_INST5;

cw <= cw1 or cw2 or cw3 or cw4 or cw5;

ENIF        <= cw(CW_SIZE-1);
-- SECOND PIPE STAGE OUTPUTS
ENDEC       <= cw(CW_SIZE-2); 
JMP         <= cw(CW_SIZE-3);
RI          <= cw(CW_SIZE-4); 
BR_TYPE     <= cw(CW_SIZE-5 downto CW_SIZE-6);
RD1         <= cw(CW_SIZE-7);        
RD2         <= cw(CW_SIZE-8);    
US          <= cw(CW_SIZE-9);    
-- THIRD PIPE STAGE OUTPUTS
ENEX        <= cw(CW_SIZE-10);
MUX1_SEL    <= cw(CW_SIZE-11);
MUX2_SEL    <= cw(CW_SIZE-12);  
UN_SEL      <= cw(CW_SIZE-13 downto CW_SIZE-15);
OP_SEL      <= cw(CW_SIZE-16 downto CW_SIZE-19);
PC_SEL      <= cw(CW_SIZE-20);
-- FOURTH PIPE STAGE OUTPUTS
ENMEM       <= cw(CW_SIZE-21);
RW          <= cw(CW_SIZE-22); 
D_TYPE      <= cw(CW_SIZE-23 downto CW_SIZE-24); 
-- FIFTH PIPE STAGE OUTPUTS
WR          <= cw(CW_SIZE-25);
MEM_ALU_SEL <= cw(CW_SIZE-26); 


end dlx_cu_fsm;
