module read_clk (
    input clk,
    input rst,
    output reg rclk
);
    parameter DIV =5;
    reg [$clog2(DIV)-1:0] cnt;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt  <=0;
            rclk <=0;
        end else if (cnt == DIV-1) begin
            cnt  <=0;
            rclk <=~rclk;
        end else begin
            cnt  <= cnt +1;
        end
    end
endmodule
