module counter_8_watch (
    input        clk,
    input        rst,
    output [2:0] sel
);
    reg [2:0] counter;
    assign sel = counter;

    always @(posedge clk, posedge rst) begin  // ?  ?  ?   ? ? �߻�?  ?   ? ?  ?  
        if (rst) begin

            counter <= 0;
        end else begin

            counter <= counter + 1;
        end
    end
endmodule
