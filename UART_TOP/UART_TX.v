module uart_tx (
    input        clk,
    input        rst,
    input        start_trigger,
    input  [7:0] tx_data,
    input        b_tick,
    output       tx,
    output       tx_busy
);
    localparam [2:0] IDLE=0, START=1, DATA=2, STOP=3;
    reg [2:0] state, next;
    reg [3:0] b_tick_cnt, b_tick_cnt_next;
    reg [2:0] bit_cnt, bit_cnt_next;
    reg [7:0] data_reg, data_next;
    reg tx_reg, tx_next, tx_busy_reg, tx_busy_next;
    assign tx = tx_reg;
    assign tx_busy = tx_busy_reg;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            tx_reg <=1'b1;
            tx_busy_reg <=0;
            b_tick_cnt <=0;
            bit_cnt <=0;
            data_reg <=0;
        end else begin
            state <= next;
            tx_reg <= tx_next;
            tx_busy_reg <= tx_busy_next;
            b_tick_cnt <= b_tick_cnt_next;
            bit_cnt <= bit_cnt_next;
            data_reg <= data_next;
        end
    end
    always @(*) begin
        next = state;
        tx_next = tx_reg;
        tx_busy_next = tx_busy_reg;
        b_tick_cnt_next = b_tick_cnt;
        bit_cnt_next = bit_cnt;
        data_next = data_reg;
        case (state)
            IDLE: begin
                tx_next =1'b1;
                tx_busy_next =0;
                if (start_trigger) begin
                    tx_busy_next =1;
                    data_next = tx_data;
                    next = START;
                end
            end
            START: begin
                tx_next =1'b0;
                if (b_tick) begin
                    if (b_tick_cnt ==15) begin
                        b_tick_cnt_next =0;
                        bit_cnt_next =0;
                        next = DATA;
                    end else
                        b_tick_cnt_next = b_tick_cnt + 1;
                end
            end
            DATA: begin
                tx_next = data_reg[0];
                if (b_tick) begin
                    if (b_tick_cnt ==15) begin
                        data_next = data_reg >>1;
                        b_tick_cnt_next =0;
                        if (bit_cnt ==7)
                            next = STOP;
                        else
                            bit_cnt_next = bit_cnt +1;
                    end else
                        b_tick_cnt_next = b_tick_cnt + 1;
                end
            end
            STOP: begin
                tx_next =1'b1;
                if (b_tick) begin
                    if (b_tick_cnt ==15) begin
                        next = IDLE;
                        tx_busy_next =0;
                    end else
                        b_tick_cnt_next = b_tick_cnt + 1;
                end
            end
        endcase
    end
endmodule
