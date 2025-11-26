//------------------------------------------------------------------------------
// instruction_memory.sv
// Simple synthesizable instruction memory initialized from program.hex
//------------------------------------------------------------------------------

module instruction_memory (
    input  logic        clk,
    input  logic [7:0]  pc,
    output logic [15:0] instr
);
    // 256 bytes -> 128 instructions
    logic [15:0] mem [0:127];

    initial begin
        $readmemh("program.hex", mem);
    end

    always_comb begin
        instr = mem[pc[7:1]];
    end
endmodule

