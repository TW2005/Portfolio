//------------------------------------------------------------------------------
// cpu_core.sv
// Simple 8-bit microcontroller core with fetch-decode-execute FSM
//------------------------------------------------------------------------------

module cpu_core (
    input  logic        clk,
    input  logic        reset,
    input  logic [15:0] instr_data,
    output logic [7:0]  pc,
    // Bus interface
    output logic [7:0]  bus_addr,
    output logic [7:0]  bus_wdata,
    input  logic [7:0]  bus_rdata,
    output logic        bus_read,
    output logic        bus_write
);
    typedef enum logic [1:0] {
        FETCH   = 2'b00,
        EXECUTE = 2'b01
    } state_t;

    state_t state, state_next;
    logic [7:0] pc_next;
    logic [15:0] instr_reg, instr_next;

    // Instruction fields
    logic [3:0] opcode;
    logic [2:0] rd;
    logic [2:0] rs;
    logic [7:0] imm;

    // Register file signals
    logic [7:0] reg_a;
    logic [7:0] reg_b;
    logic [7:0] reg0_value;
    logic       reg_we;
    logic [7:0] reg_wdata;
    logic [2:0] reg_waddr;

    // ALU signals
    logic [2:0] alu_op;
    logic [7:0] alu_result;

    // Decode fields
    assign opcode = instr_reg[15:12];
    assign rd     = instr_reg[11:9];
    assign rs     = instr_reg[8:6];
    assign imm    = instr_reg[7:0];

    register_file u_rf (
        .clk(clk),
        .reset(reset),
        .write_en(reg_we),
        .write_addr(reg_waddr),
        .write_data(reg_wdata),
        .read_addr_a(rd),
        .read_addr_b(rs),
        .read_data_a(reg_a),
        .read_data_b(reg_b),
        .r0_value(reg0_value)
    );

    alu u_alu (
        .a(reg_a),
        .b(reg_b),
        .op(alu_op),
        .result(alu_result)
    );

    // ALU operation selection
    always_comb begin
        alu_op = 3'd0;
        case (opcode)
            4'h0: alu_op = 3'd0; // ADD
            4'h1: alu_op = 3'd1; // SUB
            4'h2: alu_op = 3'd2; // AND
            4'h3: alu_op = 3'd3; // OR
            4'h4: alu_op = 3'd4; // XOR
            4'hC: alu_op = 3'd5; // NOT
            4'hD: alu_op = 3'd6; // SHL
            4'hE: alu_op = 3'd7; // SHR
            default: alu_op = 3'd0;
        endcase
    end

    // Main state machine
    always_ff @(posedge clk) begin
        if (reset) begin
            state     <= FETCH;
            pc        <= 8'h00;
            instr_reg <= 16'h0000;
        end else begin
            state     <= state_next;
            pc        <= pc_next;
            instr_reg <= instr_next;
        end
    end

    always_comb begin
        // Defaults
        state_next = state;
        pc_next    = pc;
        instr_next = instr_reg;
        reg_we     = 1'b0;
        reg_waddr  = rd;
        reg_wdata  = 8'h00;
        bus_addr   = imm;
        bus_wdata  = reg_b;
        bus_read   = 1'b0;
        bus_write  = 1'b0;

        case (state)
            FETCH: begin
                instr_next = instr_data;
                state_next = EXECUTE;
                pc_next    = pc;
            end
            EXECUTE: begin
                pc_next = pc + 8'd2;
                case (opcode)
                    4'h0, // ADD
                    4'h1, // SUB
                    4'h2, // AND
                    4'h3, // OR
                    4'h4: begin // XOR
                        reg_we    = 1'b1;
                        reg_waddr = rd;
                        reg_wdata = alu_result;
                    end
                    4'h5: begin // LD immediate
                        reg_we    = 1'b1;
                        reg_waddr = rd;
                        reg_wdata = imm;
                    end
                    4'h6: begin // LDI from memory/peripheral
                        bus_read  = 1'b1;
                        reg_we    = 1'b1;
                        reg_waddr = rd;
                        reg_wdata = bus_rdata;
                    end
                    4'h7: begin // STI to memory/peripheral
                        bus_write = 1'b1;
                        bus_wdata = reg_b;
                    end
                    4'h8: begin // JMP
                        pc_next = imm;
                    end
                    4'h9: begin // BRZ if R0 == 0
                        if (reg0_value == 8'h00) begin
                            pc_next = imm;
                        end
                    end
                    4'hA: begin // OUT
                        bus_write = 1'b1;
                        bus_wdata = reg_b;
                    end
                    4'hB: begin // IN
                        bus_read  = 1'b1;
                        reg_we    = 1'b1;
                        reg_waddr = rd;
                        reg_wdata = bus_rdata;
                    end
                    4'hC, // NOT
                    4'hD, // SHL
                    4'hE: begin // SHR
                        reg_we    = 1'b1;
                        reg_waddr = rd;
                        reg_wdata = alu_result;
                    end
                    default: begin
                        reg_we = 1'b0;
                    end
                endcase
                state_next = FETCH;
            end
            default: begin
                state_next = FETCH;
            end
        endcase
    end
endmodule

