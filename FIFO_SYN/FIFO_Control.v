module fifo_cu(
    input clk, rst,
    input push, pop, 

    output [1:0] wptr, rptr,
    output full, empty
);

    reg [1:0] wptr_reg , wptr_next;
    reg [1:0] rptr_reg , rptr_next;
    reg full_reg, full_next;
    reg empty_reg, empty_next;

    assign rptr = rptr_reg;
    assign wptr = wptr_reg;
    assign full = full_reg;
    assign empty = empty_reg;

    always@(posedge clk, posedge rst)begin
        if(rst)begin
            wptr_reg <= 0;
            rptr_reg <= 0;
            full_reg <= 0;
            empty_reg <= 1;
        end else begin
            wptr_reg <= wptr_next;
            rptr_reg <= rptr_next;
            full_reg <= full_next;
            empty_reg <= empty_next;
        end
    end


    always@(*)begin
        wptr_next = wptr_reg;
        rptr_next = rptr_reg;
        full_next = full_reg;
        empty_next = empty_reg;
        case ({push, pop}) 
            
            2'b01 : begin
                full_next = 1'b0;
                if(!empty_reg)begin
                    rptr_next = rptr_reg + 1;
                    if(wptr_reg == rptr_next)begin
                        empty_next = 1'b1;
                    end
                end
            end

            2'b10 : begin
                empty_next = 1'b0;
                if(!full_reg)begin
                    wptr_next = wptr_reg + 1;
                    if(wptr_next == rptr_reg)begin
                        full_next = 1'b1;
                    end
                end
            end

            2'b11 : begin
                if(empty_reg)begin
                    wptr_next = wptr_reg + 1;
                    empty_next = 1'b0;
                end else if(full_reg) begin
                    rptr_next = rptr_reg + 1;
                    full_next = 1'b0;
                end else begin
                    wptr_next = wptr_reg + 1;
                    rptr_next = rptr_reg + 1;
                end
            end
        endcase
    
    
    end
endmodule
