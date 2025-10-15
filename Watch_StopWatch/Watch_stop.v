module watch_stopwatch(
    input clk, rst,
    input Btn_L,
    input Btn_R,
    input Btn_U,
    input Btn_D,
    input watch_mode,
    input time_mode,

    output [3:0] fnd_com,
    output [7:0] fnd_data
    );


    wire [23:0]w_time;
    wire [5:0] w_sec, stop_sec;
    wire [6:0] stop_msec, w_msec;
    wire [5:0] stop_min, w_min;
    wire [4:0] stop_hour, w_hour;

    stopwatch U_STOPWATCH(
        .clk(clk),
        .rst(rst),
        .msec(stop_msec),
        .sec(stop_sec),
        .min(stop_min),
        .hour(stop_hour),
        .Btn_R(Btn_R),
        .Btn_L(Btn_L)
    );


    fnd_controller_watch U_FND_CNTL (
        .clk(clk),
        .rst(rst),
        .i_time(w_time),
        .watch_fnd_com(fnd_com),
        .watch_fnd_data(fnd_data),
        .mode(time_mode)
    );

        watch U_WATCH(
        .clk(clk),
        .rst(rst),
        .msec(w_msec),
        .sec(w_sec),
        .min(w_min),
        .hour(w_hour),
        .Btn_R(Btn_R),
        .Btn_L(Btn_L),
        .Btn_U(Btn_U),
        .Btn_D(Btn_D)
    );

    watch_mode_2X1 U_MODE_2X1(
        .sel(watch_mode),
        .stop_w({stop_hour, stop_min, stop_sec, stop_msec}),
        .watch({w_hour, w_min, w_sec, w_msec}),
        .watch_stop_mode(w_time)
    );
endmodule
