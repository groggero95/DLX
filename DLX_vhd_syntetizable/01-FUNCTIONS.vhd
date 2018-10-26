library ieee; 
use ieee.std_logic_1164.all;

-- Set of functions used to generate the P4 adder

package mfunc is
	function indexgen ( a : integer; b : integer ) return integer;

	function log2 ( n : integer) return integer;

	function "**" ( a : integer; b : integer ) return integer;
	
	function f ( a : integer) return integer;

	function endLoop ( row : integer; CW : integer ) return integer;
	
	function disp ( row : integer; col : integer; CW : integer ) return integer;

	function mult ( a : integer; b : integer ) return integer;

	function closemul (  a : integer; b : integer ) return integer;

	function effectivebits ( NB : integer; CW : integer ) return integer;

	function isG ( row : integer; col : integer; Cr : integer; Cc : integer; CW : integer ) return boolean;

	function delimiter ( NB : integer; CW : integer ) return integer;

	function getAddrSize( a : natural ) return natural; -- return log2 if argument is a power of two, and log2 + 1 otherwise



end package mfunc;

package body mfunc is


	function getAddrSize( a : natural ) return natural is
		variable temp : natural;
	begin
		temp := log2(a);
		if 2**temp = a then
			return temp;
		else 
			return temp + 1;
		end if;

	end function getAddrSize;

	

	function delimiter ( NB : integer; CW : integer ) return integer is

	begin
		if (NB mod CW = 0) then 
			return NB/CW-1;
		else 
			return NB/CW;
		end if;

	end delimiter;

	function effectivebits( NB : integer; CW : integer ) return integer is

	begin
		return ((NB/CW)*CW);

	end effectivebits;

	function closemul ( a : integer; b : integer ) return integer is
		variable temp : integer := 1;
	begin
		return (2**f(a/b))*b;
		
	end function closemul;
	
	function indexgen ( a : integer; b : integer) return integer is
	begin

		if a <= b/2 or b/2 = 0 then
			return 1;
		else
			return (1 + indexgen(a - b/2, b/2));
		end if;
		
	end indexgen;

	function log2 ( n : integer	) return integer is
	begin
		if n < 2 then
			return 0;
		else 
			return 1 + log2(n/2);
		end if;

	end function log2;

	function mult (a: integer; b : integer) return integer is
		variable acc : integer := 0;
	begin

		acc := 0;
		fl : for i in 1 to b loop
			acc := acc + a;
			
		end loop fl;
		
		return acc;
	end mult;

	function f ( a : integer) return integer is
	begin
		fr0 : for i in 0 to a  loop
			if ( a <= (2**i) ) then
				return i;
			end if;
		end loop fr0;

		return 0;
	end function f;

	function endLoop ( row : integer; CW : integer ) return integer is
	begin
		if (CW/(2**row)-1 < 0) then
			return 0;
		else
			return CW/(2**row)-1;
		end if;

	end function endLoop;

	function disp ( row : integer; col : integer; CW : integer ) return integer is

	type temptype is array (0 to CW-1) of integer range 1 downto 0;

	type tempArr is array ( f(CW) downto 0) of temptype;

	variable falags : tempArr := ( others => ( others => 0 ) );

	begin
		rowLoop : for z in 0 to f(CW) loop
			colLoop : for x in 1 to CW loop
				if (x mod CW = 0) then
					innerLoop : for k in 0 to endLoop(z, CW) loop
						falags(z)(x-1 - k*(2**z) ) := 1;
					end loop innerLoop;	
				end if;
			end loop colLoop;
		end loop rowLoop;

		if falags(row)( (col-1) mod CW )  = 1 then
			finderLoop : for i in 1 to row loop
				if ( falags(row-i)( ( (col-1) mod CW) - 2**(row-1) ) = 1 ) then
					return i;
					
				end if;
				
			end loop finderLoop;


		else
			report "Wrong index row and column." severity ERROR;
		end if;


		return 0;

		
	end function disp;

	function isG (row : integer; col : integer; Cr : integer; Cc : integer; CW : integer) return boolean is
		variable Pr, Pc : integer;
	begin
		if (row < Cr) then
			return isG(row, col, Cr-disp(row, col, CW), Cc-2**(Cr-1), CW);
		elsif (row > Cr) then
			return false;
		elsif (row = Cr) then
			if (col = Cc) then
				return true;
			else 
				return false;					
			end if;							
		end if;
		return false;
	end isG;

	function "**" ( a : integer; b : integer ) return integer is
		variable accumulator : integer;
	begin

		if (a < 0) then 
			assert (false) report "Cannot handle negative numbers in X**Y" severity ERROR;
			return 0;
		end if;
		if (b < 0) then 
			assert (false) report "Cannot handle negative numbers in X**Y" severity ERROR;
			return 0;
		end if;		

		if (a = 0) and ( b = 0) then 
			assert (false) report "Cannot make 0 power 0 in X**Y" severity ERROR;
			return 0;
		end if;	


		if (b = 0) then
			return 1;
		else
			accumulator := 1;
			loop1 : for i in 1 to b loop
				accumulator := mult(accumulator, a);
			end loop loop1;
		end if;

		return accumulator;

	end function "**";

end package body mfunc;