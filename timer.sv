//------------------------------------------------------------------------------
// timer.sv
// 16-bit free-running counter
//------------------------------------------------------------------------------

module timer (
    input  logic        clk,
    input  logic        reset,
    output logic [15:0] timer_value
);
    always_ff @(posedge clk) begin
        if (reset) begin
            timer_value <= 16'h0000;
        end else begin
            timer_value <= timer_value + 16'h0001;
        end
    end
endmodule

