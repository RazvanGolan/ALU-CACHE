module RippleCarryAdder (
    input [15:0] operandA,
    input [15:0] operandB,
    output reg [15:0] result
);

    reg [15:0] carry; // Carry bits

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : ripple_adders
            FullAdderCell adder_inst (
                .operandA(operandA[i]),
                .operandB(operandB[i]),
                .carryIn(carry[i]),
                .sum(result[i]),
                .carryOut(carry[i+1])
            );
        end
    endgenerate

endmodule

module FullAdderCell (
    input operandA,
    input operandB,
    input carryIn,
    output reg sum,
    output reg carryOut
);

    always @* begin
        sum = operandA ^ operandB ^ carryIn;
        carryOut = (operandA & operandB) | (operandA & carryIn) | (operandB & carryIn);
    end

endmodule



module ALU (
    input [15:0] operandA,
    input [15:0] operandB,
    input [3:0] opcode, // Control signals for selecting operation
    input reset,
    input clk,
    output reg [31:0] result
);

// Registers
reg [15:0] regA;
reg [15:0] regB;

// Adder
wire [15:0] add_result;

// Instantiate RippleCarryAdder module for addition
RippleCarryAdder adder_inst (
    .operandA(operandA),
    .operandB(operandB),
    .result(add_result)
);

// Substraction
wire [15:0] sub_result;

// Instantiate RippleCarryAdder module for substraction
RippleCarryAdder substractor_adder_inst (
    .operandA(operandA),
    .operandB(~operandB + 1'b1),
    .result(sub_result)
);

// Increment
wire [15:0] increment;

// Instantiate RippleCarryAdder module for Increment
RippleCarryAdder increment_adder_inst (
    .operandA(operandA),
    .operandB(1'b1),
    .result(increment)
);

// Decrement
wire [15:0] decrement;

// Instantiate RippleCarryAdder module for Decrement
RippleCarryAdder decrement_adder_inst (
    .operandA(operandA),
    .operandB(16'b1111_1111_1111_1111), // minus 1 in two's complement on 16 bits
    .result(sub_result)
);


// Multiplier
reg [31:0] mult_result; // Considering 32x32 multiplication

// Division
reg [15:0] div_result;

// Mux
reg [31:0] mux_output;

// Control unit
always @(posedge clk or posedge reset) begin
    if (reset) begin
        regA <= 0;
        regB <= 0;
        result <= 0;
    end
    else begin
        case(opcode)
            // 4'b0000: begin // Load operands
            //     regA <= operandA;
            //     regB <= operandB;
            // end
            4'b0001: begin // Add
                mux_output <= {16'b0, add_result};
            end
            4'b0010: begin // Substract
                mux_output <= {16'b0, sub_result};
            end
            4'b0011: begin // Multiply
                mult_result <= regA * regB;
                mux_output <= mult_result[31:0]; // Considering only lower 32 bits of the result
            end
            4'b0100: begin // Division
                div_result <= regA / regB;
                mux_output <= div_result[15:0]; 
            end
            4'b0101: begin // AND
                mux_output <= regA & regB;
            end
            4'b0110: begin // OR
                mux_output <= regA | regB;
            end
            4'b0111: begin // XOR
                mux_output <= regA ^ regB;
            end
            4'b1000: begin // LLS
                mux_output <= regA << regB;
            end
            4'b1001: begin // LRS
                mux_output <= regA >> regB;
            end
            4'b1010: begin // Increment
                mux_output <= increment;
            end
            4'b1011: begin // Decrement
                mux_output <= decrement;
            end
            default: mux_output <= 0; // Default behavior
        endcase
        // Mux for selecting between adder and multiplier output
        case(opcode)
            4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b0101, 4'b0110, 4'b0111, 4'b1000, 4'b1001, 4'b1010, 4'b1011 : result <= mux_output;
            default: result <= 0;
        endcase
    end
end

endmodule

module ALU_tb;

    // Parameters
    parameter CLK_PERIOD = 10; // Clock period in ns

    // Signals
    reg [15:0] regA;
    reg [15:0] regB;
    reg [3:0] opcode;
    reg reset;
    reg clk;

    wire [31:0] result;
    
    reg [3:0] flag = 0;

    // Instantiate ALU module
    ALU alu (
        .operandA(regA),
        .operandB(regB),
        .opcode(opcode),
        .reset(reset),
        .clk(clk),
        .result(result)
    );

    // Clock generation
    always #((CLK_PERIOD / 2)) clk = ~clk;

    // Testbench
    initial begin
        // Initialize inputs
        regA = 10;
        regB = 5;
        // opcode = 4'b0000; // Load operands
        reset = 1;
        #20; // Wait for 20 time units
        reset = 0;

        // Test case 1: Addition
        opcode = 4'b0001; // Add
        #10;
        if (result !== (regA + regB)) begin
            $display("Addition test failed");
            flag ++;
        end else begin
            $display("Addition test passed");
        end

        // Test case 2: Subtraction
        regA = 15;
        regB = 7;
        opcode = 4'b0010; // Subtract
        #10;
        if (result !== (regA - regB)) begin
            $display("Subtraction test failed");
            flag ++;
        end else begin
            $display("Subtraction test passed");
        end

        // Test case 3: Multiplication
        regA = 10;
        regB = 3;
        opcode = 4'b0011; // Multiply
        #10;
        if (result !== (regA * regB)) begin
            $display("Multiplication test failed");
            flag ++;
        end else begin
            $display("Multiplication test passed");
        end

        // Test case 4: Division
        regA = 25;
        regB = 5;
        opcode = 4'b0100; // Division
        #10;
        if (result !== (regA / regB)) begin
            $display("Division test failed");
            flag ++;
        end else begin
            $display("Division test passed");
        end

        // Test case 5: Bitwise AND
        regA = 15;
        regB = 10;
        opcode = 4'b0101; // AND
        #10;
        if (result !== (regA & regB)) begin
            $display("Bitwise AND test failed");
            flag ++;
        end else begin
            $display("Bitwise AND test passed");
        end

        // Test case 6: Bitwise OR
        regA = 120;
        regB = 224;
        opcode = 4'b0110; // OR
        #10;
        if (result !== (regA | regB)) begin
            $display("Bitwise OR test failed");
            flag ++;
        end else begin
            $display("Bitwise OR test passed");
        end

        // Test case 7: Bitwise XOR
        regA = 134;
        regB = 8;
        opcode = 4'b0111; // XOR
        #10;
        if (result !== (regA ^ regB)) begin
            $display("Bitwise XOR test failed");
            flag ++;
        end else begin
            $display("Bitwise XOR test passed");
        end
        
        // Test case 8: Logical Left Shift
        regA = 134;
        regB = 8;
        opcode = 4'b1000; // LLS
        #10;
        if (result !== (regA << regB)) begin
            $display("LLS test failed");
            flag ++;
        end else begin
            $display("LLS test passed");
        end
        
        // Test case 9: Logical Right Shift
        regA = 134;
        regB = 8;
        opcode = 4'b1001; // LRS
        #10;
        if (result !== (regA >> regB)) begin
            $display("LRS test failed");
            flag ++;
        end else begin
            $display("LRS test passed");
        end
        
        // Test case 10: Increment
        regA = 45;
        opcode = 4'b1010; // Increment
        #10;
        if (result !== (regA + 1)) begin
            $display("Increment test failed");
            flag ++;
        end else begin
            $display("Increment test passed");
        end
        
        // Test case 11: Decrement
        regA = 27;
        opcode = 4'b1011; // Decrement
        #10;
        if (result !== (regA - 1)) begin
            $display("Decrement test failed");
            flag ++;
        end else begin
            $display("Decrement test passed");
        end
        
        // End simulation
        if(flag === 11) begin
            $display("All tests passed");
        end else begin
            $display("Not all the tests passed");
        end
        $finish;
    end

endmodule


module main;
  initial 
    begin
      $display("Hello, World");
      $finish ;
    end
endmodule