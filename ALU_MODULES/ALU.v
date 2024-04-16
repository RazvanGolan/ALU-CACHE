module ALU (
    input signed[15:0] operandA,
    input signed[15:0] operandB,
    input [3:0] opcode, // Control signals for selecting operation
    input reset,
    input clk,
    output reg signed[31:0] result
);

// Adder
wire signed[15:0] add_result;

// Instantiate RippleCarry16Bit module for addition
ripple_carry_16_bit adder_inst (
    .a(operandA),
    .b(operandB),
    .cin(1'b0), // Set carry-in based on opcode (0 for addition, 1 for subtraction)
    .sum(add_result),
    .cout()
);

// Subtraction
wire signed[15:0] sub_result;

// Instantiate RippleCarry16Bit module for subtraction
substractor_16_bit subtractor_inst (
    .a(operandA),
    .b(operandB), // Two's complement of operandB + carry-in
    .cin(1'b1), // Set carry-in based on opcode (0 for addition, 1 for subtraction)
    .sum(sub_result)
);

// Increment
wire signed[15:0] increment;

// Instantiate RippleCarryAdder module for Increment
ripple_carry_16_bit increment_inst (
    .a(operandA),
    .b({15'b0, 1'b1}),
    .cin(1'b0),
    .sum(increment),
    .cout()
);

// Decrement
wire signed[15:0] decrement;

// Instantiate RippleCarryAdder module for Decrement
substractor_16_bit decrement_inst (
    .a(operandA),
    .b(16'b1), 
    .cin(),
    .sum(decrement)
);


// Multiplier
wire signed[31:0] mult_result; // Considering 32x32 multiplication

ArrayMultiplier multiplie_inst(
    .a(operandA),
    .b(operandB),
    .result(mult_result)
);

// Division
wire [15:0] div_result, rest;

non_restoring_div division_inst(
    .a(operandA),
    .b(operandB),
    .result(div_result),
    .rest(rest)
);

// Logical left shift
wire signed[15:0] lls_result;

logical_left_shift lls_inst(
    .a(operandA),
    .b(operandB),
    .result(lls_result)
);

// Logical right shift
wire signed[15:0] lrs_result;

logical_right_shift lrs_inst(
    .a(operandA),
    .b(operandB),
    .result(lrs_result)
);

// Bitwise AND 
wire signed[15:0] and_result;

bitwise_and and_inst(
    .a(operandA),
    .b(operandB),
    .c(and_result)
);

// Bitwise OR
wire signed[15:0] or_result;

bitwise_or or_inst(
    .a(operandA),
    .b(operandB),
    .c(or_result)
);

// Bitwise XOR
wire signed[15:0] xor_result;

bitwise_xor xor_inst(
    .a(operandA),
    .b(operandB),
    .c(xor_result)
);


// Control unit
always @(posedge clk or posedge reset) begin
    if (reset) begin
        result <= 0;
    end
    else begin
        case(opcode)
            4'b0000: begin // Add
                result <= add_result;
            end
            4'b0001: begin // Substract
                result <= sub_result;
            end
            4'b0010: begin // Multiply
                result <= mult_result; 
            end
            4'b0011: begin // Division
                result <= div_result; 
            end
            4'b0100: begin // AND
                result <= and_result;
            end
            4'b0101: begin // OR
                result <= or_result;
            end
            4'b0110: begin // XOR
                result <= xor_result;
            end
            4'b0111: begin // LLS
                result <= lls_result;
            end
            4'b1000: begin // LRS
                result <= lrs_result;
            end
            4'b1001: begin // Increment
                result <= increment;
            end
            4'b1010: begin // Decrement
                result <= decrement;
            end
            default: result <= 0; // Default behavior
        endcase
    end
end

endmodule
