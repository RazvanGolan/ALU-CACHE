library verilog;
use verilog.vl_types.all;
entity ALU is
    port(
        operandA        : in     vl_logic_vector(15 downto 0);
        operandB        : in     vl_logic_vector(15 downto 0);
        opcode          : in     vl_logic_vector(3 downto 0);
        reset           : in     vl_logic;
        clk             : in     vl_logic;
        result          : out    vl_logic_vector(31 downto 0)
    );
end ALU;
