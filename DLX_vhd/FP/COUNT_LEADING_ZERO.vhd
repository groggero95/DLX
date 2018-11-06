library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity CLZ is
  generic ( NB  : integer := 24;
            LS  : integer := 5;
            PN  : integer := 6
    );       
  port (
    OP : IN  std_logic_vector(NB-1 downto 0);
    NLZ : OUT std_logic_vector(LS-1 downto 0)
    );               
end CLZ;


architecture BEHAVIORAL of CLZ is

type last_two_bit is array (PN -1 downto 0) of std_logic_vector(1 downto 0); 

signal all_zero : std_logic_vector(PN -1 downto 0);

signal small_CLZ_table : last_two_bit;

signal last_bit_selector : std_logic_vector(2 downto 0);

signal to_out : std_logic_vector(LS-1 downto 0);

begin    

  zero_detect : for I in (PN -1) downto 0 generate
    all_zero(I) <= not (OP(I*4 + 3) or OP(I*4 + 2) or OP(I*4 + 1) or OP(I*4 + 0)) ;
  end generate zero_detect;

  clz4bit : for I in (PN -1) downto 0 generate
    small_CLZ_table(I)(1) <= not (OP(I*4 + 3) or OP(I*4 + 2));
    small_CLZ_table(I)(0) <= (not OP(I*4 + 3)) and (OP(I*4 + 2) or not(OP(I*4 + 1)));
  end generate clz4bit;

  mux_encoder : process(all_zero)
    variable tmp, tmp1 : std_logic;
  begin
    --tmp := all_zero(PN-1) and all_zero(PN-2);
    --tmp1 := all_zero(PN-3) and all_zero(PN-4);    
    --last_bit_selector(2) <= tmp and tmp1;
    --last_bit_selector(1) <= tmp and ( (all_zero(PN-3) nand all_zero(PN-4)) or (all_zero(PN-5) and all_zero(PN-6)) );
    --last_bit_selector(0) <= (all_zero(PN-1) and (not all_zero(PN-2))) or ((all_zero(PN-1) and all_zero(PN-3))  and ( (not all_zero(PN-4)) or (all_zero(PN-5) and (not all_zero(PN-6))) or (all_zero(PN-5) and all_zero(PN-7)) ));
    tmp := all_zero(PN-1) and all_zero(PN-2);
    tmp1 := all_zero(PN-3) and all_zero(PN-4);    
    last_bit_selector(2) <= tmp and tmp1;
    last_bit_selector(1) <= tmp and ( (not all_zero(PN-3)) or (all_zero(PN-4) and all_zero(PN-5) and all_zero(PN-6)) or (not all_zero(PN-4)) );
    last_bit_selector(0) <= (all_zero(PN-1) and (not all_zero(PN-2))) or ((all_zero(PN-1) and all_zero(PN-3))  and ( (not all_zero(PN-4)) or (all_zero(PN-5) and (not all_zero(PN-6)))));
  end process mux_encoder;

  to_out(LS-1 downto LS-3) <= last_bit_selector; 

  last_two_bit_mux : process(small_CLZ_table,last_bit_selector)
  begin

    case last_bit_selector is
      when "000" => to_out(LS-4 downto 0) <= small_CLZ_table(5);  
      when "001" => to_out(LS-4 downto 0) <= small_CLZ_table(4);
      when "010" => to_out(LS-4 downto 0) <= small_CLZ_table(3);
      when "011" => to_out(LS-4 downto 0) <= small_CLZ_table(2);
      when "100" => to_out(LS-4 downto 0) <= small_CLZ_table(1);
      when "101" => to_out(LS-4 downto 0) <= small_CLZ_table(0);
--      when "110" => to_out(LS-4 downto 0) <= small_CLZ_table(0);
--      when "111" => to_out(LS-4 downto 0) <= small_CLZ_table(0);
      when others => to_out(LS-4 downto 0) <= (others => '0');
    end case;

  end process last_two_bit_mux;

  NLZ <= to_out;

end BEHAVIORAL;


configuration CFG_CLZ of CLZ is
for BEHAVIORAL
end for;
end CFG_CLZ;