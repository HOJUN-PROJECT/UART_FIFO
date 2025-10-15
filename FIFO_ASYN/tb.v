`timescale 1ns / 1ps
module tb;
    reg clk =0;
    reg rst =1;
    reg rx;
    wire tx;
    wire [2:0] led;
    // DUT 인스턴스 (상위 모듈명에 맞게 수정)
    GEN dut (
        .clk(clk),
        .rst(rst),
        .rx (rx),
        .tx (tx),
        .led(led)
    );
    // ==========================================
    // 100 MHz 클록 생성 (주기 10 ns)
    // ==========================================
    always #5 clk =~clk;
    // ==========================================
    // UART Timing Parameter (9600 baud 기준)
    // ==========================================
    localparam real BIT_PERIOD =104_167;  // ns 단위 (1 / 9600 s)
    // ==========================================
    // UART 송신 태스크 (LSB-first, 8 N 1)
    // ==========================================
    task send_uart_byte(input [7:0] data);
        integer i;
        begin
            // Start bit (low)
            rx =0;
            #(BIT_PERIOD);
            // Data bits (LSB first)
            for (i =0; i <8; i = i +1) begin
                rx = data[i];
                #(BIT_PERIOD);
            end
            // Stop bit (high)
            rx =1;
            #(BIT_PERIOD);
        end
    endtask
    // ==========================================
    // 테스트 시나리오
    // ==========================================
    initial begin
        // 초기 상태
        rx =1;     // idle 상태는 high
        rst =1;
        // Reset 유지
        #1000;
        rst =0;
        $display("[%0t ns] Reset deasserted", $time);
        // 초기 안정화 시간
        #200_000; // 200 µs 대기 (tick_gen 안정화용)
        // UART 전송 테스트
        $display("[%0t ns] Sending UART bytes...", $time);
        send_uart_byte(8'h30);  // '0'
        send_uart_byte(8'h31);  // '1'
        send_uart_byte(8'h32);  // '2'
        send_uart_byte(8'h33);  // '3'
        send_uart_byte(8'h34);  // '4'
        // 충분한 대기
        #2_000_000; // 2 ms
        $display("[%0t ns] Simulation finished", $time);
        $finish;
    end
endmodule
