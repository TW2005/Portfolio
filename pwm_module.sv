//------------------------------------------------------------------------------
// pwm_module.sv
// 8-bit PWM generator
//------------------------------------------------------------------------------

module pwm_module (
    input  logic       clk,
    input  logic       reset,
    input  logic [7:0] duty_cycle,
    input  logic       enable,
    output logic       pwm_out
);
    logic [7:0] counter;

    always_ff @(posedge clk) begin
        if (reset) begin
            counter <= 8'h00;
        end else begin
            counter <= counter + 8'h01;
        end
    end

    always_comb begin
        if (enable) begin
            pwm_out = (counter < duty_cycle);
        end else begin
            pwm_out = 1'b0;
        end
    end
endmodule

