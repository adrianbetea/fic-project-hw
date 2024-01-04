`timescale 1ns/1ns
module adder(input clock, reset,
            input [3:0] keyboard_digit, input digit_enable, 
            output [15:0] sum, output [15:0] prev_sum);

  reg [15:0] sum_reg, sum_next;
  reg [15:0] prev_sum_reg, prev_sum_next;

  always @(posedge clock or posedge reset) begin
    if(reset) begin
        sum_reg <= 0;
        prev_sum_reg <= 0;  
    end else begin
        sum_reg <= sum_next;
        prev_sum_reg <= prev_sum_next;
    end
  end

  always @* begin
    sum_next = sum_reg;
    prev_sum_next = prev_sum_reg;

    if(digit_enable == 1'b1) begin
        sum_next = sum_reg * 10 + keyboard_digit;
    end else begin
        prev_sum_next = prev_sum_reg * 10 + keyboard_digit;
    end
  end
  
  assign sum = sum_reg;
  assign prev_sum = prev_sum_reg;

endmodule

`timescale 1ns/1ns
module tb_adder();

reg clock, reset, digit_enable;
reg [3:0] keyboard_digit;
wire [15:0] sum, prev_sum;

adder alu(.clock(clock), .reset(reset), .keyboard_digit(keyboard_digit), .digit_enable(digit_enable), .sum(sum), .prev_sum(prev_sum));

initial begin
    clock = 0;
    forever #2 clock = !clock;
end

initial begin
    digit_enable = 1'b0;
    reset = 1'b1;
    #3 reset = 1'b0;
    #200;

    keyboard_digit  = 4'd4;
    #30;
    $display("Sum: %d, Prev_sum: %d", sum, prev_sum);
    keyboard_digit  = 4'd6;
    #30;
    $display("Sum: %d, Prev_sum: %d", sum, prev_sum);
    digit_enable = 1'b1;
    #4;
    $display("Sum: %d, Prev_sum: %d", sum, prev_sum);
    digit_enable = 1'b0;

    #30

    keyboard_digit  = 4'd3;
    #30;
    $display("Sum: %d, Prev_sum: %d", sum, prev_sum);
    keyboard_digit  = 4'd2;
    #30;
    $display("Sum: %d, Prev_sum: %d", sum, prev_sum);
    keyboard_digit  = 4'd7;
    #30;
    $display("Sum: %d, Prev_sum: %d", sum, prev_sum);
    digit_enable = 1'b1;
    #4;
    $display("Sum: %d, Prev_sum: %d", sum, prev_sum);
    digit_enable = 1'b0;
    #30
    
    keyboard_digit = 4'd5;
    #30;
    $display("Sum: %d, Prev_sum: %d", sum, prev_sum);
    digit_enable = 1'b1;
    #4;
    $display("Sum: %d, Prev_sum: %d", sum, prev_sum);
    digit_enable = 1'b0;
    #30
    $finish();
  end

endmodule