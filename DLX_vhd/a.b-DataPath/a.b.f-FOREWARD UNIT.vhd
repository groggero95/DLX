library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use work.myTypes.all;

-- This unit is in charge of forewarding data when needed
-- from memory or write back in order to reduce hazards 
-- and consequently stalls

entity FOREWARD_UNIT is
  generic (NB: integer := 32;
  			LS: integer:= 5
  			);
  port 	 (  INST_EX		: IN  TYPE_STATE;
  			INST_MEM	: IN  TYPE_STATE;
  			INST_T_EX	: IN  std_logic;
  			Rs_EX 		: IN  std_logic_vector(LS-1 downto 0);
            Rt_EX 		: IN  std_logic_vector(LS-1 downto 0);
            Rd_MEM 		: IN  std_logic_vector(LS-1 downto 0); -- dest from MEM stage
            Rd_WB 		: IN  std_logic_vector(LS-1 downto 0); -- dest from WB stage
            CTL_MUX1	: OUT std_logic_vector(1 downto 0);
            CTL_MUX2 	: OUT std_logic_vector(1 downto 0)
   );
end FOREWARD_UNIT;

architecture BEHAVIOR of FOREWARD_UNIT is

begin

foreward_mux1 : process (Rd_MEM,Rs_EX,Rd_WB,INST_EX,INST_MEM)
begin
	if Rd_MEM = Rs_EX and INST_EX /= stall_if and Rd_MEM /= ADD_ZERO then
		CTL_MUX1 <= "01"; -- from alu out
	elsif Rd_WB = Rs_EX and INST_MEM /= stall_if and Rd_WB /= ADD_ZERO then
		CTL_MUX1 <= "10"; -- from wb
	else
	 	CTL_MUX1 <= "00"; 
	end if;
end process;


foreward_mux2 : process (Rd_MEM,Rs_EX,Rd_WB,Rt_EX,INST_EX,INST_MEM,INST_T_EX)
begin
	if (INST_T_EX = '1') then
		if Rd_MEM = Rt_EX and INST_EX /= stall_if and Rd_MEM /= ADD_ZERO then
			CTL_MUX2 <= "01";
		elsif (Rd_WB = Rt_EX and INST_MEM /= stall_if and Rd_WB /= ADD_ZERO ) then
			CTL_MUX2 <= "10";
		else
		 	CTL_MUX2 <= "00"; 
		end if;
	else
		CTL_MUX2 <= "00"; 
	end if;
end process;


end BEHAVIOR;

configuration CFG_FOREWARD_UNIT of FOREWARD_UNIT is
for BEHAVIOR
end for;
end CFG_FOREWARD_UNIT;