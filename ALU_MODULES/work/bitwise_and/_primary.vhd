library verilog;
use verilog.vl_types.all;
entity bitwise_and is
    port(
        a               : in     vl_logic_vector(15 downto 0);
        b               : in     vl_logic_vector(15 downto 0);
        c               : out    vl_logic_vector(15 downto 0)
    );
end bitwise_and;
