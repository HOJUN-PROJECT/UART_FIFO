module UART_TOP (
    input  clk,        // 100 MHz
    input  rst,
    input  rx,
    output tx,
    output uart_start
);
    wire b_tick, rx_done, tx_busy, w_full, w_tx_fifo_empty, w_rx_empty;
    wire [7:0] w_rx_data, w_tx_fifo_popdata, w_rx_fifo_popdata;
    //---------------------------------------------
    // UART RX
    //---------------------------------------------
    uart_rx U_UART_RX (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .b_tick(b_tick),
        .rx_data(w_rx_data),
        .rx_done(rx_done)
    );
    //---------------------------------------------
    // RX FIFO
    //---------------------------------------------
    top_fifo_connect U_FIFO_RX (
        .clk(clk),
        .rst(rst),
        .push_data(w_rx_data),
        .push(rx_done),
        .pop(~w_full),                // if TX FIFO not full, move data
        .pop_data(w_rx_fifo_popdata),
        .full(),
        .empty(w_rx_empty)
    );
    //---------------------------------------------
    // TX FIFO
    //---------------------------------------------
    top_fifo_connect U_FIFO_TX (
        .clk(clk),
        .rst(rst),
        .push_data(w_rx_fifo_popdata),
        .push(~w_rx_empty),
        .pop(~tx_busy),
        .pop_data(w_tx_fifo_popdata),
        .full(w_full),
        .empty(w_tx_fifo_empty)
    );
    //---------------------------------------------
    // UART TX
    //---------------------------------------------
    uart_tx U_UART_TX (
        .clk(clk),
        .rst(rst),
        .start_trigger(~w_tx_fifo_empty),
        .tx_data(w_tx_fifo_popdata),
        .b_tick(b_tick),
        .tx(tx),
        .tx_busy(tx_busy)
    );
    //---------------------------------------------
    // Command Control Unit
    //---------------------------------------------
    command_cu U_COMMAND_CU (
        .clk(clk),
        .rst(rst),
        .command(w_rx_fifo_popdata),
        .rx_trigger(~w_rx_empty),
        .uart_start(uart_start)
    );
    //---------------------------------------------
    // Baud Tick Generator (9600bps @ 100MHz)
    //---------------------------------------------
    tick_gen U_BAUD_TICK (
        .clk(clk),
        .rst(rst),
        .b_tick(b_tick)
    );
endmodule
