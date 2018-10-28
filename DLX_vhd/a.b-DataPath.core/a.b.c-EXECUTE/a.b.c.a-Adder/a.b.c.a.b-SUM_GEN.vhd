library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all; 
use work.mfunc.all;

-- Block used to aggregate carry select block for the P4 adder

entity sum_gen is 
        Generic ( Nrca: integer := 4;
		  NB : integer := 32 );
	Port (	A:	In	std_logic_vector(NB-1 downto 0);
			B:	In	std_logic_vector(NB-1 downto 0);
			Ci:	In	std_logic_vector(delimiter(NB,Nrca) downto 0);
			S:	Out	std_logic_vector(NB-1 downto 0)
		);
end sum_gen;


architecture structural of sum_gen is


component carry_sel_bk 
        Generic ( NB: integer := 32);
	Port (	A:	In	std_logic_vector(NB-1 downto 0);
		B:	In	std_logic_vector(NB-1 downto 0);
		Ci:	In	std_logic;
		S:	Out	std_logic_vector(NB-1 downto 0)
		);
end component;

constant  reminder : integer := (NB mod Nrca); 


begin 


vect_gen : for I in 0 to NB/Nrca-1 generate 
		csa : carry_sel_bk
		      generic map(NB => Nrca)
		      port map( A( (I+1)*Nrca-1 downto I*Nrca ), 
						B( (I+1)*Nrca-1 downto I*Nrca ),
						Ci(I),
						S( (I+1)*Nrca-1 downto I*Nrca )
						);
	  end generate;



vect_gen_extra 	: 	for I in 0 to 0 generate
						cond0 : if (reminder /= 0) generate
										
								csa_extra : carry_sel_bk
											generic map (NB => reminder)
											port map (	A( NB-1 downto NB-reminder ), 
														B( NB-1 downto NB-reminder ),
														Ci(delimiter(NB,Nrca)),
														S( NB-1 downto NB-reminder )
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


 





