module ripple_carry_16_bit(a, b, cin,sum, cout);
input [15:0] a,b;
input cin;
output [15:0] sum;
output cout;
wire c1,c2,c3;

ripple_carry_4_bit rca1 (
.a(a[3:0]),
.b(b[3:0]),
.cin(cin), 
.sum(sum[3:0]),
.cout(c1));

ripple_carry_4_bit rca2(
.a(a[7:4]),
.b(b[7:4]),
.cin(c1),
.sum(sum[7:4]),
.cout(c2));

ripple_carry_4_bit rca3(
.a(a[11:8]),
.b(b[11:8]),
.cin(c2),
.sum(sum[11:8]),
.cout(c3));

ripple_carry_4_bit rca4(
.a(a[15:12]),
.b(b[15:12]),
.cin(c3),
.sum(sum[15:12]),
.cout(cout));
endmodule

////////////////////////////////////
//4-bit Ripple Carry Adder
////////////////////////////////////

module ripple_carry_4_bit(a, b, cin, sum, cout);
input [3:0] a,b;
input cin;
wire c1,c2,c3;
output [3:0] sum;
output cout;

full_adder fa0(.a(a[0]), .b(b[0]),.cin(cin), .sum(sum[0]),.cout(c1));
full_adder fa1(.a(a[1]), .b(b[1]), .cin(c1), .sum(sum[1]),.cout(c2));
full_adder fa2(.a(a[2]), .b(b[2]), .cin(c2), .sum(sum[2]),.cout(c3));
full_adder fa3(.a(a[3]), .b(b[3]), .cin(c3), .sum(sum[3]),.cout(cout));
endmodule

//////////////////////////////
//1bit Full Adder
/////////////////////////////
module full_adder(a,b,cin,sum, cout);
input a,b,cin;
output sum, cout;
wire x,y,z;
half_adder h1(.a(a), .b(b), .sum(x), .cout(y));
half_adder h2(.a(x), .b(cin), .sum(sum), .cout(z));
or or_1(cout,z,y);
endmodule

///////////////////////////
// 1 bit Half Adder
//////////////////////////
module half_adder( a,b, sum, cout );
input a,b;
output sum, cout;
xor xor_1 (sum,a,b);
and and_1 (cout,a,b);
endmodule

module ALU (
    input [15:0] operandA,
    input [15:0] operandB,
    input [3:0] opcode, // Control signals for selecting operation
    input reset,
    input clk,
    output reg [31:0] result
);

// Adder
wire [15:0] add_result;

// Instantiate RippleCarry16Bit module for addition
ripple_carry_16_bit adder_inst (
    .a(operandA),
    .b(operandB),
    .cin(1'b0), // Set carry-in based on opcode (0 for addition, 1 for subtraction)
    .sum(add_result),
    .cout()
);

// Subtraction
wire [15:0] sub_result;

// Instantiate RippleCarry16Bit module for subtraction
ripple_carry_16_bit subtractor_inst (
    .a(operandA),
    .b(~operandB + opcode[0]), // Two's complement of operandB + carry-in
    .cin(1'b0), // Set carry-in based on opcode (0 for addition, 1 for subtraction)
    .sum(sub_result),
    .cout()
);

// Increment
wire [15:0] increment;

// Instantiate RippleCarryAdder module for Increment
ripple_carry_16_bit increment_inst (
    .a(operandA),
    .b({15'b0, 1'b1}),
    .cin(1'b0),
    .sum(increment),
    .cout()
);

// Decrement
wire [15:0] decrement;

// Instantiate RippleCarryAdder module for Decrement
ripple_carry_16_bit decrement_inst (
    .a(operandA),
    .b(16'b1111_1111_1111_1111), // minus 1 in two's complement on 16 bits
    .cin(1'b0),
    .sum(decrement),
    .cout()
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
        result <= 0;
    end
    else begin
        case(opcode)
            4'b0000: begin // Add
                result = add_result;
            end
            4'b0001: begin // Substract
                result = sub_result;
            end
            4'b0010: begin // Multiply
                mult_result <= operandA * operandB;
                result <= mult_result[31:0]; // Considering only lower 32 bits of the result
            end
            4'b0011: begin // Division
                div_result <= operandA / operandB;
                result <= div_result[15:0]; 
            end
            4'b0100: begin // AND
                result <= operandA & operandB;
            end
            4'b0101: begin // OR
                result <= operandA | operandB;
            end
            4'b0110: begin // XOR
                result <= operandA ^ operandB;
            end
            4'b0111: begin // LLS
                result <= operandA << operandB;
            end
            4'b1000: begin // LRS
                result <= operandA >> operandB;
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

module ALU_tb;

    // Parameters
    parameter CLK_PERIOD = 100; // Clock period in ns

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
        clk = 0;
        reset = 1;
        #20; // Wait for 20 time units
        reset = 0;

        // Test case 1: Addition
        opcode = 4'b0000; // Add
        #50;
        if (result !== (regA + regB)) begin
            $display("Addition test failed", result);
        end else begin
            $display("Addition test passed");
            flag ++;
        end
        #50;
        
        // Test case 2: Subtraction
        regA = 15;
        regB = 7;
        opcode = 4'b0001; // Subtract
        #50;
        if (result !== (regA - regB)) begin
            $display("Subtraction test failed");
        end else begin
            $display("Subtraction test passed");
            flag ++;
        end
        #50;
        
        // Test case 3: Multiplication
        regA = 10;
        regB = 3;
        opcode = 4'b0010; // Multiply
        #50;
        if (result !== (regA * regB)) begin
            $display("Multiplication test failed");
        end else begin
            $display("Multiplication test passed");
            flag ++;
        end
        #50;
        
        // Test case 4: Division
        regA = 25;
        regB = 5;
        opcode = 4'b0011; // Division
        #50;
        if (result !== (regA / regB)) begin
            $display("Division test failed");
        end else begin
            $display("Division test passed");
            flag ++;
        end
        #50;
        
        // Test case 5: Bitwise AND
        regA = 15;
        regB = 10;
        opcode = 4'b0100; // AND
        #50;
        if (result !== (regA & regB)) begin
            $display("Bitwise AND test failed");
        end else begin
            $display("Bitwise AND test passed");
            flag ++;
        end
        #50;
        
        // Test case 6: Bitwise OR
        regA = 120;
        regB = 224;
        opcode = 4'b0101; // OR
        #50;
        if (result !== (regA | regB)) begin
            $display("Bitwise OR test failed");
        end else begin
            $display("Bitwise OR test passed");
            flag ++;
        end
        #50;
        
        // Test case 7: Bitwise XOR
        regA = 134;
        regB = 8;
        opcode = 4'b0110; // XOR
        #50;
        if (result !== (regA ^ regB)) begin
            $display("Bitwise XOR test failed");
        end else begin
            $display("Bitwise XOR test passed");
            flag ++;
        end
        #50;
        
        // Test case 8: Logical Left Shift
        regA = 134;
        regB = 8;
        opcode = 4'b0111; // LLS
        #50;
        if (result !== (regA << regB)) begin
            $display("LLS test failed");
        end else begin
            $display("LLS test passed");
            flag ++;
        end
        #50;
        
        // Test case 9: Logical Right Shift
        regA = 134;
        regB = 8;
        opcode = 4'b1000; // LRS
        #50;
        if (result !== (regA >> regB)) begin
            $display("LRS test failed");
        end else begin
            $display("LRS test passed");
            flag ++;
        end
        #50;
        
        // Test case 10: Increment
        regA = 45;
        opcode = 4'b1001; // Increment
        #50;
        if (result !== (regA + 1)) begin
            $display("Increment test failed");
        end else begin
            $display("Increment test passed");
            flag ++;
        end
        #50;
        
        // Test case 11: Decrement
        regA = 27;
        opcode = 4'b1010; // Decrement
        #50;
        if (result !== (regA - 1)) begin
            $display("Decrement test failed");
        end else begin
            $display("Decrement test passed");
            flag ++;
        end
        #50;
        
        // End simulation
        if(flag === 11) begin
            $display("All tests passed");
        end else begin
            $display("Not all the tests passed");
        end
        $finish;
    end

endmodule