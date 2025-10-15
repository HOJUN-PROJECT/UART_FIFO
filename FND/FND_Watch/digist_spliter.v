module digit_splitter #(
    parameter BIT_WIDTH = 7
) (
    input [BIT_WIDTH-1:0] count_data,
    output [3:0] digit_1,
    output [3:0] digit_10
);
    assign digit_1  = count_data % 10;
    assign digit_10 = (count_data / 10) % 10;

endmodule
