library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use std.textio.all;
use ieee.std_logic_textio.all;


-- Instruction memory for DLX
-- Memory filled by a process which reads from a file
-- file name is "test.asm.mem"
entity IRAM is
  generic (
    RAM_DEPTH : integer := 512;
    I_SIZE : integer := 32;
    LS : integer := 5);
  port (
    Rst  : in  std_logic;
    Addr : in  std_logic_vector(I_SIZE - 1 downto 0);
    Dout : out std_logic_vector(I_SIZE - 1 downto 0)
    );

end IRAM;

architecture IRam_Bhe of IRAM is

  type RAMtype is array (0 to RAM_DEPTH - 1) of std_logic_vector( I_SIZE/4 - 1 downto 0);

  signal IRAM_mem : RAMtype;

begin  -- IRam_Bhe

  Dout(I_SIZE - 1  downto I_SIZE - 8)  <= IRAM_mem(conv_integer(unsigned(Addr) + 0));
  Dout(I_SIZE - 9  downto I_SIZE - 16) <= IRAM_mem(conv_integer(unsigned(Addr) + 1));
  Dout(I_SIZE - 17 downto I_SIZE - 24) <= IRAM_mem(conv_integer(unsigned(Addr) + 2));
  Dout(I_SIZE - 25 downto I_SIZE - 32) <= IRAM_mem(conv_integer(unsigned(Addr) + 3));  

  -- purpose: This process is in charge of filling the Instruction RAM with the firmware
  -- type   : combinational
  -- inputs : Rst
  -- outputs: IRAM_mem
  FILL_MEM_P: process (Rst)
    file mem_fp: text;
    variable file_line : line;
    variable index : integer := 0;
    variable tmp_data_u : std_logic_vector(I_SIZE-1 downto 0);
  begin  -- process FILL_MEM_P
    if (Rst = '0') then
      file_open(mem_fp,"test.asm.mem",READ_MODE);
      while (not endfile(mem_fp)) loop
        readline(mem_fp,file_line);
        hread(file_line,tmp_data_u);
        IRAM_mem(index + 0) <= tmp_data_u(I_SIZE-1  downto I_SIZE - 8 );
        IRAM_mem(index + 1) <= tmp_data_u(I_SIZE-9  downto I_SIZE - 16);
        IRAM_mem(index + 2) <= tmp_data_u(I_SIZE-17 downto I_SIZE - 24);
        IRAM_mem(index + 3) <= tmp_data_u(I_SIZE-25 downto I_SIZE - 32);
               
        index := index + 4;
      end loop;
    end if;
  end process FILL_MEM_P;

end IRam_Bhe;
