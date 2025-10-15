module SR04_tick_gen_1us (
    input clk,
    input rst,
    output reg o_tick_1us
);
    localparam NUM_CLK = 100;  // 100MHz ?�� 1us?�� 100?��?��
    reg [6:0] count;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= 0;
            o_tick_1us <= 0;
        end else if (count == NUM_CLK - 1) begin
                count <= 0;
                o_tick_1us <= 1;
            end else begin
                count <= count + 1;
                o_tick_1us <= 0;
            end
        end
endmodule
