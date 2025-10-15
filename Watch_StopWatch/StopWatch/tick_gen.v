module stop_tick_gen_100hz (
    input  clk,
    input  rst,
    input i_runstop,
    output o_tick_100hz
);

    parameter FCOUNT = 100_000_000 / 100;
    reg [$clog2(FCOUNT)-1:0] r_counter;
    reg r_tick;

    assign o_tick_100hz = r_tick;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            r_counter <= 0;
            r_tick    <= 1'b0;
        end else begin
            if(i_runstop)begin
                if (r_counter == FCOUNT - 1) begin
                    r_counter <= 0;
                    r_tick    <= 1'b1;
                end else begin
                    r_counter <= r_counter + 1;
                    r_tick    <= 1'b0;
                end
            end else begin
                r_counter <= r_counter;
                r_tick <= 1'b0;
            end
        end
    end

endmodule
