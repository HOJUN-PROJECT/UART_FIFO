`timescale 1ns / 1ps


interface UART_interface;
    logic clk;
    logic rst;
    logic tx;
    logic tx_busy;
    logic start;
    logic [7:0] tx_data;
    logic [7:0] exp_tx_data;
    logic b_tick;
endinterface

class transaction;
    rand bit [7:0] data;
    task display();
        $display("[TR] TX data = 0x%0h (%0b)", data, data);
    endtask
endclass

class generator;
    mailbox #(transaction) gen2drv;
    transaction tr;
    event gen_next_event;

    function new(mailbox#(transaction) gen2drv, event gen_next_event);
        this.gen2drv = gen2drv;
        this.gen_next_event = gen_next_event;
    endfunction

    task run(int n);
        repeat (n) begin
            tr = new();
            assert (tr.randomize());
            gen2drv.put(tr);
            $display("[GEN] Generated data = 0x%0h (%0b)", tr.data, tr.data);
            @(gen_next_event);
        end
    endtask
endclass

class driver;
    virtual UART_interface U_if;
    mailbox #(transaction) gen2drv;

    function new(virtual UART_interface U_if, mailbox#(transaction) gen2drv);
        this.U_if = U_if;
        this.gen2drv = gen2drv;
    endfunction

    task reset();
        U_if.rst   = 1;
        U_if.start = 0;
        repeat (5) @(posedge U_if.clk);
        U_if.rst = 0;
    endtask

    task run();
        reset();
        forever begin
            transaction tr;
            gen2drv.get(tr);
            U_if.tx_data     = tr.data;
            U_if.exp_tx_data = tr.data;
            @(posedge U_if.clk);
            U_if.start = 1;
            @(posedge U_if.clk);
            U_if.start = 0;

            $display("[DRV] TX Start: 0x%0h (%0b)", tr.data, tr.data);

        end
    endtask
endclass

class monitor;
    virtual UART_interface U_if;
    transaction tr;
    mailbox #(transaction) mon2scb;

    function new(virtual UART_interface U_if, mailbox#(transaction) mon2scb);
        this.U_if = U_if;
        this.mon2scb = mon2scb;
    endfunction

    task run();
        int i;
        forever begin
            tr = new();

              $write("[MON]");
            repeat (16)@(posedge U_if.b_tick); 
            for (i = 0; i < 8; i++) begin
                repeat (16)
                @(posedge U_if.b_tick); 
                tr.data[i] = U_if.tx;
                $write("tx[%0d] = %0b  | " , i, U_if.tx);  

            end
            repeat (16) @(posedge U_if.b_tick); 
            mon2scb.put(tr);
            $display("");
            $display("[MON] Captured TX data = 0x%0h (%0b)", tr.data, tr.data);
        end
    endtask

endclass

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

            if (tr.data == U_if.exp_tx_data) begin
                pass_count++;
                $display("[SCB] PASS!! tx_data= 0x%0h (%0b) exp= 0x%0h (%0b)",
                         tr.data, tr.data, U_if.exp_tx_data, U_if.exp_tx_data);
            end else begin
                fail_count++;
                $display("[SCB] FAIL!! tx_data= 0x%0h (%0b) exp= 0x%0h (%0b)",
                         tr.data, tr.data, U_if.exp_tx_data, U_if.exp_tx_data);
            end
            total_count++;
            @(negedge U_if.tx_busy);
            ->gen_next_event;

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
        scb.target_count = n;  
        fork
            gen.run(n);
            drv.run();
            mon.run();
            scb.run();
        join_none
    endtask

    task display();
        $display("-----------------------------");
        $display("----- total count = %0d -----", scb.total_count);
        $display("----- pass count  = %0d -----", scb.pass_count);
        $display("----- fail count  = %0d -----", scb.fail_count);
        $display("-----------------------------");
    endtask
endclass


module tb;

    UART_interface U_if ();
    environment e;

    UART_TOP dut (
        .clk(U_if.clk),
        .rst(U_if.rst),
        .tx_start(U_if.start),
        .tx_data(U_if.tx_data),
        .tx(U_if.tx),
        .tx_busy(U_if.tx_busy)
    );

    initial U_if.clk = 0;
    always #5 U_if.clk = ~U_if.clk;

    always @(*) U_if.b_tick = dut.U_BAUD_TICK.b_tick;

    initial begin
        e = new(U_if);
        e.run(2);
        #100000;
        $finish;
    end

endmodule
