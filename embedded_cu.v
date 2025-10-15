module embedded_cu(
    input        clk,
    input        rst,
    input  [15:13] sw,   
    output reg [1:0] en  
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            en <= 2'd0;
        end else begin
            case (sw[15:13])
                3'b001: en <= 2'b01;  // sw[13] �� stopwatch/watch
                3'b010: en <= 2'b10;  // sw[14] �� SR04
                3'b100: en <= 2'b11;  // sw[15] �� DHT11
                default: en <= 2'd0; // �ƹ� �͵� �� ����
            endcase
        end
    end

endmodule
