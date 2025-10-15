module sr04_top (
    input        clk,       
    input        rst,      
    input        btn_start, 
    input        echo,     
    input   [1:0] en,
    output       trig,      
    output [3:0] fnd_com_sr04,   
    output [7:0] fnd_data_sr04    
);
    wire       tick_1us;
    wire [13:0] distance;  // 9비트 거리
    wire       btn;  
    SR04_tick_gen_1us tick_gen_inst_SR04 (
        .clk(clk),
        .rst(rst), 
        .o_tick_1us(tick_1us)
    );
    
    btn_debounce U_SR04_B_L (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btn_start),
        .o_btn(btn)
    );
    
    sr04_controller_fsm sr04_ctrl_inst (
        .clk(clk),
        .rst(rst),
        .start(btn),
        .echo(echo),
        .i_tick(tick_1us),
        .o_trig(trig),
        .o_dist(distance),
        .en(en)
    );
    
        SR04_fnd_controller fc_inst_SR04 (
        .clk(clk),
        .reset(rst),
        .counter(distance),  
        .fnd_com(fnd_com_sr04),
        .fnd_data(fnd_data_sr04)
    );
endmodule
