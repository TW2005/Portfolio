//------------------------------------------------------------------------------
// alu.sv
// 8-bit ALU supporting arithmetic and logical operations
//------------------------------------------------------------------------------

module alu (
    input  logic [7:0] a,
    input  logic [7:0] b,
    input  logic [2:0] op,
    output logic [7:0] result
);
    // Operation encoding
    localparam OP_ADD = 3'd0;
    localparam OP_SUB = 3'd1;
    localparam OP_AND = 3'd2;
    localparam OP_OR  = 3'd3;
    localparam OP_XOR = 3'd4;
    localparam OP_NOT = 3'd5;
    localparam OP_SHL = 3'd6;
    localparam OP_SHR = 3'd7;

    always_comb begin
        case (op)
            OP_ADD: result = a + b;
            OP_SUB: result = a - b;
            OP_AND: result = a & b;
            OP_OR : result = a | b;
            OP_XOR: result = a ^ b;
            OP_NOT: result = ~a;
            OP_SHL: result = a << 1;
            OP_SHR: result = a >> 1;
            default: result = 8'h00;
        endcase
    end
endmodule

