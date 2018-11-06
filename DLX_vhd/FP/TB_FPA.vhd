library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity TB_FPA is
  generic ( NB  : integer := 32;
            LS  : integer := 5;
            PN  : integer := 6
    );                      
end TB_FPA;


architecture BEHAVIORAL of TB_FPA is

component FP_ADDER
  generic ( NB  : integer := 32
    );       
  port (
    OP1 : IN  std_logic_vector(NB-1 downto 0);
    OP2 : IN  std_logic_vector(NB-1 downto 0);
    RES : OUT std_logic_vector(NB-1 downto 0)
    );               
end component;

signal OP1, OP2 : std_logic_vector(NB-1 downto 0) := (others => '0' );
signal RES : std_logic_vector(NB-1 downto 0);

signal clk : std_logic := '0';

begin   

clk <= not clk after 0.5 ns;

dut : FP_ADDER port map (OP1,OP2,RES); 

OP1 <=  (others => '0' ), "11000000101110000000000000000000" after 1 ns;
OP2 <=  (others => '0' ), "01000001001001000001001101001011" after 1 ns;


--process(clk)
--begin
--  if clk'event and clk = '1' then 
--    OP <= std_logic_vector(rotate_left(unsigned(OP), 1));
--  end if;
--end process;

end BEHAVIORAL;
