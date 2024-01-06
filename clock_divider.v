`timescale 1ns/1ns
module clock_divider#(parameter width = 26,
                parameter MAX = 50000000)
  			   (input clock , input reset, output new_clock);
  
  localparam HALF_COUNT = (MAX-1)/2;
  reg [width-1:0] count_reg, count_next;
  reg drive_reg, drive_next;
  
  assign new_clock = drive_reg;
  
  always @(posedge clock or posedge reset) begin
    if(reset) begin
        drive_reg <= 1'b0;
        count_reg <= 'b0;  
    end else begin
        drive_reg <= drive_next;
        count_reg <= count_next;
    end
  end
  
  always @* begin
    drive_next = drive_reg;
    count_next = count_reg;
      if(count_reg == (MAX-1)) begin
        drive_next = 1'b0;
        count_next = 'b0;
      end else begin
        count_next = count_reg+1'b1;
        if(count_reg < HALF_COUNT) begin
            drive_next = 1'b0;
        end else begin
            drive_next = 1'b1;
        end
      end
  end
endmodule

`timescale 1ns/1ns
module tb_clock_divider();
  localparam input_fr  = 50;
  localparam output_fr = 10;
  localparam MAX       = input_fr/output_fr;
  localparam width     = $clog2(MAX)+1;
  reg clock, reset;
  wire new_clock;
  
  clock_divider#(.width(width),.MAX(MAX)) divider50MHz_1Hz(.clock(clock),.reset(reset),.new_clock(new_clock));
  
  initial begin
    clock = 0;
    forever #2 clock = !clock;
  end
  initial begin
    reset = 1'b1;
    #3 reset = 1'b0;
    #200;
    $finish();
  end
endmodule