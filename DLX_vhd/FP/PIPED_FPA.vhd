library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity PIPED_FPA is
  generic ( NB  : integer := 32
    );                      
  port (  CLK : IN  std_logic;
          OP1 : IN  std_logic_vector(NB-1 downto 0);
          OP2 : IN  std_logic_vector(NB-1 downto 0);
          RES : OUT std_logic_vector(NB-1 downto 0)
  );
end PIPED_FPA;


architecture BEHAVIORAL of PIPED_FPA is

component FP_ADDER
  generic ( NB  : integer := 32
    );       
  port (
    OP1 : IN  std_logic_vector(NB-1 downto 0);
    OP2 : IN  std_logic_vector(NB-1 downto 0);
    RES : OUT std_logic_vector(NB-1 downto 0)
    );               
end component;

signal OP1_t, OP2_t : std_logic_vector(NB-1 downto 0) := (others => '0' );
signal RES_t : std_logic_vector(NB-1 downto 0);

begin   

process(CLK)
begin
  if CLK'event and CLK = '1' then 
    OP1_t <= OP1;
    OP2_t <= OP2;
  end if;
end process;

fpa : FP_ADDER port map (OP1_t,OP2_t,RES_t); 


process(CLK)
begin
  if CLK'event and CLK = '1' then
    RES <= RES_t;
  end if;
end process;


end BEHAVIORAL;

configuration CFG_PIPED_FPA of PIPED_FPA is
for BEHAVIORAL
  for fpa : FP_ADDER
    use configuration WORK.CFG_FP_ADDER;
  end for;
end for;
end CFG_PIPED_FPA;
