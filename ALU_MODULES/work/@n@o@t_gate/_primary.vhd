library verilog;
use verilog.vl_types.all;
entity NOT_gate is
    port(
        a               : in     vl_logic;
        b               : out    vl_logic
    );
end NOT_gate;
