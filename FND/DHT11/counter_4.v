module counter_4_humid (
    input        clk,
    input        reset,
    output [1:0] sel
);
    reg [1:0] counter;
    assign sel = counter;

    always @(posedge clk, posedge reset) begin
        if (reset) 
            counter <= 2'd0;    
        else 
            counter <= counter + 1'b1;
    end
endmodule


module decorder_2x4_humid (
    input  [1:0] sel,
    output [3:0] fnd_com
);
    assign fnd_com = (sel==2'b00) ? 4'b1110 :
                     (sel==2'b01) ? 4'b1101 :
                     (sel==2'b10) ? 4'b1011 :
                     (sel==2'b11) ? 4'b0111 :
                                     4'b1111;
endmodule
