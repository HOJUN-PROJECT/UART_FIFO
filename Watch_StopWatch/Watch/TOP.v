module watch(
    input clk, rst,
    input Btn_L,
    input Btn_R,
    input Btn_U,
    input Btn_D,

    output [6:0] msec,
    output [5:0] sec,
    output [5:0] min,
    output [4:0] hour 
    );

    wire w_run_hour;
    wire w_run_min;
    wire w_run_sec;

    wire w_btn_r;
    wire w_btn_l;  
    wire w_btn_u;
    wire w_btn_d;


    watch_dp U_W_DP(
        .clk(clk),
        .rst(rst),
        .msec(msec),
        .sec(sec),
        .min(min),
        .hour(hour),
        .i_run_sec(w_run_sec),
        .i_run_min(w_run_min),
        .i_run_hour(w_run_hour)
    );


    watch_cu U_W_CU (
        .clk(clk),
        .rst(rst),
        .i_run_sec(Btn_U),
        .i_run_min(Btn_L),
        .i_run_hour(Btn_D),
        .o_run_sec(w_run_sec),
        .o_run_min(w_run_min),
        .o_run_hour(w_run_hour)
    );

endmodule
