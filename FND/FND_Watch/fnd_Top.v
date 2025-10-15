module fnd_controller_watch (
    input         clk,
    input         rst,
    input   mode,
    input  [23:0] i_time,
    output [ 3:0] watch_fnd_com,
    output [ 7:0] watch_fnd_data
);

    wire [3:0] w_bcd, w_msec_sec, w_min_hour, w_msec_digit_1, w_msec_digit_10, w_dot_data;
    wire [3:0] w_sec_digit_1, w_sec_digit_10;
    wire [3:0] w_min_digit_1, w_min_digit_10;
    wire [3:0] w_hour_digit_1, w_hour_digit_10;

    wire [2:0] w_sel;
    wire w_clk_1khz;


    clk_div_1khz_watch U_CLK_DIV_1KHZ_watch (
        .clk(clk),
        .rst(rst),
        .o_clk_1khz(w_clk_1khz)
    );

    counter_8_watch U_COUNTER_8_watch (
        .clk  (w_clk_1khz),
        .rst(rst),
        .sel  (w_sel)
    );


    decoder_2x4_watch U_DRCODER_2x4_watch (
        .sel(w_sel[1:0]),
        .fnd_com(watch_fnd_com)
    );

    digit_splitter #(
        .BIT_WIDTH(7)
    ) U_MSEC_DS (
        .count_data(i_time[6:0]),
        .digit_1(w_msec_digit_1),
        .digit_10(w_msec_digit_10)
    );

    digit_splitter #(
        .BIT_WIDTH(6)
    ) U_SEC_DS (
        .count_data(i_time[12:7]),
        .digit_1(w_sec_digit_1),
        .digit_10(w_sec_digit_10)
    );

    digit_splitter #(
        .BIT_WIDTH(6)
    ) U_MIN_DS (
        .count_data(i_time[18:13]),
        .digit_1(w_min_digit_1),
        .digit_10(w_min_digit_10)
    );

    digit_splitter #(
        .BIT_WIDTH(5)
    ) U_HOUR_DS (
        .count_data(i_time[23:19]),
        .digit_1(w_hour_digit_1),
        .digit_10(w_hour_digit_10)
    );

    mux_2X1_watch U_MUX_2X1_watch (
        .sel(mode),
        .msec_sec(w_msec_sec),
        .min_hour(w_min_hour),
        .bcd(w_bcd)
    );

    mux_8x1_watch U_Mux_8X1_Min_Hour_watch (

        .digit_1(w_min_digit_1),
        .digit_10(w_min_digit_10),
        .digit_100(w_hour_digit_1),
        .digit_1000(w_hour_digit_10),
        .digit_5(4'hf),
        .digit_6(4'hf),
        .digit_7(w_dot_data),  // digit dot display
        .digit_8(4'hf),
        .sel(w_sel),
        .bcd(w_min_hour)
    );
    
    compa_msec_watch U_COMP_DOT_watch (
        .msec(i_time[6:0]),
        .dot_data(w_dot_data)
    );


    mux_8x1_watch U_Mux_8X1_Msec_sec_watch (

        .digit_1(w_msec_digit_1),
        .digit_10(w_msec_digit_10),
        .digit_100(w_sec_digit_1),
        .digit_1000(w_sec_digit_10),
        .digit_5(4'hf),
        .digit_6(4'hf),
        .digit_7(w_dot_data),  // digit dot display
        .digit_8(4'hf),
        .sel(w_sel),
        .bcd(w_msec_sec)
    );

    bcd_decoder_watch U_BCD_DECODER_watch (
        .bcd(w_bcd),
        .fnd_data(watch_fnd_data)
    );

endmodule
