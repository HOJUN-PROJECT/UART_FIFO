
module regisetr_file(
    input clk, 
    input wr,
    input [7:0] push_data,
    input [1:0]wptr,
    input [1:0]rptr,

    output [7:0] pop_data
);

    reg [7:0] ram [0:3];

    assign pop_data = ram[rptr];

    always @(posedge clk) begin
        if(wr)begin
            ram[wptr] <= push_data;
        end
    end

endmodule
