module write_clk (
    input clk,
    input rst,
    output reg wclk
);
    parameter DIV =3;
    reg [$clog2(DIV)-1:0] cnt;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt  <=0;
            wclk <=0;
        end else if (cnt == DIV-1) begin
            cnt  <=0;
            wclk <=~wclk;
        end else begin
            cnt  <= cnt +1;
        end
    end
endmodule
