module uart_watch_top(
    input clk,
    input rst,
    input rx,
    input Btn_R,
    input Btn_D,
    input Btn_L,
    input Btn_U,
    input watch_mode,
    input time_mode,
    input [1:0] en,
    output tx,
    output [3:0]fnd_com,
    output [7:0]fnd_data
    );

    wire w_b_r, w_b_l, w_b_u, w_b_d;
    wire [7:0] w_rx_fifo_data;
    wire w_rx_trigger;
    wire w_r, w_l, w_d, w_u ,w_s, w_S;
    wire w_final_R, w_final_L, w_final_D, w_final_U;
    wire w_mode, w_time;
    // wire o_time_mode, o_watch_mode;

    Btn_de U_BD_TOP(
        .clk(clk), 
        .rst(rst),
        .Btn_R(Btn_R), 
        .Btn_L(Btn_L), 
        .Btn_D(Btn_D), 
        .Btn_U(Btn_U),
        .o_btn_R(w_b_r),
        .o_btn_L(w_b_l),
        .o_btn_D(w_b_d),
        .o_btn_U(w_b_u)

    );


    uart_top U_UART_TOP(
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .tx(tx),
        .rx_pop_data(w_rx_fifo_data),
        .rx_trigger(w_rx_trigger)
    );

    com_ctl U_COM_CTRL(
        .clk(clk),
        .rst(rst),
        .rx_data(w_rx_fifo_data),   
        .rx_trigger(w_rx_trigger),
        .r(w_r),
        .l(w_l), 
        .u(w_u), 
        .d(w_d),
        .watch(w_mode),
        .hour_min(w_time)
    );

    bnt_pri U_btn_pri(
        .Btn_R(w_b_r),
        .Btn_L(w_b_l) ,
        .Btn_U(w_b_u) ,
        .Btn_D(w_b_d)   ,
        .r(w_r) ,
        .l(w_l) ,
        .u(w_u) ,
        .d(w_d),                   
        .final_R(w_final_R),
        .final_L(w_final_L),
        .final_U(w_final_U),
        .final_D(w_final_D),
        .en(en)
    );


    

    watch_stopwatch U_watch_stopwatch(
        .clk(clk), 
        .rst(rst),
        .Btn_L(w_final_L),
        .Btn_R(w_final_R),
        .Btn_U(w_final_U),
        .Btn_D(w_final_D),
        .time_mode(time_mode || w_time),
        .watch_mode(watch_mode || w_mode),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data)
    );

endmodule
