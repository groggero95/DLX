library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity RAM is 
generic ( NB : integer := 32;
          LS : integer := 5);
port (
    CLOCK   	: IN  std_logic;
    RST 		: IN  std_logic;
    WR      	: IN  std_logic; -- read haigh write low
    D_TYPE		: IN  std_logic_vector(1 downto 0);
    US 			: IN  std_logic;
    ADDRESS 	: IN  std_logic_vector(LS-1 downto 0);
    MEMIN   	: IN  std_logic_vector(NB-1 downto 0);
    MEMOUT  	: OUT std_logic_vector(NB-1 downto 0)
  );
end RAM;

architecture BEHAVIORAL of RAM is

   type ram_type is array (0 to (2**ADDRESS'length)-1) of std_logic_vector((MEMIN'length)/4 - 1 downto 0);
   signal memory : ram_type;
   signal address_buff : std_logic_vector(ADDRESS'range) := (others  => '0');

begin

  MEM_proc: process(CLOCK) is

  begin
    if CLOCK'event and CLOCK='1' then
      if RST='0' then
      	memory <= (others => (others => '0'));
      else
        if WR = '1' then
        	case D_TYPE is
	        	when "01" =>		-- BYTE
			        memory(to_integer(unsigned(ADDRESS))) <= MEMIN(7 downto 0);
			    when "10" =>		-- HALFWORD
			        memory(to_integer(unsigned(ADDRESS))) <= MEMIN(15 downto 8);
			        memory(to_integer(unsigned(ADDRESS))+1) <= MEMIN(7 downto 0);
			    when "11" =>		-- WORD
			        memory(to_integer(unsigned(ADDRESS))) <= MEMIN(31 downto 24);
			        memory(to_integer(unsigned(ADDRESS))+1) <= MEMIN(23 downto 16);
			        memory(to_integer(unsigned(ADDRESS))+2) <= MEMIN(15 downto 8);
			        memory(to_integer(unsigned(ADDRESS))+3) <= MEMIN(7 downto 0);
			    when others =>
		    end case;
	        address_buff <= ADDRESS;
	      end if;
	  end if;
    end if;
  end process;

  MEM_out: process(address_buff, US, D_TYPE,memory)
  		variable tmp : std_logic_vector(NB-1 downto 0);
  	begin
	  	if (US='1') then
	  		case D_TYPE is 
	  			when "01" => 
	  				MEMOUT <= std_logic_vector(resize(unsigned(memory(to_integer(unsigned(address_buff)))),NB));
	  			when "10" =>
	  				tmp(15 downto 0) := memory(to_integer(unsigned(address_buff))) & memory(to_integer(unsigned(address_buff)+1));
	  				MEMOUT <= std_logic_vector(resize(unsigned(tmp(15 downto 0)) , NB));
	  			when "11" => 
	  				tmp := memory(to_integer(unsigned(address_buff))) & memory(to_integer(unsigned(address_buff)+1)) & memory(to_integer(unsigned(address_buff)+2)) & memory(to_integer(unsigned(address_buff)+3));
	  				MEMOUT <= tmp;
	  			when others =>
	  				tmp := memory(to_integer(unsigned(address_buff))) & memory(to_integer(unsigned(address_buff)+1)) & memory(to_integer(unsigned(address_buff)+2)) & memory(to_integer(unsigned(address_buff)+3));
	  				MEMOUT <= tmp;
	  			end case;
	  	else
	  		case D_TYPE is 
	  			when "01" => 
	  				MEMOUT <= std_logic_vector(resize(signed(memory(to_integer(unsigned(address_buff)))), NB));
	  			when "10" => 
	  				tmp(15 downto 0) := memory(to_integer(unsigned(address_buff))) & memory(to_integer(unsigned(address_buff)+1));
	  				MEMOUT <= std_logic_vector(resize(signed(tmp(15 downto 0)) , NB));
	  			when "11" => 
	  				tmp := memory(to_integer(unsigned(address_buff))) & memory(to_integer(unsigned(address_buff)+1)) & memory(to_integer(unsigned(address_buff)+2)) & memory(to_integer(unsigned(address_buff)+3));
	  				MEMOUT <= tmp;
	  			when others =>
	  				tmp := memory(to_integer(unsigned(address_buff))) & memory(to_integer(unsigned(address_buff)+1)) & memory(to_integer(unsigned(address_buff)+2)) & memory(to_integer(unsigned(address_buff)+3));
	  				MEMOUT <= tmp;
	  			end case;

	  	end if;
	end process;

end BEHAVIORAL;
