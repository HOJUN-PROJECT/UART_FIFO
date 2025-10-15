module mux_2X1_watch (
    input sel,
    input [3:0] msec_sec,
    input [3:0] min_hour,
    output [3:0] bcd

);
    assign bcd = (sel == 1) ? min_hour : msec_sec;
endmodule
