library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity TB_CLZ is
  generic ( NB  : integer := 24;
            LS  : integer := 5;
            PN  : integer := 6
    );                      
end TB_CLZ;


architecture BEHAVIORAL of TB_CLZ is

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

signal OP : std_logic_vector(NB-1 downto 0) := (0 => '1', others => '0' );
signal NLZ : std_logic_vector(LS-1 downto 0);

signal clk : std_logic := '0';

begin   

clk <= not clk after 0.5 ns;

dut : CLZ port map (OP,NLZ); 

process(clk)
begin
  if clk'event and clk = '1' then 
    OP <= std_logic_vector(rotate_left(unsigned(OP), 1));
  end if;
end process;

end BEHAVIORAL;
