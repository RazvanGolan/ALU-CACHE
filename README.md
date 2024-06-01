# Description 

This repository contains two school projects: an Arithmetic Logic Unit (ALU) implemented in Verilog and a cache controller implemented in SystemVerilog. Both projects were developed as part of academic coursework, providing practical experience in digital design and computer architecture concepts.

The development of these projects was a collaborative effort, and I worked alongside [Raul Candrea](https://github.com/RaulCandrea) on both implementations.

# Content Page

 [ALU Verilog Module](#alu-verilog-module)
 
 [Cache Controller](#cache-controller)

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

# Cache Controller

## General Description

This document presents the implementation of a cache memory alongside a 4 GiB main memory with a 32-bit physical address. It describes the `cache_controller` module, a SystemVerilog implementation of a 4-way set-associative cache controller with a write-back policy. The module handles read and write operations, as well as eviction and replacement of data based on the LRU (Least Recently Used) policy.

## Block Diagram
![block_diagram](https://github.com/RazvanGolan/ALU-CACHE/assets/117024228/8dcb0394-0a34-46b4-9f5c-30bf9add3697)

## FSM Diagram
![FSM_DIagram](https://github.com/RazvanGolan/ALU-CACHE/assets/117024228/79b116b9-7170-4799-97b5-ecc2c0d3c6e9)

## Inputs and Outputs

### Inputs:
- `clk`: clock signal.
- `reset`: reset signal.
- `read`, `write`: control signals for read and write operations.
- `address`: 32-bit address for read/write operations.
- `write_data`: data to be written to the cache.
- `memory_write_complete`: confirmation from memory when a write-back operation is complete.

### Outputs:
- `read_data`: data to be read.
- `hit`, `miss`: indicators for cache hit or miss.
- `memory_write_address`, `memory_write_data`, `memory_write_enable`: signals for interfacing with the main memory during write-back.

## Cache Structure

- **Cache Size:** 32 KiB
- **Block Size:** 64 bytes
- **Number of Sets:** 128
- **Associativity:** 4-way set associative
- **•	Word adressable** (one word is one byte), thus no byte offset
- 
Each set contains 4 cache lines, each line holding 64 bytes. The address is split into tag, index, and block offset bits to identify cache lines.

## States

- **IDLE:** waiting for read/write requests.
- **READ_HIT, WRITE_HIT:** read/write requests were successful. The requested addresses were found in the cache.
- **READ_MISS, WRITE_MISS:** read/write requests were unsuccessful as the requested addresses were not found in the cache. In case of a read, the required data block is fetched from main memory and placed in the cache at the appropriate address. In case of a write, the data is modified in the cache, and the dirty bit is set.
- **EVICT:** determines which cache line to evict based on the LRU policy.
- **WRITE_BACK:** when the cache is full, the last line is evicted based on the LRU policy, and the main memory is updated if the dirty bit was set.

## Registers

- `tags`, `valid`, `lru`, `dirty`: arrays for address components.
- `cache_data`: array where cache data is stored.

# Wires

- `tag`, `index`, `block_offset`: components of the input address.

# Functions

- `check_hit`: this function checks if there is a hit in the cache for a given index and tag.
- `get_hit_way`: this function returns the index of the way in which a hit was found.
- `get_lru_way`: this function returns the index of the way to be replaced according to the LRU policy.
- `update_lru`: this task updates the LRU counters after a hit or replacement.

## FSM Sequential Logic

This logic ensures that the FSM state is updated correctly at each clock cycle and that it can be reset to an initial state (in this case, the IDLE state) in case of a system reset.

## FSM Combinational Logic
This code represents the combinational logic for an FSM, which decides the next state based on the current state and input signals (read, write, etc.).

**IDLE State** 

- If the `read` signal is active, it checks if the read is a hit (`check_hit()`). If it is a hit, the FSM transitions to `READ_HIT`. If not, the FSM transitions to `READ_MISS`.
- If the `write` signal is active, it checks if the write is a hit (`check_hit()`). If it is a hit, the FSM transitions to `WRITE_HIT`. If not, the FSM transitions to `WRITE_MISS`.
- If neither read nor write are active, the FSM remains in `IDLE`.

**READ_HIT State**

- In this state, after a read hit, the FSM transitions back to `IDLE`.

**READ_MISS State**

- In this state, after a read miss, the FSM transitions to `EVICT` to handle the eviction.

**WRITE_HIT State**

- In this state, after a write hit, the FSM transitions back to `IDLE`.

**WRITE_MISS State**

- In this state, after a write miss, the FSM transitions to `EVICT` to handle the eviction.

**EVICT State** 

- Determines the cache line to be replaced using LRU (`get_lru_way`).
- If the evicted cache line is dirty, the data is written to memory and the FSM transitions to `WRITE_BACK`.
- If the evicted cache line is not dirty, the tag and validity of the cache line are updated, the data is updated, and the FSM transitions to `IDLE`.

**WRITE_BACK State** 

- The FSM waits for confirmation that the memory write is complete (`memory_write_complete`).
- After completing the write, `memory_write_enable` is deactivated (1'b0), and the tag and validity of the cache line are updated. If it is a write operation, the data is replaced, and the dirty bit is set.
- The FSM then transitions to `IDLE`.

## Output Logic and Cache Operations

This code handles cache operations based on the current FSM state. On reset, the cache is initialized to an invalid state. Depending on the current state, various cache signals and data are updated.

**IDLE State** 

- In this state, the hit and miss signals are deactivated (`1'b0`).

**READ_HIT State**

- Data is read from the cache (`read_data`). The hit signal is activated. The miss signal is deactivated. The LRU is updated (`update_lru(index, get_hit_way())`).

**READ_MISS and WRITE_MISS States:**

- In these states, the miss signal is activated, and the hit signal is deactivated.

**WRITE_HIT State**

- Data is written to the cache (`cache_data`). The hit signal is activated. The miss signal is deactivated. The cache line is marked as dirty. The LRU is updated (`update_lru(index, get_hit_way())`).



## Testbench

The testbench (`tb_cache_controller`) initializes and tests the cache controller by simulating various read and write operations, verifying the correct handling of hits, misses, and write-back processes. The clock is generated with a period of 10 time units, and various sequences of read and write operations are executed, including simulating memory write-back confirmation.

This document provides an overview of the functionality and structure of the cache controller, highlighting key aspects such as cache architecture, state transitions, and testing scenarios.

