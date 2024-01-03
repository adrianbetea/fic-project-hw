`timescale 1ns/1ns
`define IDLE 3'b000
`define POUR_FOOD 3'b001
`define STOP_FOOD 3'b010
`define INTERVAL 3'b011
`define RESET 3'b100

module option_fsm(input clock, input reset, input fsm_enable, input [2:0] option, output count_enable, output count_reset, output interval_enable);

reg [2:0] state_reg, state_next;
reg count_enable_reg, count_enable_next;
reg count_reset_reg, count_reset_next;
reg interval_enable_reg, interval_enable_next;
reg fsm_enable_reg, fsm_enable_next;

always @(posedge clock or posedge reset) begin
	if(reset) begin
		state_reg <= `RESET;
		count_enable_reg <= 1'b0;
		count_reset_reg <= 1'b0;
        interval_enable_reg <= 1'b0;
        fsm_enable_reg <= 1'b1; // button activ pe 0
	end
	else begin
		state_reg <= state_next;
		count_enable_reg <= count_enable_next;
		count_reset_reg <= count_reset_next;
        interval_enable_reg <= interval_enable_next;
        fsm_enable_reg <= fsm_enable_next;
	end
	
end

always @* begin 
	state_next = state_reg;
	count_enable_next = count_enable_reg;
	count_reset_next = count_reset_reg;
    interval_enable_next = interval_enable_reg;
    fsm_enable_next = fsm_enable;

	case(state_reg)
	
		`RESET:	begin
			count_enable_next = 1'b0;
			count_reset_next = 1'b0;
            interval_enable_next = 1'b0;
			state_next = `IDLE;
		end
		`IDLE: begin
			if((fsm_enable_reg ^ fsm_enable) & (!fsm_enable)) begin
                case(option)
                    `POUR_FOOD: state_next = `POUR_FOOD;
                    `STOP_FOOD: state_next = `STOP_FOOD;
                    `INTERVAL: state_next = `INTERVAL;
                endcase
			end
		end
		`POUR_FOOD: begin
			count_enable_next = 1'b1;
			count_reset_next = 1'b0;
            interval_enable_next = 1'b0;
			state_next = `IDLE;
		end
		`STOP_FOOD: begin
			count_enable_next = 1'b0;
			count_reset_next = 1'b1;
            interval_enable_next = 1'b0;
			state_next = `IDLE;
		end
		`INTERVAL: begin
			count_enable_next = 1'b0;
			count_reset_next = 1'b0;
            interval_enable_next = 1'b1;
			state_next = `IDLE;
		end
	
	endcase
	
	

end

assign count_enable = count_enable_reg;
assign count_reset = count_reset_reg;
assign interval_enable = interval_enable_reg;
  
endmodule 

`timescale 1ns/1ns

module tb_option_fsm();
  reg clock, reset, fsm_enable;
  reg [2:0] option;
  wire count_enable, count_reset, interval_enable;
  
  option_fsm option_fsm_instance(.clock(clock), .reset(reset), .fsm_enable(fsm_enable), .option(option), 
                .count_enable(count_enable), .count_reset(count_reset), .interval_enable(interval_enable));
  
  initial begin 
    clock = 0;
    forever #10 clock = !clock;
  end
  
 
  initial begin

    reset = 1'b1;
    fsm_enable = 1'b1;
    option = 3'b000;
  	
    #100;
    reset = 1'b0;
    #100;

   
    option = 3'b001;
    #200; 
    fsm_enable = 1'b0;
    #200;
    fsm_enable = 1'b1;
    #200;
    // count_enable = 1, count_reset = 0, interval_enable = 0;
    #2000;

    
    option = 3'b010;
    #200; 
    fsm_enable = 1'b0;
    #200;
    fsm_enable = 1'b1;
    #200;
    // count_enable = 0, count_reset = 1, interval_enable = 0;
    #2000
   
    option = 3'b111;
    #80;
    option = 3'b101;
    #100;
    option = 3'b011;
    #200; 
    fsm_enable = 1'b0;
    #200;
    fsm_enable = 1'b1;
    #200;
    // count_enable = 0, count_reset = 0, interval_enable = 1;

    #2000;
 
    option = 3'b011;
    #100;
    option = 3'b001;
    #200; 
    fsm_enable = 1'b0;
    #200;
    fsm_enable = 1'b1;
    #200;

    #2000;
    // count_enable = 1, count_reset = 0, interval_enable = 0;

    option = 3'b010;
    #100;
    option = 3'b011;
    #200; 
    fsm_enable = 1'b0;
    #200;
    fsm_enable = 1'b1;
    #200;

    #2000;
    // count_enable = 1, count_reset = 0, interval_enable = 1;

    $finish();
  end
  
endmodule