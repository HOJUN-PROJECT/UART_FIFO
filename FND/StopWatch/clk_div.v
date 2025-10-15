module clk_div_1khz_watch (
    input  clk,
    input  rst,
    output o_clk_1khz
);
    reg [$clog2(100_000)-1 : 0] r_counter;
    reg r_clk_1khz;
    assign o_clk_1khz = r_clk_1khz;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            r_counter  <= 0;
            r_clk_1khz <= 1'b0;
        end else begin
            if (r_counter == 100_000 - 1) begin
                r_counter  <= 0;
                r_clk_1khz <= 1'b1;
            end else begin
                r_counter  <= r_counter + 1;
                r_clk_1khz <= 1'b0;
            end
        end
    end
endmodule
