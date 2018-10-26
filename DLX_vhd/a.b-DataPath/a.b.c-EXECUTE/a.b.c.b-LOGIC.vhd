library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_misc.all;

-- T2 structure to compute logic functions having
-- a balanced tree of logic gates

entity LOGIC is 
	generic (NB : integer := 32);
	port (  SEL		: in  std_logic_vector(3 downto 0);
          A 		: in  std_logic_vector(NB-1 downto 0);
          B 		: in  std_logic_vector(NB-1 downto 0);
          RES 	: out std_logic_vector(NB-1 downto 0)
  );
end LOGIC;


architecture STRUCTURAL of LOGIC is
  type logic_l is array (0 to NB-1) of std_logic_vector(3 downto 0);
	signal L : logic_l;
  signal BW : std_logic_vector(NB-1 downto 0);
	
begin
	LO : for I in 0 to NB-1 generate
      L(I)(0) <= not(SEL(0) and not(A(I)) and not(B(I)));
      L(I)(1) <= not(SEL(1) and not(A(I)) and (B(I)));
      L(I)(2) <= not(SEL(2) and (A(I)) and not(B(I)));
      L(I)(3) <= not(SEL(3) and (A(I)) and (B(I)));
      BW(I) <= not (and_reduce(L(I)));
  end generate LO;

  RES <= BW;

end STRUCTURAL;


configuration CFG_LOGIC of LOGIC is
  for STRUCTURAL
    for LO
    end for;
  end for;
end CFG_LOGIC;