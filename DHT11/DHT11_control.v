module dht11_control (
    input clk,
    input rst,
    input i_start,
    input i_tick,
    inout dht_io,
    input [1:0]en,

    output o_vaild,
    output [15:0] humid,
    output [15:0] temp,
    output [3:0] led
);

    localparam  [3:0] IDLE=0, START=1, WAIT=2, SYNC_L=3, SYNC_H=4,
                      DATA=5, DATA_DETECT=6, RECVIE=8, CAL = 7;

    reg [3:0] s, ns;
    reg [9:0] sum10;
    reg [7:0] csum_reg, csum_next;
    reg [5:0] bit_cnt_next, bit_cnt_reg;
    reg dht_out_reg, dht_out_next;
    reg dht_io_enable_reg, dht_io_enable_next;
    reg [39:0] data_out_reg, data_out_next;
    reg [19:0] i_tick_reg, i_tick_next;
    reg vaild_next, vaild_reg;

    assign dht_io = (dht_io_enable_reg) ? dht_out_reg : 1'bz;
    assign o_vaild = vaild_reg;
    assign led = s;
    assign humid = data_out_reg[39:24];
    assign temp = data_out_reg[23:8];

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            s                 <= IDLE;
            dht_out_reg       <= 1;
            dht_io_enable_reg <= 1;
            i_tick_reg        <= 0;
            data_out_reg      <= 0;
            bit_cnt_reg       <= 0;
            vaild_reg         <= 0;
            csum_reg          <= 0;
        end else begin
            s                 <= ns;
            dht_out_reg       <= dht_out_next;
            dht_io_enable_reg <= dht_io_enable_next;
            i_tick_reg        <= i_tick_next;
            data_out_reg      <= data_out_next;
            bit_cnt_reg       <= bit_cnt_next;
            vaild_reg         <= vaild_next;
            csum_reg          <= csum_next;
        end
    end

    always @(*) begin
        ns                 = s;
        i_tick_next        = i_tick_reg;
        vaild_next         = vaild_reg;
        dht_out_next       = dht_out_reg;
        dht_io_enable_next = dht_io_enable_reg;
        data_out_next      = data_out_reg;
        bit_cnt_next       = bit_cnt_reg;
        csum_next          = csum_reg;

        case (s)
            IDLE: begin
                dht_out_next = 1'b1;
                if(en == 3) begin
                    if (i_start) begin
                        dht_out_next = 1'b0;
                        ns = START;
                    end
                end
            end

            START: begin
                bit_cnt_next = 0;
                if (i_tick) begin
                    if (i_tick_reg == 19000) begin
                        dht_out_next = 1'b1;
                        ns = WAIT;
                        i_tick_next = 0;
                    end else begin
                        i_tick_next = i_tick_reg + 1;
                    end
                end
            end

            WAIT: begin
                if (i_tick) begin
                    if (i_tick_reg == 30) begin
                        i_tick_next = 0;
                        dht_io_enable_next = 0;
                        ns = SYNC_L;
                    end else begin
                        i_tick_next = i_tick_reg + 1;
                    end
                end
            end

            SYNC_L: begin
                if (i_tick) begin
                    if (i_tick_reg > 20) begin
                        if (dht_io) begin
                            ns = SYNC_H;
                            i_tick_next = 0;
                        end
                    end else i_tick_next = i_tick_reg + 1;
                end
            end

            SYNC_H: begin
                if (i_tick) begin
                    if (!dht_io) begin
                        ns = DATA;
                    end
                end
            end

            DATA: begin
                if (i_tick) begin
                    if (dht_io) begin
                        ns = DATA_DETECT;
                    end
                end
            end

            DATA_DETECT: begin
                if (i_tick) begin
                    if (!dht_io) begin
                        bit_cnt_next = bit_cnt_reg + 1;
                        ns = CAL;
                    end else begin
                        i_tick_next = i_tick_reg + 1;
                    end
                end
            end

            CAL: begin
                if (i_tick_reg > 40) begin
                    data_out_next[40-bit_cnt_reg] = 1'b1;
                end else begin
                    data_out_next[40-bit_cnt_reg] = 1'b0;
                end
                i_tick_next = 0;
                if (bit_cnt_reg == 40) begin
                    ns = RECVIE;
                end else begin
                    ns = DATA;
                end
            end

            RECVIE: begin
                if (i_tick_reg > 50) begin
                    dht_io_enable_next = 1;
                    if((data_out_reg[39:32] 
                    + data_out_reg[31:24] 
                    + data_out_reg[23:16] 
                    + data_out_reg[15:8]) == data_out_reg[7:0]) begin
                        vaild_next = 1'b1;
                    end else begin
                        vaild_next = 1'b0;
                    end
                    ns = IDLE;
                end else begin
                    i_tick_next = i_tick_reg + 1;
                end
            end
        endcase
    end
endmodule
