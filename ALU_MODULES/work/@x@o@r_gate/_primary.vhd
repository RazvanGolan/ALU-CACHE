library verilog;
use verilog.vl_types.all;
entity XOR_gate is
    port(
        a               : in     vl_logic;
        b               : in     vl_logic;
        c               : out    vl_logic
    );
end XOR_gate;
