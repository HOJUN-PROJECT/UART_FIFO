module watch_cu (
    input  clk,
    input  rst,
    input  i_run_sec,
    input  i_run_min,
    input  i_run_hour,  
    output o_run_sec,
    output o_run_min,
    output o_run_hour
);

    // state define
    parameter IDLE = 2'b00, SEC_RUN = 2'b01, MIN_RUN = 2'b10, HOUR_RUN = 2'b11;
    reg [2:0] s, ns;
    reg run_sec_reg, run_sec_next;
    reg run_min_reg, run_min_next;
    reg run_hour_reg, run_hour_next;

    assign o_run_sec = run_sec_reg;
    assign o_run_min = run_min_reg;
    assign o_run_hour = run_hour_reg;

    // state register SL

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            s <= IDLE;
            run_sec_reg <= 1'b0;
            run_min_reg <= 1'b0;
            run_hour_reg <= 1'b0;
        end else begin
            s <= ns;
            run_sec_reg   <= run_sec_next;
            run_min_reg  <= run_min_next;
            run_hour_reg <= run_hour_next;
        end
    end

    // next combinational logic
    always @(*) begin
       
        ns    = s;
        run_sec_next  = 1'b0;
        run_min_next  = 1'b0;
        run_hour_next = 1'b0;

        case (s)
            IDLE: begin
                if (i_run_hour) ns = HOUR_RUN;
                else if (i_run_min) ns = MIN_RUN;
                else if (i_run_sec) ns = SEC_RUN;
            end

            SEC_RUN: begin
                run_sec_next = 1'b1;
             ns   = IDLE;
            end

            MIN_RUN: begin
                run_min_next = 1'b1;
             ns   = IDLE;
            end

            HOUR_RUN: begin
                run_hour_next = 1'b1;
             ns    = IDLE;
            end

            default: begin
             ns = IDLE;
            end
        endcase
    end

endmodule
