library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all; 
use work.mfunc.all;

entity sum_gen is 
        Generic ( Nrca: integer := 4;
		  N : integer := 32 );
	Port (	A:	In	std_logic_vector(N-1 downto 0);
		B:	In	std_logic_vector(N-1 downto 0);
		Ci:	In	std_logic_vector(delimiter(N,Nrca) downto 0);
		S:	Out	std_logic_vector(N-1 downto 0)
		);
end sum_gen;


architecture structural of sum_gen is


component carry_sel_bk 
        Generic ( N: integer := 32);
	Port (	A:	In	std_logic_vector(N-1 downto 0);
		B:	In	std_logic_vector(N-1 downto 0);
		Ci:	In	std_logic;
		S:	Out	std_logic_vector(N-1 downto 0)
		);
end component;

constant  reminder : integer := (N mod Nrca); 


begin 


vect_gen : for I in 0 to N/Nrca-1 generate 
		csa : carry_sel_bk
		      generic map(N => Nrca)
		      port map( A( (I+1)*Nrca-1 downto I*Nrca ), 
						B( (I+1)*Nrca-1 downto I*Nrca ),
						Ci(I),
						S( (I+1)*Nrca-1 downto I*Nrca )
						);
	  end generate;



vect_gen_extra 	: 	for I in 0 to 0 generate
						cond0 : if (reminder /= 0) generate
										
								csa_extra : carry_sel_bk
											generic map (N => reminder)
											port map (	A( N-1 downto N-reminder ), 
														B( N-1 downto N-reminder ),
														Ci(delimiter(N,Nrca)),
														S( N-1 downto N-reminder )
														);
								end generate cond0;			
	
end generate vect_gen_extra;

end structural;


configuration CFG_SUM_GEN_BEH of sum_gen is
for structural
	for vect_gen 
		for all	:	carry_sel_bk
			use configuration WORK.CFG_CSBLK_BEHAV;
		end for;
	end for;

	for vect_gen_extra
		for cond0
			for all :	carry_sel_bk
				use configuration WORK.CFG_CSBLK_BEHAV;
			end for;
		end for;
	end for; 
end for;
end CFG_SUM_GEN_BEH;


 





