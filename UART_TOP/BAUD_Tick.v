module tick_gen (
    input clk,
    input rst,
    output reg b_tick
);
    parameter BAUD_Priod =9600 *16;
    parameter BAUD_TICK =100_000_000 / BAUD_Priod; // ≈10416
    reg [$clog2(BAUD_TICK)-1:0] cnt;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt <=0;
            b_tick <=0;
        end else if (cnt == BAUD_TICK -1) begin
            cnt <=0;
            b_tick <=1;
        end else begin
            cnt <= cnt +1;
            b_tick <=0;
        end
    end
endmodule
