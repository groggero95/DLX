library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.mfunc.all;


entity p4addgen is
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
end entity p4addgen;



architecture stuctural of p4addgen is


component CSTgen 
	generic(CW : integer := 4;
			NB : integer := 32);
	port(	A  : In 	std_logic_vector( NB-1 downto 0);
			B  : In 	std_logic_vector( NB-1 downto 0);
			Ci : In 	std_logic;
			C  : Out 	std_logic_vector( delimiter(NB,CW) downto 0)
	    );
end component;

component sum_gen 
         Generic ( Nrca: integer := 4;
		  NB : integer := 32 );
	Port (	A:	In	std_logic_vector(NB-1 downto 0);
			B:	In	std_logic_vector(NB-1 downto 0);
			Ci:	In	std_logic_vector(delimiter(NB,Nrca) downto 0);
			S:	Out	std_logic_vector(NB-1 downto 0)
		);
end component;

signal carry, carry_sh : std_logic_vector(delimiter(NB,CW)  downto 0);

begin

carry_sh(delimiter(NB,CW)  downto 1) <= carry(delimiter(NB,CW)-1  downto 0);
carry_sh(0) <= Ci;

sparse_tree : CSTgen 
	generic map ( 	CW => CW,
					NB => NB
				)
	port map (	A => A, 
				B => B,
				Ci => Ci, 
				C => carry
			 );

carry_sel : sum_gen
	generic map (	Nrca => CW,
					NB => NB
				)
	port map (	A => A, 
				B => B,
				Ci => carry_sh,
				S => S
			 );

	Co <= carry(delimiter(NB,CW));

	
end architecture stuctural;



configuration CFG_P4ADDGEN_STRUC of p4addgen is
	for stuctural
		for sparse_tree : CSTgen
			use configuration WORK.CFG_CSTGEN_STRUC;
		end for;

		for carry_sel : sum_gen
			use configuration WORK.CFG_SUM_GEN_BEH;
		end for;
	end for;
end CFG_P4ADDGEN_STRUC;