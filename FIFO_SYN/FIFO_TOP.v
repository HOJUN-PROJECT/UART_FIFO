module FIFO(
    input clk, rst,
    input [7:0] push_data,
    input push,
    input pop,

    output [7:0]pop_data,
    output full,
    output empty
    );

    wire [1:0] w_wptr, w_rptr;

    regisetr_file U_reg_file(
        .clk(clk),
        .wr(~full & push),
        .push_data(push_data),
        .wptr(w_wptr),
        .rptr(w_rptr),
        .pop_data(pop_data)
    );

    fifo_cu U_CU(
        .clk(clk),
        .rst(rst),
        .wptr(w_wptr),
        .rptr(w_rptr),
        .push(push),
        .pop(pop),
        .full(full),
        .empty(empty)
    );


endmodule
