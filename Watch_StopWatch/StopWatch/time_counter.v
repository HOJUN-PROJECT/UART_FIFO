module stop_time_counter #(
    parameter BIT_WIDTH = 7,
    TIME_COUNT = 100
) (
    input clk, 
    input rst,
    input i_tick,
    input i_clear,
    output [BIT_WIDTH-1:0] o_time,
    output o_tick
);

    reg [$clog2(TIME_COUNT) -1:0] count_reg, count_next;
    reg tick_reg, tick_next;

    assign o_time = count_reg;
    assign o_tick = tick_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count_reg <= 0;
            tick_reg <= 1'b0;
        end else begin
            count_reg <= count_next;
            tick_reg <= tick_next;
        end
    end

    always @(*) begin  
        count_next = count_reg;
        tick_next = 1'b0;
        if (i_tick) begin
            if (count_reg == TIME_COUNT - 1) begin
                    count_next = 0;
                    tick_next = 1'b1;
            end else begin
                count_next = count_reg + 1;
                tick_next = 1'b0; 
            end
        end else begin
            tick_next = 1'b0;
        end
        if (i_clear)begin
            count_next = 0;
        end
    end

endmodule
