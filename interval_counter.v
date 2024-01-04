`timescale 1ns/1ns
module interval_counter(input clock,input reset,input enable,input interval_reset, input [15:0]interval, 
                      output switch_i_c, output [20:0] count_out);
    // intervalul o sa fie dat in minute, deci il inmultim cu 60
  reg [20:0] count_reg, count_next;
  reg switch_i_c_reg, switch_i_c_next;
  reg [20:0]interval_seconds_reg;

    always @(posedge clock or posedge reset) begin
        if(reset || interval_reset) begin
            count_reg <= 'b0;
            switch_i_c_reg<='b0;
            interval_seconds_reg<=60*interval;
        end else begin
            count_reg <= count_next;
            switch_i_c_reg <= switch_i_c_next;
        end
    end   

    always @* begin
        count_next = count_reg;
        switch_i_c_next = switch_i_c_reg;
        if(enable && !interval_reset) begin
            if(count_reg <= (interval_seconds_reg - 2) && count_reg >= (interval_seconds_reg - 6)) begin
                switch_i_c_next = 1'b1;
            end
            // aici se reseteaza contorul
            if(count_reg == (interval_seconds_reg - 1)) begin
                switch_i_c_next = 1'b0;
                count_next = 'b0;
            end else begin
                count_next = count_reg+1'b1;
            end
        end
    end

    assign switch_i_c = switch_i_c_reg;
    assign count_out = count_reg;
 
endmodule

`timescale 1ns/1ns
module tb_interval_counter();
  reg clock, reset, enable, interval_reset;
  reg [15:0]interval;
  wire switch_i_c;
  wire [20:0]count_out;
  
  interval_counter interval_counter_instance(.clock(clock),.reset(reset),.enable(enable),.interval_reset(interval_reset) ,.interval(interval),.switch_i_c(switch_i_c), .count_out(count_out));
  
  initial begin
    clock = 0;
    forever #2 clock = !clock;
  end
  initial begin
    interval=5'd10;
    reset = 1'b1;
    interval_reset = 1'b0;
    enable  = 1'b1;
    #3 reset = 1'b0;
    #200;
    interval_reset = 1'b1;
    #50;
    interval_reset = 1'b0;
    #10;
    enable = 1'b1;
    #20000;
    $finish();
  end
  initial begin
    $dumpfile("dump.vcd"); 
    $dumpvars;
  end
endmodule
