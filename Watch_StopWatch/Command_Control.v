
module com_ctl(
    input        clk,
    input        rst,
    input  [7:0] rx_data,   
    input        rx_trigger,   

    output       r, l, u, d,   
    output     watch , 
    output      hour_min
);

    reg r_reg, l_reg, u_reg, d_reg;
    reg r_next, l_next, u_next, d_next;

    reg stopwatch_reg, stopwatch_next;  
    reg hour_min_reg, hour_min_next;

    assign r = r_reg;
    assign l = l_reg;
    assign u = u_reg;
    assign d = d_reg;
    assign watch = stopwatch_reg;
    assign hour_min = hour_min_reg;

    reg rx_trigger_d;
    always @(posedge clk or posedge rst) begin
        if (rst)
            rx_trigger_d <= 1'b0;
        else
            rx_trigger_d <= rx_trigger;
    end
    wire rx_trigger_edge = rx_trigger & ~rx_trigger_d;  


    always @(posedge clk or posedge rst) begin
        if (rst) begin
            r_reg         <= 1'b0;
            l_reg         <= 1'b0;
            u_reg         <= 1'b0;
            d_reg         <= 1'b0;
            stopwatch_reg <= 1'b0;  
            hour_min_reg <= 1'b0;
        end
        else begin
            r_reg         <= r_next;
            l_reg         <= l_next;
            u_reg         <= u_next;
            d_reg         <= d_next;
            stopwatch_reg <= stopwatch_next;
            hour_min_reg <= hour_min_next;
        end
    end

    always @(*) begin
        r_next = 1'b0;
        l_next = 1'b0;
        u_next = 1'b0;
        d_next = 1'b0;
        stopwatch_next = stopwatch_reg; 
        hour_min_next = hour_min_reg;

        if (rx_trigger_edge) begin
            case (rx_data)
                8'h72: r_next = 1'b1;  
                8'h6C: l_next = 1'b1;  
                8'h75: u_next = 1'b1;   
                8'h64: d_next = 1'b1;   
                8'h30: stopwatch_next = ~stopwatch_reg; 
                8'h31: hour_min_next = ~hour_min_reg;
            endcase
        end
        else begin
            r_next = 1'b0;
            l_next = 1'b0;
            u_next = 1'b0;
            d_next = 1'b0;
        end
    end
    

endmodule
