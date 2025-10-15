module bcd_decorder_humid (
    input  [3:0] bcd,
    output reg [7:0] fnd
);
    always @(*) begin
        case (bcd)
            4'b0000: fnd = 8'hC0; // 0
            4'b0001: fnd = 8'hF9; // 1
            4'b0010: fnd = 8'hA4; // 2
            4'b0011: fnd = 8'hB0; // 3
            4'b0100: fnd = 8'h99; // 4
            4'b0101: fnd = 8'h92; // 5
            4'b0110: fnd = 8'h82; // 6
            4'b0111: fnd = 8'hF8; // 7
            4'b1000: fnd = 8'h80; // 8
            4'b1001: fnd = 8'h90; // 9
            4'b1010: fnd = 8'h88; // A
            4'b1011: fnd = 8'h83; // b
            4'b1100: fnd = 8'hC6; // C
            4'b1101: fnd = 8'hA1; // d
            4'b1110: fnd = 8'h86; // E
            4'b1111: fnd = 8'h8E; // F
            default: fnd = 8'hFF; // OFF
        endcase
    end
endmodule
