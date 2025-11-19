interface UART_interface;
    logic clk;
    logic rst;
    logic rx;
    logic b_tick;
    logic rx_done;
    logic [7:0] rx_data;
    logic [7:0] exp_rx_data;
endinterface


//=============================================
// Transaction Class
//=============================================
class transaction;
    rand bit [7:0] data;

    task display(bit [7:0] rx_value, bit [7:0] exp_value);
        $display("rx = %0d exp = %0d", rx_value, exp_value);
    endtask
endclass


//=============================================
// Generator Class
//=============================================
class generator;
    mailbox #(transaction) gen2drv;
    transaction tr;
    event gen_next_event;

    function new(mailbox#(transaction) gen2drv, event gen_next_event);
        this.gen2drv = gen2drv;
        this.gen_next_event = gen_next_event;
    endfunction

    // 실행 시 랜덤 데이터를 생성
    task run(int n);
        repeat (n) begin
            tr = new();
            assert (tr.randomize());
            gen2drv.put(tr);
            $display("[GEN] random = %0d", tr.data);
            @(gen_next_event);  // scoreboard에서 트리거
        end
    endtask
endclass


//=============================================
// Driver Class
//=============================================
class driver;
    virtual UART_interface U_if;
    mailbox #(transaction) gen2drv;

    function new(virtual UART_interface U_if, mailbox#(transaction) gen2drv);
        this.U_if = U_if;
        this.gen2drv = gen2drv;
    endfunction

    task reset();
        U_if.rst = 1;
        U_if.rx  = 1;
        repeat (5) @(posedge U_if.clk);
        U_if.rst = 0;
    endtask

    task send_uart_data_rx(input [7:0] data);
        int i;
        U_if.rx = 0;
        repeat (23) @(posedge U_if.b_tick);

        $write("[DRV]");
        for (i = 0; i < 8; i++) begin
            U_if.rx = data[i];
            $write("rx[%0d]=%0d ", i,
                   U_if.rx);
            repeat (16) @(posedge U_if.b_tick);
        end

        $display("");
        repeat (16) @(posedge U_if.b_tick);
        U_if.rx = 1;
    endtask



    task run();
        reset();
        forever begin
            transaction tr;
            gen2drv.get(tr);
            U_if.exp_rx_data = tr.data;
            send_uart_data_rx(tr.data);
            $display("[DRV] rx_data = %0d(%0b)", U_if.exp_rx_data, U_if.exp_rx_data);
        end
    endtask
endclass


//=============================================
// Monitor Class
//=============================================
class monitor;
    virtual UART_interface U_if;
    transaction tr;
    mailbox #(transaction) mon2scb;

    function new(virtual UART_interface U_if, mailbox#(transaction) mon2scb);
        this.U_if = U_if;
        this.mon2scb = mon2scb;
    endfunction

    task run();
        forever begin
            @(posedge U_if.rx_done);
            tr = new();
            tr.data = U_if.rx_data;
            mon2scb.put(tr);
            $display("[MON] rx_data = %0d", tr.data);
        end
    endtask
endclass


//=============================================
// Scoreboard Class
//=============================================
//=============================================
// Scoreboard Class
//=============================================
class scoreboard;
    mailbox #(transaction) mon2scb;
    virtual UART_interface U_if;
    transaction tr;
    event gen_next_event;

    int pass_count = 0;
    int fail_count = 0;
    int total_count = 0;
    int target_count = 0;  // ★ 목표 트랜잭션 수

    function new(mailbox#(transaction) mon2scb, virtual UART_interface U_if,
                 event gen_next_event);
        this.mon2scb = mon2scb;
        this.U_if = U_if;
        this.gen_next_event = gen_next_event;
    endfunction

    task run();
        forever begin
            mon2scb.get(tr);

            if (U_if.rx_data == U_if.exp_rx_data) begin
                pass_count++;
                $display("[SCB] PASS!! rx_data=%0d exp=%0d", U_if.rx_data,
                         U_if.exp_rx_data);
            end else begin
                fail_count++;
                $display("[SCB] FAIL!! rx_data=%0d exp=%0d", U_if.rx_data,
                         U_if.exp_rx_data);
            end

            total_count++;
            ->gen_next_event;

            // ★ 모든 트랜잭션 완료 시 자동 출력 및 종료
            if (total_count == target_count) begin
                display();
                $finish;
            end
        end
    endtask

    task display();
        $display("-----------------------------");
        $display("----- total count = %0d -----", total_count);
        $display("----- pass count  = %0d -----", pass_count);
        $display("----- fail count  = %0d -----", fail_count);
        $display("-----------------------------");
    endtask
endclass




//=============================================
// Environment Class
//=============================================
class environment;
    generator gen;
    driver drv;
    monitor mon;
    scoreboard scb;

    mailbox #(transaction) gen2drv, mon2scb;
    event gen_next_event;

    virtual UART_interface U_if;

    function new(virtual UART_interface U_if);
        this.U_if = U_if;
        gen2drv = new();
        mon2scb = new();

        gen = new(gen2drv, gen_next_event);
        drv = new(U_if, gen2drv);
        mon = new(U_if, mon2scb);
        scb = new(mon2scb, U_if, gen_next_event);
    endfunction

    task run(int n);
        scb.target_count = n;  // ★ 목표 트랜잭션 수 전달
        fork
            gen.run(n);
            drv.run();
            mon.run();
            scb.run();
        join_none
    endtask


    task display();
        $display("-----------------------------");
        $display("-----total count == %0d------", scb.total_count);
        $display("-----fail count == %0d------", scb.fail_count);
        $display("-----pass count == %0d------", scb.pass_count);
        $display("---------------------------");
    endtask

endclass


//=============================================
// Top-level Testbench
//=============================================
module tb_RX_VERIFICATION ();

    environment e;
    UART_interface U_if ();

    // DUT 인스턴스
    UART_TOP U_dut (
        .clk(U_if.clk),
        .rst(U_if.rst),
        .rx(U_if.rx),
        .rx_done(U_if.rx_done),
        .rx_data(U_if.rx_data),
        .b_tick(U_if.b_tick)
    );

    // Clock generation
    initial U_if.clk = 0;
    always #5 U_if.clk = ~U_if.clk;

    always @(*) U_if.b_tick = U_dut.U_BAUD_TICK.b_tick;


    // 시뮬레이션 시작
    initial begin
        e = new(U_if);
        e.run(600);
        #1000;
        $finish;
    end

endmodule
