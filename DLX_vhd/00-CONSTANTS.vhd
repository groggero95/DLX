library ieee;
use ieee.std_logic_1164.all;

package const is
    
-- Constants used to define the bit number and address size
    constant NB : integer := 32;
    constant AS : integer := 5;



-- Type used in the fsm inside the control unit
    type TYPE_STATE is (
                            reset,
                            fetch,
                            stall_if
    );

-- Control unit input sizes
	constant CW_SIZE   : integer :=  23;
    constant OP_SIZE   : integer :=  6;                                              -- OPCODE field size
    constant F_SIZE    : integer :=  11;                                             -- FUNC field size

-- R-Type instruction -> FUNC field
    constant RTYPE_SLL  : std_logic_vector(F_SIZE - 1 downto 0) :=  "00000000100";    -- SLL RD,RS,RT
    constant RTYPE_SRL  : std_logic_vector(F_SIZE - 1 downto 0) :=  "00000000110";    -- SRL RD,RS,RT
    constant RTYPE_SRA  : std_logic_vector(F_SIZE - 1 downto 0) :=  "00000000111";    -- SRA RD,RS,RT
    constant RTYPE_ADD  : std_logic_vector(F_SIZE - 1 downto 0) :=  "00000100000";    -- ADD RD,RS,RT
    constant RTYPE_ADDU : std_logic_vector(F_SIZE - 1 downto 0) :=  "00000100001";    -- ADDU RD,RS,RT
    constant RTYPE_SUB  : std_logic_vector(F_SIZE - 1 downto 0) :=  "00000100010";    -- SUB RD,RS,RT
    constant RTYPE_SUBU : std_logic_vector(F_SIZE - 1 downto 0) :=  "00000100011";    -- SUBU RD,RS,RT
    constant RTYPE_AND  : std_logic_vector(F_SIZE - 1 downto 0) :=  "00000100100";    -- AND RD,RS,RT
    constant RTYPE_OR   : std_logic_vector(F_SIZE - 1 downto 0) :=  "00000100101";    -- OR RD,RS,RT
    constant RTYPE_XOR  : std_logic_vector(F_SIZE - 1 downto 0) :=  "00000100110";    -- XOR RD,RS,RT
    constant RTYPE_SEQ  : std_logic_vector(F_SIZE - 1 downto 0) :=  "00000101000";    -- SEQ RD,RS,RT
    constant RTYPE_SNE  : std_logic_vector(F_SIZE - 1 downto 0) :=  "00000101001";    -- SNE RD,RS,RT
    constant RTYPE_SLT  : std_logic_vector(F_SIZE - 1 downto 0) :=  "00000101010";    -- SLT RD,RS,RT
    constant RTYPE_SGT  : std_logic_vector(F_SIZE - 1 downto 0) :=  "00000101011";    -- SGT RD,RS,RT
    constant RTYPE_SLE  : std_logic_vector(F_SIZE - 1 downto 0) :=  "00000101100";    -- SLE RD,RS,RT
    constant RTYPE_SGE  : std_logic_vector(F_SIZE - 1 downto 0) :=  "00000101101";    -- SGE RD,RS,RT    

-- TODO add only if we add floating point 
    constant RTYPE_MOVI2S   : std_logic_vector(F_SIZE - 1 downto 0) :=  "00000110000";    -- MOVI2S RD,RS,RT
    constant RTYPE_MOVS2I   : std_logic_vector(F_SIZE - 1 downto 0) :=  "00000110001";    -- MOVS2I RD,RS,RT
    constant RTYPE_MOVF     : std_logic_vector(F_SIZE - 1 downto 0) :=  "00000110010";    -- MOVF RD,RS,RT
    constant RTYPE_MOVD     : std_logic_vector(F_SIZE - 1 downto 0) :=  "00000110011";    -- MOVD RD,RS,RT
    constant RTYPE_MOVFP2I  : std_logic_vector(F_SIZE - 1 downto 0) :=  "00000110100";    -- MOVFP2I RD,RS,RT
    constant RTYPE_MOVI2FP  : std_logic_vector(F_SIZE - 1 downto 0) :=  "00000110101";    -- MOVI2FP RD,RS,RT
    constant RTYPE_MOVI2T   : std_logic_vector(F_SIZE - 1 downto 0) :=  "00000110110";    -- MOVI2T RD,RS,RT
    constant RTYPE_MOVT2I   : std_logic_vector(F_SIZE - 1 downto 0) :=  "00000110111";    -- MOVT2I RD,RS,RT


    constant RTYPE_SLTU : std_logic_vector(F_SIZE - 1 downto 0) :=  "00000111010";    -- SLTU RD,RS,RT
    constant RTYPE_SGTU : std_logic_vector(F_SIZE - 1 downto 0) :=  "00000111011";    -- SGTU RD,RS,RT
    constant RTYPE_SLEU : std_logic_vector(F_SIZE - 1 downto 0) :=  "00000111100";    -- SLEU RD,RS,RT
    constant RTYPE_SGEU : std_logic_vector(F_SIZE - 1 downto 0) :=  "00000111101";    -- SGEU RD,RS,RT


-- R-Type instruction -> OPCODE field
    constant RTYPE 	   : std_logic_vector(OP_SIZE - 1 downto 0) :=  "000000";          -- for ADD, SUB, AND, OR register-to-register operation

-- I-Type instruction -> OPCODE field
    constant ITYPE_J     : std_logic_vector(OP_SIZE - 1 downto 0) :=  "000010";    -- ADDI1 RS1,RD,INP1
    constant ITYPE_JAL   : std_logic_vector(OP_SIZE - 1 downto 0) :=  "000011";    -- ADDI1 RS1,RD,INP1
    constant ITYPE_BEQZ  : std_logic_vector(OP_SIZE - 1 downto 0) :=  "000100";    -- ADDI1 RS1,RD,INP1
    constant ITYPE_BNEZ  : std_logic_vector(OP_SIZE - 1 downto 0) :=  "000101";    -- ADDI1 RS1,RD,INP1

-- TODO some floating stuff add only if we do fp_unit
    constant ITYPE_BFPT  : std_logic_vector(OP_SIZE - 1 downto 0) :=  "000110";    -- ADDI1 RS1,RD,INP1
    constant ITYPE_BFPF  : std_logic_vector(OP_SIZE - 1 downto 0) :=  "000111";    -- ADDI1 RS1,RD,INP1

    constant ITYPE_ADDI  : std_logic_vector(OP_SIZE - 1 downto 0) :=  "001000";    -- ADDI1 RS1,RD,INP1
    constant ITYPE_ADDUI : std_logic_vector(OP_SIZE - 1 downto 0) :=  "001001";    -- ADDI1 RS1,RD,INP1
    constant ITYPE_SUBI  : std_logic_vector(OP_SIZE - 1 downto 0) :=  "001010";    -- ADDI1 RS1,RD,INP1
    constant ITYPE_SUBUI : std_logic_vector(OP_SIZE - 1 downto 0) :=  "001011";    -- ADDI1 RS1,RD,INP1
    constant ITYPE_ANDI  : std_logic_vector(OP_SIZE - 1 downto 0) :=  "001100";    -- ADDI1 RS1,RD,INP1
    constant ITYPE_ORI   : std_logic_vector(OP_SIZE - 1 downto 0) :=  "001101";    -- ADDI1 RS1,RD,INP1
    constant ITYPE_XORI  : std_logic_vector(OP_SIZE - 1 downto 0) :=  "001110";    -- ADDI1 RS1,RD,INP1
    constant ITYPE_LHI   : std_logic_vector(OP_SIZE - 1 downto 0) :=  "001111";    -- ADDI1 RS1,RD,INP1
    constant ITYPE_RFE   : std_logic_vector(OP_SIZE - 1 downto 0) :=  "010000";    -- ADDI1 RS1,RD,INP1
    constant ITYPE_TRAP  : std_logic_vector(OP_SIZE - 1 downto 0) :=  "010001";    -- ADDI1 RS1,RD,INP1
    constant ITYPE_JR    : std_logic_vector(OP_SIZE - 1 downto 0) :=  "010010";    -- ADDI1 RS1,RD,INP1
    constant ITYPE_JALR  : std_logic_vector(OP_SIZE - 1 downto 0) :=  "010011";    -- ADDI1 RS1,RD,INP1
    constant ITYPE_SLLI  : std_logic_vector(OP_SIZE - 1 downto 0) :=  "010100";    -- ADDI1 RS1,RD,INP1
    constant ITYPE_NOP   : std_logic_vector(OP_SIZE - 1 downto 0) :=  "010101";    -- ADDI1 RS1,RD,INP1
    constant ITYPE_SRLI  : std_logic_vector(OP_SIZE - 1 downto 0) :=  "010110";    -- ADDI1 RS1,RD,INP1
    constant ITYPE_SRAI  : std_logic_vector(OP_SIZE - 1 downto 0) :=  "010111";    -- ADDI1 RS1,RD,INP1

-- COMPARE TYPE
    constant ITYPE_SEQI  : std_logic_vector(OP_SIZE - 1 downto 0) :=  "011000";    -- ADDI1 RS1,RD,INP1
    constant ITYPE_SNEI  : std_logic_vector(OP_SIZE - 1 downto 0) :=  "011001";    -- ADDI1 RS1,RD,INP1
    constant ITYPE_SLTI  : std_logic_vector(OP_SIZE - 1 downto 0) :=  "011010";    -- ADDI1 RS1,RD,INP1
    constant ITYPE_SGTI  : std_logic_vector(OP_SIZE - 1 downto 0) :=  "011011";    -- ADDI1 RS1,RD,INP1
    constant ITYPE_SLEI  : std_logic_vector(OP_SIZE - 1 downto 0) :=  "011100";    -- ADDI1 RS1,RD,INP1
    constant ITYPE_SGEI  : std_logic_vector(OP_SIZE - 1 downto 0) :=  "011101";    -- ADDI1 RS1,RD,INP1

-- LOAD TYPE
    constant ITYPE_LB    : std_logic_vector(OP_SIZE - 1 downto 0) :=  "100000";    -- ADDI1 RS1,RD,INP1
    constant ITYPE_LH    : std_logic_vector(OP_SIZE - 1 downto 0) :=  "100001";    -- ADDI1 RS1,RD,INP1
    constant ITYPE_LW    : std_logic_vector(OP_SIZE - 1 downto 0) :=  "100011";    -- ADDI1 RS1,RD,INP1
    constant ITYPE_LBU   : std_logic_vector(OP_SIZE - 1 downto 0) :=  "100100";    -- ADDI1 RS1,RD,INP1
    constant ITYPE_LHU   : std_logic_vector(OP_SIZE - 1 downto 0) :=  "100101";    -- ADDI1 RS1,RD,INP1
    constant ITYPE_LF    : std_logic_vector(OP_SIZE - 1 downto 0) :=  "100110";    -- ADDI1 RS1,RD,INP1
    constant ITYPE_LD    : std_logic_vector(OP_SIZE - 1 downto 0) :=  "100111";    -- ADDI1 RS1,RD,INP1
    constant ITYPE_SB    : std_logic_vector(OP_SIZE - 1 downto 0) :=  "101000";    -- ADDI1 RS1,RD,INP1
    constant ITYPE_SH    : std_logic_vector(OP_SIZE - 1 downto 0) :=  "101001";    -- ADDI1 RS1,RD,INP1
    constant ITYPE_SW    : std_logic_vector(OP_SIZE - 1 downto 0) :=  "101011";    -- ADDI1 RS1,RD,INP1
    constant ITYPE_SF    : std_logic_vector(OP_SIZE - 1 downto 0) :=  "101110";    -- ADDI1 RS1,RD,INP1
    constant ITYPE_SD    : std_logic_vector(OP_SIZE - 1 downto 0) :=  "101111";    -- ADDI1 RS1,RD,INP1

    constant ITYPE_SLTUI : std_logic_vector(OP_SIZE - 1 downto 0) :=  "111010";    -- ADDI1 RS1,RD,INP1
    constant ITYPE_SGTUI : std_logic_vector(OP_SIZE - 1 downto 0) :=  "111011";    -- ADDI1 RS1,RD,INP1
    constant ITYPE_SLEUI : std_logic_vector(OP_SIZE - 1 downto 0) :=  "111100";    -- ADDI1 RS1,RD,INP1
    constant ITYPE_SGEUI : std_logic_vector(OP_SIZE - 1 downto 0) :=  "111101";    -- ADDI1 RS1,RD,INP1

    constant ADD_ZERO : std_logic_vector(4 downto 0) := "00000";

end const;

