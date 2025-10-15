module top_fifo_connect (
    input        clk,       // System clock (UART 등)
    input        rst,
    input  [7:0] push_data, // clk domain
    input        push,      // clk domain
    input        pop,       // clk domain (or sync to rclk)
    output [7:0] pop_data,
    output       full,
    output       empty
);
    // 내부 클럭 (비동기 도메인)
    wire wclk, rclk;
    wire push_sync; // wclk domain으로 동기화된 push
    // -----------------------------
    // 클럭 분주기 (비동기 도메인 생성)
    // -----------------------------
    write_clk u_wclk (.clk(clk), .rst(rst), .wclk(wclk));
    read_clk  u_rclk (.clk(clk), .rst(rst), .rclk(rclk));
    // -----------------------------
    // push 신호를 wclk 도메인으로 동기화
    // -----------------------------
    wire push_wclk_pulse;
    push_sync_to_wclk u_push_sync (
        .clk_src(clk),
        .sig_in(push),
        .rst(rst),
        .clk_dst(wclk),
        .sig_out_pulse(push_wclk_pulse)
    );
    // -----------------------------
    // FIFO 본체
    // -----------------------------
    fifo u_fifo (
        .wclk (wclk),
        .rclk (rclk),
        .rst  (rst),
        .wdata(push_data),
        .wr   (push_wclk_pulse),
        .rd   (pop),
        .rdata(pop_data),
        .full (full),
        .empty(empty)
    );
endmodule
