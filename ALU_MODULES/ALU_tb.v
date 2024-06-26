module ALU_tb;

    // Parameters
    parameter CLK_PERIOD = 100; // Clock period in ns

    // Signals
    reg signed[15:0] regA;
    reg signed[15:0] regB;
    reg signed[15:0] regC;
    reg signed[31:0] regM;
    reg [3:0] opcode;
    reg reset;
    reg clk;

    wire signed[31:0] result;
    
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
        regA = -10;
        regB = -11;
        clk = 0;
        reset = 1;
        #20; // Wait for 20 time units
        reset = 0;

        // Test case 1: Addition
        opcode = 4'b0000; // Add
        #50;
        regC = regA + regB;
        if (result !== regC) begin
            $display("Addition test failed", result, regC);
        end else begin
            $display("Addition test passed");
            flag =flag+1;
        end
        #50;
        
        // Test case 2: Subtraction
        regA = -15;
        regB = 7;
        opcode = 4'b0001; // Subtract
        #50;
        regC = regA - regB;
        if (result !== regC) begin
            $display("Subtraction test failed", result, regC);
        end else begin
            $display("Subtraction test passed");
            flag =flag+1;
        end
        #50;
        
        // Test case 3: Multiplication
        regA = 10;
        regB = 3;
        opcode = 4'b0010; // Multiply
        #50;
        regM = regA * regB;
        if (result !== regM) begin
            $display("Multiplication test failed", result, regM);
        end else begin
            $display("Multiplication test passed");
            flag =flag+1;
        end
        #50;
        
        // Test case 4: Division
        regA = 25;
        regB = 3;
        opcode = 4'b0011; // Division
        #50;
        if (result!== (regA / regB)) begin
            $display("Division test failed", result, regA/regB);
        end else begin
            $display("Division test passed");
            flag =flag+1;
        end
        #50;
        
        // Test case 5: Bitwise AND
        regA = 4;
        regB = -6;
        opcode = 4'b0100; // AND
        #50;
        regC = regA & regB;
        if (result !== regC) begin
            $display("Bitwise AND test failed", result, regC);
        end else begin
            $display("Bitwise AND test passed");
            flag =flag+1;
        end
        #50;
        
        // Test case 6: Bitwise OR
        regA = 120;
        regB = 224;
        opcode = 4'b0101; // OR
        #50;
        regC = regA | regB;
        if (result !== regC) begin
            $display("Bitwise OR test failed", result, regC);
        end else begin
            $display("Bitwise OR test passed");
            flag =flag+1;
        end
        #50;
        
        // Test case 7: Bitwise XOR
        regA = 10;
        regB = -1;
        opcode = 4'b0110; // XOR
        #50;
        regC = regA ^ regB;
        if (result !== regC) begin
            $display("Bitwise XOR test failed", result, regC);
        end else begin
            $display("Bitwise XOR test passed");
            flag =flag+1;
        end
        #50;
        
        // Test case 8: Logical Left Shift
        regA = 10;
        regB = 2;
        opcode = 4'b0111; // LLS
        #50;
        regC = regA << regB;
        if (result !== regC) begin
            $display("LLS test failed", result, regC);
        end else begin
            $display("LLS test passed");
            flag =flag+1;
        end
        #50;
        
        // Test case 9: Logical Right Shift
        regA = 138;
        regB = 4;
        opcode = 4'b1000; // LRS
        #50;
        regC = regA >> regB;
        if (result !== regC) begin
            $display("LRS test failed", result, regC);
        end else begin
            $display("LRS test passed");
            flag =flag+1;
        end
        #50;
        
        // Test case 10: Increment
        regA = 45;
        opcode = 4'b1001; // Increment
        #50;
        regC = regA + 1;
        if (result !== regC) begin
            $display("Increment test failed", result, regC);
        end else begin
            $display("Increment test passed");
            flag =flag+1;
        end
        #50;
        
        // Test case 11: Decrement
        regA = 0;
        opcode = 4'b1010; // Decrement
        #50;
        regC = regA - 1;
        if (result !== regC) begin
            $display("Decrement test failed", result, regC);
        end else begin
            $display("Decrement test passed");
            flag =flag+1;
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


