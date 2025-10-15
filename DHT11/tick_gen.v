module micro_tick_gen (
    input  clk,
    input  rst,
    output o_tick
);
    localparam TICK_COUNT = 100_000_000 / 1_000_000;
    reg [$clog2(TICK_COUNT) - 1:0] counter_reg, counter_next;
    reg tick_reg, tick_next;
    // output
    assign o_tick = tick_reg;
    //SL
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter_reg <= 0;
            tick_reg    <= 1'b0;
        end else begin
            counter_reg <= counter_next;
            tick_reg    <= tick_next;
        end
    end
    // next CL
    always @(*) begin
        counter_next = counter_reg;
        tick_next    = tick_reg;
        if (counter_reg == TICK_COUNT - 1) begin
            counter_next = 0;
            tick_next    = 1'b1;
        end else begin
            counter_next = counter_reg + 1;
            tick_next    = 1'b0;
        end
    end
endmodule
