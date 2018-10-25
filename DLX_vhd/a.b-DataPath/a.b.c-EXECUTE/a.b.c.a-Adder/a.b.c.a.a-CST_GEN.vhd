library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all; 
use work.mfunc.all;

-- This block generate the structure used to compute the carry used by the carry select

entity CSTgen is
	generic(CW : integer := 4;
			NB : integer := 32);
	port(	A  : In 	std_logic_vector( NB-1 downto 0);
			B  : In 	std_logic_vector( NB-1 downto 0);
			Ci : In 	std_logic;
			C  : Out 	std_logic_vector( delimiter(NB,CW) downto 0)
	    );
end CSTgen;



architecture structural of CSTgen is



component G 
        Port (	Gik:	In	std_logic;
				Gk_1j:	In	std_logic;
				Pik:	In	std_logic;
				Gij:    Out 	std_logic
	);
end component;

component pg_net 
        Port (	a:	In		std_logic;
				b:	In		std_logic;
				p:  Out     std_logic;
				g:  Out 	std_logic
	);
end component;


component blockPG 
        Port (	Gik:	In	std_logic;
				Gk_1j:	In	std_logic;
				Pik:	In	std_logic;
				Pk_1j: 	In	std_logic;
				Pij:    Out std_logic;
				Gij:    Out std_logic
	);
end component;

type SignalVector is array ( 0 to f(CW)+f(NB/CW) ) of std_logic_vector(NB-1 downto 0);

signal matrixGen  : SignalVector := ( others => ( others => '0' ) ); 
signal matrixProp : SignalVector := ( others => ( others => '0' ) );

constant reminder : integer := (NB mod CW); 
signal g0temp : std_logic;


begin

matrixGen(0)(0) <=  g0temp or (Ci and matrixProp(0)(0) );

pg_network : 	for z in 0 to closemul(NB,CW) -1 generate
					pgn0 	:	if (z < NB) generate
						pgn1 	: 	if (z = 0) generate
										pg_n0 : pg_net port map ( a => A(z),
															 	  b => B(z),
																  p => matrixProp(0)(z),
															 	  g => g0temp
										    					);
									end generate pgn1;

						pgn2 	: 	if (z /= 0) generate
										pg_n : pg_net port map ( a => A(z),
																 b => B(z),
																 p => matrixProp(0)(z),
																 g => matrixGen(0)(z)
										    					);	
									end generate pgn2;	
								end generate pgn0;
	     		end generate pg_network; 


G1 	: 	for j in 1 to (f(CW)+f(NB/CW)) generate 
	G2 :	for i in 1 to closemul(NB,CW) generate

		G3 :	if (j <= f(CW) ) generate
			G4 :	if ( (i mod CW) = 0 ) generate
				G5 : 	for k in 0 to endLoop(j,CW) generate
					G6 : 	if (i-(k*(2**j)) <= effectivebits(NB, CW) ) generate					
						G7 : 	if ( isG( j, (i-(k*(2**j))), f(CW), CW,CW) ) generate

									gen : G port map ( 	Gij => matrixGen(j)(i-(k*(2**j))-1),
														Gik => matrixGen(j-1)(i-(k*(2**j))-1), 
														Gk_1j => matrixGen(j-disp(j,i-(k*(2**j)),CW))(i -(k*(2**j)) -2**(j-1) -1),
														Pik =>  matrixProp(j-1)(i-(k*(2**j))-1)
														); 
						
							G8 :	if ( j = f(CW) ) generate
										C(0) <= matrixGen(j)(i-(k*(2**j))-1);														
							end generate G8;																							
						end generate G7;	
						
						G9 :	if ( not isG( j, (i-(k*(2**j))), f(CW), CW,CW) ) generate

									pg : blockPG  port map (Gij => matrixGen(j)(i-(k*(2**j))-1), 
															Gik => matrixGen(j-1)(i-(k*(2**j))-1), 
															Gk_1j => matrixGen(j-disp(j,i-(k*(2**j)),CW))(i -(k*(2**j)) -2**(j-1) -1), 
															Pij => matrixProp(j)(i-(k*(2**j))-1), 
															Pik =>  matrixProp(j-1)(i-(k*(2**j))-1),
															Pk_1j => matrixProp(j-disp(j,i-(k*(2**j)),CW))(i -(k*(2**j)) -2**(j-1) -1)
															);
						end generate G9;				
					end generate G6;
				end generate G5;
			end generate G4;
		end generate G3;

		G10 :	if (j > f(CW)) generate
			G11 :	if ( (i mod (CW*( 2**( j-f(CW) ) ) ) ) = 0 ) generate
				G12 : 	for k in 1 to ( 2**( j-f(CW) -1) ) generate
					G13	: 	if ( (i - CW*(k-1)) <= effectivebits(NB, CW) ) generate 
						G14 :	if (i = (CW*(2**(j-f(CW)))) ) generate
								
									gen2 : G port map (	Gij => matrixGen(j)(i - CW*(k-1) -1), 
														Gik => matrixGen(j- indexgen(k, ( 2**(j-f(CW) -1) )))(i - CW*(k-1) -1), 
														Gk_1j => matrixGen(j-1)(i - CW*(2**(j-f(CW) -1)) -1),  
														Pik =>  matrixProp(j- indexgen(k, ( 2**(j-f(CW) -1) )))(i - CW*(k-1) -1)
														);
												 		

									C(i/CW - k) <= matrixGen(j)(i - CW*(k-1) -1);

						end generate G14;

						G15	:	if ( i /= CW*(2**(j-f(CW))) ) generate

												pg1 : blockPG port map (Gij => matrixGen(j)(i - CW*(k-1) -1), 
														 				Gik => matrixGen(j- indexgen(k, ( 2**(j-f(CW) -1) )))(i - CW*(k-1) -1),
																		Gk_1j => matrixGen(j-1)(i - CW*(2**(j-f(CW) -1)) -1), 
																		Pij => matrixProp(j)(i - CW*(k-1) -1), 
																		Pik =>  matrixProp(j- indexgen(k, ( 2**(j-f(CW) -1) )))(i - CW*(k-1) -1),
																		Pk_1j => matrixProp(j-1)(i - CW*(2**(j-f(CW) -1)) -1)
																		);	
						end generate G15;
					end generate G13;
				end generate G12;
			end generate G11;
		end generate G10;
	end generate G2;
end generate G1;


G16 :	for j in 0 to f(reminder) generate
	G17 : 	if (reminder /= 0 and j /= 0) generate
		G18 : 	for i in 1 to reminder generate
			G19 : 	if (i mod reminder = 0) generate
				G20 : 	for k in 0 to endLoop(j,reminder) generate

							pgextra : blockPG  port map (Gij => matrixGen(j)(i-(k*(2**j))+ effectivebits(NB, CW) -1), 
														 Gik => matrixGen(j-1)(i-(k*(2**j))+ effectivebits(NB, CW) -1), 
													 	 Gk_1j => matrixGen(j-disp(j,i-(k*(2**j)),reminder))(i -(k*(2**j)) -2**(j-1)+ effectivebits(NB, CW) -1), 
														 Pij => matrixProp(j)(i-(k*(2**j))+ effectivebits(NB, CW) -1), 
														 Pik =>  matrixProp(j-1)(i-(k*(2**j))+ effectivebits(NB, CW) -1),
														 Pk_1j => matrixProp(j-disp(j,i-(k*(2**j)),reminder))(i -(k*(2**j)) -2**(j-1)+ effectivebits(NB, CW) -1)
														);

					G21 : 	if (j = f(reminder)) generate
								genextra : G port map ( Gij => matrixGen(f(CW)+f(NB/CW))(NB-1),
														Gik => matrixGen(j)(i-(k*(2**j))+ effectivebits(NB, CW) -1), 
														Gk_1j => matrixGen(f(CW)+f(NB/CW) )(effectivebits(NB, CW)-1),
														Pik =>  matrixProp(j)(i-(k*(2**j))+ effectivebits(NB, CW) -1)
														);

								C(delimiter(NB,CW)) <= matrixGen(f(CW)+f(NB/CW))(NB-1);
									
					end generate G21;
				end generate G20;						
			end generate G19;	
		end generate G18;		
	end generate G17;
end generate G16;


end structural;




configuration CFG_CSTGEN_STRUC of CSTgen is
	for structural
		for pg_network
			for pgn0
				for pgn1
					for all : pg_net
						use configuration WORK.CFG_PGN_NET_BEH;
					end for;
				end for;

				for pgn2
					for all : pg_net
						use configuration WORK.CFG_PGN_NET_BEH;
					end for;
				end for;
			end for;
		end for;
				

		for G1
			for G2
				for G3
					for G4
						for G5
							for G6
								for G7
									for all : G
										use configuration WORK.CFG_G_BEH;
									end for;

									for G8
									end for;
								end for;

								for G9
									for all : blockPG
										use configuration WORK.CFG_PG_BEH;
									end for;
								end for;
							end for;
						end for;
					end for;
				end for;

				for G10
					for G11
						for G12
							for G13
								for G14
									for all : G
										use configuration WORK.CFG_G_BEH;
									end for;
								end for;

								for G15
									for all : blockPG
										use configuration WORK.CFG_PG_BEH;
									end for;
								end for;
							end for;
						end for;
					end for;
				end for;
			end for;
		end for;
		
		for G16
			for G17
				for G18
					for G19
						for G20
							for all : blockPG
								use configuration WORK.CFG_PG_BEH;
							end for;

							for G21
								for all : G
									use configuration WORK.CFG_G_BEH;
								end for;
							end for;
						end for;
					end for;
				end for;
			end for;
		end for;
	end for;		
end configuration CFG_CSTGEN_STRUC;	


