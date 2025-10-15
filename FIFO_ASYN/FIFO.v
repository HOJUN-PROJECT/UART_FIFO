module fifo (
    input       wclk,
    input       rclk,
    input       rst,
    input [7:0] wdata,
    input       wr,
    input       rd,
    output reg [7:0] rdata,
    output      full,
    output      empty
);
    reg [7:0] mem [0:3];          // 4-depth
    reg [1:0] wptr_bin, rptr_bin; // 2비트 포인터
    reg [1:0] wptr_gray, rptr_gray;
    reg [1:0] rptr_gray_sync1, rptr_gray_sync2;
    reg [1:0] wptr_gray_sync1, wptr_gray_sync2;
    // Binary to Gray 변환 함수
    function [1:0] bin2gray;
        input [1:0] bin;
        bin2gray = (bin >>1) ^ bin;
    endfunction
    always @(posedge wclk or posedge rst) begin
        if (rst) begin
            wptr_bin  <=0;
            wptr_gray <=0;
        end else if (wr &&!full) begin
            mem[wptr_bin] <= wdata;
            wptr_bin  <= wptr_bin +1;
            wptr_gray <= bin2gray(wptr_bin +1);
        end
    end
    always @(posedge rclk or posedge rst) begin
        if (rst) begin
            rptr_bin  <=0;
            rptr_gray <=0;
            rdata     <=0;
        end else if (rd &&!empty) begin
            rdata     <= mem[rptr_bin];
            rptr_bin  <= rptr_bin +1;
            rptr_gray <= bin2gray(rptr_bin +1);
        end
    end

    always @(posedge wclk or posedge rst) begin
        if (rst) begin
            rptr_gray_sync1 <=0;
            rptr_gray_sync2 <=0;
        end else begin
            rptr_gray_sync1 <= rptr_gray;
            rptr_gray_sync2 <= rptr_gray_sync1;
        end
    end
    always @(posedge rclk or posedge rst) begin
        if (rst) begin
            wptr_gray_sync1 <=0;
            wptr_gray_sync2 <=0;
        end else begin
            wptr_gray_sync1 <= wptr_gray;
            wptr_gray_sync2 <= wptr_gray_sync1;
        end
    end
    assign full  = (wptr_gray == {~rptr_gray_sync2[1], rptr_gray_sync2[0]});
    assign empty = (rptr_gray == wptr_gray_sync2);
endmodule
