
module non_restoring_div(
    input [15:0] a, b, 
    output reg [15:0] result, rest
);

    wire [15:0] shift_result, sum_result, negation_result, shift_result2;
    reg [15:0] a1, b1, s, a_not, s2;
    reg a_or, b_or;
    reg [15:0] a_or2,b_or2;
    wire or_result;
    wire [15:0] or_result2;

    reg [15:0] p, ac, temp;
    integer i;

    ripple_carry_16_bit rca16(
        .a(a1), 
        .b(b1),
        .cin(),
        .sum(sum_result),
        .cout()
    );

    logical_left_shift lls(
        .a(s),
        .b(16'b1),
        .result(shift_result)
    );

    logical_left_shift lls2(
        .a(s2),
        .b(16'b1),
        .result(shift_result2)
    );

    OR_gate or_gate(
        .a(a_or),
        .b(b_or),
        .c(or_result)
    );

    bitwise_or or_gate2(
        .a(a_or2),
        .b(b_or2),
        .c(or_result2)
    );

    bitwise_not negation(
        .a(a_not),
        .b(negation_result)
    );

    always @(*) begin
        ac = a;
        p = 0;
        result = 0;
        rest = 0;

        for (i = 0; i < 16; i = i + 1) begin
            // Shift Left carrying a's MSB into p's LSB
             s2 = p; #1;
             p = shift_result2  | (ac[15]); 
            //$display("Data to display: %d", p);

            //a_or2 = ac[15];#1
           // b_or2 = shift_result2; #1;
            //p = or_result2;


             ac = ac << 1;
            //s = ac; #1;
           // ac = shift_result;

            // Check the old value of p
            if (p[15]) // if p is negative
                temp = b; // add divisor
            else begin
                temp = ~b + 1; // subtract divisor
            end
            // this will do the appropriate add or subtract
            // depending on the value of temp
            p = p + temp;
            // a1 = p;
            // b1 = temp;
            // #5;
            // p = sum_result;

            // Check the new value of p
            if (p[15]) begin// if p is negative
                // ac = ac | 0; // no change to quotient
                b_or = 0;
            end
            else begin
                // ac = ac | 1; 
                a_or = ac[0];
                b_or = 1;
                #1;
                ac[0] = or_result; 
            end
        end

        // Correction is needed if remainder is negative
        if (p[15]) begin // if p is negative
            // p = p + b;
            a1 = p;
            b1 = b;
            #1;
            p = sum_result;
        end

        result = ac;
        rest = p;
    end
endmodule