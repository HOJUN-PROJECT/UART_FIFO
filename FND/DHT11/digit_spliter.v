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

