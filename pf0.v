`timescale 1ns/1ns

module pet_feeder(input clock, reset, input [2:0]keyboard_option, input option_enable, 
    input empty_tank_sensor, input full_bowl_sensor,
    input [3:0]keyboard_digit, input digit_enable, output food_switch);
    wire count_enable, count_reset, interval_enable, interval_reset;
    wire [15:0]interval;
    wire new_clock_1Hz;
    wire switch_f_c, switch_i_c;
    wire [3:0]count_out_f_c;
    wire [20:0]count_out_i_c;

    localparam IDLE = 3'b000;
    localparam POUR_FOOD = 3'b001;
    localparam STOP_FOOD = 3'b010;
    localparam INTERVAL = 3'b011;
    localparam RESET = 3'b100;

    // clock dividerul este folosit intr-un scenariu realist in care procesorul are frecventa de 50Mhz si aceasta trebuie redusa la un 1Hz (pentru ca perioada unui clock sa fie de o secunda)
    //clock_divider#(.width(26), .MAX(50000000)) divider50MHz_1Hz(.clock(clock), .reset(reset), .new_clock(new_clock_1Hz));
    
    adder alu(.clock(clock), .reset(reset), .keyboard_digit(keyboard_digit), .digit_enable(digit_enable), .sum(interval));

    option_fsm option_fsm_inst(.clock(clock), .reset(reset), .fsm_enable(option_enable), .option(keyboard_option), 
                                .count_enable(count_enable), .count_reset(count_reset), .interval_enable(interval_enable), .interval_reset(interval_reset));

    food_counter food_counter_inst(.clock(clock), .reset(reset), .enable(count_enable), .count_reset(count_reset), 
                                .full_bowl_sensor(full_bowl_sensor), .empty_tank_sensor(empty_tank_sensor),
                                .switch_f_c(switch_f_c), .count_out(count_out_f_c));
    
    interval_counter interval_counter_inst(.clock(clock), .reset(reset), .enable(interval_enable), .interval_reset(interval_reset), 
                                .full_bowl_sensor(full_bowl_sensor), .empty_tank_sensor(empty_tank_sensor), .interval(interval), 
                                .switch_i_c(switch_i_c), .count_out(count_out_i_c));


    assign food_switch = (keyboard_option==POUR_FOOD && switch_f_c) || (keyboard_option==INTERVAL && switch_i_c);

    

endmodule


`timescale 1ns/1ns
module tb_pet_feeder();
    reg clock, reset;
    reg [2:0]keyboard_option;
    reg [3:0]keyboard_digit;
    reg option_enable, digit_enable;
    reg full_bowl_sensor, empty_tank_sensor;
    wire food_switch;

    localparam IDLE = 3'b000;
    localparam POUR_FOOD = 3'b001;
    localparam STOP_FOOD = 3'b010;
    localparam INTERVAL = 3'b011;
    localparam RESET = 3'b100;

    pet_feeder pet_feeder_instance(
        .clock(clock), 
        .reset(reset), 
        .keyboard_option(keyboard_option), 
        .option_enable(option_enable), 
        .full_bowl_sensor(full_bowl_sensor),
        .empty_tank_sensor(empty_tank_sensor),
        .keyboard_digit(keyboard_digit),
        .digit_enable(digit_enable), 
        .food_switch(food_switch)
    );

    initial begin
        clock = 0;
        forever #2 clock = !clock;  // Generarea semnalului de ceas
    end

    initial begin
        full_bowl_sensor = 0'b0;
        empty_tank_sensor = 0'b0;
        // Reset și inițializare
        reset = 1'b1;
        //fsm_enable = 1'b1;
        keyboard_option = IDLE;
        keyboard_digit = 4'b0;
        option_enable = 1'b0;
        digit_enable = 1'b0;
        #3 reset = 1'b0;

        // Test 1: POUR_FOOD
        #10;
        keyboard_option = POUR_FOOD;
        option_enable = 1'b1;
        #10 option_enable = 1'b0;
        #100;

        // Test 2: POUT_FOOD THEN STOP_FOOD
        option_enable = 1'b1;
        #8;
        option_enable = 1'b0;
        #10;
        keyboard_option = STOP_FOOD;
        option_enable = 1'b1;
        #10;
        option_enable = 1'b0;

        #100;

        keyboard_digit = 4'd6;
        digit_enable = 1'b1;
        #4;
        digit_enable = 1'b0;
        #2;
        keyboard_digit = 4'd4;
        digit_enable = 1'b1;
        #4;
        digit_enable = 1'b0;

        #200;
        keyboard_option = INTERVAL;
        option_enable = 1'b1;
        #10;
        option_enable = 1'b0;

        #100000;

        keyboard_option = STOP_FOOD;
        option_enable = 1'b1;
        #10000;

        $finish();
    end

    initial begin
        $dumpfile("dump.vcd"); 
        $dumpvars;  // Înregistrarea activităților pentru analiză
    end
endmodule