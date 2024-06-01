module cache_controller (
    input wire clk,
    input wire reset,
    input wire read,
    input wire write,
    input wire [31:0] address,
    input wire [31:0] write_data,
    output reg [31:0] read_data,
    output reg hit,
    output reg miss,
    // Memory interface signals
    output reg [31:0] memory_write_address,
    output reg [31:0] memory_write_data,
    output reg memory_write_enable,
    input wire memory_write_complete
);

    // Define cache parameters
    localparam CACHE_SIZE = 32 * 1024; // 32 KB
    localparam BLOCK_SIZE = 64;        // 64 bytes
    localparam NUM_BLOCKS = CACHE_SIZE / BLOCK_SIZE;
    localparam NUM_SETS = 128;         // 128 sets
    localparam ASSOC = 4;              // 4-way set associative
    localparam BLOCK_OFFSET_BITS = $clog2(BLOCK_SIZE);
    localparam INDEX_BITS = $clog2(NUM_SETS);
    localparam TAG_BITS = 32 - INDEX_BITS - BLOCK_OFFSET_BITS;

    // Define states
    typedef enum logic [2:0] {
        IDLE,
        READ_HIT,
        READ_MISS,
        WRITE_HIT,
        WRITE_MISS,
        EVICT,
        WRITE_BACK // New state for write-back
    } state_t;

    state_t current_state, next_state;

    // Cache memory arrays
    reg [TAG_BITS-1:0] tags [NUM_SETS-1:0][ASSOC-1:0];
    reg valid [NUM_SETS-1:0][ASSOC-1:0];
    reg [31:0] cache_data [NUM_SETS-1:0][ASSOC-1:0][BLOCK_SIZE/4-1:0]; // 32-bit words in a block
    reg [1:0] lru [NUM_SETS-1:0][ASSOC-1:0]; // LRU counters
    reg dirty [NUM_SETS-1:0][ASSOC-1:0]; // New array to track dirty bits

    // Extract tag, index, and block offset from address
    wire [TAG_BITS-1:0] tag = address[31:INDEX_BITS+BLOCK_OFFSET_BITS];
    wire [INDEX_BITS-1:0] index = address[INDEX_BITS+BLOCK_OFFSET_BITS-1:BLOCK_OFFSET_BITS];
    wire [BLOCK_OFFSET_BITS-1:0] block_offset = address[BLOCK_OFFSET_BITS-1:0];

    // FSM sequential logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    // FSM combinational logic
    always @(*) begin
        case (current_state)
            IDLE: begin
                if (read) begin
                    // Check for read hit
                    if (check_hit()) begin
                        next_state = READ_HIT;
                    end else begin
                        next_state = READ_MISS;
                    end
                end else if (write) begin
                    // Check for write hit
                    if (check_hit()) begin
                        next_state = WRITE_HIT;
                    end else begin
                        next_state = WRITE_MISS;
                    end
                end else begin
                    next_state = IDLE;
                end
            end
            READ_HIT: begin
                next_state = IDLE;
            end
            READ_MISS: begin
                next_state = EVICT;
            end
            WRITE_HIT: begin
                next_state = IDLE;
            end
            WRITE_MISS: begin
                next_state = EVICT;
            end
            EVICT: begin
                // Implement LRU eviction and replacement logic
                integer way_to_replace;
                way_to_replace = get_lru_way(index);
                // Check if the evicted line is dirty, write back to memory if necessary
                if (dirty[index][way_to_replace]) begin
                    // Write back to memory
                    memory_write_data <= cache_data[index][way_to_replace];
                    memory_write_address <= {tags[index][way_to_replace], index};
                    memory_write_enable <= 1'b1;
                    next_state = WRITE_BACK; // Move to write-back state
                end else begin
                    tags[index][way_to_replace] <= tag;
                    valid[index][way_to_replace] <= 1'b1;
                    if (write) begin
                        cache_data[index][way_to_replace][block_offset / 4] <= write_data;
                        dirty[index][way_to_replace] <= 1'b1; // Mark the cache line as dirty on write miss
                    end
                    update_lru(index, way_to_replace);
                    next_state = IDLE;
                end
            end
            WRITE_BACK: begin // New state for write-back
                if (memory_write_complete) begin
                    // Memory write complete
                    memory_write_enable <= 1'b0;
                    integer way_to_replace;
                    way_to_replace = get_lru_way(index);
                    tags[index][way_to_replace] <= tag;
                    valid[index][way_to_replace] <= 1'b1;
                    if (write) begin
                        cache_data[index][way_to_replace][block_offset / 4] <= write_data;
                        dirty[index][way_to_replace] <= 1'b1; // Mark the cache line as dirty on write miss
                    end
                    update_lru(index, way_to_replace);
                    next_state = IDLE; // Transition back to IDLE state
                end
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // FSM output logic and cache operations
    always @(posedge clk) begin
        if (reset) begin
            // Initialize cache to invalid state
            integer i, j, k;
            for (i = 0; i < NUM_SETS; i = i + 1) begin
                for (j = 0; j < ASSOC; j = j + 1) begin
                    valid[i][j] <= 1'b0;
                    lru[i][j] <= 2'b0;
                    dirty[i][j] <= 1'b0; // Initialize dirty bits
                    for (k = 0; k < BLOCK_SIZE/4; k = k + 1) begin
                        cache_data[i][j][k] <= 32'b0;
                    end
                end
            end
        end else begin
            case (current_state)
                IDLE: begin
                    hit <= 1'b0;
                    miss <= 1'b0;
                end
                READ_HIT: begin
                    read_data <= cache_data[index][get_hit_way()][block_offset / 4];
                    hit <= 1'b1;
                    miss <= 1'b0;
                    update_lru(index, get_hit_way());
                end
                READ_MISS: begin
                    miss <= 1'b1;
                    hit <= 1'b0;
                end
                WRITE_HIT: begin
                    cache_data[index][get_hit_way()][block_offset / 4] <= write_data;
                    hit <= 1'b1;
                    miss <= 1'b0;
                    dirty[index][get_hit_way()] <= 1'b1; // Mark the cache line as dirty on write hit
                    update_lru(index, get_hit_way());
                end
                WRITE_MISS: begin
                    miss <= 1'b1;
                    hit <= 1'b0;
                end
                EVICT: begin
                    // Logic moved to FSM combinational part
                end
                WRITE_BACK: begin
                    // Logic moved to FSM combinational part
                end
            endcase
        end
    end

    // Function to check if there is a cache hit
    function check_hit;
        integer i;
        check_hit = 0;
        for (i = 0; i < ASSOC; i = i + 1) begin
            if (valid[index][i] && tags[index][i] == tag) begin
                check_hit = 1;
            end
        end
    endfunction

    // Function to get the way index of a hit
    function [1:0] get_hit_way;
        integer i;
        for (i = 0; i < ASSOC; i = i + 1) begin
            if (valid[index][i] && tags[index][i] == tag) begin
                get_hit_way = i;
            end
        end
    endfunction

    // Function to get the way index to be replaced based on LRU policy
    function [1:0] get_lru_way;
        input [INDEX_BITS-1:0] idx;
        integer i;
        reg [1:0] min_lru;
        get_lru_way = 0;
        min_lru = lru[idx][0];
        for (i = 1; i < ASSOC; i = i + 1) begin
            if (lru[idx][i] < min_lru) begin
                min_lru = lru[idx][i];
                get_lru_way = i;
            end
        end
    endfunction

    // Procedure to update LRU counters
    task update_lru(input [INDEX_BITS-1:0] idx, input [1:0] way);
        integer i;
        for (i =  0; i < ASSOC; i = i + 1) begin
            if (lru[idx][i] < lru[idx][way]) begin
                lru[idx][i] = lru[idx][i] + 1;
            end
        end
        lru[idx][way] = 0;
    endtask

endmodule


    module tb_cache_controller;

    // Inputs
    reg clk;
    reg reset;
    reg read;
    reg write;
    reg [31:0] address;
    reg [31:0] write_data;

    // Outputs
    wire [31:0] read_data;
    wire hit;
    wire miss;
    wire mem_write_req;
    wire [31:0] mem_write_addr;
    wire [31:0] mem_write_data;
    reg mem_write_ack;

    // Instantiate the cache controller
    cache_controller uut (
        .clk(clk),
        .reset(reset),
        .read(read),
        .write(write),
        .address(address),
        .write_data(write_data),
        .read_data(read_data),
        .hit(hit),
        .miss(miss),
        .mem_write_req(mem_write_req),
        .mem_write_addr(mem_write_addr),
        .mem_write_data(mem_write_data),
        .mem_write_ack(mem_write_ack)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Monitor signals
    initial begin
        $monitor("Time=%0t clk=%0b reset=%0b read=%0b write=%0b address=%h write_data=%h read_data=%h hit=%0b miss=%0b mem_write_req=%0b mem_write_addr=%h mem_write_data=%h mem_write_ack=%0b",
                 $time, clk, reset, read, write, address, write_data, read_data, hit, miss, mem_write_req, mem_write_addr, mem_write_data, mem_write_ack);
    end

    // Test sequence
    initial begin
        // Initialize inputs
        clk = 0;
        reset = 1;
        read = 0;
        write = 0;
        address = 0;
        write_data = 0;
        mem_write_ack = 0;

        // Reset pulse
        #10 reset = 0;

        // Test write miss (write data to address 0x00000000)
        #10 write = 1;
        address = 32'h00000000;
        write_data = 32'hdeadbeef;
        #10 write = 0;

        // Test read hit (read data from address 0x00000000)
        #10 read = 1;
        address = 32'h00000000;
        #10 read = 0;

        // Test read miss (read data from address 0x00000100)
        #10 read = 1;
        address = 32'h00000100;
        #10 read = 0;

        // Test write miss (write data to address 0x00000040)
        #10 write = 1;
        address = 32'h00000040;
        write_data = 32'hcafebabe;
        #10 write = 0;

        // Test read hit (read data from address 0x00000040)
        #10 read = 1;
        address = 32'h00000040;
        #10 read = 0;

        // Simulate write-back acknowledgement
        #10 mem_write_ack = 1;
        #10 mem_write_ack = 0;

        // End of test
        #100 $stop;
    end

endmodule   


