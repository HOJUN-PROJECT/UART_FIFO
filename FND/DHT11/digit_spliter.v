module digit_splitter_humtemp (
    input  [7:0] humid, 
    input  [7:0] temp,  
    output [3:0] hu1,
    output [3:0] hu10,
    output [3:0] te1,
    output [3:0] te10
);
    assign hu1  = humid % 10;
    assign hu10 = (humid / 10) % 10;

    assign te1  = temp % 10;
    assign te10 = (temp / 10) % 10;
endmodule

module mux_4x1_humtemp (
    input  [3:0] hu1, hu10, te1, te10,
    input  [1:0] sel,
    output [3:0] bcd
);
    reg [3:0] r_bcd;
    assign bcd = r_bcd;

    always @(*) begin
        case (sel)
            2'b00: r_bcd = te1;   
            2'b01: r_bcd = te10; 
            2'b10: r_bcd = hu1;  
            2'b11: r_bcd = hu10; 
            default: r_bcd = 4'd0;
        endcase
    end
endmodule
