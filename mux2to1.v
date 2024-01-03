`timescale 1ns/1ns

module mux2to1(input in1, in2, input [2:0]sel, output out);
    reg out_reg;

    localparam POUR_FOOD = 3'b001;  
    localparam INTERVAL = 3'b011;

    assign out = 0;

    always @* begin
    //in1 o sa fie food_counter, in2 o sa fie interval_counter
        if(sel == POUR_FOOD) begin 
            out_reg = in1;
        end
        else if(sel == INTERVAL) begin
            out_reg = in2;
        end
    end

    assign out = out_reg;
endmodule
