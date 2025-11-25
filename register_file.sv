//------------------------------------------------------------------------------
// register_file.sv
// 8 x 8-bit register file with two read ports and one write port
//------------------------------------------------------------------------------

module register_file (
    input  logic       clk,
    input  logic       reset,
    input  logic       write_en,
    input  logic [2:0] write_addr,
    input  logic [7:0] write_data,
    input  logic [2:0] read_addr_a,
    input  logic [2:0] read_addr_b,
    output logic [7:0] read_data_a,
    output logic [7:0] read_data_b,
    output logic [7:0] r0_value
);
    logic [7:0] regs [7:0];

    always_ff @(posedge clk) begin
        if (reset) begin
            regs[0] <= 8'h00;
            regs[1] <= 8'h00;
            regs[2] <= 8'h00;
            regs[3] <= 8'h00;
            regs[4] <= 8'h00;
            regs[5] <= 8'h00;
            regs[6] <= 8'h00;
            regs[7] <= 8'h00;
        end else if (write_en) begin
            regs[write_addr] <= write_data;
        end
    end

    always_comb begin
        read_data_a = regs[read_addr_a];
        read_data_b = regs[read_addr_b];
        r0_value    = regs[0];
    end
endmodule

