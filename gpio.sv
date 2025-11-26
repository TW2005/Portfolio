//------------------------------------------------------------------------------
// gpio.sv
// Simple GPIO peripheral connecting switches to LEDs
//------------------------------------------------------------------------------

module gpio (
    input  logic       clk,
    input  logic       reset,
    input  logic [7:0] sw_in,
    input  logic [7:0] gpio_out_data,
    output logic [7:0] led_out,
    output logic [7:0] gpio_in_data
);
    always_ff @(posedge clk) begin
        if (reset) begin
            led_out <= 8'h00;
        end else begin
            led_out <= gpio_out_data;
        end
    end

    always_comb begin
        gpio_in_data = sw_in;
    end
endmodule

