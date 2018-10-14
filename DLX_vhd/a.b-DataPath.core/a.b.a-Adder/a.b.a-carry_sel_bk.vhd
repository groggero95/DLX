library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all; 

entity carry_sel_bk is 
    Generic ( N: integer := 32);
	Port (	A:	In	std_logic_vector(N-1 downto 0);
			B:	In	std_logic_vector(N-1 downto 0);
			Ci:	In	std_logic;
			S:	Out	std_logic_vector(N-1 downto 0)
		);
end carry_sel_bk; 

architecture behavioral of carry_sel_bk is

	signal out0_b, out1_b : std_logic_vector( N-1 downto 0);

begin

rca0_b:	process(A,B)
	begin

	out0_b <= A + B;

	end process;

rca1_b:	process(A,B)
	begin

	out1_b <= A + B + '1';

	end process;

mux0_b:	process(out0_b, out1_b, Ci)	
	begin

	if Ci = '1' then
		S <= out1_b;
	else
		S <= out0_b;
	end if;

	end process;

end behavioral;


architecture structural of carry_sel_bk is


component FA 
	Port (	A:	In	std_logic;
		B:	In	std_logic;
		Ci:	In	std_logic;
		S:	Out	std_logic;
		Co:	Out	std_logic);
end component; 

component MUX21 
	Port (	A:	In	std_logic;
		B:	In	std_logic;
		S:	In	std_logic;
		Y:	Out	std_logic);
end component;

	signal Cp0, Cp1 : std_logic_vector( N downto 0);
	signal out0_s, out1_s : std_logic_vector( N-1 downto 0);

begin

Cp0(0) <= '0';

rca0_s: for J in 0 to N-1 generate
		fa_v_map0 : FA
			port map( A(J), B(J), Cp0(J), out0_s(J), Cp0(J+1) );
	end generate;

Cp1(0) <=  '1';

rca1_s: for K in 0 to N-1 generate
		fa_v_map1 : FA
			port map( A(K), B(K), Cp1(K), out1_s(K), Cp1(K+1) );
	end generate;

		


mux0_s: for I in 0 to N-1 generate
		mux_v_map : MUX21  Port Map (out1_s(I), out0_s(I), Ci, S(I)); 
	end generate;

end structural;


configuration CFG_CSBLK_BEHAV of carry_sel_bk is
	for behavioral
	end for;
end CFG_CSBLK_BEHAV;

configuration CFG_CSBLK_STRUC of carry_sel_bk is
	for structural
		for rca0_s
			for all : FA
				use configuration WORK.CFG_FA_BEHAVIORAL;
			end for;
		end for;

		for rca1_s
			for all : FA
				use configuration WORK.CFG_FA_BEHAVIORAL;
			end for;
		end for;

		for mux0_s
			for all : MUX21
				use configuration WORK.CFG_MUX21_BEHAVIORAL;
			end for;
		end for;
	end for;
end CFG_CSBLK_STRUC;






	
	

