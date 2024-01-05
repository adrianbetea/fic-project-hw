`timescale 1ns/1ns
module food_counter(input clock,input reset,input enable, input count_reset, input full_sensor,  output switch_f_c, output [3:0] count_out);


  reg [3:0] count_reg, count_next;
  reg switch_f_c_reg, switch_f_c_next;
  localparam food_time = 10;

    always @(posedge clock or posedge reset) begin
        if(reset || count_reset || full_sensor) begin
            count_reg <= 'b0;
            switch_f_c_reg<='b0;
        end else begin
            count_reg <= count_next;
            switch_f_c_reg <= switch_f_c_next;
        end
    end   

    always @* begin
        count_next = count_reg;
        switch_f_c_next = switch_f_c_reg;
        if(enable && !count_reset && !full_sensor) begin
            if(count_reg <= (food_time - 1) ) begin
                switch_f_c_next = 1'b1;
            end
            // aici se reseteaza contorul
            if(count_reg == (food_time)) begin
                switch_f_c_next = 1'b0;
                count_next = 0;
                // problema apare aici din cauza lui count_reg care nu se reseteaza (nici nu pot sa-l resetez eu ca numara nonstop)
            end else begin
                count_next = count_reg+1'b1;
            end
        end
    end

    assign switch_f_c = switch_f_c_reg;
    assign count_out = count_reg;
 
endmodule

`timescale 1ns/1ns
module tb_food_counter();
  reg clock, reset, enable, count_reset, full_sensor;
  wire switch_f_c;
  wire [3:0]count_out;
  
  food_counter food_counter_instance(.clock(clock),.reset(reset),.enable(enable),.count_reset(count_reset), .full_sensor(full_sensor), .switch_f_c(switch_f_c), .count_out(count_out));
  
  initial begin
    clock = 0;
    forever #2 clock = !clock;
  end
  initial begin
    full_sensor = 1'b0;
    reset = 1'b1;
    count_reset = 1'b0;
    enable  = 1'b1;
    #3 reset = 1'b0;
    #30
    count_reset = 1'b1;
    #30
    count_reset = 1'b0;
    enable = 1'b1;
    #200;
    full_sensor = 1'b1;
    #400;
    $finish();
  end
  initial begin
    $dumpfile("dump.vcd"); 
    $dumpvars;
  end
endmodule