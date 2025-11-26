//------------------------------------------------------------------------------
// simple_bus.sv
// Routes CPU memory-mapped accesses to peripherals
//------------------------------------------------------------------------------

module simple_bus (
    input  logic        clk,
    input  logic        reset,
    input  logic [7:0]  addr,
    input  logic        read_en,
    input  logic        write_en,
    input  logic [7:0]  write_data,
    output logic [7:0]  read_data,
    output logic        ready,
    // Peripheral connections
    input  logic [7:0]  gpio_in,
    output logic [7:0]  gpio_out,
    input  logic [15:0] timer_value,
    output logic [7:0]  pwm_duty,
    output logic        pwm_enable
);
    // Internal registers for GPIO output and PWM configuration
    logic [7:0] gpio_out_reg;
    logic [7:0] pwm_duty_reg;
    logic       pwm_enable_reg;

    assign ready = 1'b1;
    assign gpio_out = gpio_out_reg;
    assign pwm_duty = pwm_duty_reg;
    assign pwm_enable = pwm_enable_reg;

    always_ff @(posedge clk) begin
        if (reset) begin
            gpio_out_reg   <= 8'h00;
            pwm_duty_reg   <= 8'h00;
            pwm_enable_reg <= 1'b0;
        end else if (write_en) begin
            case (addr)
                8'hF0: gpio_out_reg   <= write_data;
                8'hF4: pwm_duty_reg   <= write_data;
                8'hF5: pwm_enable_reg <= write_data[0];
                default: ;
            endcase
        end
    end

    always_comb begin
        case (addr)
            8'hF0: read_data = gpio_out_reg;
            8'hF1: read_data = gpio_in;
            8'hF2: read_data = timer_value[7:0];
            8'hF3: read_data = timer_value[15:8];
            8'hF4: read_data = pwm_duty_reg;
            8'hF5: read_data = {7'b0, pwm_enable_reg};
            default: read_data = 8'h00;
        endcase
    end
endmodule

