//------------------------------------------------------------------------------
// top_microcontroller.sv
// Top-level integration for DE1-SoC board
//------------------------------------------------------------------------------

module top_microcontroller (
    input  logic        CLOCK_50,
    input  logic [9:0]  SW,
    input  logic [3:0]  KEY,
    output logic [9:0]  LEDR
);
    // Active-low reset from KEY0
    logic reset;
    logic [7:0] pc;
    logic [15:0] instr;

    // Bus signals
    logic [7:0] bus_addr;
    logic [7:0] bus_wdata;
    logic [7:0] bus_rdata;
    logic       bus_read;
    logic       bus_write;
    logic       bus_ready;

    // Peripheral connections
    logic [7:0] gpio_out;
    logic [7:0] gpio_in;
    logic [15:0] timer_value;
    logic [7:0] pwm_duty;
    logic       pwm_enable;
    logic       pwm_out;

    assign reset   = ~KEY[0];

    cpu_core u_cpu (
        .clk(CLOCK_50),
        .reset(reset),
        .instr_data(instr),
        .pc(pc),
        .bus_addr(bus_addr),
        .bus_wdata(bus_wdata),
        .bus_rdata(bus_rdata),
        .bus_read(bus_read),
        .bus_write(bus_write)
    );

    instruction_memory u_imem (
        .clk(CLOCK_50),
        .pc(pc),
        .instr(instr)
    );

    timer u_timer (
        .clk(CLOCK_50),
        .reset(reset),
        .timer_value(timer_value)
    );

    simple_bus u_bus (
        .clk(CLOCK_50),
        .reset(reset),
        .addr(bus_addr),
        .read_en(bus_read),
        .write_en(bus_write),
        .write_data(bus_wdata),
        .read_data(bus_rdata),
        .ready(bus_ready),
        .gpio_in(gpio_in),
        .gpio_out(gpio_out),
        .timer_value(timer_value),
        .pwm_duty(pwm_duty),
        .pwm_enable(pwm_enable)
    );

    gpio u_gpio (
        .clk(CLOCK_50),
        .reset(reset),
        .sw_in(SW[7:0]),
        .gpio_out_data(gpio_out),
        .led_out(LEDR[7:0]),
        .gpio_in_data(gpio_in)
    );

    pwm_module u_pwm (
        .clk(CLOCK_50),
        .reset(reset),
        .duty_cycle(pwm_duty),
        .enable(pwm_enable),
        .pwm_out(pwm_out)
    );

    // Connect PWM output and preserve LEDR[8]
    assign LEDR[8] = 1'b0;
    assign LEDR[9] = pwm_out;
endmodule

