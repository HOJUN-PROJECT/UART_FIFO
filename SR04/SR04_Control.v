module sr04_controller_fsm (
    input        clk,
    input        rst,
    input        i_tick,
    input        start,
    input        echo,
    input [1:0] en,
    output       o_trig,
    output [8:0] o_dist
);
    reg [1:0] state, next;
    reg [15:0] tick_cnt_reg, tick_cnt_next;
    reg [8:0] dist_reg, dist_next;
    reg trig_reg, trig_next;
    parameter IDLE = 2'b00, START = 2'b01, WAIT = 2'b10, DIST = 2'b11;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state    <= IDLE;
            tick_cnt_reg <= 0;
            trig_reg <= 0;
            dist_reg <= 0;
        end else begin
            state <= next;
            trig_reg <= trig_next;
            dist_reg <= dist_next;
            tick_cnt_reg <= tick_cnt_next;
        end
    end

    assign o_dist = dist_reg;
    assign o_trig = trig_reg;

    always @(*) begin
        next = state;
        dist_next = dist_reg;
        trig_next = trig_reg;
        tick_cnt_next = tick_cnt_reg;
        case (state)
            IDLE: begin
                tick_cnt_next = 0;
                if(en==2)begin
                    if (start) begin
                        next = START;
                    end
                end
            end
            START: begin
                trig_next = 1'b1;
                if (i_tick) begin
                    tick_cnt_next = tick_cnt_reg + 1;
                    if (tick_cnt_reg == 10) begin
                        next = WAIT;
                        tick_cnt_next = 0;
                    end
                end
            end
            WAIT: begin
                trig_next = 1'b0;
                if (i_tick) begin
                    if (echo) begin
                        next = DIST;
                    end
                end
            end
            DIST: begin
                if (i_tick) begin
                    if (echo) begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                    if (!echo) begin
                        dist_next = tick_cnt_reg / 58;
                        next = IDLE;
                    end
                end
            end
        endcase
    end
endmodule
