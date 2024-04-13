module NOT_gate(
    input a,
    output reg b
);

always @* begin
    if(a == 1'b0)
        b = 1'b1;
    else
        b = 1'b0;
end

endmodule

module OR_gate(
    input a, b,
    output reg c
);

always @* begin
    if(a == 1'b0) begin
        if(b == 1'b0) begin
            c = 1'b0;
        end
        else
            c = 1'b1;
    end
    else 
    c = 1'b1;
end

endmodule

module AND_gate(
    input a, b,
    output reg c
);

always @* begin
    if(a == 1'b1) begin
        if(b == 1'b1) begin
            c = 1'b1;
        end
        else
            c = 1'b0;
    end
    else 
    c = 1'b0;
end

endmodule

module XOR_gate(
    input a, b,
    output reg c
);

always @* begin
    if(a == 1'b1) begin
        if(b == 1'b0) begin
            c = 1'b1;
        end
        else
            c = 1'b0;
    end
    else begin
        if(b == 1'b1)
            c = 1'b1;
        else
            c = 1'b0;
    end
end

endmodule

module bitwise_and (
    input signed [15:0]a, b,
    output reg signed[15:0] c
);

reg a1, b1;
wire c1;
integer i;
AND_gate and_inst(.a(a1), .b(b1), .c(c1));

always @* begin
    for(i = 0; i < 16; i=i+1) begin
        a1 = a[i];
        b1 = b[i];
        #1
        c[i] = c1;
    end
end

endmodule

module bitwise_or (
    input signed [15:0]a, b,
    output reg signed[15:0] c
);

reg a1, b1;
wire c1;
integer i;
OR_gate and_inst(.a(a1), .b(b1), .c(c1));

always @* begin
    for(i = 0; i < 16; i=i+1) begin
        a1 = a[i];
        b1 = b[i];
        #1
        c[i] = c1;
    end
end

endmodule

module bitwise_xor (
    input signed [15:0]a, b,
    output reg signed[15:0] c
);

reg a1, b1;
wire c1;
integer i;
XOR_gate and_inst(.a(a1), .b(b1), .c(c1));

always @* begin
    for(i = 0; i < 16; i=i+1) begin
        a1 = a[i];
        b1 = b[i];
        #1
        c[i] = c1;
    end
end

endmodule

module bitwise_not (
    input signed [15:0] a,
    output reg signed [15:0] b
);

reg a1;
wire b1;
integer i;
NOT_gate not_inst(.a(a1), .b(b1));

always @* begin
    for(i = 0; i < 16; i=i+1) begin
        a1 = a[i];
        #1
        b[i] = b1;
    end
end

endmodule


module logical_left_shift(
    input signed [15:0]a, b,
    output signed [15:0] result
);

reg signed[15:0] res;
integer i;

always @* begin
res = a;
    for(i=0; i<b; i=i+1) begin
        
        res = {res[14:0], 1'b0};
        
    end
end

assign result = res;

endmodule

module logical_right_shift(
    input signed [15:0]a, b,
    output signed [15:0] result
);

reg signed[15:0] res;
integer i;

always @* begin
res = a;
    for(i=0; i<b; i=i+1) begin
        
        res = {1'b0, res[15:1]};
        
    end
end

assign result = res;

endmodule


module logical_left_shift_32_bit(
    input signed [31:0]a, b,
    output signed [31:0] result
);

reg signed[31:0] res;
integer i;

always @* begin
res = a;
    for(i=0; i<b; i=i+1) begin
        
        res = {res[30:0], 1'b0};
        
    end
end
assign result = res;
endmodule
