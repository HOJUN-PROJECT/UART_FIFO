module uart_rx (
    input        clk,
    input        rst,
    input        rx,
    input        b_tick,
    output [7:0] rx_data,
    output       rx_done
);
    localparam [1:0] IDLE =0, START =1, DATA =2, STOP =3;
    // state
    reg [1:0] state, nstate;
    // tick count
    reg [4:0] b_tick_cnt_reg, b_tick_cnt_next;
    // bit count
    reg [3:0] bit_cnt, bit_cnt_next;
    // output
    reg rx_done_reg, rx_done_next;
    // rx_internal buffer
    reg [7:0] rx_buf_reg, rx_buf_next;
    // output
    assign rx_data = rx_buf_reg;
    assign rx_done = rx_done_reg;
    // state
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state          <= IDLE;
            b_tick_cnt_reg <=0;
            bit_cnt        <=0;
            rx_done_reg    <=0;
            rx_buf_reg     <=0;
        end else begin
            state          <= nstate;
            b_tick_cnt_reg <= b_tick_cnt_next;
            bit_cnt        <= bit_cnt_next;
            rx_done_reg    <= rx_done_next;
            rx_buf_reg     <= rx_buf_next;
        end
    end
    always @(*) begin
        nstate = state;
        b_tick_cnt_next = b_tick_cnt_reg;
        bit_cnt_next = bit_cnt;
        rx_done_next = rx_done_reg;
        rx_buf_next = rx_buf_reg;
        case (state)
            IDLE: begin
                rx_done_next =0;
                if (b_tick ==1 && rx ==0) begin
                    b_tick_cnt_next =0;
                    nstate = START;
                end else begin
                    nstate = IDLE;
                end
            end
            START: begin
                if (b_tick) begin
                    if (b_tick_cnt_reg ==23) begin
                        bit_cnt_next    =0;
                        b_tick_cnt_next =0;
                        nstate          = DATA;
                    end else begin
                        b_tick_cnt_next = b_tick_cnt_reg +1;
                    end
                end
            end
            DATA: begin
                if (b_tick) begin
                    if (b_tick_cnt_reg ==0) begin
                        rx_buf_next[7] = rx;
                    end
                    if (b_tick_cnt_reg ==15) begin
                        if (bit_cnt ==7) begin
                            nstate = STOP;
                            bit_cnt_next =0;
                        end else begin
                            b_tick_cnt_next =0;
                            bit_cnt_next = bit_cnt +1;
                            rx_buf_next = rx_buf_reg >>1;
                        end
                    end else begin
                        b_tick_cnt_next = b_tick_cnt_reg +1;
                    end
                end
            end
            STOP: begin
                if (b_tick) begin
                    rx_done_next =1;
                    nstate = IDLE;
                end
            end
        endcase
    end
endmodule
