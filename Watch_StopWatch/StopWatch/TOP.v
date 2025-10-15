module stopwatch (
    input        clk,
    input        rst,
    // input  mode,
    input        Btn_L,
    input        Btn_R,

    output [6:0] msec,
    output [5:0] sec,
    output [5:0] min,
    output [4:0] hour 
);


    wire w_runstop;
    wire w_clear;
    wire w_btn_r;
    wire w_btn_l;   

    stopwatch_dp1 U_SW_DP(
        .clk(clk),
        .i_runstop(w_runstop),
        .i_clear(w_clear),
        .rst(rst),
        .msec(msec),
        .sec(sec),
        .min(min),
        .hour(hour)
    );

    stopwatch_cu U_SW_CU (
        .clk(clk),
        .rst(rst),
        .i_runstop(Btn_R),
        .i_clear(Btn_L),
        .o_runstop(w_runstop),
        .o_clear(w_clear)
    );

endmodule
