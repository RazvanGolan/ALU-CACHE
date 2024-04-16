library verilog;
use verilog.vl_types.all;
entity substractor_16_bit is
    port(
        a               : in     vl_logic_vector(15 downto 0);
        b               : in     vl_logic_vector(15 downto 0);
        cin             : in     vl_logic;
        sum             : out    vl_logic_vector(15 downto 0)
    );
end substractor_16_bit;
