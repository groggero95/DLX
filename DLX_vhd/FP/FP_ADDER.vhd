library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity FP_ADDER is
  generic ( NB  : integer := 32
    );       
  port (
    OP1 : IN  std_logic_vector(NB-1 downto 0);
    OP2 : IN  std_logic_vector(NB-1 downto 0);
    RES : OUT std_logic_vector(NB-1 downto 0)
    );               
end FP_ADDER;

-- NOTE Step are ordered in such a way to describe a human readable algorithm
-- it doesn't mean that such step need to be executed in an ordered way, some 
-- of them can actually execute in parallel 
architecture BEHAVIORAL of FP_ADDER is

  component CLZ 
  generic ( NB  : integer := 24;
            LS  : integer := 5;
            PN  : integer := 6
    );       
  port (
    OP : IN  std_logic_vector(NB-1 downto 0);
    NLZ : OUT std_logic_vector(LS-1 downto 0)
    );               
end component;

  constant ZERO_EXP : std_logic_vector(7 downto 0) := "00000000"; 

  -- Temporary hidden bits
  signal H1, H2 : std_logic;

  -- Exponents and their differnec
  signal E1, E2, DIFF_EXP, E_ADJ: std_logic_vector(7 downto 0);

  -- Significand of the two number, plus the adjusted version of S2
  signal S1, S2, S2_ADJ : std_logic_vector(23 downto 0);

  -- The operand, in N1 the exponent will alwas be bigger than N2
  signal N1, N2 : std_logic_vector(NB-1 downto 0);

  -- Record if the two number have the same sign
  signal SIGN_DETECTOR : std_logic;

  signal SHA : std_logic_vector(4 downto 0);

  signal S_TMP : std_logic_vector(24 downto 0);

  signal E_OUT : std_logic_vector(7 downto 0);
  signal S_OUT, S_ADJ : std_logic_vector(23 downto 0);



begin    

-- Step 1: Check if any of the exponent is zero and set the hidden bit
process(OP1)
begin
  if OP1(NB-2 downto NB-9) = ZERO_EXP then
    H1 <= '0';
  else
    H1 <= '1';
  end if;
end process;

process(OP2)
begin
  if OP2(NB-2 downto NB-9) = ZERO_EXP then
    H2 <= '0';
  else
    H2 <= '1';
  end if;
end process;

-- Step 2: determine which of the operand has a bigger exponent and set it to N1 while the other operand to N2
process(OP1,OP2,H1,H2)
begin
  if unsigned(OP1(NB-2 downto NB-9)) > unsigned(OP2(NB-2 downto NB-9)) then
    N1 <= OP1;
    N2 <= OP2;
    S1(23) <= H1;
    S2(23) <= H2;
  else
    N1 <= OP2;
    N2 <= OP1;
    S1(23) <= H2;
    S2(23) <= H1;
  end if;
end process;

--Step 3: Extract the exponent and significand fields from the ordered numbers 
  E1 <= N1(NB-2 downto NB-9);
  E2 <= N2(NB-2 downto NB-9);
  S1(22 downto 0) <= N1(NB-10 downto 0);
  S2(22 downto 0) <= N2(NB-10 downto 0); 
-- Computhe the difference between the exponent and shift right significand two to 
-- align it with significand one
  DIFF_EXP <= std_logic_vector(unsigned(E1) - unsigned(E2));
  S2_ADJ <= std_logic_vector(shift_right(unsigned(S2), to_integer(unsigned(DIFF_EXP))));
  
-- Step 4: Determine if the two number have the same sign
SIGN_DETECTOR <= N1(NB-1) xnor N2(NB-1);

-- Step 5: According to the sign of the two number add S1 with S2 or its two's complement version
process(SIGN_DETECTOR,S1,S2_ADJ)
begin
  if (SIGN_DETECTOR = '1') then
    S_TMP <= std_logic_vector(unsigned('0' & S1) + unsigned('0' & S2_ADJ)); -- TODO consider carry out
  else
    S_TMP <= std_logic_vector(unsigned('0' & S1) + ('0' &  unsigned(not S2_ADJ)) + 1 );
  end if;
end process;

counter : CLZ port map (S_TMP(23 downto 0),SHA);

-- Step 5 bis: necessary only if the two number have different sign 
process(S_TMP,SHA,E1)
begin 
  if (S_TMP(24) = '1') then
    S_ADJ <= std_logic_vector(shift_left(unsigned(S_TMP(23 downto 0)), to_integer(unsigned(SHA))));
    E_ADJ <= std_logic_vector(unsigned(E1) - unsigned(SHA));
  else
      if S_TMP(23) = '1' then
        S_ADJ <= std_logic_vector(unsigned(not S_TMP(23 downto 0)) + 1);
      else
        S_ADJ <= S_TMP(23 downto 0);
      end if;
    E_ADJ <= E1;
  end if;
end process;

---- Step 6: Adjust the final exponent according to the addition of the two operands 
--process(E1,S_TMP(24))
--  variable tmp : std_logic_vector(0 downto 0);
--begin
--  tmp(0) := S_TMP(24);
--  E_OUT <= std_logic_vector(unsigned(E1) + unsigned(tmp));
--end process;  

-- Step 7: Assign the 23 needed bit to the significand according to the carry out, and the 8 bit for the exponent
process(S_TMP,SIGN_DETECTOR,E1,S_ADJ,E_ADJ)
  variable tmp : std_logic_vector(0 downto 0);
begin
  If SIGN_DETECTOR = '1' then
     if S_TMP(24) = '1' then 
      S_OUT <= S_TMP(24 downto 1);
    else
      S_OUT <= S_TMP(23 downto 0);
    end if;
      tmp(0) := S_TMP(24);
      E_OUT <= std_logic_vector(unsigned(E1) + unsigned(tmp));
  else
    S_OUT <= S_ADJ;
    E_OUT <= E_ADJ;
  end if;

 
end process;

-- Step 8: Reassemble the result
RES(NB-1) <= N1(NB-1);
RES(NB-2 downto NB-9) <= E_OUT;
RES(NB-10 downto 0) <= S_OUT(22 downto 0); 


end BEHAVIORAL;

configuration CFG_FP_ADDER of FP_ADDER is
for BEHAVIORAL
	for counter : CLZ
		use configuration WORK.CFG_CLZ;
	end for;
end for;
end CFG_FP_ADDER;
