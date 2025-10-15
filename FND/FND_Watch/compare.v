module compa_msec_watch(
    input [6:0] msec,
    output [3:0] dot_data
);
    assign dot_data = (msec < 50) ? 4'hf : 4'he;


endmodule
