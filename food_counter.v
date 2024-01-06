`timescale 1ns/1ns
module food_counter(input clock,input reset,input enable, input count_reset, 
                  input full_bowl_sensor, input empty_tank_sensor, output switch_f_c, output [3:0] count_out);


  reg [3:0] count_reg, count_next;
  reg switch_f_c_reg, switch_f_c_next;
  localparam food_time = 10;

    always @(posedge clock or posedge reset) begin
      if (reset || count_reset || full_bowl_sensor || empty_tank_sensor) begin
          count_reg <= 0;
          switch_f_c_reg <= 0;
      end else if (enable) begin
          if (count_reg < food_time - 1) begin
              count_reg <= count_reg + 1;
              switch_f_c_reg <= 1;
          end else begin

              switch_f_c_reg <= 0;
          end
      end else begin

          switch_f_c_reg <= 0;
      end
    end   

    assign switch_f_c = switch_f_c_reg;
    assign count_out = count_reg;
 
endmodule

`timescale 1ns/1ns
module tb_food_counter();
  reg clock, reset, enable, count_reset, full_bowl_sensor
, empty_tank_sensor;
  wire switch_f_c;
  wire [3:0]count_out;
  
  food_counter food_counter_instance(.clock(clock),.reset(reset),.enable(enable),.count_reset(count_reset), .full_bowl_sensor
(full_bowl_sensor
), .empty_tank_sensor(empty_tank_sensor), .switch_f_c(switch_f_c), .count_out(count_out));
  
  initial begin
    clock = 0;
    forever #2 clock = !clock;
  end
  initial begin
    full_bowl_sensor
   = 1'b0;
    empty_tank_sensor = 1'b0;
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
    full_bowl_sensor
   = 1'b1;
    #400;
    full_bowl_sensor
   = 1'b0;
    #100;
    empty_tank_sensor = 1'b1;
    #300;
    empty_tank_sensor = 1'b0;
    #200;
    $finish();
  end
  initial begin
    $dumpfile("dump.vcd"); 
    $dumpvars;
  end
endmodule