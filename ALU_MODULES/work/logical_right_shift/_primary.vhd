library verilog;
use verilog.vl_types.all;
entity logical_right_shift is
    port(
        a               : in     vl_logic_vector(15 downto 0);
        b               : in     vl_logic_vector(15 downto 0);
        result          : out    vl_logic_vector(15 downto 0)
    );
end logical_right_shift;
