library verilog;
use verilog.vl_types.all;
entity non_restoring_div is
    port(
        a               : in     vl_logic_vector(15 downto 0);
        b               : in     vl_logic_vector(15 downto 0);
        result          : out    vl_logic_vector(15 downto 0);
        rest            : out    vl_logic_vector(15 downto 0)
    );
end non_restoring_div;
