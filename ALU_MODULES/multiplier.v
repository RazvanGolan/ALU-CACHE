module ArrayMultiplier (
    input signed[15:0] a,
    input signed[15:0] b,
    output reg signed[31:0] result
);

wire signed[31:0] shift_result, sum_result;
reg signed[31:0] a1, b1;
reg signed[31:0] s, j;

ripple_carry_32_bit rca32 (
    .a(a1), 
    .b(b1),
    .cin(),
    .sum(sum_result),
    .cout()
);

logical_left_shift_32_bit lls (
    .a(s),
    .b(j),
    .result(shift_result)
);

integer i;

always @* begin
result = 0;
    for(i=0; i<16; i = i+1) begin
        if(b[i] == 1'b1) begin
            // result = result + (a << i); asta facem cu porti
            s = a; // aici il shiftez pe a cu i pozitii
            j = i;
            #1;
            a1 = shift_result; // adun in result pe result + (a << i)
            b1 = result;
            #1;
            result = sum_result;
        end
    end
end


endmodule
