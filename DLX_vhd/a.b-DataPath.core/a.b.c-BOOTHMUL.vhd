library IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity BOOTHMUL is 
		generic (	NB: integer := 32); -- Number of output bits
		port (	A: in std_logic_vector((NB/2)-1 downto 0);
				B: in std_logic_vector((NB/2)-1 downto 0);
				C: out std_logic_vector(NB-1 downto 0)
			);
end BOOTHMUL;

architecture BEHAVIORAL of BOOTHMUL is

component MUX_SHIFT is 
		generic (	NB: integer:= 32;
				N_sh: integer:= 0
				);
		port (	A: in std_logic_vector(NB-1 downto 0);
				sel: in std_logic_vector(2 downto 0);
				AS: out std_logic;
				B: out std_logic_vector(2*NB-1 downto 0)
			);
end component MUX_SHIFT;

component p4addgen is
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
end component p4addgen;



type SignalVector is array ((NB/4)-1 downto 0) of std_logic_vector(NB-1 downto 0);

signal Term, Res: SignalVector;
signal to_mux: std_logic_vector(NB/2 downto 0);
signal OP: std_logic_vector((NB/2)-1 downto 0); -- used to determine the carry in of the adder, in order to correctly have the negative version of A
signal carry: std_logic_vector((NB/2)-1 downto 0);
signal ZER: std_logic_vector((NB/2)-1 downto 0) := (others => '0');
signal A_ext, B_ext: std_logic_vector(NB-1 downto 0);


begin

	to_mux <= B & '0'; 
	
	MUX_SH_VECTOR: for I in 0 to ((NB/4)-1) generate
	    mux_map : MUX_SHIFT Generic Map(NB/2, 2*I)
							Port Map (A, to_mux((2*I+2) downto (2*I)), OP(I), Term(I)); 
	  end generate MUX_SH_VECTOR;
	
	ADD_VECTOR : for I in 0 to ((NB/4)-1) generate
		COMPL: if (I=0) generate 
			adder: p4addgen Generic Map (NB)
						Port Map (Term(I), (others => '0'), OP(I), carry(I), Res(I));
		end generate COMPL;
		ADD: if (I/=0) generate
		add_map	: p4addgen Generic Map (NB)
						Port Map (Term(I), Res(I-1), OP(I), carry(I), Res(I));
		end generate ADD;
	end generate ADD_VECTOR;
	
	C <= Res((NB/4)-1);
	
end BEHAVIORAL;


configuration CFG_BOOTHMUL_STRUCTURAL of BOOTHMUL is
	for BEHAVIORAL
	    for MUX_SH_VECTOR
		for all : MUX_SHIFT
			use configuration WORK.CFG_MUX_SH_MUL_BEHAVIORAL;
		end for;
	    end for;
		
		for ADD_VECTOR
			for COMPL 
				for all : p4addgen
					use configuration WORK.CFG_P4ADDGEN_STRUC;
				end for;
			end for;

			for ADD
				for all : p4addgen
					use configuration WORK.CFG_P4ADDGEN_STRUC;
				end for;
			end for;
		
		end for;
	end for;
end CFG_BOOTHMUL_STRUCTURAL;


