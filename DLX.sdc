###################################################################

# Created by write_sdc on Thu Oct 25 20:59:41 2018

###################################################################
set sdc_version 1.7

create_clock [get_ports CLK]  -period 3  -waveform {0 1.5}
set_max_delay 3  -from [list [get_ports CLK] [get_ports RST] [get_ports {EXT_MEM_IN[31]}]      \
[get_ports {EXT_MEM_IN[30]}] [get_ports {EXT_MEM_IN[29]}] [get_ports           \
{EXT_MEM_IN[28]}] [get_ports {EXT_MEM_IN[27]}] [get_ports {EXT_MEM_IN[26]}]    \
[get_ports {EXT_MEM_IN[25]}] [get_ports {EXT_MEM_IN[24]}] [get_ports           \
{EXT_MEM_IN[23]}] [get_ports {EXT_MEM_IN[22]}] [get_ports {EXT_MEM_IN[21]}]    \
[get_ports {EXT_MEM_IN[20]}] [get_ports {EXT_MEM_IN[19]}] [get_ports           \
{EXT_MEM_IN[18]}] [get_ports {EXT_MEM_IN[17]}] [get_ports {EXT_MEM_IN[16]}]    \
[get_ports {EXT_MEM_IN[15]}] [get_ports {EXT_MEM_IN[14]}] [get_ports           \
{EXT_MEM_IN[13]}] [get_ports {EXT_MEM_IN[12]}] [get_ports {EXT_MEM_IN[11]}]    \
[get_ports {EXT_MEM_IN[10]}] [get_ports {EXT_MEM_IN[9]}] [get_ports            \
{EXT_MEM_IN[8]}] [get_ports {EXT_MEM_IN[7]}] [get_ports {EXT_MEM_IN[6]}]       \
[get_ports {EXT_MEM_IN[5]}] [get_ports {EXT_MEM_IN[4]}] [get_ports             \
{EXT_MEM_IN[3]}] [get_ports {EXT_MEM_IN[2]}] [get_ports {EXT_MEM_IN[1]}]       \
[get_ports {EXT_MEM_IN[0]}] [get_ports {IRAM_OUT[31]}] [get_ports              \
{IRAM_OUT[30]}] [get_ports {IRAM_OUT[29]}] [get_ports {IRAM_OUT[28]}]          \
[get_ports {IRAM_OUT[27]}] [get_ports {IRAM_OUT[26]}] [get_ports               \
{IRAM_OUT[25]}] [get_ports {IRAM_OUT[24]}] [get_ports {IRAM_OUT[23]}]          \
[get_ports {IRAM_OUT[22]}] [get_ports {IRAM_OUT[21]}] [get_ports               \
{IRAM_OUT[20]}] [get_ports {IRAM_OUT[19]}] [get_ports {IRAM_OUT[18]}]          \
[get_ports {IRAM_OUT[17]}] [get_ports {IRAM_OUT[16]}] [get_ports               \
{IRAM_OUT[15]}] [get_ports {IRAM_OUT[14]}] [get_ports {IRAM_OUT[13]}]          \
[get_ports {IRAM_OUT[12]}] [get_ports {IRAM_OUT[11]}] [get_ports               \
{IRAM_OUT[10]}] [get_ports {IRAM_OUT[9]}] [get_ports {IRAM_OUT[8]}] [get_ports \
{IRAM_OUT[7]}] [get_ports {IRAM_OUT[6]}] [get_ports {IRAM_OUT[5]}] [get_ports  \
{IRAM_OUT[4]}] [get_ports {IRAM_OUT[3]}] [get_ports {IRAM_OUT[2]}] [get_ports  \
{IRAM_OUT[1]}] [get_ports {IRAM_OUT[0]}]]  -to [list [get_ports {D_TYPE[1]}] [get_ports {D_TYPE[0]}] [get_ports RW]      \
[get_ports US_MEM] [get_ports {IRAM_ADD[31]}] [get_ports {IRAM_ADD[30]}]       \
[get_ports {IRAM_ADD[29]}] [get_ports {IRAM_ADD[28]}] [get_ports               \
{IRAM_ADD[27]}] [get_ports {IRAM_ADD[26]}] [get_ports {IRAM_ADD[25]}]          \
[get_ports {IRAM_ADD[24]}] [get_ports {IRAM_ADD[23]}] [get_ports               \
{IRAM_ADD[22]}] [get_ports {IRAM_ADD[21]}] [get_ports {IRAM_ADD[20]}]          \
[get_ports {IRAM_ADD[19]}] [get_ports {IRAM_ADD[18]}] [get_ports               \
{IRAM_ADD[17]}] [get_ports {IRAM_ADD[16]}] [get_ports {IRAM_ADD[15]}]          \
[get_ports {IRAM_ADD[14]}] [get_ports {IRAM_ADD[13]}] [get_ports               \
{IRAM_ADD[12]}] [get_ports {IRAM_ADD[11]}] [get_ports {IRAM_ADD[10]}]          \
[get_ports {IRAM_ADD[9]}] [get_ports {IRAM_ADD[8]}] [get_ports {IRAM_ADD[7]}]  \
[get_ports {IRAM_ADD[6]}] [get_ports {IRAM_ADD[5]}] [get_ports {IRAM_ADD[4]}]  \
[get_ports {IRAM_ADD[3]}] [get_ports {IRAM_ADD[2]}] [get_ports {IRAM_ADD[1]}]  \
[get_ports {IRAM_ADD[0]}] [get_ports {EXT_MEM_ADD[4]}] [get_ports              \
{EXT_MEM_ADD[3]}] [get_ports {EXT_MEM_ADD[2]}] [get_ports {EXT_MEM_ADD[1]}]    \
[get_ports {EXT_MEM_ADD[0]}] [get_ports {EXT_MEM_DATA[31]}] [get_ports         \
{EXT_MEM_DATA[30]}] [get_ports {EXT_MEM_DATA[29]}] [get_ports                  \
{EXT_MEM_DATA[28]}] [get_ports {EXT_MEM_DATA[27]}] [get_ports                  \
{EXT_MEM_DATA[26]}] [get_ports {EXT_MEM_DATA[25]}] [get_ports                  \
{EXT_MEM_DATA[24]}] [get_ports {EXT_MEM_DATA[23]}] [get_ports                  \
{EXT_MEM_DATA[22]}] [get_ports {EXT_MEM_DATA[21]}] [get_ports                  \
{EXT_MEM_DATA[20]}] [get_ports {EXT_MEM_DATA[19]}] [get_ports                  \
{EXT_MEM_DATA[18]}] [get_ports {EXT_MEM_DATA[17]}] [get_ports                  \
{EXT_MEM_DATA[16]}] [get_ports {EXT_MEM_DATA[15]}] [get_ports                  \
{EXT_MEM_DATA[14]}] [get_ports {EXT_MEM_DATA[13]}] [get_ports                  \
{EXT_MEM_DATA[12]}] [get_ports {EXT_MEM_DATA[11]}] [get_ports                  \
{EXT_MEM_DATA[10]}] [get_ports {EXT_MEM_DATA[9]}] [get_ports                   \
{EXT_MEM_DATA[8]}] [get_ports {EXT_MEM_DATA[7]}] [get_ports {EXT_MEM_DATA[6]}] \
[get_ports {EXT_MEM_DATA[5]}] [get_ports {EXT_MEM_DATA[4]}] [get_ports         \
{EXT_MEM_DATA[3]}] [get_ports {EXT_MEM_DATA[2]}] [get_ports {EXT_MEM_DATA[1]}] \
[get_ports {EXT_MEM_DATA[0]}]]
