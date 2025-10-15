module DHT11_top (
    input        clk,
    input        rst,
    input        btn_L,
    inout        dht_io,
    input  [1:0] en,
    output [3:0] humid_fnd_com,
    output [7:0] humid_fnd,
    output [4:0] led
);

    wire o_btn_L;
    wire w_tick;
    wire [15:0] w_humid, w_temp;
    // 버튼 ?��바운?��
    btn_debounce U_B_L (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btn_L),
        .o_btn(o_btn_L)
    );

    // DHT11 ?��?�� 모듈
    dht11_control U_CONTROL_dht11 (
        .clk    (clk),
        .rst    (rst),
        .i_start(o_btn_L),
        .i_tick (w_tick),
        .dht_io (dht_io),
        .o_vaild(led[4]),
        .humid  (w_humid),
        .temp   (w_temp),
        .led    (led[3:0]),
        .en(en)
    );

    // 1us tick ?��?���?
    micro_tick_gen U_micro_tick (
        .clk   (clk),
        .rst   (rst),
        .o_tick(w_tick)
    );

    // FND ?��?���?: ?�� ?�� ?���? ?��?��, ?�� ?�� ?���? ?��?��
    fnd_controller_humid U_fnd_controller_humid (
        .clk    (clk),
        .reset  (rst),
        .humid  (w_humid),
        .temp   (w_temp),
        .humid_fnd_com(humid_fnd_com),
        .humid_fnd    (humid_fnd)
    );

endmodule
