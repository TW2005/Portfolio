//------------------------------------------------------------------------------
// instruction_memory.sv
// Simple synthesizable instruction memory initialized from program.hex
//------------------------------------------------------------------------------

module instruction_memory #(
    // Parameterized init file so Quartus picks it up; leave empty to use embedded default.
    parameter string INIT_FILE = "program.hex"
)(
    input  logic        clk,
    input  logic [7:0]  pc,
    output logic [15:0] instr
);
    // 256 bytes -> 128 instructions
    // ram_init_file attribute ensures Quartus loads the hex into the bitstream.
    (* ram_init_file = INIT_FILE *) logic [15:0] mem [0:127];

    // Provide an embedded default program so the design still runs if the hex is
    // not located correctly in the Quartus project.
    initial begin : init_mem
        integer i;
        for (i = 0; i < 128; i = i + 1) begin
            mem[i] = 16'h0000;
        end

        // Default interactive demo program (mirrors switches to GPIO/PWM)
        // 0: LD  R1, 0x01         (PWM enable flag)
        // 1: OUT [0xF5] <= R1     (PWM enable)
        // 2: IN  R0  <= [0xF1]    (read switches)
        // 3: OUT [0xF0] <= R0     (drive LEDs)
        // 4: OUT [0xF4] <= R0     (set PWM duty)
        // 5: JMP 0x02             (loop)
        mem[0] = 16'h5201; // LD  R1, 0x01
        mem[1] = 16'hA0F5; // OUT [0xF5] <= R1
        mem[2] = 16'hB0F1; // IN  R0  <= [0xF1]
        mem[3] = 16'hA0F0; // OUT [0xF0] <= R0
        mem[4] = 16'hA0F4; // OUT [0xF4] <= R0
        mem[5] = 16'h8002; // JMP 0x02

        if (INIT_FILE != "") begin
            // If the file is present in the Quartus project, it overrides the
            // embedded defaults above.
            $readmemh(INIT_FILE, mem);
        end
    end

    always_comb begin
        instr = mem[pc[7:1]];
    end
endmodule

