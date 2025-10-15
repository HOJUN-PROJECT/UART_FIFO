module bnt_pri(
    input  Btn_R, Btn_L, Btn_U, Btn_D,   
    input  r, l, u, d,                   
    input  [1:0]en,                        
    output final_R, final_L, final_U, final_D
);

    wire any_btn; 

    assign any_btn = Btn_R | Btn_L | Btn_U | Btn_D;

    assign final_R = en ? (any_btn ? Btn_R : r) : 1'b0;
    assign final_L = en ? (any_btn ? Btn_L : l) : 1'b0;
    assign final_U = en ? (any_btn ? Btn_U : u) : 1'b0;
    assign final_D = en ? (any_btn ? Btn_D : d) : 1'b0;

endmodule
