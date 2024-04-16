module substractor_16_bit(
    input signed[15:0] a,b,
    input cin,
    output signed[15:0] sum
);

wire signed [15:0] not_b, result;
reg signed [15:0] not_b_reg;
bitwise_not negation(.a(b), .b(not_b));

ripple_carry_16_bit subtractor_inst (
    .a(a),
    .b(not_b_reg), // Bitwise negation of b
    .cin(1'b1), // Set carry-in for C2 trasnformation
    .sum(result),
    .cout()
);

always @* begin
    not_b_reg = not_b;
end

assign sum = result;

endmodule

