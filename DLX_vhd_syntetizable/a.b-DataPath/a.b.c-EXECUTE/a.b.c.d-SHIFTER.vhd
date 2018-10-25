library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

-- Behavioral descriprion of a shifter which implemets
-- also rotation capability which is not used by the DLX

entity SHIFTER is
  generic ( NB: integer := 32;
  			LS: integer:= 5
  			);
  port 	 ( 	FUNC: 			IN std_logic_vector(1 downto 0);
  			US: 			IN std_logic;
           	DATA1: 			IN std_logic_vector(NB-1 downto 0);
           	DATA2: 			IN std_logic_vector(LS-1 downto 0);
           	OUTSHFT: 		OUT std_logic_vector(NB-1 downto 0)
          );
end SHIFTER;

architecture BEHAVIOR of SHIFTER is


begin

P_ALU: process (FUNC, US, DATA1, DATA2)
  begin
  		if(US='1') then
		    case FUNC is
		    	-- SLL
				when "00"	=>
						OUTSHFT <= std_logic_vector(shift_left(unsigned(DATA1), to_integer(unsigned(DATA2)))); 	
				-- SRL
				when "01" 	=>
						OUTSHFT <= std_logic_vector(shift_right(unsigned(DATA1), to_integer(unsigned(DATA2))));
				-- ROL
				when "10"	=>
						OUTSHFT <= std_logic_vector(rotate_left(unsigned(DATA1), to_integer(unsigned(DATA2))));
				-- ROR
				when "11" 	=>
						OUTSHFT <= std_logic_vector(rotate_right(unsigned(DATA1), to_integer(unsigned(DATA2))));
				when others => 
				    OUTSHFT <= (others =>'0');
		    end case; 
		 else
		   	case FUNC is
				-- SLL
				when "00"	=>
						OUTSHFT <= std_logic_vector(shift_left(signed(DATA1), to_integer(unsigned(DATA2)))); 	
				-- SRL
				when "01" 	=>
						OUTSHFT <= std_logic_vector(shift_right(signed(DATA1), to_integer(unsigned(DATA2))));
				-- ROL
				when "10"	=>
						OUTSHFT <= std_logic_vector(rotate_left(signed(DATA1), to_integer(unsigned(DATA2))));
				-- ROR
				when "11" 	=>
						OUTSHFT <= std_logic_vector(rotate_right(signed(DATA1), to_integer(unsigned(DATA2))));
				when others => 
				    OUTSHFT <= (others =>'0');
			end case;
		end if;
  end process P_ALU;

end BEHAVIOR;

configuration CFG_SHIFTER of SHIFTER is
for BEHAVIOR
end for;
end CFG_SHIFTER;