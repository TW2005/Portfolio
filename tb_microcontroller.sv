//------------------------------------------------------------------------------
// tb_microcontroller.sv
// Testbench for the soft microcontroller system
//------------------------------------------------------------------------------
`timescale 1ns/1ps

module tb_microcontroller;
    logic CLOCK_50;
    logic [9:0] SW;
    logic [3:0] KEY;
    logic [9:0] LEDR;

    top_microcontroller dut (
        .CLOCK_50(CLOCK_50),
        .SW(SW),
        .KEY(KEY),
        .LEDR(LEDR)
    );

    // Clock generation: 50 MHz equivalent (period 20ns)
    initial begin
        CLOCK_50 = 1'b0;
        forever #10 CLOCK_50 = ~CLOCK_50;
    end

    // Stimulus
    initial begin
        SW  = 10'h000;
        KEY = 4'b1111;
        // Apply active-low reset
        KEY[0] = 1'b0;
        #100;
        KEY[0] = 1'b1;

        // Change switch inputs during simulation
        #200;
        SW[7:0] = 8'h3C;
        #200;
        SW[7:0] = 8'hF0;
        #200;
        SW[7:0] = 8'h0F;

        #400;
        $finish;
    end

    // Monitor CPU state
    always @(posedge CLOCK_50) begin
        $display("Time %0t | PC=%h Instr=%h R0=%h R1=%h R2=%h R3=%h R4=%h LEDR=%h", $time,
                 dut.u_cpu.pc,
                 dut.u_cpu.instr_reg,
                 dut.u_cpu.u_rf.regs[0],
                 dut.u_cpu.u_rf.regs[1],
                 dut.u_cpu.u_rf.regs[2],
                 dut.u_cpu.u_rf.regs[3],
                 dut.u_cpu.u_rf.regs[4],
                 LEDR[7:0]);
    end
endmodule

