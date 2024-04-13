library verilog;
use verilog.vl_types.all;
entity bitwise_not is
    port(
        a               : in     vl_logic_vector(15 downto 0);
        b               : out    vl_logic_vector(15 downto 0)
    );
end bitwise_not;
