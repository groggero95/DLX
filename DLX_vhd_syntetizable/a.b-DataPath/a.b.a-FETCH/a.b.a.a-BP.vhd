library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.const.all;


entity BP is
	generic(NB: integer 		:= 32;
			BP_LEN: integer 	:= 4);
	port(
		CLK			: in  std_logic;
		RST			: in  std_logic;
		EX_PC		: in  std_logic_vector(NB-1 downto 0);
		CURR_PC		: IN  std_logic_vector(NB-1 downto 0);
		NEXT_PC		: in  std_logic_vector(NB-1 downto 0);
		NEW_PC		: in  std_logic_vector(NB-1 downto 0);
		INST 		: in  std_logic_vector(NB-1 downto 0);
		MISS_HIT	: out std_logic_vector(1 downto 0);
		PRED  		: out std_logic_vector(NB-1 downto 0) -- to the PC input
		);
end BP;

architecture BEHAVIORAL of BP is
	
	type PC_table_type is array (0 to (2**BP_LEN)-1) of std_logic_vector(NB-1 downto 0);
	type PRED_type is array (0 to (2**BP_LEN)-1) of unsigned(1 downto 0);
	type PRED_HIST_type is array (0 to 1) of std_logic_vector(NB downto 0);
	type ADD_HIST_type is array (0 to 1) of integer;
	

   	signal PC_TABLE : PC_table_type; -- used to store pc

   	signal PRED_TABLE : PRED_type; -- table of prediction

   	signal PRED_HISTORY : PRED_HIST_type;

   	signal PC_HISTORY : ADD_HIST_type;

   	signal PRED_TK, PRED_NT, PRED_TMP : std_logic_vector(NB-1 downto 0);

   	signal INSERT, BRANCH : std_logic;

   	signal H_M : std_logic_vector(1 downto 0);



begin

PRED_TK <= std_logic_vector( unsigned(NEXT_PC)  +  unsigned(resize(signed(INST(15 downto 0)),INST'length))); 
PRED_NT <= NEXT_PC;

PRED <= PRED_TMP;
MISS_HIT <= H_M;

-- Process to decide the next PC value
process(INST,NEW_PC,PC_TABLE,CURR_PC,PRED_TABLE,PRED_NT,PRED_TK,H_M,NEXT_PC)
begin
	if INST(NB-1 downto NB-6) = ITYPE_BEQZ or INST(NB-1 downto NB-6) = ITYPE_BNEZ then
		if PC_TABLE(to_integer(unsigned(CURR_PC(BP_LEN-1 + 2 downto 0 + 2)))) = CURR_PC then
			case PRED_TABLE(to_integer(unsigned(CURR_PC(BP_LEN-1 + 2 downto 0 + 2)))) is
			 	when "00" | "01" => PRED_TMP <= PRED_NT;
			 	when "10" | "11" => PRED_TMP <= PRED_TK;
			 	when others => PRED_TMP <= NEW_PC;
			 end case; 
			INSERT <= '0';
		else
			PRED_TMP <= PRED_NT;
			INSERT <= '1';
		end if;	
		BRANCH <= '1';
	else
		case H_M is
			when "11" => PRED_TMP <= NEW_PC; -- miss
			when "10" => PRED_TMP <= NEXT_PC; -- hit
			when others => PRED_TMP <= NEW_PC;
		end case;
		INSERT <= '0';
		BRANCH <= '0';
	end if; 

end process;


-- Process used to update the table of PC related to brach instructions
process(CLK,RST)
begin
	if RST = '0' then
		PC_TABLE <= (others => (others => '0'));
	elsif CLK'event and CLK = '1' then
		if INSERT = '1' then
			PC_TABLE(to_integer(unsigned(CURR_PC(BP_LEN-1 + 2 downto 0 + 2)))) <= CURR_PC;
		end if;
	end if;
end process;


process(PRED_HISTORY,EX_PC)
begin
	if PRED_HISTORY(1)(NB) = '1' then
		if PRED_HISTORY(1)(NB-1 downto 0) = EX_PC then -- HIT
			H_M <= "10";
		else -- MISS
			H_M <= "11";
		end if;
	else
		H_M <= "00";
	end if;
end process;

-- Process used to update the counter used for the branch prediction
process(CLK,RST)
begin
	if RST = '0' then
		PRED_TABLE <= (others => "01");
	elsif CLK'event and CLK = '1' then
		if PRED_HISTORY(1)(NB) = '1' then
		--	if PRED_HISTORY(1)(NB-1 downto 0) = NEW_PC then -- HIT
			if H_M = "10" then -- HIT

				case PRED_TABLE(PC_HISTORY(1)) is
					when "00" | "01" => PRED_TABLE(PC_HISTORY(1)) <= "00";
					when "10" | "11" => PRED_TABLE(PC_HISTORY(1)) <= "11";
					when others =>  PRED_TABLE(PC_HISTORY(1)) <= "01";
				end case;

			else -- MISS

				case PRED_TABLE(PC_HISTORY(1)) is
					when "00" | "10" => PRED_TABLE(PC_HISTORY(1)) <= "01";
					when "01" | "11" => PRED_TABLE(PC_HISTORY(1)) <= "10";
					when others =>  PRED_TABLE(PC_HISTORY(1)) <= "01";
				end case;

			end if;
		end if;
	end if;
end process;


-- Process used to pipeline the predictions plus one 
-- bit to track if the prediction was related to a branch
pred_pipe : process(CLK,RST) 
begin
	if RST = '0' then
		PRED_HISTORY <= (others => (others => '0'));
	elsif CLK'event and CLK = '1' then
		PC_loop: for I in 0 to 1 loop
			if (I=0) then
				PRED_HISTORY(I) <= BRANCH & PRED_TMP;
			else
				PRED_HISTORY(I) <= PRED_HISTORY(I-1);
			end if;
		end loop;
	end if;
end process;

-- Process used to pipeline the`PC
pc_pipe : process(CLK,RST) 
begin
	if RST = '0' then
		PC_HISTORY <= (others => 0);
	elsif CLK'event and CLK = '1' then
		PC_loop: for I in 0 to 1 loop
			if (I=0) then
				PC_HISTORY(I) <= to_integer(unsigned(CURR_PC(BP_LEN-1 + 2 downto 0 + 2)));
			else
				PC_HISTORY(I) <= PC_HISTORY(I-1);
			end if;
		end loop;
	end if;
end process;

end BEHAVIORAL;

configuration CFG_BP of BP is
for BEHAVIORAL
end for;
end CFG_BP;