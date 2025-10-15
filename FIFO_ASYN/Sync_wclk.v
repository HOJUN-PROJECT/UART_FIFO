module push_sync_to_wclk (
    input  clk_src,       // 원래 push 신호의 클럭
    input  sig_in,        // clk_src 도메인 push
    input  rst,
    input  clk_dst,       // 동기화 대상 wclk
    output sig_out_pulse  // wclk 도메인에서 1클럭 펄스
);

    reg toggle_src;
    always @(posedge clk_src or posedge rst) begin
        if (rst)
            toggle_src <=0;
        else if (sig_in)
            toggle_src <=~toggle_src;
    end
    reg sync1, sync2;
    always @(posedge clk_dst or posedge rst) begin
        if (rst) begin
            sync1 <=0;
            sync2 <=0;
        end else begin
            sync1 <= toggle_src;
            sync2 <= sync1;
        end
    end
    assign sig_out_pulse = sync1 ^ sync2;  // 엣지 시 1클럭 high
endmodule
