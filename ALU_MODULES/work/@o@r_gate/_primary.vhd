library verilog;
use verilog.vl_types.all;
entity OR_gate is
    port(
        a               : in     vl_logic;
        b               : in     vl_logic;
        c               : out    vl_logic
    );
end OR_gate;
