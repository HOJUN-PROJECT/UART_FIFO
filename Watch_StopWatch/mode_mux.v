module watch_mode_2X1(
    input sel,
    input [23:0] stop_w,
    input [23:0] watch,
    output [23:0] watch_stop_mode
);

    assign watch_stop_mode = (sel == 1) ? watch : stop_w;

endmodule
