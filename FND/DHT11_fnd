module fnd_controller_humid (
    input        clk,
    input        reset,
    input  [15:0] humid,
    input  [15:0] temp,
    output [3:0] humid_fnd_com,
    output [7:0] humid_fnd
);

    wire [3:0] w_hu1, w_hu10;
    wire [3:0] w_te1, w_te10;
    wire [3:0] w_counter;
    wire [1:0] w_sel;
    wire w_clk_1khz;

    // 1kHz multiplexing
    clk_div_1khz_humid u_clk_div_1khz_humid (
        .clk(clk),
        .reset(reset),
        .o_clk_1khz(w_clk_1khz)
    );

    counter_4_humid u_counter_4_humid (
        .clk  (w_clk_1khz),
        .reset(reset),
        .sel  (w_sel)
    );

    digit_splitter_humtemp u_digit_splitter (
        .humid(humid[15:8]),  
        .temp(temp[15:8]),
        .hu1(w_hu1),
        .hu10(w_hu10),
        .te1(w_te1),
        .te10(w_te10)
    );

    decorder_2x4_humid u_decorder_2x4_humid (
        .sel(w_sel),
        .fnd_com(humid_fnd_com)
    );

    mux_4x1_humtemp u_mux_4x1_humid (
        .hu1(w_hu1),
        .hu10(w_hu10),
        .te1(w_te1),
        .te10(w_te10),
        .sel(w_sel),
        .bcd(w_counter)
    );

    bcd_decorder_humid u_bcd_decorder_humid (
        .bcd(w_counter),
        .fnd(humid_fnd)
    );

endmodule
