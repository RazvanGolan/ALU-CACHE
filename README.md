# ALU Verilog Module

## Overview
This project implements an Arithmetic Logic Unit (ALU) module in Verilog. The ALU supports various arithmetic and logical operations, including addition, subtraction, increment, decrement, multiplication, division, and logical operations. Each operation is implemented as an individual module within the project.

## Project Structure
The project consists of the following modules:

1. **Adder**: Implements addition operation.
2. **Subtractor**: Implements subtraction operation.
3. **Multiplier**: Implements multiplication operation.
4. **Divider**: Implements division operation.
5. **Incrementer**: Implements increment operation.
6. **Decrementer**: Implements decrement operation.
7. **Logical Operations**: Implements logical AND, OR, XOR, Left and Right Shift operations.

## Logic Design
![image](https://github.com/RazvanGolan/ALU-CACHE/assets/117024228/ad832212-a026-4b5a-a83e-f949f6985333)


## Usage
The ALU module (`ALU.v`) acts as the main controller for performing arithmetic and logical operations. It takes input operands and an opcode to select the desired operation. To use the ALU module, instantiate it in your Verilog design and provide the necessary inputs.

### Inputs
- `operandA`: First operand (16-bit signed).
- `operandB`: Second operand (16-bit signed).
- `opcode`: Control signal for selecting operation (4-bit unsigned).
- `reset`: Reset signal.
- `clk`: Clock signal.

### Outputs
- `result`: Result of the operation (32-bit signed).

## Opcode Definitions
- `4'b0000`: Addition
- `4'b0001`: Subtraction
- `4'b0010`: Multiplication
- `4'b0011`: Division
- `4'b0100`: Logical AND
- `4'b0101`: Logical OR
- `4'b0110`: Logical XOR
- `4'b0111`: Logical Left Shift
- `4'b1000`: Logical Right Shift
- `4'b1001`: Increment
- `4'b1010`: Decrement
  
## Example
```verilog
module TestBench;

    // Instantiate ALU module
    ALU alu (
        .operandA(operandA),
        .operandB(operandB),
        .opcode(opcode),
        .reset(reset),
        .clk(clk),
        .result(result)
    );
    // Provide inputs and observe outputs
    // Your testbench code here...

endmodule
```

