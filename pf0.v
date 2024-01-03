`timescale 1ns/1ns

module pet_feeder(input clock, reset, input [2:0]keyboard_option, input option_enable, 
    input [3:0]keyboard_digit, input digit_enable, output food_switch);
    wire count_enable, count_reset, interval_enable;
    wire [15:0]interval;
    wire new_clock_1Hz;
    wire switch_f_c, switch_i_c;
    wire [3:0]count_out_f_c;
    wire [20:0]count_out_i_c;
    wire out_switch;

    localparam IDLE = 3'b000;
    localparam POUR_FOOD = 3'b001;
    localparam STOP_FOOD = 3'b010;
    localparam INTERVAL = 3'b011;
    localparam RESET = 3'b100;

    clock_divider#(.width(26), .MAX(50000000)) divider50MHz_1Hz(.clock(clock), .reset(reset), .new_clock(new_clock_1Hz));
    
    adder alu(.clock(clock), .reset(reset), .keyboard_digit(keyboard_digit), .digit_enable(digit_enable), .sum(interval));

    option_fsm option_fsm_inst(.clock(clock), .reset(reset), .fsm_enable(option_enable), .option(keyboard_option), 
                                .count_enable(count_enable), .count_reset(count_reset), .interval_enable(interval_enable));

    food_counter food_counter_inst(.clock(new_clock_1Hz), .reset(reset), .enable(count_enable), .count_reset(count_reset), 
                                .switch_f_c(switch_f_c), .count_out(count_out_f_c));
    
    interval_counter interval_counter_inst(.clock(new_clock_1Hz), .reset(reset), .enable(interval_enable), .interval(interval), 
                                .switch_i_c(switch_i_c), .count_out(count_out_i_c));

    mux2to1 mux2to1_instance(.in1(switch_f_c), .in2(switch_i_c), .sel(keyboard_digit), .out(out_switch));

    assign food_switch = out_switch;

endmodule


`timescale 1ns/1ns
module tb_pet_feeder();
    reg clock, reset;
    reg [2:0]keyboard_option;
    reg [3:0]keyboard_digit;
    reg option_enable, digit_enable;
    wire food_switch;

    localparam IDLE = 3'b000;
    localparam POUR_FOOD = 3'b001;
    localparam STOP_FOOD = 3'b010;
    localparam INTERVAL = 3'b011;
    localparam RESET = 3'b100;

    pet_feeder pet_feeder_instance(.clock(clock), .reset(reset), .keyboard_option(keyboard_option), .option_enable(option_enable), .digit_enable(digit_enable), .food_switch(food_switch));

     initial begin
    clock = 0;
    forever #2 clock = !clock;
    end
    initial begin
        reset = 1'b1;
        #3 reset = 1'b0;

        keyboard_option = POUR_FOOD;
        #10 option_enable = 1'b1;
        #10 option_enable = 1'b0;
        #10 keyboard_option = IDLE;
        #200;
        $finish();
    end
    initial begin
        $dumpfile("dump.vcd"); 
        $dumpvars;
    end

endmodule