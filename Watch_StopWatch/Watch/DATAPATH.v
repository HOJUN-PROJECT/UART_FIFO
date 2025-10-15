module watch_dp (
    input        clk,
    input        rst,
    input i_run_sec,
    input i_run_min,
    input i_run_hour,
    output [6:0] msec,
    output [5:0] sec,
    output [5:0] min,
    output [4:0] hour
);

    wire w_tick_100hz;
    wire w_sec_tick;
    wire w_min_tick;
    wire w_hour_tick;
    wire w_run_sec, w_run_min, w_run_hour;


    time_counter #(
        .BIT_WIDTH(7),
        .TIME_COUNT(100)
    ) U_MSEC_COUNTER (
        .clk(clk), 
        .rst(rst),
        .i_tick(w_tick_100hz),
        .o_time(msec),
        .o_tick(w_sec_tick)
    );

    time_counter #(
        .BIT_WIDTH(6),
        .TIME_COUNT(60)
    ) U_SEC_COUNTER (
        .clk(clk), 
        .rst(rst),
        .i_run_sec(i_run_sec),
        .i_run_min(1'b0),
        .i_run_hour(1'b0),
        .i_tick(w_sec_tick),
        .o_time(sec),
        .o_tick(w_min_tick)
    );
    
    time_counter #(
        .BIT_WIDTH(6),
        .TIME_COUNT(60)
    ) U_MIN_COUNTER (
        .clk(clk), 
        .rst(rst),
        .i_run_sec(1'b0),
        .i_run_min(i_run_min),
        .i_run_hour(1'b0),
        .i_tick(w_min_tick),
        .o_time(min),
        .o_tick(w_hour_tick)
    );
    
    time_counter #(
        .BIT_WIDTH(6),
        .TIME_COUNT(60)
    ) U_HOUR_COUNTER (
        .clk(clk), 
        .rst(rst),
        .i_run_sec(1'b0),
        .i_run_min(1'b0),
        .i_run_hour(i_run_hour),
        .i_tick(w_hour_tick),
        .o_time(hour),
        .o_tick()
    );
    
    tick_gen_100hz U_TICK_GEN_100HZ(
        .clk(clk),
        .rst(rst),
        .o_tick_100hz(w_tick_100hz)
    );

endmodule
