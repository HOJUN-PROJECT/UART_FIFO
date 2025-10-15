`timescale 1ns / 1ps

module embadded_TOP (
    input         rst,
    input         clk,
    input [15:13] sw,
    input         time_mode,
    input         watch_mode,
    input         Btn_U,
    input         Btn_D,
    input         Btn_L,
    input         Btn_R,
    input         rx,
    input         echo,
    output         tx,
    output         trig,

    inout dht_io,

    output  [3:0] fnd_com,
    output  [7:0] fnd_data,
    output [4:0] led
);
    
    wire [1:0] w_en;
      
    wire [7:0] w_humid_data, w_watch_data, w_sr04_data;
    wire [3:0] w_humid_com, w_watch_com, w_sr04_com; 
      
    DHT11_top U_DHT11(
        .clk(clk),
        .rst(rst),
        .btn_L(Btn_L),
        .dht_io(dht_io),
        .humid_fnd_com(w_humid_com),
       . humid_fnd(w_humid_data),
        .led(led),
        .en(w_en)
    );
    
     team_cu U_TEAM_CU (
        .clk(clk),
        .rst(rst),
        .sw(sw),
        .en(w_en)
    );
    
 uart_watch_top U_STOP_WATCH(
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .Btn_R(Btn_R),
        .Btn_D(Btn_D),
        .Btn_L(Btn_L),
        .Btn_U(Btn_U),
        .watch_mode(watch_mode),
        .time_mode(time_mode),
        .tx(tx),
        .fnd_com(w_watch_com),
        .fnd_data(w_watch_data),
        .en(w_en)
 );
    
     sr04_top U_sr04_top(
        .clk(clk),        // 100MHz
        .rst(rst),        // 리셋
        .btn_start(Btn_R),  // 거리 측정 ?��?�� (버튼)
        .echo(echo),       // ?��?�� Echo ?��?��
        .en(w_en),
        .trig(trig),       
        .fnd_com_sr04(w_sr04_com),    // 7?���? ?��?�� 공통?��
        .fnd_data_sr04(w_sr04_data)    // 7?���? ?��?�� ?��?��?��
);
       to_fnd U_to_fnd(
             .a_com(w_watch_com), 
             .b_com(w_sr04_com), 
             .c_com(w_humid_com),  
             .a_data(w_watch_data), 
             .b_data(w_sr04_data), 
             .c_data(w_humid_data),
             .sel(w_en),                   
            .fnd_data(fnd_data),
            .fnd_com(fnd_com)
    );
    
endmodule
