library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use work.myTypes.all;


entity FOREWARD_UNIT is
  generic (NB: integer := 32;
  			LS: integer:= 5
  			);
  port 	 (  Rs_EX 		: IN  std_logic_vector(LS-1 downto 0);
            Rt_EX 		: IN  std_logic_vector(LS-1 downto 0);
            Rd_MEM 		: IN  std_logic_vector(LS-1 downto 0); -- dest from MEM stage
            Rd_WB 		: IN  std_logic_vector(LS-1 downto 0); -- dest from WB stage
            CTL_MUX1	: OUT std_logic_vector(1 downto 0);
            CTL_MUX2 	: OUT std_logic_vector(1 downto 0)
            );
end FOREWARD_UNIT;

architecture BEHAVIOR of FOREWARD_UNIT is


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

begin

foreward_mux1 : process (Rd_MEM,Rs_EX,Rd_WB)
begin
	if Rd_MEM = Rs_EX and (active_ex/mem) then
		CTL_MUX1 <= "01"; -- from alu out
	elsif (Rd_WB = Rs_EX and active_mem/wb ) then
		CTL_MUX1 <= "10"; -- from wb
	else
	 	CTL_MUX1 <= "00"; 
	end if;
end process;


foreward_mux2 : process (Rd_MEM,Rs_EX,Rd_WB)
begin
	if (r_type_exe) then
		if Rd_MEM = Rt_EX and (active_ex/mem) then
			CTL_MUX1 <= "01";
		elsif (Rd_WB = Rt_EX and active_mem/wb ) then
			CTL_MUX1 <= "10";
		else
		 	CTL_MUX1 <= "00"; 
		end if;
	end if;
end process;


end BEHAVIOR;